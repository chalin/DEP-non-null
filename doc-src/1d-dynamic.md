# Part D: Dealing with `dynamic` and missing static type annotations {- #part-dynamic}

## D.1 Type `dynamic` in [DartC][]

In [DartC][], `dynamic`

- "denotes the _unknown type_" ([DSS][] 19.6, "Type dynamic"), and
- is a supertype of all types ([DSS][] 19.7, "Type Void").

The type `dynamic` is used/assumed when, e.g.:

- A type is malformed ([DSS][] 19.1, "Static Types").
- No static type annotation is provided, or type arguments are missing ([DSS][] 19.6, "Type dynamic").
- An incorrect number of type arguments are provided for a generic class ([DSS][] 19.8, "Parameterized Types").

## D.2 Feature details: dynamic {#dynamic}

The [DartC][] role and static and dynamic semantics of `dynamic` are preserved in [DartNNBD][].

### D.2.1 `!dynamic` is the unknown non-null type, and `?dynamic` is `dynamic`{} {#dynamic-and-type-operators}

The authors of [Ceylon][] suggest that its `Anything` type [can be interpreted][Ceylon important types explained] as a union of all possible types. Such an interpretation leads to a natural understanding of the meaning of `dynamic` possibly decorated with the type operators `?` and `!`:

- `dynamic`, _the_ unknown type, can be interpreted as the union of all types, and hence the supertype of all types.
- `!dynamic` can be interpreted as the union of all _non-null_ types, and hence a supertype of all non-null types.
- `?dynamic` = `dynamic` | `Null` = `dynamic`.

Thus, `T << !dynamic` precisely when `T << Object` ([A.1.4](#def-subtype)). It follows that `T <: !dynamic` for any class type *T* other than `Null` and `_ObjectOrNull`.

> Comment. From another perspective, we can say that `!dynamic` represents an unknown non-null type rooted at `Object`, and `?dynamic` represents an unknown type rooted at `_ObjectOrNull`.

### D.2.2 Defining `!dynamic <:` *S* {#bang-dynamic-subtype-of}

Let $T$ and $S$ be normalized types ([E.1.2](#normalization)). We introduce, $\botObject$ to represent the bottom element of the non-null type subhierarchy and add the following as one of the conditions to be met for $T << S$ to hold ([A.1.4](#def-subtype)):

> $T$ is $\botObject$ and $S << \cd{Object}$.

We refine `<:` in the following backwards compatible manner: $T <: S$ iff

> $[\bot/\DYNAMIC{}]U << S$ where $U = [\botObject/!\DYNAMIC{}]T$.

See [D.3.3](#bang-dynamic-subtype-of-alt) for a discussion and alternative.

## D.3 Discussion

### D.3.1 Clarification of the semantics of `T extends !dynamic`{} {#extends-bang-dynamic}

As a point of clarification, we note that a generic class declared with a type parameter `T extends !dynamic`:

- is equivalent to `T extends Object`, except that;
- for the purpose of static checking, *T* is treated as an unknown type.

This is semantically consistent with the manner in which `T extends dynamic` is treated in [DartC][].

### D.3.2 Semantics for `dynamic`, an alternative {#dynamic-alt}

The main alternative relevant to this part, consists of interpreting an undecorated occurrence of `dynamic` as `!dynamic`. This would broaden the scope of the [NNBD][] rule to encompass `dynamic`.

This corresponds to the choice made in the [Kotlin][] language which has types `Any` and `Any?` as representative of "any non-null type", and "any type", respectively. Notice how the unadorned type `Any` is non-null.

The main disadvantage of this alternative is that [static warning][]s could be reported for programs without any static type annotations---such as for the statement `var o = null`, because the static type of `o` would be `!dynamic`. This goes contrary to [G0, optional types](#g0).

### D.3.3 Defining `!dynamic <:` *S*, an alternative {#bang-dynamic-subtype-of-alt}

The [DartC][] definition of the subtype relation ([A.1.4](#def-subtype)) states that *S* `<:` *T* iff

> $[\bot/\DYNAMIC{}]S << T$.

Replacing `dynamic` by $\bot$ ensures that expressions having the static type `dynamic` can "be assigned everywhere without complaint by the static checker" ([DSS][] 16.2, "Null"), and that `dynamic` is a valid type argument for any type parameter.

The refined definitions of `<<` and `<:` given in [D.2.2](#bang-dynamic-subtype-of) allows `!dynamic` to be:

- Assigned everywhere a non-`Null` type is expected without complaint by the static checker,  and;
- Used as a valid type argument for any non-`Null` type parameter.

Introducing a new bottom element for the `Object` subhierarchy most accurately captures our needs thought it renders the semantics more complex, decreasing [G0, usability](#g0) and increasing tool reengineering costs.

An alternative, allowing us to avoid this extra complexity, is to treat `!dynamic` simply as $\bot$. What we loose, are [static warning][]s and/or [dynamic type error][]s when: an expression of the static type `!dynamic` is assigned to variable declared as `Null` and, when `!dynamic` is used as a type argument for a `Null` type parameter. But such uses of `Null` are likely to be rare.
