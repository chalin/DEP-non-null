# Part E: Miscellaneous, syntactic sugar and other conveniences {- #part-misc}

## E.1 Feature details: miscellaneous

In this section we cover some features, and present features summaries, that require concepts from all of the previous parts.

### E.1.1 Optional parameters are nullable-by-default in function bodies only {#opt-func-param}

Dart supports positional and named optional parameters, as illustrated here:

```dart
int f([int i = 0]) => i; // i is an optional positional parameter
int g({int j : 0}) => j; // j is an optional named parameter
```

Within a function's body, its optional parameters are naturally nullable, since they are initialized to `null` when no default value is provided and corresponding optional arguments are omitted at a point of call. I.e., `null` is used as a default mechanism by which missing optional arguments can be _detected_.

We adopt a *dual view* for the types of optional parameters as is explained next. Suppose that an optional parameter `p` is declared to be of the normalized type *T* ([E.1.2](#normalization)):

(a) **Within the scope of the function's body**, `p` will have static type:

    - *T* if `p`:
        - is _explicitly_ declared non-null---i.e., *T* is !*U* for some *U*;
        - has no meta type annotation, and has a non-null default value (see [E.1.1.1](#non-null-init));
        - is a field parameter (see [E.1.1.2](#field-param)).
    - ?*T* otherwise. (Note that if *T* has type arguments, then the
      interpretation of the nullity of these type arguments is not affected.)

(b) **In any other context**, the type of `p` is *T*.

\label{guideline}<a name="guideline"></a>
This helps enforce the following **guideline**: from a caller's perspective, an optional parameter can either be _omitted_, or given a value matching its declared type.

> Comments:
>
> - E.g., one can invoke `f`, defined above, as either `f()` or `f(1)`, but `f(null)` would result in a [static warning][] and [dynamic type error][].
> - Just like for any other declaration, an optional parameter can be marked as nullable. So `f([?int j])` would permit `f(null)` without warnings or errors.
> - Explicitly marking an optional parameter as non-null, e.g., `int h([!int i = 0]) => i`, makes it non-null in both views. But, if a non-null default value is not provided, then a [static warning][] and [dynamic type error][] will be reported.
> - *T*, the type of `p`, might implicitly be `dynamic` if no static type annotation is given ([D.2](#dynamic)). By the rules above, `p` has type `?dynamic`, i.e., `dynamic` ([D.2.1](#dynamic-and-type-operators)), in the context of the declaring function's body. Hence, a caveat is that we cannot declare `p` to have type `dynamic` in the function body scope and type `!dynamic` otherwise.
> - The dual view presented here is an example of an application of [G0, utility](#g0-utility). This is further discussed, and an alternative is presented, in [E.3.3](#opt-param-alt).
> - Also see [E.3.4](#function-subtype) for a discussion of function subtype tests.

#### E.1.1.1 Optional parameters with non-null initializers are non-null {#non-null-init}

In Dart, the initializer of an optional parameter must be a compile time constant ([DSS][] 9.2.2). Thus, in support of [G0, ease migration](#g0), an optional parameter with a non-null default value is considered non-null.

#### E.1.1.2 Default field parameters are single view {#field-param}

Dart field constructor parameters can also be optional, e.g.:

```dart
class C {
  num n;
  C([this.n]);
  C.fromInt([int this.n]);
}
```

While `this.n` may have a type annotation (as is illustrated for the named constructor `C.fromInt()`), the notion of dual view does not apply to optional field parameters since they do not introduce a new variable into the constructor body scope.

### E.1.2 Normalization of type expressions {#normalization}

A _normalized_ type expression has no _superfluous_ applications of a type operator ([B.3.1](#semantics-of-maybe), [B.3.2](#semantics-of-bang)).

Let *P* be a type parameter name and *N* a non-null class type, *N* `<: Object`. In all contexts where [NNBD][] applies ([E.3.1](#nnbd-scope)), the following type expressions, used as static type annotations or type arguments, are in _normal form_:

- *N*, and ?*N*
- *P*, ?*P*, and !*P*
- `dynamic` and `!dynamic`
- `Null`

In the context of an optional function parameter `p` as viewed from within the scope of the declaring function body ([E.1.1](#opt-func-param)(a)), the following is also a normal form (in addition to the cases listed above): !*N*.

> Comment. Excluded are `void`, to which type operators cannot be applied ([B.3.1](#semantics-of-maybe), [B.3.2](#semantics-of-bang)), `?dynamic`, `?Null` and various repeated and/or canceling applications of `?` and `!` ([B.3](#nnbd-semantics)).

## E.2 Feature details: syntactic sugar and other conveniences {#sugar}

We define various syntactic sugars and other syntactic conveniences in this section. Being conveniences, they are **not essential to the proposal** and their eventual adoption may be subject to an "applicability survey", in particular through analysis of existing code.

### E.2.1 Non-null `var`{}

While `var x` introduces `x` with static type `dynamic`, we propose that `var !x` be a shorthand for `!dynamic x`. Note that this shorthand is applicable to all kinds of variable declaration as well as function parameters.

### E.2.2 Formal type parameters

In [C.3.4](#default-type-param-bound) we defined the default type parameter upper bound as `?Object`; i.e., `class Box<T>` is equivalent to `class Box<T extends ?Object>`. We define `class Box<T!>` as a shorthand for `class Box<T extends Object>`. Note that `!` is used as a _suffix_ to `T`; though it is a meta type annotation _prefix_ to the implicit `Object` type upper bound.

> Comment. We avoid suggesting `class Box<!T>` as a sugar because it opens the door to `class Box<?T>` and `class Box<?T extends Object>`. The latter is obviously be an error, and for novices the former might lead to confusion about the meaning of an undecorated type parameter `class Box<T>` (which could quite reasonably arise if there is a lack of understanding of the scope of the [NNBD][] rule). Also, `class Box<!T>` would conflict with the use of the same notation for the purpose of excluding `Null` type arguments ([C.5.3](#type-param-not-null)).


### E.2.3 Non-null type arguments

We define `!` as a shorthand for `!dynamic` when used as a type argument as in

```dart
List listOfNullableAny = ...
List<!> listOfNonnullAny = ...
```

### E.2.4 Non-null type cast

The following extension of type casts ([DSS][] 16.34, "Type Cast") allows an expression to be projected into its non-null type variant, if it exists. Let *e* have the static type *T*, then *e* `as! Null` has static type !*T*.

> Comments:
>
> - If *T* is outside the domain of `!`, then !*T* is malformed ([B.3.2](#semantics-of-bang)).
> - Syntactic ambiguity, between `as!` and a cast to a non-null type !*T*, is addressed as it was for type tests ([B.2.4](#type-test-ambiguity)).
> - In the presence of union types, `as!` might be generalized as follows. If the static type of *e* is the (normalized) union type *U* | *T*, then the static type of *e* `as!` *U* could be defined as *T*.

## E.3 Discussion

### E.3.1 Scope of [NNBD][] in [DartNNBD][] {#nnbd-scope}

We clarify here the scope of [NNBD][] as defined in this proposal. This will be contrasted with the scope of [NNBD][] in other languages or frameworks in ([E.3.2](#discussion-nnbd-scope)).

(a) The [NNBD][] rule states that for _all_ class types *T* `<: Object`, it is false that `Null` can be _assigned to_ *T* ([A.1.4](#def-subtype)). This includes class types introduced via function signatures in the context of a

    - Formal parameter declaration---these are anonymous class types
      ([B.2.6](#nnbd-function-sig)).
    - `typedef`---these are named, possibly generic, class types
      ([DSS][] 19.3, "Type Declarations").

    Thus *T*, unadorned with any type operator, (strictly) represents
    instances of *T* (excluding `null`).

(b) The [NNBD][] rule applies to **class types** _only_. In particular, it does **not** apply to:

    - Type parameters ([Part C](#part-generics)).
    - Implicit or explicit occurrences of `dynamic` ([D.2](#dynamic)).

(c) The [NNBD][] rule applies in _all_ contexts where a class type is _explicitly_ given, _except one_: static type annotations of optional function parameters as viewed from within the scope of the declaring function's body ([E.1.1](#opt-func-param)).

### E.3.2 Scope of [NNBD][] in other languages or frameworks {#discussion-nnbd-scope}

In contrast to this proposal, the scope of the [NNBD][] rule in other languages or frameworks often has more exceptions. This is the case for [Spec#][] ([Fahndrich and Leino, 2003][]), [JML][] ([Chalin et al., 2008][]) and Java enhanced with nullity annotations from the [Checker Framework][]. Next, we compare and contrast [DartNNBD][] with the latter, partly with the purpose of justifying the language design decisions made in this proposal, and implicitly for the purpose of presenting potential alternatives for [DartNNBD][].

The Java [Checker Framework][] has a principle named [CLIMB-to-top][Checker Framework CLIMB-to-top] which, in the case of the [Nullness Checker][], means that types are interpreted as _nullable-by-default_ in the following contexts:

- Casts,
- Locals,
- Instanceof, and
- iMplicit (type parameter) Bounds

(CLIMB). We adhere to this principle for _implicit_ type parameter bounds ([C.3.4](#default-type-param-bound)) and discuss other cases next.

#### (a) Local variables {- #local-var-alt}

When retrofitting a strongly (mandatorily) typed nullable-by-default language (like Java) with [NNBD][] it is common to relax [NNBD][] for local variables since standard flow analysis can determine if a local variable is potentially `null` or not, and to do otherwise would result in the need to annotate many local variables as nullable. Unfortunately, excluding local variables from the scope of [NNBD][] is at the cost of loss of a form of _referential transparency_: consider the following declaration

```dart
List<String> guestList;
```

Is `guestList` nullable? In the [Checker Framework][], it is not possible to tell without knowing the context: `guestList` is [NNBD][] if this is a (package) field declaration, but nullable if it is a local variable.

In contrast, static type annotations are optional in Dart, and a common idiom is to omit them for local variables. This idiom is in fact prescribed in the [Dart Style Guide][] section on [type annotations][Dart Style Guide, var]:

> PREFER using `var` without a type annotation for local variables.

In light of this idiom, if a developer goes out of his or her way to write an explicit static type annotation, then we believe that the type should be interpreted literally; it is for this reason that we have chosen to include local variable declarations in the scope of [NNBD][] ([B.3.4](#var-init), [B.4.2](#var-init-alt)(a)). As a benefit, we retain referential transparency for all ([non-optional](#opt-func-param)) variable declaration kinds---in particular instance variables and local variables.

As applied to local variables, the [NNBD][] rule of this proposal may result in extra warnings when [DartC][] code is migrated to [DartNNBD][], but such warnings will _not_ prevent the code from being executed in production mode---in strongly typed languages like Java, such migrated code would simply _not run_, and so our approach would not be a realistic alternative. Also, in the case of Dart code migration, tooling can contribute to the elimination of such warnings by automatically annotating explicitly typed local variables determined to be nullable ([G0, ease migration](#g0)). The strategy proposed in [E.3.6](#local-var-analysis) can also help reduce warnings.

#### (b) Type tests {-}

In [DartC][], the type test expression *e* `is` *T* holds only if the result of evaluating *e* is a value *v* that is an instance of *T* ([DSS][] 16.33, "Type Test"). Hence, in [DartNNBD][], this naturally excludes `null` for all *T* `<: Object`.

#### (c) Type casts {-}

Out of the 150K physical [Source Lines Of Code (SLOC)][sloccount] of the Dart SDK libraries, there are only 30 or so occurrences of the `as` operator and most clearly assume that their first operand is non-null. Based on such a usage profile, and for reasons similar to those given for local variables (i.e., explicitly declared types interpreted literally), we have chosen to include Dart type casts in the scope of the [NNBD][] rule.

#### Broad applicability of [NNBD][] rule for [DartNNBD][] {-}

While balancing all [G0](#g0) language design goals, we have chosen to make the [NNBD][] rule as broadly applicable as possible, thus making the language simpler and hence increasing [G0, usability](#g0).

### E.3.3 Optional parameters are always nullable-by-default, an alternative {#opt-param-alt}

The "dual view" semantics proposed above ([E.1.1](#opt-func-param)) for optional parameters is an example of a language design feature which is slightly more complex (and hence penalizes [G0, usability](#g0)) but which we believe offers more utility ([G0, utility](#g0-utility)). A simpler alternative is to adopt (a) as the sole view: i.e., optional parameters would be nullable-by-default in all contexts.

### E.3.4 Subtype relation over function types unaffected by nullity {#function-subtype}

In contexts were a function's type might be used to determine if it is a subtype of another type, then optional parameters are treated as [NNBD][] (view [E.1.1](#opt-func-param)(b)). But as we explain next, whether optional parameter semantics are based on a "dual" ([E.1.1](#opt-func-param)) or "single" ([E.3.3](#opt-param-alt)) view, this will have no impact on subtype tests.

Subtype tests of function types ([DSS][] 19.5 "Function Types") are structural, in that they depend on the types of parameters and return types ([DSS][] 6, "Overview"). Nullity type operators have no bearing on function subtype tests. This is because the subtype relation over function types is defined in terms of the "assign to" ($\Longleftrightarrow$) relation over the parameter and/or return types. The "assign to" relation ([A.1.4](#def-subtype)), in turn, is unaffected by the nullity: if types *S* and *T* differ only in that one is an application of `?` over the other, then either *S* `<:` *T* or *T* `<:` *S* and hence *S* $\Longleftrightarrow$ *T*. Similar arguments can be made for `!`.

### E.3.5 Catch target types and meta type annotations {#catch-type-qualification}

The following illustrates a try-catch statement:

```dart
class C<T> {}
main() {
  try {
    ...
  } on C<?num> catch (e) {
    ...
  }
}
```

Given that `null` cannot be thrown ([DSS][] 16.9), it is meaningless to have a catch target type qualified with `?`; a [static warning][] results if `?` is used in this way. Any such qualification is ignored at runtime. Note that because meta type annotations are reified ([C.4](#semantics-of-generics)), they can be meaningfully applied to catch target type arguments as is illustrated above.

### E.3.6 Reducing the annotation burden for local variables, an alternative {#local-var-analysis}

This section expands on [B.3.4.c](#var-local-init).2. We propose as an alternative that standard read-before-write analysis be used for non-null _local variables_ without an explicit initializer, to determine if its default initial value of `null` has the potential of being read before the variable is initialized.

Consider the following illustration of a common coding idiom:

```dart
int v; // local variable left uninitialized
if (...) {
  // possibly nested conditionals, each initializing v
} else {
  // possibly nested conditionals, each initializing v
}
// v is initialized to non-null by this point
```

Without the feature described in this subsection, `v` would need to be declared nullable.

### E.3.7 Dart Style Guide on `Object` vs. `dynamic`{} {#style-guide-object}

The [Dart Style Guide][] recommends [DO annotate with `Object` instead of `dynamic` to indicate any object is accepted][Dart Style Guide, Object vs dynamic]. Of course, this will need to be adapted to recommend use of `?Object` instead.
