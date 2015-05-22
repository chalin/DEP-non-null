# Part A: Recovering non-null types {- #part-non-null-types}

The purpose of this part is to "recover" Dart's non-null types, in the sense that we describe next.

## A.1 Non-null types in [DartC][]

In Dart, *everything* is an object. In contrast to other mainstream languages, the term `null` refers to the null *object*, not the null *reference*. That is, `null` denotes the singleton of the `Null` class. Although built-in, `Null` is like a regular Dart class and so it is a subtype of `Object`, etc.

Given that everything is an object in Dart, and in particular that `null` is an object of type `Null` as opposed to a null *reference* then, in a sense, **[DartC][] types are already non-null**. To illustrate this, consider the following [DartC][] code:

``` {.dart .numberLines}
const Null $null = null;

void main() {
  int i = null,
      j = $null,
      k = "a-string";
  print("i = $i, j = $j, k = $k");
  print("i is ${i.runtimeType}, j is ${j.runtimeType}");
}
```

Running the [Dart Analyzer][] results in

```shell
Analyzing [null.dart]...
[warning] A value of type 'Null' cannot be assigned to a variable of type 'int' (line 5, col 11)
[warning] A value of type 'String' cannot be assigned to a variable of type 'int' (line 6, col 11)
2 warnings found.
```

### A.1.1 Static checking {#dartc-static-checking}

As is illustrated above, the `Null` type is unrelated to the type `int`. In fact, as a direct subtype of `Object`, `Null` is only related to `Object` and itself. Hence, the assignment of `$null` to `j` results in a [static warning][] just as it would for an instance of any other type (such as `String`) unrelated to `int` ([DSS][] 16.19, "Assignment", referring to an assignment *v* = *e*):

> It is a static type warning if the static type of *e* may not be assigned to the static type of *v*.

While the static type of `$null` is `Null`, the language specification has a special rule used to establish the static type of `null`. This rule makes `null` [assignment compatible][] with any type *T*, including `void` ([DSS][] 16.2, "Null"):

> The static type of `null` is $\bot$ (bottom). _(Rationale) The decision to use $\bot$ instead of `Null` allows `null` to be assigned everywhere without complaint by the static checker._

Because bottom is a subtype of every type ([DSS][] 19.7, "Type Void"), `null` can be assigned to or used as an initializer for a variable of any type, without a [static warning][] or [dynamic type error][] ([DSS][] 16.19; 19.4, "Interface Types").

### A.1.2 Checked mode execution

Execution in checked mode of the program given above results in an exception being reported only for the assignment to `k`:

```shell
> dart -c null.dart
 Unhandled exception: type 'String' is not a subtype of type 'int' of 'k'.
 #0      main (~/example/null.dart:6:11)
```

The assignment to `j` raises no exception because of this clause ([DSS][] 16.19, "Assignment", where *o* is the result of evaluating *e* in *v* = *e*):

> In checked mode, it is a dynamic type error if *o* is not `null` and the interface of the class of *o* is not a subtype of the actual type (19.8.1) of *v*.

### A.1.3 Production mode execution

Production mode execution of our sample code results in successful termination and the following output is generated:

```shell
i = null, j = null, k = a-string
i is Null, j is Null
```

Note that `Null` is the `runtimeType` of both `null` and `$null`; bottom is not a runtime type.

### A.1.4 Relations over types: `<<`, `<:`, and $\Longleftrightarrow$ {#def-subtype}

We reproduce here the definitions of essential binary relations over Dart types found in [DSS][] 19.4, "Interface Types". We will appeal to these definitions throughout the proposal.
Let *S* and *T* be types.

\label{assignment-compatible}<a name="assignment-compatible"></a>

- *T* may be _assigned to_ *S*, written  $T \Longleftrightarrow S$, iff either $T <: S$ or $S <: T$. (Let *T* be the static type of *e*. We will sometimes write "*e* may be assigned to *S*" when we mean that "*T* may be assigned to *S*". Given that this relation is symmetric, we will sometimes write that *S* and *T* are **assignment compatible**.)

- *T* is a _subtype_ of *S*, written $T <: S$, iff $[\bot/\DYNAMIC{}]T << S$.

+ $T$ is _more specific than_ $S$, written $T << S$, if one of the following conditions is met:
    - $T$ is $S$.
    - T is $\bot$.
    - S is \DYNAMIC{}.
    - $S$ is a direct supertype of $T$.
    - $T$ is a type parameter and $S$ is the upper bound of $T$.
    - $T$ is a type parameter and $S$ is \cd{Object}.
    - $T$ is of the form $I<T_1, \ldots, T_n>$ and $S$ is of the form $I<S_1, \ldots, S_n>$ and:
$T_i << S_i, 1 \le i \le n$
    - $T$ and $S$ are both function types, and $T << S$ under the rules of [DSS][] 19.5.
    - $T$ is a function type and $S$ is \cd{Function}.
    - $T << U$ and $U << S$.

## A.2 Feature details: recovering non-null types {#non-null-types}

To recover the general interpretation of a class type *T* as non-null, we propose the following changes.

### A.2.1 `Null` is the static type of `null`{} {#type-of-null}

We drop the rule that attributes a special static type to `null`, and derive the static type of `null` normally as it would be done for any constant declared of type `Null` ([DSS][] 16.2, "Null"): "[The static type of `null` is $\bot$ (bottom). _(Rationale) The decision to use $\bot$ ... checker_.][del]".

### A.2.2 `Null` may be assigned to `void`{} {#null-for-void}

As explained in [DSS][] 17.12, "Return", functions declared `void` must return _some_ value. (In fact, in production mode, where static type annotations like `void` are irrelevant, a `void` function can return _any_ value.)

In [DartC][] checked mode, `void` functions can either implicitly or explicitly return `null` without a [static warning][] or [dynamic type error][]. As was mentioned, this is because the static type of `null` is taken as $\bot$ in [DartC][]. In [DartNNBD][], we make explicit that `Null` can be _assigned to_ `void`, by establishing that `Null` is more specific than `void`  ([A.1.4](#def-subtype)): `Null << void`.

> Comment. In a sense, this makes explicit the fact that `Null` is being treated as a "carrier type" for `void` in Dart. `Null` is a [unit type][], and hence returning `null` conveys no information. The above also fixes the slight irregularity noted in [A.1.1](#dartc-static-checking): in [DartNNBD][], no [static warning][] will result from a statement like `return $null;` used inside a `void` function (where `$null` is declared as a `const Null`).

### A.2.3 Drop other special semantic provisions for `null`{} {#null-not-special}

Special provisions made for `null` in the [DartC][] semantics are dropped in [DartNNBD][], such as:

- [DSS][] 16.19, "Assignment": In checked mode, it is a dynamic type error if [*o* is not null and][del] the interface of the class of *o* is not a subtype of the actual type (19.8.1) of *v*.

- [DSS][] 17.12, "Return", e.g., for a synchronous function: it is a dynamic type error if [$o$ is not `null` and][del] the runtime type of $o$ is not a subtype of the actual return type of $f$.

We will address other similar ancillary changes to the semantics once a "critical mass" of this proposal's features have gained approval ([7](#alt-and-deliverables)).

## A.3 Discussion

As we do at the end of most parts, we discuss here topics relevant to the changes proposed in this part.

### A.3.1 Why non-null *types*? {#why-nn-types}

Of course, one can appeal to programmer discipline and encourage the use of coding idioms and design patterns as a means of avoiding problems related to `null`. For one thing, an [option type][] can be realized in most languages, as can the *Null Object* pattern ([Fowler][Null Object pattern, Fowler], [C&C][Null Object pattern, C&C]).
\label{NPE}<a name="NPE"></a>
Interestingly, Java 8's new `java.util.Optional<T>` type is being promoted as a way of avoiding `null` pointer exceptions (**NPE**s) in this Oracle Technology Network article entitled, "[Tired of Null Pointer Exceptions? Consider Using Java SE 8's Optional!][Use Java 8 Optional]".

Coding discipline can only go so far. Avoiding problems with `null` is best achieved with proper language support that enables mechanized tooling diagnostics (vs. manual code reviews). Thus, while the use of [option type][]s (or any other discipline/strategy for avoiding `null` described in the [survey](#appendix-1-review)) could be applicable to Dart, we do not give serious consideration to any language feature less expressive than non-null types. Given that there is generally _some_ effort involved on the part of developers who wish nullable and non-null types to be distinguished in their code, support for non-null _types_ offer the \label{ROI}<a name="ROI">**highest return on investment** (ROI)</a>, especially in the presence of [generics](#part-generics). Hence, we have chosen to base this proposal on non-null types rather than, e.g., non-null _declarator_ annotations ([I.2](#strategies)), which would not impact the type system. Languages like [JML][] ([I.3.1](#lang-extensions)), for example, which previously only supported nullity assertion constraints and nullity declaration modifiers, evolved to support non-null types and [NNBD][].

It is interesting to note a similar evolution in tool support for *potential "null dereference" errors* in modern (and popular) IDEs like in [IntelliJ][] and the [Eclipse JDT][]. Following conventional terminology, we will refer to such errors as [NPE][]s. As Stephan Herrmann ([Eclipse JDT][] committer) points out ([Herrmann ECE 2014, page 3][]), [NPE][]s remain the most frequent kind of exception in Eclipse. This high rate of occurrence of [NPE][]s is not particular to the [Eclipse][] code base or even to [Java][]. 

[Slide 5 of Stephan Herrmann's *Advanced Null Type Annotations* talk][Herrmann ECE 2014, page 5] summarizes the evolution of support for nullity analysis in the [Eclipse JDT][]. While initial analysis was ad hoc, the advent of Java 5 metadata allowed for the introduction of nullity annotations like `@NonNull` and `@Nullable`. Such annotations were used early on by the [Eclipse JDT][] and the popular Java linter [Findbugs][] to perform intraprocedural analysis. As of Eclipse Luna (4.4), support is provided for non-null *types* (and interprocedural analysis), and options exist for enabling [NNBD][] at various levels of granularity. Such an evolution (from ad hoc, to nullity declarator annotations, to non-null types), seems to be part of a general trend that we are witnessing in programming language evolution ([I.4](#modern-lang-nnbd)), towards features that enable efficient and effective static checking, so as to help uncover coding errors earlier---in particular through the use of non-null types, and in many cases, [NNBD][].

### A.3.2 Embracing non-null types but preserving nullable-by-default? {#nullable-by-default}

As an alternative to the changes proposed in this part, the nullable-by-default semantics of [DartC][] could be preserved in favor of the introduction of a _non-null_ meta type annotation `!`. Reasons for not doing this are given in the [*Motivation* section](#part-nnbd-motivation) of the next part.
