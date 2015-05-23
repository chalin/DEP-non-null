# Part B: Non-null by default (NNBD) {- #part-nnbd}

## B.1 Motivation: nullable-by-default increases migration effort {#part-nnbd-motivation}

Several languages (see the [survey](#appendix-1-review)) with nullable-by-default semantics that have been subsequently retrofitted with support for non-null types have achieved this through the introduction of meta type annotations like `?` and `!`, used to indicate the nullable and non-null variants of a type, respectively. 

The simplest adaptation to a language with a nullable-by-default semantics like [DartC][], is to leave the default untouched and require developers to explicitly mark types as non-null using the `!` meta type annotation. 

```dart
// DartC extended with the meta type annotation `!'
int i = null;     // ok
!String s = null; // error
```

Unfortunately, this would unnecessarily burden developers and negatively impact [G0, ease migration](#g0) as we explain next. An [empirical study of Java code][Chalin et al., 2008] established that 80% of declarations (having a reference type) are meant to be non-null, _by design_. An independent study reports 20 nullity annotations per KLOC ([Dietl, 2014][]; [Dietl et al., 2011][]).

We expect the proportion of non-null vs. nullable declarations in Dart to be similarly high; a claim supported by anecdotal evidence---e.g., [Nystrom, 2011], and our preliminary experiments in translating the Dart SDK libraries ([Part F](#part-libs)). For example, under a variant of [DartC][] extended with `!`, `int.dart` would have to be updated with 38 `!` annotations (that's 86%) against 6 declarations left undecorated.

## B.2 Feature details: non-null by default {#nnbd}

A consequence of dropping the special semantic rules for `null` ([A.2](#non-null-types)) is that all non-`Null` classes except `Object` lose [assignment compatibility][assignment compatible] with `Null`, and hence *naturally recover* their status as *non-null types*. In [DartC][], `Null` directly extends `Object` and so `Null <: Object`. This means that `Null` may still be [assigned to](#def-subtype) `Object`, effectively making `Object` nullable. We ensure that `Object` is non-null as follows.

### B.2.1 Ensuring `Object` is non-null: elect `_Anything` as a new root {#new-root}

We define the internal class `_Anything` as the **new root** of the class hierarchy. Being internal, it cannot be subclassed or instantiated by users. The only two immediate subclasses of `_Anything` are `Object` and `Null`. Class members of `Object` that are relevant to `Null` shall be promoted to `_Anything`. This impacts various sections of the language specification, including ([DSS][] 10, "Classes"): "Every class has a single superclass except class [`Object`][del][`_Anything`][ins] which has no superclass".

As is discussed below ([B.4.1](#ceylon-root)), [Ceylon][] has a class hierarchy like the one proposed here for Dart.

> Comments:
>
> - `Object` remains the implicit upper bound of classes (i.e., `extends` clause argument).
> - Under this new hierarchy, `Null` is only [assignable to](#def-subtype) the new root, `void` and itself.

### B.2.2 Nullable type operator `?`{} {#nullable-type-op}

The **nullable type operator**, **?**_T_, is used to introduce a nullable variant of a type *T*.

> Comment. Like other metadata annotations in Dart, `?` is applied as a prefix.

### B.2.3 Non-null type operator `!`{} {#non-null-type-op}

The **!** (bang) **non-null type operator**, can be thought of as an inverse of the nullable type operator `?`. It also acts as an identity function when applied to non-null types.

### B.2.4 Resolution of negated type test (`is!`) syntactic ambiguity {#type-test-ambiguity}

Unfortunately, the choice of `!` syntax introduces an ambiguity into the grammar relative to negated type tests, such as: `o is !`*T*. The ambiguity shall be resolved in favor of the original negated type test production, requiring parentheses for a type test against a non-null type, as in `o is (!`*T*`)`. See [B.4.5](#type-test-ambiguity-alt) for further discussion and an alternative.

### B.2.5 Syntax for nullable factory constructors {#factory-constructors}

It may seem unnecessary to qualify that factory constructors are non-null, but in [DartC][], a factory constructor for a class *T* is permitted to return an instance of _any_ subtype of *T*, including `null` ([DSS][] 10.6.2, "Factories"):

> In checked mode, it is a dynamic type error if a factory returns a non-`null` object whose type is not a subtype of its actual return type. _(Rationale) It seems useless to allow a factory to return `null`. But it is more uniform to allow it, as the rules currently do._

In support of [G0, compatibility](#g0), we propose to extended the syntax of factory constructors so that they can be marked nullable, as is illustrated next. For further discussion and an alternative see [B.4.3](#factory-constructor-alt).

```dart
// DartNNBD - part of dart.core;
abstract class int extends num {
  external const factory ?int.fromEnvironment(String name, {int defaultValue});
  ...
}
```

### B.2.6 Syntax for nullable parameters declared using function signature syntax {#nnbd-function-sig}

A formal parameter can be declared by means of a function signature ([DSS][] 9.2.1, "Required Formals") as is done for `f` in: `int applyTo1(int f(int)) => f(1)`.

This, in effect, declares an anonymous class type ([DSS][] 19.5, "Function Types") "that implements the class `Function` and implements a `call` method with the same signature as the function". The [NNBD][] rule also applies to such anonymous class types, so special syntax must be introduced to allow them to be marked as nullable. To declare a such a parameter as nullable, the parameter name can be *suffixed* with `?` as in:

```dart
int applyTo1(int f?(int)) => f == null ? 1 : f(1);
```

This can be thought of as equivalent to:

```dart
typedef int _ANON(int);
int applyTo1(?_ANON f) => f == null ? 1 : f(1);

```

This syntactic extension to function signatures can only be used in formal parameter declarations, not in other places in which function signatures are permitted by the grammar (e.g., class member declarations and type aliases).

> Comment. We avoid suggesting the use of `?` as a *prefix* to the function name since that could be interpreted as an implicitly (nullable) `dynamic` return type when no return type is provided.


## B.3 Semantics {#nnbd-semantics}

### B.3.1 Semantics of `?`{} {#semantics-of-maybe}

#### (a) Union type interoperability {- #uti}

While *union types* are not yet a part of Dart, [they have been discussed][DSC 2015/01] by the Dart standards committee, and a [proposal is anticipated][DEP 2015/03/18]. Once introduced, union types and the language features suggested by this proposal---especially the `?` type operator---will need to "interoperate" smoothly. This can be achieved by defining the nullable type operator as:

> **?**_T_ = *T* | `Null`

The semantics of `?` then follow naturally from this definition. While the Dart union type proposal has yet to be published, it can be safe to assume that its semantics will be *similar* to that of union types in other languages such as:

- [TypeScript][], see Section 3.4 of the [TypeScript language specification][TSLS]; or,
- [Ceylon][], see the language specification Section on [Ceylon union types][].

From such a semantics it follows that, e.g., `Null <: ?T` and `T <: ?T` for any *T*.

#### (b) Core properties of `?`{} {-}

This proposal does not *require* union types. In the absence of union types we characterize `?` by its core properties. For any type *T*

+ `Null` and *T* are _more specific_ than ?*T* ([A.1.4](#def-subtype)):
    - `Null` << ?*T*,
    - *T* << ?*T*;
- ??*T* = ?*T* (idempotence),
- ?`Null` = `Null` (fixed point),
- ?`dynamic` = `dynamic` (fixed point, [D.2.1](#dynamic-and-type-operators)).

These last three equations are part of the rewrite rules for the **normalization** of ?*T* expressions ([B.3.3](#shared-type-op-semantics)).

It is a compile-time error if `?` is applied to `void`.
It is a [static warning][] if an occurrence of ?*T* is not in normal form.

### B.3.2 Semantics of `!`{} {#semantics-of-bang}

When regarding ?*T* as the union type *T* | `Null`, then `!` can be seen as a projection operator that yields the non-`Null` union member *T*. For all non-null class types *T* `<: Object`

- !?*T* = *T* (inverse of `?`)
- !*T* = *T* (identity over non-null types)

These equations are part of the rewrite rules for the **normalization** of !*T* expressions ([B.3.3](#shared-type-op-semantics)).

It is a compile-time error if `!` is applied to `void`. Application of `!` to an element outside its domain is considered a _malformed_ type ([DSS][] 19.1, "Static Types") and "any use of a malformed type gives rise to a static warning. A malformed type is then interpreted as `dynamic` by the static type checker and the runtime unless explicitly specified otherwise". Alternatives are presented in [B.4.4](#semantics-of-bang-alt).

> Comment. Currently in [DartNNBD][], the only user expressible type outside of the domain of `!` is `Null` since `_Anything` is not accessible to users ([B.2.1](#new-root)).

### B.3.3 Runtime representation of type operators and other shared semantics {#shared-type-op-semantics}

Besides the semantic rules presented in the previous two subsections for their respective type operators, all other checked mode semantics ([static warning][]s or [dynamic type error][]s) for both `?` and `!` follow from those of [DartC][] and the semantics of [DartNNBD][] presented thus far.

Type expressions involving type operators shall be represented at runtime, in normalized form ([E.1.2](#normalization), for use in:

- Reflection.
- Reification ([C.4](#semantics-of-generics)).
- Structural type tests of function types ([E.3.4](#function-subtype)).

### B.3.4 Initialization of non-null variables is like [DartC][] {#var-init}

We make no changes to the rules regarding variable initialization, even if a variable is statically declared as non-null. In particular, the following rule still applies ([DSS][] 8, "Variables"): "A variable that has not been initialized has the initial value `null`".

Explicit initialization checks are extended to also address cases of implicit initialization with `null`.

> Comments:
>
> - Thus, explicit or implicit initialization of a variable with a value whose static type cannot be [assigned to](#def-subtype) the variable, will result in:
> 
>		- [Static warning][].
>		- [Dynamic type error][].
>		- No effect on production mode execution.
>
> - The term *variable* refers to a "storage location in memory", and encompasses local variables, library variables, instance variables, etc. ([DSS][] 8).

## B.4 Discussion

### B.4.1 Precedent: [Ceylon][]'s root is `Object` | `Null`{} {#ceylon-root}

The [Ceylon][] language essentially has the nullity semantics established so far in this proposal but without `!`, i.e.: types are non-null by default, `?` is a (postfix) nullable meta type annotation, and the top of the [Ceylon][] type hierarchy is defined with a structure identical to that proposed in [B.2.1](#new-root) for [DartNNBD][], namely:

```dart
abstract class Anything of Object | Null
class Null of null extends Anything
class Object extends Anything
```

Thus, [`Anything`][Ceylon `Anything` API] is defined as the *union type* of `Object` and `Null`.

### B.4.2 Initialization of non-null variables, alternative approaches {#var-init-alt}

Given a variable statically declared as non-null, some might prefer to see this proposal _mandate_ (i.e., issue a compile-time error) if the variable is not explicitly initialized with a value assignable to its statically declared type (and hence not `null`), but this would go against [G0, optional types](#g0).

In our opinion, preserving the variable initialization semantics of [DartC][] is the only approach that is consistent with [G0, optional types](#g0). Also see [I.3.2](#language-evolution) for discussion of issues related to soundness. Though Dart's static type system is already unsound by design ([Brandt, 2011][]), this proposal does not contribute to (increase) the unsoundness because of non-null types.

### B.4.3 Factory constructors, an alternative {#factory-constructor-alt}

In [B.3.2](#factory-constructors) we extended the syntax of factory constructors so that they could be marked as nullable. Allowing a factory constructor to return `null` renders _all_ `new`/`const` expressions _potentially nullable_. This is an unfortunate complication in the semantics of Dart (and hence goes against [G0, usability](#g0)).

As was mentioned earlier, in [DartC][], a factory constructor for a class *T* is permitted to return an instance of _any_ subtype of *T*, including `null` ([DSS][] 10.6.2, "Factories"): "In checked mode, it is a dynamic type error if a factory returns a non-`null` object whose type is not a subtype of its actual return type. _(Rationale) It seems useless to allow a factory to return `null`. But it is more uniform to allow it, as the rules currently do_". From the statement of rationale, it seems that factory constructors have been permitted to return `null` out of a desired uniformity in the application of the semantic constraint on factory results (which is based on subtyping).

Given that `Null` is no longer a subtype of every type in [DartNNBD][], we could also choose to (strictly) uphold the uniformity of the subtype constraint, thus _disallowing_ a factory _constructor_ from returning `null`---of course, factory _methods_ could be nullable. Unfortunately, this would be a breaking change impacting features of the Dart core library, in particular `const` `factory` constructors like `int.fromEnvironment()` and `String.fromEnvironment()`. Because of the `const` nature of these factories, they have proven useful in "_compile-time dead code elimination_" ([Ladd, 2013][]). We suspect that few other factory constructors return `null` other than in the context of this idiom, and those that do, could provide a non-null default return value.

There has been some discussions of the possible elimination of `new` and/or `const` as constructor qualifiers (e.g., [Nielsen, 2015]), in which case the attempted distinction made here of factory constructors vs. factory methods would be moot.

### B.4.4 Dealing with `!Null`, alternatives {#semantics-of-bang-alt}

In the absence of generics, `!Null` could simply be reported as a compile-time error. With generics, the issue is more challenging since we must deal with type expressions like `!T` possibly when type parameter `T` is instantiated with `Null` ([Part C](#part-generics)).

While we proposed, in [B.3.2](#semantics-of-bang), to define !*T* as malformed when *T* is `Null`, alternatives include treating it as (i) $\bot$, or (ii) a distinct empty (error) type that is assignment compatible with no other type. The latter would introduce a new way of handling type errors to Dart, in contrast to the current uniform treatment of such "errored types" as malformed instead. Use of $\bot$ would also be a new feature since, to our knowledge, no type expression can be $\bot$ in [DartC][]. Hence both of these alternatives introduce extra complexity, thus decreasing [G0, usability](#g0) and increasing retooling costs ([G0, ease migration](#g0)).

### B.4.5 Resolution of negated type test (`is!`) syntactic ambiguity, an alternative {#type-test-ambiguity-alt}

Syntactic ambiguity between a negated type test and a type test against a non-null type ([B.2.4](#type-test-ambiguity)) could be avoided by adopting a different symbol, such as `~`, for the non-null type operator, but `!` is conventional. It helps somewhat that there is a lexical convention (enforced by the [Dart Code Formatter][]) of writing the tokens `is` and `!` immediately adjacent to each other. It might further help if the analyzer reported a hint when the tokens `is` and `!` are separated by whitespace, inquiring (something like): "did you intend to write `o is (!`*T*`)`?".

Note that there is no _class name_ *T* that can be written in a non-null type test `o is (!`*T*`)` because `!Null` is malformed and !*T* will not be in normal form otherwise ([B.3.2](#semantics-of-bang)). But as we shall see in [Part C](#part-generics), it is legal to write !*T* when *T* is a type parameter name.

### B.4.6 Encoding `?` and `!` as metadata {#type-anno-alt}

Use of specialized syntax for meta type annotations `?` and `!` requires changes to Dart tooling front ends, impacting [G0, ease migration](#g0). We can _almost_ do away with such front-end changes by encoding the meta type annotations as metadata such as `@NonNull` and `@Nullable`. We write "almost" because Dart metadata annotations would first need to be (fully) extended to types through an equivalent of [JSR-308][] which extended Java's [metadata facility to types][JSR-308 explained]. Broadened support for type metadata (which was mentioned in the [DEP 2015/03/18][] meeting) could be generally beneficial since nullity type annotations are only one among a variety of useful kinds of type annotation. E.g., the [Checker Framework][], created jointly with JSR itself by the team that realized [JSR-308][], offers 20 checkers as examples, not the least of which is the [Nullness Checker][]. It might also make sense to consider *internally* representing `?` and `!` as type metadata. But then again, special status may make processing of this core feature more efficient in both tooling and runtimes.

Regardless, the use of the single character meta type annotations `?` and `!` seems to have become quite common: it is certainly much shorter to type and it makes for a less noisy syntax.
