# Appendix II. Tooling and preliminary experience report {- #appendix-tooling}

## II.1 Variant of proposal implemented in the Dart Analyzer {#proposal-variant}

We describe here a _version_ of this proposal as implemented in the [Dart Analyzer][]. It is "a version" in that we have adopted all core ideas ([8.1](#lang-changes)) but we have made a particular choice of alternatives ([8.3](#alternatives)). Choices have been driven by the need to create a solution that is **fully backwards compatible**, as will be explained below.

Core language design decisions (cf. [8.1](#lang-changes)) and main alternatives:

- [A.2](#non-null-types). Drop semantic rules giving special treatment to `null`.
- [B.2](#nnbd). Ensure `Object` is non-null by making `Null` a root ([B.4.7](#object-not-nullable-alt)).
- [B.2](#nnbd). Support meta type annotations
    - `@nullable` and `@non_null` ([B.4.6](#type-anno-alt)), and in those places where [DartC][] does not currently support metadata, 
    - allow the use of specialized comments `/*?*/` and `/*!*/`.
- [C.3](#generics). Support for generics matches the proposal.
- [G.2](#g-2-migration-aids). Support `library`, `part` and `class` level `@nullable_by_default` annotations.

By our choice of input syntax, [DartNNBD][] annotated code can be **analyzed and executed in DartC** without any impact on DartC tooling.

## II.2 Dart Analyzer

We describe here a realization of this proposal in the [Dart Analyzer][].

### II.2.1 Design outline

The dart analyzer processes compilation units within a collection of libraries. The processing of each library is done in multiple phases on the Abstract Syntax Tree (AST) provided by the parser. 

#### (a) AST

No structural changes have been done to the AST types since nullity annotations are represented by metadata and comments. Also, `NullityElement`s, described next, are attached to `TypeName`s via the generic AST property mechanism (a hash map associated with any AST node).

#### (b) Element model

- We introduce two `DartType` subtypes, one for each of `?` and `!` meta type annotations, named `UnionWithNullType` and `NonNullType`, respectively. These represent normalized types ([E.1.2](#normalization)).
- The model `Element` representing a `UnionWithNullType` is `UnionWithNullElement`. Its is a representation of a  (synthetic) `ClassElement`-like entity that can be queried for members via methods like `lookUpMethod(methodName)`, etc. When queried for a member with a given name *n*, a (synthetic) multi-member is returned which represents the collection of members matching declarations of *n* in `Null` and/or the other type argument of `UnionWithNullType`.
- The dual-view for optional function parameters ([E.1.1](#opt-func-param)) is realized by associating to each optional parameter (`DefaultParameterElementImpl`) a synthetic counterpart (`DefaultParameterElementWithCalleeViewImpl`) representing the declared parameter from the function-body/callee view ([E.1.1(a)](#opt-func-param)). All identifier occurrences within the function body scope have the callee-view parameter instance as an associated static element.

#### (c) Resolution

We describe here the _added_ / _adapted_ analyzer processing (sub-)phases:

1. Nullity annotation processing:

    (a) Nullity annotation resolution (earlier than would normally be done since nullity annotations impact _types_ in [DartNNBD][]). Note that we currently match annotation names only, regardless of library of origin so as to facilitate experimentation.
    (b) `NullityElement`s (see (b) below) are computed in a top-down manner, and attached to the AST nodes that they decorate (e.g., `TypeName`, `LibraryDirective`, etc.). The final nullity of a type name depends on: global defaults (whether [NNBD][] is enabled or not), `@nullable_by_default` nullity scope annotations, and individual declarator annotations.

2. Element resolution (via `ElementResolver` and `TypeResolverVisitor`) is enhanced to:

    (a) Adjust the static type associated with a, e.g., a `TypeName` based on its nullities.
    (b) Associate a callee view to each default parameter element and suitably adjust its type.
    (c) Handle problem reporting for operator and method (including getter and setter) invocation over nullable targets.

3. Error verification has been adapted to, e.g., check for invalid implicit initialization of variables with `null`. See [B.3.4](#var-init) for details.

The [NNBD][] analyzer also builds upon existing [DartC][] flow analysis and type propagation facilities.

> Caveat excerpt from a code comment: TODO(scheglov) type propagation for instance/top-level fields was disabled because it depends on the order or visiting. If both field and its client are in the same unit, and we visit the client before the field, then propagated type is not set yet.

### II.2.2 Source code and change footprint {#analyzer-code-changes}

The [NNBD][]-enabled analyzer sources are in the author's GitHub Dart SDK fork @[chalin/sdk, dep30 branch][], under `pkg/analyzer`. This SDK fork also contains updates to the SDK library and sample projects which have been subject to nullity analysis (as documented in [II.3](#experience-report)). Note that

- All code changes are marked with comments containing the token `DEP30` to facilitate identification (and merging of upstream changes from @[dart-lang/sdk][Dart SDK project]).
- Most significant code changes are marked with appropriate references to sections of this proposal for easier feature implementation tracking.

As of the time of writing, the [Dart Analyzer][] code change footprint (presented as a git diff summary) is:

```
Showing  8 changed files  with 245 additions and 35 deletions.
+3   −2   pkg/analyzer/lib/src/generated/ast.dart
+5   −3   pkg/analyzer/lib/src/generated/constant.dart
+40  −5   pkg/analyzer/lib/src/generated/element.dart
+53  −9   pkg/analyzer/lib/src/generated/element_resolver.dart
+16  −0   pkg/analyzer/lib/src/generated/engine.dart
+10  −0   pkg/analyzer/lib/src/generated/error.dart
+20  −7   pkg/analyzer/lib/src/generated/error_verifier.dart
+94  −8   pkg/analyzer/lib/src/generated/resolver.dart
+4   −1   pkg/analyzer/lib/src/generated/static_type_analyzer.dart
```

There is approximately 1K [Source Lines Of Code (SLOC)][sloccount] of new code (or 3K LOC including comments and whitespace).

### II.2.3 Status {#analyzer-status}

Please see the GitHub [DEP #30 Analyzer project page][].

## II.3 Preliminary experience report {#experience-report}

We stress from the outset that this is a **preliminary** report.

Our initial objective has been to test run the new analyzer on sample projects. Our first target has been the SDK library Dart sources. We have also used some sample projects found in the Dart SDK `pkg` directory. So far, results are encouraging in that the nullable annotation burden seems to be low as we quantify in detail below.

### II.3.1 Nullity annotation density

[Dietl, 2014][], reports 20 nullity annotations / KLOC (anno/KLOC). So far, nullable annotation density for the SDK sources have been:

- <1 anno/KLOC for the library core (with <2 line/KLOC of general changes related to nullity);
- 1 anno/KLOC for the samples.

We attribute such a low annotation count to Dart's relaxed definition of assignability (see [A.1.4][assignment compatible] and [B.3.5](#new-assignment-semantics)), and a judicious choice in the scope of [NNBD][] ([E.3.1](#nnbd-scope)), in particular for optional parameters---namely our dual-view approach and use of compile-time default values to influence the nullability ([E.1.1](#opt-func-param)).

We are not claiming that such a low annotation count will be typical (it certainly is not the case for the analyzer code itself, in part due to most AST fields being nullable), but results are encouraging.

### II.3.2 Dart SDK library

Our strategy has been to run the [NNBD][] analyzer over the SDK library and address any reported issues. In addition, we added the nullable annotations mentioned in [Part F](#part-libs). Here is a summary, to date, of the changes.

- `sdk/lib/core/core.dart` updated to include the definition of nullity annotations `@nullable`, `@non_null`, etc. (19 lines).

- Nullable annotations were added in 70 locations. Most (64) were occurrences of `Object`.

- The remaining updates (10 lines) were necessary to overcome the limitations in the analyzer's flow analysis capabilities. For example, when an optional nullable parameter is initialized to a non-null value when it is null at the point of call. This is a typical code change of this nature:

    ```
    *** 280,287 ****
        static void checkValidIndex(int index, var indexable,
    !                               [String name, int length, String message]) {
    !     if (length == null) length = indexable.length;
          // Comparing with `0` as receiver produces better dart2js type inference.
    --- 280,287 ----
         * otherwise the length is found as `indexable.length`.
         */
        static void checkValidIndex(int index, var indexable,
    !                               [String name, int _length, String message]) { //DEP30: renamed to _length
    !     int length = _length == null ? indexable.length : _length;              //DEP30: assign non-const default value
          // Comparing with `0` as receiver produces better dart2js type inference.
          if (0 > index || index >= length) {
            if (name == null) name = "index";
    ```

- There remain two false positives related to limitations in the analyzer's flow analysis.

### II.3.3 Sample projects

As a sanity test we have run the [NNBD][] analyzer on itself. As expected, a large number of problems are reported, due the nullable nature of AST class type fields. We have chosen not to tackle the annotation of the full analyzer code itself at the moment. On the other hand, we have annotated the nullity specific code, for which we have a nullity annotation ratio is 10 anno/KLOC.

As for other projects, to date, we have run the [NNBD][] analyzer over the following SDK `pkg` projects totaling 2K LOC:

- `expect`
- `fixnum`

Each projects required only a single nullity annotation. The remaining changes to `expect` were to remove redundant (in [DartC][]) explicit initialization of the optional `String reason` parameter with `null` (16 lines).
