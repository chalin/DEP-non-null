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

We define the internal class `_Anything` as the **new root** of the class hierarchy. Being internal, it cannot be subclassed or instantiated by users. `Object` and `Null` are immediate subclasses of `_Anything`, redeclared as:

```dart
abstract class _Anything { const _Anything(); }

abstract class _Basic extends _Anything {
  bool operator ==(other) => identical(this, other);
  int get hashCode;
  String toString();
  dynamic noSuchMethod(Invocation invocation);
  Type get runtimeType;
}

class Object extends _Anything implements _Basic {
  const Object();
  ... // Methods of _Basic are all declared external
}
```

The definition of `Null` is the same as in [DartC][] except that the class extends `_Anything` and implements `_Basic`. The latter declares all members of [DartC][]'s `Object`. Note that the declaration of equality allows a `null` operand (such a definition is needed, e.g., by the [Dart Analyzer][]).

> Comment. Declaring `_Anything` as a class without methods allows us to provide a conventional definition for `void` as an empty interface, realized only by `Null`:
>
> ```dart
> abstract class void extends _Anything {}
> class Null extends _Anything implements _Basic, void { /* Same as in DartC */ }
> ```

The changes proposed in this subsection impact various sections of the language specification, including ([DSS][] 10, "Classes"): "Every class has a single superclass except class [`Object`][del][`_Anything`][ins] which has no superclass".

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

These last three equations are part of the rewrite rules for the **normalization** of ?*T* expressions ([B.3.3](#shared-type-op-semantics)). When ?*V* and ?*U* are in  normal form, then:

- ?*V* << *S*  **iff**  `Null` << *S*  $\land$  *V* << *S*.

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

### B.3.4 Default initialization of non-null variables is like [DartC][] {#var-init}

We make no changes to the rules regarding default variable initialization, even if a variable is statically declared as non-null. In particular, the following rule still applies ([DSS][] 8, "Variables"): "A variable that has not been initialized has the initial value `null`".

> Comment. The term *variable* refers to a "storage location in memory", and encompasses local variables, library variables, instance variables, etc. ([DSS][] 8).

Explicit initialization checks are extended to also address cases of implicit initialization with `null`. Thus, generally speaking, explicit or implicit initialization of a variable with a value whose static type cannot be [assigned to](#def-subtype) the variable, will result in:

- [Static warning][].
- [Dynamic type error][].
- No effect on production mode execution.

Rule details are given next.

#### (a) Instance variables

An instance variable *v* that is:

1. `final`, or
2. declared in a non-`abstract` class and for which: `null` cannot be [assigned to](#def-subtype) the (actual) type of *v*;

then *v* be explicitly initialized (either from a declarator initializer, a field formal parameter, or a constructor field initialization).

> Comment. Conforming to [DartC][], the above holds true for nullable `final` instance variables even if this is not strictly necessary. In (2) we disregard abstract classes since we cannot easily and soundly determine if all of its uses (e.g. as an interface, mixin or extends clause target) will result in all non-null instance variables being explicitly initialized).

#### (b) Class (static) and library variables

A class or library variable that is (1) `const` or `final`, or (2) declared non-null, must be explicitly initialized.

> Comment. Conforming to [DartC][], the above holds true for nullable `const` or `final` variables even if this is not strictly necessary.

#### (c) Local variables {#var-local-init}

(1) A `const` or `final` local variable  must be explicitly initialized.
(2) For a non-null local variable, a [static warning][] (and a [dynamic type error][]) will result if there is a path from its declaration to an occurrence of the variable where its value is being read. If a local variable read in inside a closure, then it is assumed to be read at the point of declaration of the closure. Also see [E.3.6](#local-var-analysis).

### B.3.5 Adjusted semantics for "assignment compatible" ($\Longleftrightarrow$) {#new-assignment-semantics}

Consider the following [DartNNBD][] code:

```dart
?int i = 1; // ok
class C1<T1 extends int> { T1 i1 = 1; } // ok
class C2<T2 extends int> { ?T2 i2 = 1; } // should be ok
```

According to the [DartC][] definition of [assignment compatible][] described in [A.1.4](#def-subtype), a [static warning][] should be reported for the initialization of `i2`. To understand why, let us examine the general case of

```dart
class C<T extends B> { T o = s; }
```

where `s` is some expression of type $S$. Let us write $T^B$ to represent that the type parameter $T$ has upper bound $B$. The assignment to `o` is valid if $S$ is [assignment compatible][] with $T^B$, written $S \asgn T^B$. But $T^B$ is incomparable when it is not instantiated. The best we can do is compare $S$ to $B$ and try to establish that $B \subtype S$. Thus, $S \asgn T^B$

$= S \subtype T^B \lor T^B \subtype S$ (by definition of $\asgn$) <br/> \
$\impliedby S \subtype T^B \lor T^B \subtype B \land B \subtype S$ <br/> \
$= S \subtype T^B \lor B \subtype S$ (simplified because $B$ is the upper bound of $T^B$).

where $\impliedby$ is reverse implication. In the case of class `C2` above, the field `i2` is of type ?`T2`, hence we are dealing with the general case: $S \asgn \nut{T^B}$

$= S \subtype \nut{T^B} \lor \nut{T^B} \subtype S$ (by definition of $\asgn$) <br/> \
$= S \subtype \pg{Null} \lor S \subtype T^B \lor \nut{T^B} \subtype S$ (property of ?) <br/> \
$= S \subtype \pg{Null} \lor S \subtype T^B \lor (\pg{Null} \subtype S \land T^B \subtype S)$ (property of ?) <br/> \
$\impliedby S \subtype \pg{Null} \lor S \subtype T^B \lor (\pg{Null} \subtype S \land T^B \subtype B \land B \subtype S)$ <br/> \
$= S \subtype \pg{Null} \lor S \subtype T^B \lor (\pg{Null} \subtype S \land B \subtype S)$. (*)

If we substitute the type of `i2` and the bound of `T2` for $S$ and $B$ in (*) and we get:

$\pg{int} \subtype \pg{Null} \lor \pg{int} \subtype T^{\pg{int}} \lor (\pg{Null} \subtype \pg{int} \land \pg{int} \subtype \pg{int})$ <br/> \
$= \pg{false} \lor \pg{int} \subtype T^{\pg{int}} \lor (\pg{false} \land \pg{true})$ <br/> \
$= \pg{int} \subtype T^{\pg{int}} \lor \pg{false}$ <br/> \
$= \pg{false}$.

This seems counter intuitive: if `i2` is (at least) a nullable `int`, then it should be valid to assign an `int` to it. The problem is that the definition of [assignment compatible][] is too strong in the presence of union types. Before proposing a relaxed definition we repeat the definition of assignability given in [A.1.4](#def-subtype), along with the associated commentary from ([DSS][] 19.4):

> An interface type $T$ may be assigned to a type $S$, written  $T \asgn S$, iff either $T \subtype S$ or $S \subtype T$. 
> _This rule may surprise readers accustomed to conventional type checking. The intent of the $\asgn$ relation is not to ensure that an assignment is correct. Instead, it aims to only flag assignments that are almost certain to be erroneous, without precluding assignments that may work._

In the spirit of the commentary, we refine the definition of "[assignment compatible][]" as follows: let $T$, $S$, $V$ and $U$ be any types such that $\nut{V}$ and $\nut{U}$ are in normal form, then we define $\asgn$ by cases:

- $T \asgn \nut{U}$ **iff** $T \asgn \pg{Null} \lor T \asgn U$, when $T$ is *not* of the form $\nut{V}$
- Otherwise the [DartC][] definition holds; i.e., $T \asgn S$ iff $T \subtype S \lor S \subtype T$.

> Comment. It follows that $\nut{V} \asgn \nut{U}$ iff $V \asgn U$. An equivalent redefinition is: <br/> \
> $T \asgn S$ **iff** $T \subtype S \lor S \subtype T \lor S = \nut{U} \land U \subtype T$ (for some $U$).

If we expand this new definition for arguments $\nut{V}$ and $S$, we end up with the formula (*) as above, except that the last logical operator is a disjunction rather than a conjunction. Under this new relaxed definition of [assignment compatible][], `i2` can be initialized with an `int` in [DartNNBD][].

### B.3.6 Static semantics of members of ?T {#multi-members}

We define the static semantics of the members of ?*T* as if it were an anonymous class with `Null` and *T* as superinterfaces. Then the rules of member inheritance and type overrides as defined in ([DSS][] 11.1.1) apply.

### B.3.7 Type promotion {#type-promotion}

In the context of `if` statements, conditional expressions, and conjunction and disjunction expressions, the following type promotions shall be performed for any expression *e* of type ?*T*:

|  Condition   |  True context  |  False context
| ------------ | -------------- | ---------------
| *e* == null  | *e* is `Null`  | *e* is *T*
| *e* != null  | *e* is *T*     | *e* is `Null`
| *e* is *T*   | *e* is *T*     | -
| *e* is! *T*  | -              | *e* is *T*


This applies to function types as well.

### B.3.8 Type least upper bound {#lub}

The least upper bound of `Null` and any non-`void` type *T* is ?*T*.

### B.3.9 Null-aware operators {#null-awareoperators}

> Comment. TODO.

## B.4 Discussion

### B.4.1 Precedent: [Ceylon][]'s root is `Object` | `Null`{} {#ceylon-root}

The [Ceylon][] language essentially has the nullity semantics established so far in this proposal but without `!`, i.e.: types are non-null by default, `?` is a (postfix) nullable meta type annotation, and the top of the [Ceylon][] type hierarchy is defined with a structure identical to that proposed in [B.2.1](#new-root) for [DartNNBD][], namely:

```dart
abstract class Anything of Object | Null
class Null of null extends Anything
class Object extends Anything
```

Thus, [`Anything`][Ceylon `Anything` API] is defined as the *union type* of `Object` and `Null`.

### B.4.2 Default initialization of non-null variables, alternative approaches {#var-init-alt}

#### (a) Preserving [DartC][] semantics is consistent with JavaScript & TypeScript

Our main proposal ([B.3.4](#var-init)) preserves the [DartC][] semantics, i.e., a variable not explicitly initialized is set to `null`. In JavaScript, such variables are set to `undefined` ([ES5 8.1][]), and [TypeScript][] conforms to this behavior as well ([TSLS 3.2.6][]). 

For variables statically declared as non-null, some might prefer to see this proposal _mandate_ (i.e., issue a compile-time error) if the variable is not explicitly initialized (with a value assignable to its statically declared type, and hence not `null`) but this would go against [G0, optional types](#g0).

In our opinion, preserving the default variable initialization semantics of [DartC][] is the only approach that is consistent with [G0, optional types](#g0). Also see [I.3.2](#language-evolution) for a discussion of issues related to soundness. Although Dart's static type system is already unsound by design ([Brandt, 2011][]), this proposal does not contribute to (increase) the unsoundness because of non-null types. [NNBD][] scope and local variables are also discussed in [E.3.2(a)](#local-var-alt).

Also see [E.3.2(a)](#discussion-nnbd-scope) and [E.3.6](#local-var-analysis).

#### (b) Implicit type-specific initialization of non-null variables {- #type-specific-init}

In some other languages (especially in the presence of primitive types), it is conventional to have type-specific default initialization rules---e.g., integers and booleans are initialized to 0 and false, respectively. Due to our desired conformance to [G0, optional types](#g0), it is not possible to infer such type-specific default initialization from a static type annotation _alone_. On the other hand, special declarator syntax, such as (where `T` is a class type and `<U,...>` represents zero or more type arguments):

```dart
  !T<U,...> v;
```
could be treated as syntactic sugar for

```dart
  T<U,...> v = T<U,...>.DEFAULT_INIT();
```

In production mode this would be interpreted as:

```dart
  var v = T<U,...>.DEFAULT_INIT();
```

Any class type `T`, for which this form of initialization is desired, would provide `DEFAULT_INIT()` as a factory constructor, e.g.:

```dart
abstract class int extends num {
  factory int.DEFAULT_INIT() => 0;
  ...
}
```

Although what we are proposing here effectively overloads the meaning of meta type annotation `!`, there is no ambiguity since, in an [NNBD][] context, a class type *T* is already non-null, and hence !*T*---which is not in normal form ([B.3.3](#shared-type-op-semantics))---can be interpreted as a request for an implicit type-specific initialization. This even extends nicely to handle `!T` optional parameter declarations ([E.1.1](#opt-func-param)).

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

### B.4.7 Ensuring `Object` is non-null: making `Null` a root too {#object-not-nullable-alt}

An alternative to creating a new class hierarchy root ([B.2.1](#new-root)) is to create a class hierarchy _forest_ with two roots `Object` and `Null`. This has the advantage of being a less significant change to the class hierarchy, benefiting [G0, ease migration](#g0), though it is less conventional.

```diff
  class Object {
    const Object();
    bool operator ==(other) => identical(this, other);
    external int get hashCode;
    external String toString();
    external dynamic noSuchMethod(Invocation invocation);
    external Type get runtimeType;
    }

- class Null {
+ class Null /*no supertype*/ {
    factory Null._uninstantiable() {
      throw new UnsupportedError('class Null cannot be instantiated');
    }
+   external int get hashCode;
    String toString() => "null";
+   external dynamic noSuchMethod(Invocation invocation);
+   external Type get runtimeType;
  }
```

Note that `dynamic` remains the top of the subtype relation.
