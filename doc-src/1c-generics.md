# Part C: Generics {- #part-generics}

## C.1 Motivation: enhanced generics through non-null types

One of the main benefits of a non-null type system is its potential interplay with generics. It is quite useful, for example, to be able to declare a `List` of non-null elements, and know that list element access will yield non-null instances.

## C.2 Design goals for this part {#generics-design-goals}

### G1: Support three kinds of formal type parameter {- #generics-g1}

  [G1]: #generics-g1

Support three kinds of formal type parameter: i.e., formal type parameters that constrain arguments to be

1. Non-null.
2. Nullable.
3. Either non-null or nullable.

(We address whether the last two cases should be distinguished in [C.3.2](#generics-g1-2) and [C.5.2](#lower-bound-for-maybe).)

### G2: Support three kinds of type parameter expression in a class body {- #generics-g2}

 [G2]: #generics-g2

Within the body of a generic class, we wish to be able to represent three kinds of type parameter expression for any given formal type parameter: i.e., use of a type parameter name as part of a type expression, occurring in the class body, that is

1. Non-null.
2. Nullable.
3. Matching the nullity of the argument.

### Running example {-}

Defining and assessing suitable [DartNNBD][] language features in support of Goals [G1][] and [G2][] has been one of the most challenging aspects of this proposal. To help us understand the choices we face, we will use the following Dart code as a running example. Note that this code uses `/*(...)*/` comments to mark those places where we want to come up with appropriate syntax. Each of the three cases of Goal [G2][] is represented in the class body.

```dart
class Box< /*(...)*/ T /*extends (...) Object*/ > {
  final /*(non-null)*/ T _default; // non-null (G2.1)
  /*(matching)*/ T value; // match nullity of type parameter T (G2.3)

  Box(this._default, this.value);

  /*(nullable)*/ T maybeNull() => // nullable (G2.2)
      value == _default ? null : value;

  /*(non-null)*/ T neverNull() => value == null ? _default : value;
}
```

Thus, `Box<`*U*`>.value` would have the same nullity as *U*. For example, `Box<?int>.value` would be of type `?int` and `Box<String>.value` of type `String`. As defined above, `Box<`*U*`>.maybeNull()` returns `null` when `value` matches `_default`, even if *U* is non-null. Finally, `Box<`*U*`>.neverNull()` always returns a non-null value regardless of the nullity of *U*.

## C.3 Feature details: generics {#generics}

We now work through the three cases of Goal [G1][] in reverse order.

### C.3.1 Maybe-nullable formal type parameter, case [G1][].3 {#generic-param-maybe-null}

Here is an illustration of the base syntax (without any syntactic sugar or abbreviations) for the maybe-nullable formal type parameter case (code inessential to presentation has been elided, "`...`"):

```dart
// DartNNBD
class Box<T extends ?Object> {
  final !T _default;     // non-null (G2.1)
  T value;               // nullity matching parameter (G2.3)
  ?T maybeNull() => ...; // nullable (G2.2)
  ...
}
```

### C.3.2 Nullable formal type parameter, case [G1][].2 {#generics-g1-2}

Given that Dart generics are covariant and that `T <: ?T`, it would be a significant departure from the current Dart semantics if we were to define static checking rules *requiring* that a type argument be nullable while rejecting non-null arguments. Thus, we propose that cases [G1][].2 and [G1][].3 be indistinguishable in [DartNNBD][]. For an alternative, see [C.5.2](#lower-bound-for-maybe).

### C.3.3 Non-null formal type parameter, case [G1][].1 {#generic-param-non-null}

For a non-null formal type parameter `T` we simply have `T` extend `Object`; again, here is the syntax without any sugar or abbreviations:

```dart
// DartNNBD
class Box<T extends Object> {
  final !T _default;     // non-null (G2.1)
  T value;               // nullity matching parameter (G2.3)
  ?T maybeNull() => ...; // nullable (G2.2)
  ...
}
```

> Comment. Given that `T` is non-null, the use of `!` could be dropped in the body.

### C.3.4 Default type parameter upper bound is `?Object`{} {#default-type-param-bound}

When no explicit upper bound is provided for a type parameter it is assumed to be `?Object`, thus providing clients of a generic type the most flexibility in instantiating parameters with either a nullable or non-null type (cf. [E.3.2](#discussion-nnbd-scope)). The following are equivalent:

```dart
// DartNNBD
class Box<T extends ?Object> {...}
class Box<T> {...}                 // Implicit upper bound of ?Object.
```

## C.4 Semantics {#semantics-of-generics}

While the static and dynamic semantics of generics follow from those of [DartC][] and the semantics of [DartNNBD][] introduced in the previous parts, there are quite a few alternative ways of dealing with certain aspects of generics. These are presented in the next section.

## C.5 Discussion

### C.5.1 Loss of expressivity due to union type interoperability, an alternative {#nullable-type-op-alt}

One caveat of "future proofing" the nullable type operator ?*T*, so that its semantics are compatible with the union type *T* | `Null` ([B.3.1](#uti)), is that we loose the ability to statically constrain a generic type parameter to be nullable but _not_ `Null`---we discuss _why_ we might want to do this in [C.5.3](#type-param-not-null). We loose this ability because ?*T* is not a type _constructor_, which would yield a unique (tagged) type, but rather just a type _operator_ mapping *T* to the equivalent of the (untagged) union type *T* | `Null`. Thus, e.g., no distinction is made between `Null` and `?Null`.

We could alternatively define ?*T* as a type constructor (as if it were introducing a new type like `_$Nullable<`*T*`>`), orthogonal to union types, but there seems to be little to justify this complexity---future interoperability with union types seems more important and would be much more supportive of [G0, usability](#g0) and [G0, ease migration](#g0).

### C.5.2 Lower bounds to distinguish nullable/maybe-nullable parameters {#lower-bound-for-maybe}

The [Checker Framework][] supports case [G1][].2 (nullable type parameter) distinctly from [G1][].3 (maybe-nullable type parameter) by allowing a type parameter lower bound to be defined ([Checker Framework Manual, 23.1.2][Checker Framework generics]) in addition to an upper bound (via `extends`). This is a natural fit for [Java][] since the language already has some support for lower bounds through [lower bounded wildcards][Java, lower bounded wildcards].

Without introducing general support for lower bounds, such an approach could be adopted for [DartNNBD][] as well. In our notation, it would look like this: `class Box<?T extends ?Object>`, which would require an argument *U* to satisfy `?T <: `*U* ` <: ?Object`, which is only possible if *U* is nullable.

### C.5.3 Statically constraining a type parameter to be nullable but _not_ `Null`{} {#type-param-not-null}

Consider the following code:

```dart
// DartNNBD
class C<T extends ?Object> { List<!T> list; ... }
var c = new C<Null>();
```

In the current form of the proposal, when a type parameter `T` is instantiated with `Null` then `!T` is considered malformed ([B.3.2](#semantics-of-bang)), as is the case for the type of `c.list` from the code sample above. Ideally, we would like to statically constrain `T` so that it cannot be `Null`. This would inform the clients of such a generic class that `T` should not be instantiated with `Null` and if it is, then a [static warning][] could be reported at the earliest point possible, i.e., instantiation expressions like `new C<Null>()`.

It is possible to statically avoid malformed types that arise from such `!T` type expressions. One way is to adopt a completely different semantics for ?*T* as was presented in [C.5.1](#nullable-type-op-alt). Another approach is to make use of type parameter lower bounds using syntax similar to what was presented in [C.5.2](#lower-bound-for-maybe): e.g., `class Box<!T extends ?Object>` would constrain an argument *U* to satisfy `T <: `*U* ` <: ?Object`. The absence of an explicit lower-bound qualifier would be interpreted as `!`.

### C.5.4 Parametric nullity abstraction, an alternative approach to generics {#generics-alt}

There are a few alternatives to the proposal of [C.3](#generics) for handling generics. We mention only one here. It consists of broadening the scope of the [NNBD][] rule to encompass type parameter occurrences inside the body of a generic class; i.e., an _undecorated_ occurrence of a type parameter would _always_ represent a non-null type. Such an alternative is best introduced by an example covering cases [G1][].2 and [G1][].3:

```dart
// DartNNBD
class Box<&T extends ?Object> {
  final T _default;      // non-null (G2.1)
  &T value;              // nullity matching parameter (G2.3)
  ?T maybeNull() => ...; // nullable (G2.2)
  ...
}
```

One can think of the type parameter decorator `&` as a symbol acting as a "formal parameter" for the nullity of the corresponding type argument---i.e., as a form of *parametric nullity abstraction*---which will be instantiated as either `?` or `!`. (This is similar in spirit to the [Checker Framework qualifier parameters][].) Thus, `Box` could be instantiated as `Box<?int>` or `Box<int>`, with `&` denoting `?` and (an implicit) `!`, respectively.

Case [G1][].1, for a non-null type parameter, could be written as `class Box<&T extends Object> {...}` or more simply as `class Box<T extends Object> {...}`.

The **main advantage** of this approach is that it upholds *nullity notational consistency* (NNC). That is, just like for class names,

- An _undecorated_ type parameter name *T* represents a non-null type ([G2][].1),
- ?*T* is its nullable variant ([G2][].2), and
- &*T* matches the nullity of the corresponding type argument ([G2][].3).

The **main disadvantage** of this alternative is that it introduces a new concept (parametric nullity abstraction) which increases the complexity of the language, impacting [G0, usability](#g0) as well as [G0, ease migration](#g0). Code migration effort is especially impacted because, in practice, case [G2][].3 is most frequent; hence, in porting [DartC][] code to [DartNNBD][], most type parameter uses would need to be annotated with `&` vs. no annotation for our main alternative ([C.3](#generics)).

### C.5.5 Generics and nullity in other languages or frameworks {#generics-related-work}

#### (a) Default type parameter upper bound {-}

As we have done here, the [Nullness Checker][] of the [Checker Framework][] has `@Nullable Object` as the implicit upper bound for type parameters, following its general [CLIMB-to-top][Checker Framework CLIMB-to-top] principle (which is further discussed in [E.3.2](#discussion-nnbd-scope)). [Ceylon][]'s implicit type parameter upper bound is `Anything`, i.e., `Object | Null`, which is also nullable.

#### (b) Nullity polymorphism {-}

Because Java generics are invariant, the [Checker Framework][] [Nullness Checker][] originally resorted to defining a special annotation to handle some common cases of polymorphism in type parameter nullities. E.g.,

```Java
@PolyNull T m(@PolyNull Object o) { ... }
```

The above constrains the return type of `m` to have a nullity that matches that of `o`. Since February 2015, a new form of polymorphism was introduced into the [Checker Framework][], namely the [qualifier parameters][Checker Framework qualifier parameters] mentioned in [C.5.3](#generics-alt).

#### (c) [Ceylon][] cannot represent [G2][].1 {-}

It is interesting to note that case [G2][].1 cannot be represented in [Ceylon][] due to the absence of a non-null type operator `!`:

```dart
// Ceylon
class Box<T> {
  final T _default;      // can't enforce non-null; fall back to nullity matching param.
  T value;               // nullity matching parameter (G2.3)
  ?T maybeNull() => ...; // nullable (G2.2)
  ...
}
```
