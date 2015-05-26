# Non-null Types and Non-null By Default (NNBD) {- #part-main}

## Contact information {-}

- [Patrice Chalin][], @[chalin][], [chalin@dsrg.org](mailto:chalin@dsrg.org)
- **[DEP][] home**: [github.com/chalin/DEP-non-null][DEP-non-null].
- **Additional stakeholders**:
    + Leaf Petersen, @[leafpetersen](https://github.com/leafpetersen), [Dart Dev Compiler][] team.

## 1 Introduction

In this [DEP][] we propose [4 _core_ updates and additions](#lang-changes) to the language allowing us to [naturally recover](#part-non-null-types) a [**non-null-by-default** (NNBD)](#part-nnbd) interpretation of Dart _class types_. That is, _generally speaking_, an unadorned class type *T* will represent the *non-null* type consisting (strictly) of instances of *T*. When needed, the _meta type annotation_ `?` can be used; ?*T* denotes the *nullable* type derived from *T*, consisting of values from *T* or `null`.

Careful consideration has been given to [language design goals (Section 5)](#goals) during the writing of this proposal. For example, this proposal fully preserves the optional nature of static type annotations.

The scope of this proposal [includes](#proposal-details):
generics ([Part C](#part-generics));
dealing with `dynamic` and missing static type annotations ([Part D](#part-dynamic));
miscellaneous features including syntactic sugar ([Part E](#part-misc));
preliminary impact on the Dart SDK libraries ([Part F](#part-libs)), and finally
a migration strategy ([Part G](#part-migration)).

TL;DR: the [_executive summary_ of updates and additions (Section 8.1)](#lang-changes) fits in 3/4 of a page.

## 2 Motivation

### 2.1 Dart: improving compilation to JavaScript

Being able to **compile Dart into compact and efficient JavaScript** ([JS][]) is paramount, possibly even more so given the Dart news _[Dart for the Entire Web][]_, March 25, 2015 (emphasis mine):

> In order to do what's best for our users and the web, and not just Google Chrome, we will **focus our web efforts on compiling Dart to JavaScript**. We have decided **not to integrate the Dart VM into Chrome**.

[NNBD][] allows compilers and VMs to perform important optimizations. For example, under the current *nullable-by-default* semantics, the [Dart Dev Compiler][] (DDC) translates this Dart fragment:

```dart
return (a + b) * a * b;  // a and b are declared as int
```
into this [JS][]:

```javascript
return dart.notNull(dart.notNull((dart.notNull(a) + dart.notNull(b)))
     * dart.notNull(a)) * dart.notNull(b);
```

as is pointed out in [DDC issue #64][]. Under [NNBD][], the `dart.notNull()` wrappers become unnecessary, so that the Dart and corresponding [JS][] would be identical. (We ignore here the issue of finite vs. arbitrary precision numerics, as it is both orthogonal to, and outside the scope of this proposal.)

Interest in non-null types for Dart and related projects has been manifested in:

- [Dart issue #22][], starred by 197 individuals, is a request for *support for non-nullable types*.
- Bob Nystrom's 2011 strawman _[proposal for Null-safety in Dart][Nystrom, 2011]_ suggested the use of non-null types and [NNBD][]. Unfortunately, at the time, the language committee was busy with other issues that took precedence.
- [Chrome V8][] team is giving thought to [NNBD][] for [JS][]; see [Experiments with Strengthening JavaScript][], especially p. 39 (the second to last page) of [JSExperimentalDirections][].
- Finally, non-null types are on [Lasse R.H. Nielsen's 2014 wish list][dart-misc-1], and so far, almost half of his wishes have either come true or are the subject of a [DEP][] ;).

 [dart-misc-1]: https://groups.google.com/a/dartlang.org/d/msg/misc/8Uchi3bW1YQ/WnVkaDDmvzUJ

### 2.2 Precedent: modern web/mobile languages with non-null types and [NNBD][] {#precedent}

Programming languages, many recently released, that are relevant to web applications (either dialects of [JS][] or that compile to [JS][]) and/or mobile, and that support _non-null types_ and [NNBD][] include:

|      Language        |                 About              | v1.0?  | Nullable via  | Reference
| -------------------- | ---------------------------------- | ------ | ------------- | ---------
|[Ceylon][] (Red Hat)|Compiles to [JS][], [Java Bytecode][JB] (**JB**)|2013Q4| *T*?  | [Ceylon optional types][]
| [Fantom][]         | Compiles to [JS][], [JB][], .Net CLR | 2005   | *T*?          | [Fantom nullable types][]
| [Flow][] (Facebook)  | [JS][] superset and static checker | 2014Q4 | *T*?          | [Flow maybe types][]
| [Kotlin][] (JetBrains)| Compiles to [JS][] and [JB][]     | 2011Q3 | *T*?          | [Kotlin null safety][]
| [Haste][]            | [Haskell][] to [JS][] compiler     | @0.4.4 |[option type][]| [Haskell maybe type][]
| [Swift][] (Apple)    | iOS/OS X Objective-C successor     | 2014Q4 |[option type][]| [Swift optional type][]

(Note: 2014Q4, for example, refers to the 4th quarter of 2014). There is even discussion of introducing non-null types to [TypeScript][], the Dart peer that brings optional types and static type checking to JavaScript:

- [TS issue #185][], *Suggestion: non-nullable type*.
- [TS issue #1265][], *Comparison with Facebook Flow Type System*.
- [TS issue #3003][], *Compile / edit time pluggable analyzers like C#* as a possible mechanism for introducing support for nullity checks.

## 3 Normative reference, terms and notation {#terms}

The main normative reference for this proposal is the *ECMA [Dart Specification Standard][DSS]*, 2nd Edition (December 2014, Dart v1.6) which we abbreviate as [DSS][]. When proposing changes to the [DSS][], text that is removed will be [marked like this][del] and, new or updated text will be [marked like this][ins].

Throughout this proposal, qualified section numbers, sometimes in parentheses, e.g. ([DSS][] 16.19), will refer to the corresponding section of the named resource.

We will refer to current Dart, with nullable-by-default semantics, as *classic Dart* (<a name="def-dartc">**DartC**</a>) and we will use <a name="def-dartnnbd">**DartNNBD**</a> to denote Dart as adapted to conform to this proposal. In cases where it is pertinent, we will mark code samples as being [DartC][] or [DartNNBD][] code.

\label{terms}<a name="terms"></a>
We adhere to the following terminology ([DSS][] 7, "Errors and Warnings") a: _[static warning](#terms)_ is a problem reported by the static checker; _[dynamic type error](#terms)_ is a type error reported in checked mode; _[run-time error](#terms)_ is an exception raised during execution.

## 4 Impact, examples and benefits: a first look {#first-look}

Among other important language design goals ([5](#goals)), this proposal has been designed so as to _minimize_ the effort involved in migrating existing code, so that [DartC][] code will require _no_ or _few textual changes_ to run with the _same behavior_ in [DartNNBD][].

Consider the following program, slightly adapted from an article on Dart types ([Bracha, 2012][Dart Optional Types]):

```dart
class Point {
  final num x, y;
  Point(this.x, this.y);
  Point operator +(Point other) => new Point(x+other.x, y+other.y);
  String toString() => "x: $x, y: $y";
}

void main() {
  Point p1 = new Point(0, 0);
  Point p2 = new Point(10, 10);
  print("p1 + p2 = ${p1 + p2}");
}
```

This code has the same behavior in [DartC][] as in [DartNNBD][]. But, in [DartNNBD][], an expression like `new Point(0, `_some nullable expression_`)` would cause a [static warning][] to be issued and a [dynamic type error][] to be raised, whereas no problems would be reported in [DartC][].

**Dart SDK libraries**. What would be the impact on the Dart SDK libraries? The **`int`** API would look textually the same in [DartNNBD][] except for the addition of 3 instances of the `?` meta type annotation, out of 44 possible places where such an addition could be made ([F.1.1](#int-nnbd)). The **`Iterable<E>`** interface would be unchanged ([F.1.2](#iterable-nnbd)).

The **benefits** of this proposal include:

- An increased *potential* for the static detection of unanticipated use of `null`.
- A base semantics which enables compilers (and VMs) to be much more effective at generating efficient code (e.g., code with fewer runtime checks).
- Annotated code contributes to improving API documentation.

## 5 Language design goals {#goals}

Language design is a process of *balancing tensions* among goals under given constraints. It is difficult to assess a language, or a language proposal, when its design principles and goals are not clearly identified. In this section, we present some of the broad language design goals for this proposal. Other goals will be presented, as relevant, in their respective parts.

The group of goals presented next will be collectively referred to as **G0**; subgoals will be referred to by name, such as [G0, compatibility](#g0).

\label{g0}<a name="g0"></a>

- **Goal G0, optional types**. Specifically these two aspects, which follow from the fundamental property of Dart that _static type annotations are_ **optional** (see "Overview", [Bracha, 2012][Dart Optional Types, overview]):

    (a) Static type annotations, whether they include nullity meta type annotations or not, shall have _no impact on_ **production mode execution**.

    (b) Static type checking rules shall never prevent code from executing, and hence never coerce a developer into _adding or changing_ static (nullity) type annotations.

    > Comment. This is why problems reported by the static checker are warnings and not errors. The basic premise is that "the developer knows best" since he or she can see beyond the inherent limitations of the static type system.

- _Maximize_ each of the following properties:

    - **Goal G0, utility** (of which more is said in the paragraph below).
    - **Goal G0, [usability][]**: the ease with which [DartNNBD][] can be learned and used.
    - **Goal G0, compatibility** with [DartC][]; i.e., mainly _backwards compatibility_,
      though the intent is also to be respectful of Dart's language design philosophy.

- **Goal G0, ease migration**. _Minimize_ the effort associated with the: (a) [migration](#part-migration) of [DartC][] code to [DartNNBD][]; (b) reengineering of tooling.

\label{g0-utility}<a name="g0-utility"></a>
The main purpose of this proposal (**[G0, utility](#g0)**) is to enable static and dynamic checks to report situations where a possibly null expression is being used but a non-null value is expected. Even in the presence of non-null types, developers could choose to declare all types as nullable (and hence be back in the realm of [DartC][]). Consequently, to the extent possible, in this proposal we will give preference to new language features that will interpret unadorned types as being non-null _by default_.

## 6 Proposal details

For ease of comprehension, this proposal has been divided into parts. Each part treats a self-contained topic and generally builds upon its predecessor parts, if any. Most parts start with a brief introduction or motivation, followed by proposed feature details, then ending with a discussion and/or presentation of alternatives.

- [A. Recovering non-null types](#part-non-null-types).
- [B. Non-null by default](#part-nnbd)---also introduces the type operators `?` and `!`.
- [C. Generics](#part-generics).
- [D. Dealing with `dynamic` and missing static type annotations](#part-dynamic).
- [E. Miscellaneous, syntactic sugar and other conveniences](#part-misc).
- [F. Impact on core libraries](#part-libs).
- [G. Migration strategy](#part-migration).

## 7 Alternatives and deliverables {#alt-and-deliverables}

Alternatives, as well as implications and limitations have been addressed throughout the proposal. [Appendix I](#appendix-1-review) is a review (survey) of nullity in programming languages: from languages without `null` to strategies for coping with `null`. It establishes a broad and partly historical context for this proposal and some of its presented alternatives.

Once a "critical mass" of this proposal's features have gained approval, a fully updated version of the _Dart Language Specification_ will be produced. A prototype implementation is also planned.

## 8 Executive summary

### 8.1 Language updates and additions {#lang-changes}

**Core language design decisions**:

- [A.2](#non-null-types). *Drop semantic rules giving special treatment to* `null`. In particular, the static type of `null` is taken to be `Null`, not $\bot$ (while still allowing `null` to be returned for `void` functions). As a consequence, all non-`Null` class types (except `Object`, which is addressed next) lose [assignment compatibility][assignment compatible] with `null`, and hence *naturally recover* their status as *non-null types*.

- [B.2](#nnbd). Create a *new class hierarchy root* named `_Anything` with only two immediate subclasses: `Object` and `Null`. This new root is internal and hence inaccessible to users. Thus, `Object` _remains the implicit upper bound_ of classes.

- [B.2](#nnbd). Introduce _type operators_:
    - ?*T* defines the _nullable_ variant of type *T*;
    - !*T*, an inverse of `?`, is useful in the context of type ([C.3](#generics))
      and optional parameters ([E.1.1](#opt-func-param)).

- [C.3](#generics). Redefine the _default type parameter upper bound_ as `?Object`, i.e., nullable-by-default ([C.3.4](#default-type-param-bound)). Non-null type parameters extend `Object` ([C.3.3](#generic-param-non-null)). Support for generics requires no additional features.

**Subordinate language design decisions**:

- [B.2.4](#type-test-ambiguity). Resolution of negated type test (`is!`) syntactic ambiguity.
- [B.2.5](#factory-constructors). Syntax for nullable factory constructors.
- [B.2.6](#nnbd-function-sig). Syntax for nullable parameters declared using function signature syntax.
- [B.3.1](#uti). Union type interoperability.
- [B.3.3](#shared-type-op-semantics). Runtime representation of type operators and other shared semantics.
- [D.2.1](#dynamic-and-type-operators). `!dynamic` is the unknown non-null type, and `?dynamic` is `dynamic`.
- [D.2.2](#bang-dynamic-subtype-of). Defining `!dynamic <:` *S*.
- [E.1.1](#opt-func-param). Optional parameters are nullable-by-default in function bodies only.
- [E.1.2](#normalization). Normalization of type expressions.
- [E.2](#sugar). Syntactic sugar and other conveniences.

### 8.2 What is unchanged?

Other than the changes listed above, the semantics of [DartNNBD][] match [DartC][], most notably:

- [B.3.4](#var-init). _Default variable initialization_ semantics are untouched; i.e., `null` is the value of a variable when it is not explicitly initialized. Given that `null` is only [assignment compatible][] with `Null` in [DartNNBD][], this will result in [static warning][]s and [dynamic type error][]s for uninitialized variables declared to have a non-null type.

- [D.2](#dynamic). The role and semantics of `dynamic` are untouched. Thus, `dynamic` (and `?dynamic`) denote the "unknown type", supertype of all types. Also, e.g., in the absence of static type annotations or type arguments, `dynamic` is still assumed.

### 8.3 Summary of alternatives and discussions

**Discussions / clarifications**:

- [B.4.1](#ceylon-root). Precedent: [Ceylon][]'s root is `Object` | `Null`.
- [C.5.5](#generics-related-work). Generics and nullity in other languages or frameworks.
- [D.3.1](#extends-bang-dynamic). Clarification of the semantics of `T extends !dynamic`.
- [E.3.1](#nnbd-scope). Scope of [NNBD][] in [DartNNBD][].
- [E.3.4](#function-subtype). Subtype relation over function types unaffected by nullity.

**Points of variance / proposal part alternatives**:

- [A.3.1](#why-nn-types). Why non-null *types*?
- [A.3.2](#nullable-by-default). Embracing non-null types but preserving nullable-by-default?
- [B.4.2](#var-init-alt). Default initialization of non-null variables.
- [B.4.3](#factory-constructor-alt). Factory constructors.
- [B.4.4](#semantics-of-bang-alt). Dealing with `!Null`.
- [B.4.5](#type-test-ambiguity-alt). Resolution of negated type test (`is!`) syntactic ambiguity.
- [B.4.6](#type-anno-alt). Encoding `?` and `!` as metadata.
- [C.5.1](#nullable-type-op-alt). Loss of expressivity due to union type interoperability.
- [C.5.2](#lower-bound-for-maybe). Lower bounds to distinguish nullable/maybe-nullable parameters.
- [C.5.3](#type-param-not-null). Statically constraining a type parameter to be nullable but _not_ `Null`.
- [C.5.4](#generics-alt). Parametric nullity abstraction.
- [D.3.2](#dynamic-alt). Semantics for `dynamic`.
- [D.3.3](#bang-dynamic-subtype-of-alt). Defining `!dynamic <:` *S*.
- [E.3.2](#discussion-nnbd-scope). Scope of [NNBD][] in other languages or frameworks.
- [E.3.3](#opt-param-alt). Optional parameters are always nullable-by-default.

### 8.4 Assessment of goals {#goal-assessment}

This proposal has strictly upheld [G0, optional types](#g0), in particular, in the choices made to preserve the [DartC][] semantics:

- Regarding default (non-null) variable initialization ([B.3.4](#var-init) vs. [B.4.2](#var-init-alt)), and by
- Leaving `dynamic`, the unknown type, as nullable ([D.2](#dynamic) vs. [D.3.2](#dynamic-alt)).

Consequently, these features also support [G0, compatibility](#g0), and hence [G0, usability](#g0)---since fewer differences relative to [DartC][], and fewer special cases in the semantic rules, make [DartNNBD][] easier to learn and use---as well as [G0, ease migration](#g0).

Unavoidably, recovery of non-null types ([A.2](#non-null-types)), induces two **breaking changes** that may impact the production mode execution of existing programs that:

(a) Use _reflection_ to query: the direct members of, or the supertype of, `Object` or `Null`  ([B.2.1](#new-root)); or, the upper bound of a type parameter ([C.3.4](#default-type-param-bound)).
(b) Perform _type tests_ of the form *e* `is Object` since this will now return false for `null`. It seems unlikely though, that fielded code would actually contain such a type test given that it is always true in [DartC][].

We have noted that breaking changes of similar magnitude are sometimes incorporated in Dart minor releases---see the [Dart CHANGELOG][].

There are **no other backwards incompatible** changes impacting _production mode execution_ ([G0, compatibility](#g0)).

[Trending](#precedent) seems to indicate that there is value ([G0, utility](#g0-utility)) in having non-null types and [NNBD][] supported by languages with static type systems. This proposal helps Dart recover its non-null types and proposes adoption of [NNBD][]. The latter is the principle feature in support of [G0, ease migration](#g0); another key decision in support of ease of migration is leaving optional parameters ([E.1.1](#opt-func-param)) outside the scope of [NNBD][] ([E.3.1](#nnbd-scope)).

In fact, most of the core language design decisions adopted for this proposal relate back to the choices made concerning the **scope of [NNBD][]** ([E.3.1](#nnbd-scope)). During the creation of this proposal we constantly revisited potential impacts on the scope of [NNBD][] to ensure that the proposal stayed true to Dart's overall language design philosophy. Our main point of comparison, detailing the many ways in which this proposal could have been differently crafted, is the section on the _scope of [NNBD][] in other languages or frameworks_ ([E.3.2](#discussion-nnbd-scope)).

Overall, we are hopeful that this proposal has found a suitable balance between the [G0 goals](#g0) of _utility_, _usability_, _compatibility_ and _ease of migration_.
