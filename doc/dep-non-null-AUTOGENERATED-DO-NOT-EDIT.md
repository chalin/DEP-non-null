# Dart DEP for Non-null Types and Non-null By Default (NNBD)
### Patrice Chalin, [chalin@dsrg.org](mailto:chalin@dsrg.org)
#### 2015-06-25 (0.5.1) - [revision history](#revision-history)

-   [Non-null Types and Non-null By Default (NNBD)](#part-main)
    -   [Contact information](#contact-information)
    -   [1 Introduction](#introduction)
    -   [2 Motivation](#motivation)
        -   [2.1 Dart: improving compilation to JavaScript](#dart-improving-compilation-to-javascript)
        -   [2.2 Precedent: modern web/mobile languages with non-null types and](#precedent)[NNBD](#part-nnbd "Non-Null By Default")
    -   [3 Normative reference, terms and notation](#terms)
    -   [4 Impact, examples and benefits: a first look](#first-look)
    -   [5 Language design goals](#goals)
    -   [6 Proposal details](#proposal-details)
    -   [7 Alternatives and deliverables](#alt-and-deliverables)
    -   [8 Executive summary](#executive-summary)
        -   [8.1 Language updates and additions](#lang-changes)
        -   [8.2 What is unchanged?](#what-is-unchanged)
        -   [8.3 Summary of alternatives and discussions](#alternatives)
        -   [8.4 Assessment of goals](#goal-assessment)
-   [Part A: Recovering non-null types](#part-non-null-types)
    -   [A.1 Non-null types in](#a.1-non-null-types-in-dartc)[DartC](#terms "Classic (i.e., current) Dart")
        -   [A.1.1 Static checking](#dartc-static-checking)
        -   [A.1.2 Checked mode execution](#a.1.2-checked-mode-execution)
        -   [A.1.3 Production mode execution](#a.1.3-production-mode-execution)
        -   [A.1.4 Relations over types: `<<`, `<:`, and <span class="math"> ⇔ </span>](#def-subtype)
    -   [A.2 Feature details: recovering non-null types](#non-null-types)
        -   [A.2.1 `Null` is the static type of `null`](#type-of-null)
        -   [A.2.2 `Null` may be assigned to `void`](#null-for-void)
        -   [A.2.3 Drop other special semantic provisions for `null`](#null-not-special)
    -   [A.3 Discussion](#a.3-discussion)
        -   [A.3.1 Why non-null *types*?](#why-nn-types)
        -   [A.3.2 Embracing non-null types but preserving nullable-by-default?](#nullable-by-default)
-   [Part B: Non-null by default (NNBD)](#part-nnbd)
    -   [B.1 Motivation: nullable-by-default increases migration effort](#part-nnbd-motivation)
    -   [B.2 Feature details: non-null by default](#nnbd)
        -   [B.2.1 Ensuring `Object` is non-null: elect `_Anything` as a new root](#new-root)
        -   [B.2.2 Nullable type operator `?`](#nullable-type-op)
        -   [B.2.3 Non-null type operator `!`](#non-null-type-op)
        -   [B.2.4 Resolution of negated type test (`is!`) syntactic ambiguity](#type-test-ambiguity)
        -   [B.2.5 Syntax for nullable factory constructors](#factory-constructors)
        -   [B.2.6 Syntax for nullable parameters declared using function signature syntax](#nnbd-function-sig)
    -   [B.3 Semantics](#nnbd-semantics)
        -   [B.3.1 Semantics of `?`](#semantics-of-maybe)
            -   [(a) Union type interoperability](#uti)
            -   [(b) Core properties of `?`](#b-core-properties-of)
        -   [B.3.2 Semantics of `!`](#semantics-of-bang)
        -   [B.3.3 Runtime representation of type operators and other shared semantics](#shared-type-op-semantics)
        -   [B.3.4 Default initialization of non-null variables is like](#var-init)[DartC](#terms "Classic (i.e., current) Dart")
        -   [B.3.5 Adjusted semantics for “assignment compatible” (<span class="math"> ⇔ </span>)](#new-assignment-semantics)
        -   [B.3.6 Static semantics of members of ?T](#multi-members)
    -   [B.4 Discussion](#b.4-discussion)
        -   [B.4.1 Precedent:](#ceylon-root)[Ceylon](http://ceylon-lang.org)’s root is `Object` | `Null`
        -   [B.4.2 Default initialization of non-null variables, alternative approaches](#var-init-alt)
            -   [(a) Preserving](#a-preserving-dartc-semantics-is-consistent-with-javascript-typescript)[DartC](#terms "Classic (i.e., current) Dart") semantics is consistent with JavaScript & TypeScript
            -   [(b) Implicit type-specific initialization of non-null variables](#type-specific-init)
        -   [B.4.3 Factory constructors, an alternative](#factory-constructor-alt)
        -   [B.4.4 Dealing with `!Null`, alternatives](#semantics-of-bang-alt)
        -   [B.4.5 Resolution of negated type test (`is!`) syntactic ambiguity, an alternative](#type-test-ambiguity-alt)
        -   [B.4.6 Encoding `?` and `!` as metadata](#type-anno-alt)
        -   [B.4.7 Ensuring `Object` is non-null: making `Null` a root too](#object-not-nullable-alt)
-   [Part C: Generics](#part-generics)
    -   [C.1 Motivation: enhanced generics through non-null types](#c.1-motivation-enhanced-generics-through-non-null-types)
    -   [C.2 Design goals for this part](#generics-design-goals)
        -   [G1: Support three kinds of formal type parameter](#generics-g1)
        -   [G2: Support three kinds of type parameter expression in a class body](#generics-g2)
        -   [Running example](#running-example)
    -   [C.3 Feature details: generics](#generics)
        -   [C.3.1 Maybe-nullable formal type parameter, case](#generic-param-maybe-null)[G1](#generics-g1).3
        -   [C.3.2 Nullable formal type parameter, case](#generics-g1-2)[G1](#generics-g1).2
        -   [C.3.3 Non-null formal type parameter, case](#generic-param-non-null)[G1](#generics-g1).1
        -   [C.3.4 Default type parameter upper bound is `?Object`](#default-type-param-bound)
    -   [C.4 Semantics](#semantics-of-generics)
    -   [C.5 Discussion](#c.5-discussion)
        -   [C.5.1 Loss of expressivity due to union type interoperability, an alternative](#nullable-type-op-alt)
        -   [C.5.2 Lower bounds to distinguish nullable/maybe-nullable parameters](#lower-bound-for-maybe)
        -   [C.5.3 Statically constraining a type parameter to be nullable but *not* `Null`](#type-param-not-null)
        -   [C.5.4 Parametric nullity abstraction, an alternative approach to generics](#generics-alt)
        -   [C.5.5 Generics and nullity in other languages or frameworks](#generics-related-work)
            -   [(a) Default type parameter upper bound](#a-default-type-parameter-upper-bound)
            -   [(b) Nullity polymorphism](#b-nullity-polymorphism)
            -   [(c)](#c-ceylon-cannot-represent-g2.1)[Ceylon](http://ceylon-lang.org) cannot represent [G2](#generics-g2).1
-   [Part D: Dealing with `dynamic` and missing static type annotations](#part-dynamic)
    -   [D.1 Type `dynamic` in](#d.1-type-dynamic-in-dartc)[DartC](#terms "Classic (i.e., current) Dart")
    -   [D.2 Feature details: dynamic](#dynamic)
        -   [D.2.1 `!dynamic` is the unknown non-null type, and `?dynamic` is `dynamic`](#dynamic-and-type-operators)
        -   [D.2.2 Defining `!dynamic <:` *S*](#bang-dynamic-subtype-of)
    -   [D.3 Discussion](#d.3-discussion)
        -   [D.3.1 Clarification of the semantics of `T extends !dynamic`](#extends-bang-dynamic)
        -   [D.3.2 Semantics for `dynamic`, an alternative](#dynamic-alt)
        -   [D.3.3 Defining `!dynamic <:` *S*, an alternative](#bang-dynamic-subtype-of-alt)
-   [Part E: Miscellaneous, syntactic sugar and other conveniences](#part-misc)
    -   [E.1 Feature details: miscellaneous](#e.1-feature-details-miscellaneous)
        -   [E.1.1 Optional parameters are nullable-by-default in function bodies only](#opt-func-param)
            -   [E.1.1.1 Optional parameters with non-null initializers are non-null](#non-null-init)
            -   [E.1.1.2 Default field parameters are single view](#field-param)
        -   [E.1.2 Normalization of type expressions](#normalization)
    -   [E.2 Feature details: syntactic sugar and other conveniences](#sugar)
        -   [E.2.1 Non-null `var`](#e.2.1-non-null-var)
        -   [E.2.2 Formal type parameters](#e.2.2-formal-type-parameters)
        -   [E.2.3 Non-null type arguments](#e.2.3-non-null-type-arguments)
        -   [E.2.4 Non-null type cast](#e.2.4-non-null-type-cast)
    -   [E.3 Discussion](#e.3-discussion)
        -   [E.3.1 Scope of](#nnbd-scope)[NNBD](#part-nnbd "Non-Null By Default") in [DartNNBD](#terms "Dart as defined in this proposal with Non-Null By Default semantics")
        -   [E.3.2 Scope of](#discussion-nnbd-scope)[NNBD](#part-nnbd "Non-Null By Default") in other languages or frameworks
            -   [(a) Local variables](#local-var-alt)
            -   [(b) Type tests](#b-type-tests)
            -   [(c) Type casts](#c-type-casts)
            -   [Broad applicability of](#broad-applicability-of-nnbd-rule-for-dartnnbd)[NNBD](#part-nnbd "Non-Null By Default") rule for [DartNNBD](#terms "Dart as defined in this proposal with Non-Null By Default semantics")
        -   [E.3.3 Optional parameters are always nullable-by-default, an alternative](#opt-param-alt)
        -   [E.3.4 Subtype relation over function types unaffected by nullity](#function-subtype)
        -   [E.3.5 Catch target types and meta type annotations](#catch-type-qualification)
        -   [E.3.6 Reducing the annotation burden for local variables, an alternative](#local-var-analysis)
        -   [E.3.7 Dart Style Guide on `Object` vs. `dynamic`](#style-guide-object)
-   [Part F: Impact on Dart SDK libraries](#part-libs)
    -   [F.1 Examples](#f.1-examples)
        -   [F.1.1 `int.dart`](#int-nnbd)
        -   [F.1.2 Iterable](#iterable-nnbd)
        -   [F.1.3 `Future<T>`](#f.1.3-futuret)
    -   [F.2 Suggested library improvements](#better-libs)
        -   [F.2.1 Iterator](#f.2.1-iterator)
            -   [](#dartc)[DartC](#terms "Classic (i.e., current) Dart")
            -   [](#dartnnbd)[DartNNBD](#terms "Dart as defined in this proposal with Non-Null By Default semantics")
        -   [F.2.2 `List<E>`](#f.2.2-liste)
            -   [`factory List<E>([int length])`](#factory-listeint-length)
            -   [`List<E>.length=`](#liste.length)
    -   [F.3 Other classes](#f.3-other-classes)
        -   [Object](#object)
-   [Part G: Migration strategy (sketch)](#part-migration)
    -   [G.1 Precedent](#g.1-precedent)
    -   [G.2 Migration aids](#g.2-migration-aids)
    -   [G.3 Impact](#g.3-impact)
    -   [G.4 Migration steps](#g.4-migration-steps)
    -   [G.5 Migration plan details](#g.5-migration-plan-details)
-   [Appendix I. Nullity in programming languages, an abridged survey](#appendix-1-review)
    -   [I.1 Languages without null](#i.1-languages-without-null)
    -   [I.2 Strategies for dealing with null in null-enabled languages](#strategies)
    -   [I.3 Retrofitting a null-enabled language with support for non-null](#retrofit)
        -   [I.3.1 Language extensions](#lang-extensions)
            -   [(a) Contracts](#a-contracts)
            -   [(b) Non-null declarators](#b-non-null-declarators)
            -   [(c) Non-null types](#c-non-null-types)
        -   [I.3.2 Language evolution](#language-evolution)
    -   [I.4 Modern web/mobile languages with non-null types and](#modern-lang-nnbd)[NNBD](#part-nnbd "Non-Null By Default")
-   [Appendix II. Tooling and preliminary experience report](#appendix-tooling)
    -   [II.1 Variant of proposal implemented in the Dart Analyzer](#proposal-variant)
    -   [II.2 Dart Analyzer](#ii.2-dart-analyzer)
        -   [II.2.1 Design outline](#ii.2.1-design-outline)
            -   [(a) AST](#a-ast)
            -   [(b) Element model](#b-element-model)
            -   [(c) Resolution](#c-resolution)
        -   [II.2.2 Source code and change footprint](#analyzer-code-changes)
        -   [II.2.3 Status](#analyzer-status)
    -   [II.3 Preliminary experience report](#experience-report)
        -   [II.3.1 Nullity annotation density](#ii.3.1-nullity-annotation-density)
        -   [II.3.2 Dart SDK library](#ii.3.2-dart-sdk-library)
        -   [II.3.3 Sample projects](#ii.3.3-sample-projects)
-   [Revision History](#revision-history)
    -   [2016.02.24 (0.5.0)](#section)

<a name="part-main"></a>
# Non-null Types and Non-null By Default (NNBD)

<a name="contact-information"></a>
## Contact information

-   [Patrice Chalin](https://plus.google.com/+PatriceChalin), @[chalin](https://github.com/chalin), <chalin@dsrg.org>
-   **[DEP](https://github.com/dart-lang/dart_enhancement_proposals) home**: [github.com/chalin/DEP-non-null](https://github.com/chalin/DEP-non-null).
-   **Additional stakeholders**:
    -   Leaf Petersen, @[leafpetersen](https://github.com/leafpetersen), [Dart Dev Compiler](https://github.com/dart-lang/dev_compiler) team.

<a name="introduction"></a>
## 1 Introduction

In this [DEP](https://github.com/dart-lang/dart_enhancement_proposals) we propose [4 *core* updates and additions](#lang-changes) to the language allowing us to [naturally recover](#part-non-null-types) a [**non-null-by-default** (NNBD)](#part-nnbd) interpretation of Dart *class types*. That is, *generally speaking*, an unadorned class type *T* will represent the *non-null* type consisting (strictly) of instances of *T*. When needed, the *meta type annotation* `?` can be used; ?*T* denotes the *nullable* type derived from *T*, consisting of values from *T* or `null`.

Careful consideration has been given to [language design goals (Section 5)](#goals) during the writing of this proposal. For example, this proposal fully preserves the optional nature of static type annotations.

The scope of this proposal [includes](#proposal-details): generics ([Part C](#part-generics)); dealing with `dynamic` and missing static type annotations ([Part D](#part-dynamic)); miscellaneous features including syntactic sugar ([Part E](#part-misc)); preliminary impact on the Dart SDK libraries ([Part F](#part-libs)), and finally a migration strategy ([Part G](#part-migration)).

TL;DR: the [*executive summary* of updates and additions (Section 8.1)](#lang-changes) fits in 3/4 of a page.

<a name="motivation"></a>
## 2 Motivation

<a name="dart-improving-compilation-to-javascript"></a>
### 2.1 Dart: improving compilation to JavaScript

Being able to **compile Dart into compact and efficient JavaScript** ([JS](https://developer.mozilla.org/en-US/docs/Web/JavaScript "JavaScript")) is paramount, possibly even more so given the Dart news *[Dart for the Entire Web](http://news.dartlang.org/2015/03/dart-for-entire-web.html)*, March 25, 2015 (emphasis mine):

> In order to do what’s best for our users and the web, and not just Google Chrome, we will **focus our web efforts on compiling Dart to JavaScript**. We have decided **not to integrate the Dart VM into Chrome**.

[NNBD](#part-nnbd "Non-Null By Default") allows compilers and VMs to perform important optimizations. For example, under the current *nullable-by-default* semantics, the [Dart Dev Compiler](https://github.com/dart-lang/dev_compiler) (DDC) translates this Dart fragment:

``` java
return (a + b) * a * b;  // a and b are declared as int
```

into this [JS](https://developer.mozilla.org/en-US/docs/Web/JavaScript "JavaScript"):

``` javascript
return dart.notNull(dart.notNull((dart.notNull(a) + dart.notNull(b)))
     * dart.notNull(a)) * dart.notNull(b);
```

as is pointed out in [DDC issue \#64](https://github.com/dart-lang/dev_compiler/issues/64). Under [NNBD](#part-nnbd "Non-Null By Default"), the `dart.notNull()` wrappers become unnecessary, so that the Dart and corresponding [JS](https://developer.mozilla.org/en-US/docs/Web/JavaScript "JavaScript") would be identical. (We ignore here the issue of finite vs. arbitrary precision numerics, as it is both orthogonal to, and outside the scope of this proposal.)

Interest in non-null types for Dart and related projects has been manifested in:

-   [Dart issue \#22](https://code.google.com/p/dart/issues/detail?id=22 "Support non-nullable types"), starred by 198 individuals, is a request for *support for non-nullable types*.
-   Bob Nystrom’s 2011 strawman *[proposal for Null-safety in Dart](http://journal.stuffwithstuff.com/2011/10/29/a-proposal-for-null-safety-in-dart)* suggested the use of non-null types and [NNBD](#part-nnbd "Non-Null By Default"). Unfortunately, at the time, the language committee was busy with other issues that took precedence.
-   [Chrome V8](https://developers.google.com/v8/) team is giving thought to [NNBD](#part-nnbd "Non-Null By Default") for [JS](https://developer.mozilla.org/en-US/docs/Web/JavaScript "JavaScript"); see [Experiments with Strengthening JavaScript](https://developers.google.com/v8/experiments), especially p. 39 (the second to last page) of [JSExperimentalDirections](https://drive.google.com/file/d/0B1v38H64XQBNT1p2XzFGWWhCR1k/view).
-   Finally, non-null types are on [Lasse R.H. Nielsen’s 2014 wish list](https://groups.google.com/a/dartlang.org/d/msg/misc/8Uchi3bW1YQ/WnVkaDDmvzUJ), and so far, almost half of his wishes have either come true or are the subject of a [DEP](https://github.com/dart-lang/dart_enhancement_proposals) ;).

<a name="precedent"></a>
### 2.2 Precedent: modern web/mobile languages with non-null types and [NNBD](#part-nnbd "Non-Null By Default")

Programming languages, many recently released, that are relevant to web applications (either dialects of [JS](https://developer.mozilla.org/en-US/docs/Web/JavaScript "JavaScript") or that compile to [JS](https://developer.mozilla.org/en-US/docs/Web/JavaScript "JavaScript")) and/or mobile, and that support *non-null types* and [NNBD](#part-nnbd "Non-Null By Default") include:

| Language                                            | About                                                                                                                                                                        | v1.0?  | Nullable via                                            | Reference                                                                                                                                                                        |
|-----------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------|---------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [Ceylon](http://ceylon-lang.org) (Red Hat)          | Compiles to [JS](https://developer.mozilla.org/en-US/docs/Web/JavaScript "JavaScript"), [Java Bytecode](http://en.wikipedia.org/wiki/Java_bytecode "Java Bytecode") (**JB**) | 2013Q4 | *T*?                                                    | [Ceylon optional types](http://ceylon-lang.org/documentation/1.1/tour/basics/#optional_types)                                                                                    |
| [Fantom](http://fantom.org)                         | Compiles to [JS](https://developer.mozilla.org/en-US/docs/Web/JavaScript "JavaScript"), [JB](http://en.wikipedia.org/wiki/Java_bytecode "Java Bytecode"), .Net CLR           | 2005   | *T*?                                                    | [Fantom nullable types](http://fantom.org/doc/docLang/TypeSystem#nullableTypes)                                                                                                  |
| [Flow](http://flowtype.org) (Facebook)              | [JS](https://developer.mozilla.org/en-US/docs/Web/JavaScript "JavaScript") superset and static checker                                                                       | 2014Q4 | *T*?                                                    | [Flow maybe types](http://flowtype.org/docs/nullable-types.html)                                                                                                                 |
| [Kotlin](http://kotlinlang.org) (JetBrains)         | Compiles to [JS](https://developer.mozilla.org/en-US/docs/Web/JavaScript "JavaScript") and [JB](http://en.wikipedia.org/wiki/Java_bytecode "Java Bytecode")                  | 2011Q3 | *T*?                                                    | [Kotlin null safety](http://kotlinlang.org/docs/reference/null-safety.html)                                                                                                      |
| [Haste](http://haste-lang.org/)                     | [Haskell](https://www.haskell.org) to [JS](https://developer.mozilla.org/en-US/docs/Web/JavaScript "JavaScript") compiler                                                    | @0.4.4 | [option type](http://en.wikipedia.org/wiki/Option_type) | [Haskell maybe type](https://wiki.haskell.org/Maybe)                                                                                                                             |
| [Swift](https://developer.apple.com/swift/) (Apple) | iOS/OS X Objective-C successor                                                                                                                                               | 2014Q4 | [option type](http://en.wikipedia.org/wiki/Option_type) | [Swift optional type](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/TheBasics.html#//apple_ref/doc/uid/TP40014097-CH5-ID330) |

(Note: 2014Q4, for example, refers to the 4th quarter of 2014). There is even discussion of introducing non-null types to [TypeScript](http://www.typescriptlang.org), the Dart peer that brings optional types and static type checking to JavaScript:

-   [TS issue \#185](https://github.com/Microsoft/TypeScript/issues/185), *Suggestion: non-nullable type*.
-   [TS issue \#1265](https://github.com/Microsoft/TypeScript/issues/1265), *Comparison with Facebook Flow Type System*.
-   [TS issue \#3003](https://github.com/Microsoft/TypeScript/issues/3003), *Compile / edit time pluggable analyzers like C\#* as a possible mechanism for introducing support for nullity checks.

<a name="terms"></a>
## 3 Normative reference, terms and notation

The main normative reference for this proposal is the *ECMA [Dart Specification Standard](http://www.ecma-international.org/publications/standards/Ecma-408.htm)*, 2nd Edition (December 2014, Dart v1.6) which we abbreviate as [DSS](http://www.ecma-international.org/publications/standards/Ecma-408.htm). When proposing changes to the [DSS](http://www.ecma-international.org/publications/standards/Ecma-408.htm), text that is removed will be ~~marked like this~~ and, new or updated text will be [[[marked like this]]](#terms "INS: Text added or updated in the DSS").

Throughout this proposal, qualified section numbers, sometimes in parentheses, e.g. ([DSS](http://www.ecma-international.org/publications/standards/Ecma-408.htm) 16.19), will refer to the corresponding section of the named resource.

We will refer to current Dart, with nullable-by-default semantics, as *classic Dart* (<a name="def-dartc">**DartC**</a>) and we will use <a name="def-dartnnbd">**DartNNBD**</a> to denote Dart as adapted to conform to this proposal. In cases where it is pertinent, we will mark code samples as being [DartC](#terms "Classic (i.e., current) Dart") or [DartNNBD](#terms "Dart as defined in this proposal with Non-Null By Default semantics") code.

<a name="terms"></a> We adhere to the following terminology ([DSS](http://www.ecma-international.org/publications/standards/Ecma-408.htm) 7, “Errors and Warnings”) a: *[static warning](#terms)* is a problem reported by the static checker; *[dynamic type error](#terms)* is a type error reported in checked mode; *[run-time error](#terms)* is an exception raised during execution.

<a name="first-look"></a>
## 4 Impact, examples and benefits: a first look

Among other important language design goals ([5](#goals)), this proposal has been designed so as to *minimize* the effort involved in migrating existing code, so that [DartC](#terms "Classic (i.e., current) Dart") code will require *no* or *few textual changes* to run with the *same behavior* in [DartNNBD](#terms "Dart as defined in this proposal with Non-Null By Default semantics").

Consider the following program, slightly adapted from an article on Dart types ([Bracha, 2012](https://www.dartlang.org/articles/optional-types)):

``` java
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

This code has the same behavior in [DartC](#terms "Classic (i.e., current) Dart") as in [DartNNBD](#terms "Dart as defined in this proposal with Non-Null By Default semantics"). But, in [DartNNBD](#terms "Dart as defined in this proposal with Non-Null By Default semantics"), an expression like `new Point(0,`*some nullable expression*`)` would cause a [static warning](#terms "A problem reported by the static checker") to be issued and a [dynamic type error](#terms "A type error reported in checked mode") to be raised, whereas no problems would be reported in [DartC](#terms "Classic (i.e., current) Dart").

**Dart SDK libraries**. What would be the impact on the Dart SDK libraries? The **`int`** API would look textually the same in [DartNNBD](#terms "Dart as defined in this proposal with Non-Null By Default semantics") except for the addition of 3 instances of the `?` meta type annotation, out of 44 possible places where such an addition could be made ([F.1.1](#int-nnbd)). The **`Iterable<E>`** interface would be unchanged ([F.1.2](#iterable-nnbd)).

The **benefits** of this proposal include:

-   An increased *potential* for the static detection of unanticipated use of `null`.
-   A base semantics which enables compilers (and VMs) to be much more effective at generating efficient code (e.g., code with fewer runtime checks).
-   Annotated code contributes to improving API documentation.

<a name="goals"></a>
## 5 Language design goals

Language design is a process of *balancing tensions* among goals under given constraints. It is difficult to assess a language, or a language proposal, when its design principles and goals are not clearly identified. In this section, we present some of the broad language design goals for this proposal. Other goals will be presented, as relevant, in their respective parts.

The group of goals presented next will be collectively referred to as **G0**; subgoals will be referred to by name, such as [G0, compatibility](#g0).

<a name="g0"></a>

-   **Goal G0, optional types**. Specifically these two aspects, which follow from the fundamental property of Dart that *static type annotations are* **optional** (see “Overview”, [Bracha, 2012](https://www.dartlang.org/articles/optional-types/#overview)):

    1.  Static type annotations, whether they include nullity meta type annotations or not, shall have *no impact on* **production mode execution**.

    2.  Static type checking rules shall never prevent code from executing, and hence never coerce a developer into *adding or changing* static (nullity) type annotations.

    > Comment. This is why problems reported by the static checker are warnings and not errors. The basic premise is that “the developer knows best” since he or she can see beyond the inherent limitations of the static type system.

-   *Maximize* each of the following properties:

    -   **Goal G0, utility** (of which more is said in the paragraph below).
    -   **Goal G0, [usability](http://en.wikipedia.org/wiki/Usability)**: the ease with which [DartNNBD](#terms "Dart as defined in this proposal with Non-Null By Default semantics") can be learned and used.
    -   **Goal G0, compatibility** with [DartC](#terms "Classic (i.e., current) Dart"); i.e., mainly *backwards compatibility*, though the intent is also to be respectful of Dart’s language design philosophy.
-   **Goal G0, ease migration**. *Minimize* the effort associated with the: (a) [migration](#part-migration) of [DartC](#terms "Classic (i.e., current) Dart") code to [DartNNBD](#terms "Dart as defined in this proposal with Non-Null By Default semantics"); (b) reengineering of tooling.

<a name="g0-utility"></a> The main purpose of this proposal (**[G0, utility](#g0)**) is to enable static and dynamic checks to report situations where a possibly null expression is being used but a non-null value is expected. Even in the presence of non-null types, developers could choose to declare all types as nullable (and hence be back in the realm of [DartC](#terms "Classic (i.e., current) Dart")). Consequently, to the extent possible, in this proposal we will give preference to new language features that will interpret unadorned types as being non-null *by default*.

<a name="proposal-details"></a>
## 6 Proposal details

For ease of comprehension, this proposal has been divided into parts. Each part treats a self-contained topic and generally builds upon its predecessor parts, if any. Most parts start with a brief introduction or motivation, followed by proposed feature details, then ending with a discussion and/or presentation of alternatives.

-   [A. Recovering non-null types](#part-non-null-types).
-   [B. Non-null by default](#part-nnbd)—also introduces the type operators `?` and `!`.
-   [C. Generics](#part-generics).
-   [D. Dealing with `dynamic` and missing static type annotations](#part-dynamic).
-   [E. Miscellaneous, syntactic sugar and other conveniences](#part-misc).
-   [F. Impact on core libraries](#part-libs).
-   [G. Migration strategy](#part-migration).

<a name="alt-and-deliverables"></a>
## 7 Alternatives and deliverables

Alternatives, as well as implications and limitations have been addressed throughout the proposal. [Appendix I](#appendix-1-review) is a review (survey) of nullity in programming languages: from languages without `null` to strategies for coping with `null`. It establishes a broad and partly historical context for this proposal and some of its presented alternatives.

Once a “critical mass” of this proposal’s features have gained approval, a fully updated version of the *Dart Language Specification* will be produced. Tooling reengineering and a preliminary experience report can be found in [Appendix II](#appendix-tooling).

<a name="executive-summary"></a>
## 8 Executive summary

<a name="lang-changes"></a>
### 8.1 Language updates and additions

**Core language design decisions**:

-   [A.2](#non-null-types). *Drop semantic rules giving special treatment to* `null`. In particular, the static type of `null` is taken to be `Null`, not ⊥ (while still allowing `null` to be returned for `void` functions). As a consequence, all non-`Null` class types (except `Object`, which is addressed next) lose [assignment compatibility](#assignment-compatible) with `null`, and hence *naturally recover* their status as *non-null types*.

-   [B.2](#nnbd). Create a *new class hierarchy root* named `_Anything` with only two immediate subclasses: `Object` and `Null`. This new root is internal and hence inaccessible to users. Thus, `Object` *remains the implicit upper bound* of classes.

-   [B.2](#nnbd). Introduce *type operators*:
    -   ?*T* defines the *nullable* variant of type *T*;
    -   !*T*, an inverse of `?`, is useful in the context of type ([C.3](#generics)) and optional parameters ([E.1.1](#opt-func-param)).
-   [C.3](#generics). Redefine the *default type parameter upper bound* as `?Object`, i.e., nullable-by-default ([C.3.4](#default-type-param-bound)). Non-null type parameters extend `Object` ([C.3.3](#generic-param-non-null)). Support for generics requires no additional features.

**Subordinate language design decisions**:

-   [B.2.4](#type-test-ambiguity). Resolution of negated type test (`is!`) syntactic ambiguity.
-   [B.2.5](#factory-constructors). Syntax for nullable factory constructors.
-   [B.2.6](#nnbd-function-sig). Syntax for nullable parameters declared using function signature syntax.
-   [B.3.1](#uti). Union type interoperability.
-   [B.3.3](#shared-type-op-semantics). Runtime representation of type operators and other shared semantics.
-   [B.3.5](#new-assignment-semantics). Adjusted semantics for “assignment compatible” (⟺).
-   [B.3.6](#multi-members). Static semantics of members of ?T.
-   [D.2.1](#dynamic-and-type-operators). `!dynamic` is the unknown non-null type, and `?dynamic` is `dynamic`.
-   [D.2.2](#bang-dynamic-subtype-of). Defining `!dynamic <:` *S*.
-   [E.1.1](#opt-func-param). Optional parameters are nullable-by-default in function bodies only.
-   [E.1.2](#normalization). Normalization of type expressions.
-   [E.2](#sugar). Syntactic sugar and other conveniences.

<a name="what-is-unchanged"></a>
### 8.2 What is unchanged?

Other than the changes listed above, the semantics of [DartNNBD](#terms "Dart as defined in this proposal with Non-Null By Default semantics") match [DartC](#terms "Classic (i.e., current) Dart"), most notably:

-   [B.3.4](#var-init). *Default variable initialization* semantics are untouched; i.e., `null` is the value of a variable when it is not explicitly initialized. Given that `null` is only [assignment compatible](#assignment-compatible) with `Null` in [DartNNBD](#terms "Dart as defined in this proposal with Non-Null By Default semantics"), this will result in [static warning](#terms "A problem reported by the static checker")s and [dynamic type error](#terms "A type error reported in checked mode")s for uninitialized variables declared to have a non-null type.

-   [D.2](#dynamic). The role and semantics of `dynamic` are untouched. Thus, `dynamic` (and `?dynamic`) denote the “unknown type”, supertype of all types. Also, e.g., in the absence of static type annotations or type arguments, `dynamic` is still assumed.

<a name="alternatives"></a>
### 8.3 Summary of alternatives and discussions

**Discussions / clarifications**:

-   [B.4.1](#ceylon-root). Precedent: [Ceylon](http://ceylon-lang.org)’s root is `Object` | `Null`.
-   [C.5.5](#generics-related-work). Generics and nullity in other languages or frameworks.
-   [D.3.1](#extends-bang-dynamic). Clarification of the semantics of `T extends !dynamic`.
-   [E.3.1](#nnbd-scope). Scope of [NNBD](#part-nnbd "Non-Null By Default") in [DartNNBD](#terms "Dart as defined in this proposal with Non-Null By Default semantics").
-   [E.3.4](#function-subtype). Subtype relation over function types unaffected by nullity.
-   [E.3.5](#catch-type-qualification). Catch target types and meta type annotations.
-   [E.3.7](#style-guide-object). Dart Style Guide on `Object` vs. `dynamic`.

**Points of variance / proposal part alternatives**:

-   [A.3.1](#why-nn-types). Why non-null *types*?
-   [A.3.2](#nullable-by-default). Embracing non-null types but preserving nullable-by-default?
-   [B.4.2](#var-init-alt). Default initialization of non-null variables.
-   [B.4.3](#factory-constructor-alt). Factory constructors.
-   [B.4.4](#semantics-of-bang-alt). Dealing with `!Null`.
-   [B.4.5](#type-test-ambiguity-alt). Resolution of negated type test (`is!`) syntactic ambiguity.
-   [B.4.6](#type-anno-alt). Encoding `?` and `!` as metadata.
-   [B.4.7](#object-not-nullable-alt). Ensuring `Object` is non-null: making `Null` a root too.
-   [C.5.1](#nullable-type-op-alt). Loss of expressivity due to union type interoperability.
-   [C.5.2](#lower-bound-for-maybe). Lower bounds to distinguish nullable/maybe-nullable parameters.
-   [C.5.3](#type-param-not-null). Statically constraining a type parameter to be nullable but *not* `Null`.
-   [C.5.4](#generics-alt). Parametric nullity abstraction.
-   [D.3.2](#dynamic-alt). Semantics for `dynamic`.
-   [D.3.3](#bang-dynamic-subtype-of-alt). Defining `!dynamic <:` *S*.
-   [E.3.2](#discussion-nnbd-scope). Scope of [NNBD](#part-nnbd "Non-Null By Default") in other languages or frameworks.
-   [E.3.3](#opt-param-alt). Optional parameters are always nullable-by-default.
-   [E.3.6](#local-var-analysis). Reducing the annotation burden for local variables.

<a name="goal-assessment"></a>
### 8.4 Assessment of goals

This proposal has strictly upheld [G0, optional types](#g0), in particular, in the choices made to preserve the [DartC](#terms "Classic (i.e., current) Dart") semantics:

-   Regarding default (non-null) variable initialization ([B.3.4](#var-init) vs. [B.4.2](#var-init-alt)), and by
-   Leaving `dynamic`, the unknown type, as nullable ([D.2](#dynamic) vs. [D.3.2](#dynamic-alt)).

Consequently, these features also support [G0, compatibility](#g0), and hence [G0, usability](#g0)—since fewer differences relative to [DartC](#terms "Classic (i.e., current) Dart"), and fewer special cases in the semantic rules, make [DartNNBD](#terms "Dart as defined in this proposal with Non-Null By Default semantics") easier to learn and use—as well as [G0, ease migration](#g0).

Unavoidably, recovery of non-null types ([A.2](#non-null-types)), induces two **breaking changes** that may impact the production mode execution of existing programs that:

1.  Use *reflection* to query: the direct members of, or the supertype of, `Object` or `Null` ([B.2.1](#new-root)); or, the upper bound of a type parameter ([C.3.4](#default-type-param-bound)).
2.  Perform *type tests* of the form *e* `is Object` since this will now return false for `null`. It seems unlikely though, that fielded code would actually contain such a type test given that it is always true in [DartC](#terms "Classic (i.e., current) Dart").

We have noted that breaking changes of similar magnitude are sometimes incorporated in Dart minor releases—see the [Dart CHANGELOG](https://github.com/dart-lang/sdk/blob/master/CHANGELOG.md).

There are **no other backwards incompatible** changes impacting *production mode execution* ([G0, compatibility](#g0)).

[Trending](#precedent) seems to indicate that there is value ([G0, utility](#g0-utility)) in having non-null types and [NNBD](#part-nnbd "Non-Null By Default") supported by languages with static type systems. This proposal helps Dart recover its non-null types and proposes adoption of [NNBD](#part-nnbd "Non-Null By Default"). The latter is the principle feature in support of [G0, ease migration](#g0); another key decision in support of ease of migration is leaving optional parameters ([E.1.1](#opt-func-param)) outside the scope of [NNBD](#part-nnbd "Non-Null By Default") ([E.3.1](#nnbd-scope)).

In fact, most of the core language design decisions adopted for this proposal relate back to the choices made concerning the **scope of [NNBD](#part-nnbd "Non-Null By Default")** ([E.3.1](#nnbd-scope)). During the creation of this proposal we constantly revisited potential impacts on the scope of [NNBD](#part-nnbd "Non-Null By Default") to ensure that the proposal stayed true to Dart’s overall language design philosophy. Our main point of comparison, detailing the many ways in which this proposal could have been differently crafted, is the section on the *scope of [NNBD](#part-nnbd "Non-Null By Default") in other languages or frameworks* ([E.3.2](#discussion-nnbd-scope)).

Overall, we are hopeful that this proposal has found a suitable balance between the [G0 goals](#g0) of *utility*, *usability*, *compatibility* and *ease of migration*.

<a name="part-non-null-types"></a>
# Part A: Recovering non-null types

The purpose of this part is to “recover” Dart’s non-null types, in the sense that we describe next.

<a name="a.1-non-null-types-in-dartc"></a>
## A.1 Non-null types in [DartC](#terms "Classic (i.e., current) Dart")

In Dart, *everything* is an object. In contrast to other mainstream languages, the term `null` refers to the null *object*, not the null *reference*. That is, `null` denotes the singleton of the `Null` class. Although built-in, `Null` is like a regular Dart class and so it is a subtype of `Object`, etc.

Given that everything is an object in Dart, and in particular that `null` is an object of type `Null` as opposed to a null *reference* then, in a sense, **[DartC](#terms "Classic (i.e., current) Dart") types are already non-null**. To illustrate this, consider the following [DartC](#terms "Classic (i.e., current) Dart") code:

``` java
const Null $null = null;

void main() {
  int i = null,
      j = $null,
      k = "a-string";
  print("i = $i, j = $j, k = $k");
  print("i is ${i.runtimeType}, j is ${j.runtimeType}");
}
```

Running the [Dart Analyzer](https://www.dartlang.org/tools/analyzer) results in

``` shell
Analyzing [null.dart]...
[warning] A value of type 'Null' cannot be assigned to a variable of type 'int' (line 5, col 11)
[warning] A value of type 'String' cannot be assigned to a variable of type 'int' (line 6, col 11)
2 warnings found.
```

<a name="dartc-static-checking"></a>
### A.1.1 Static checking

As is illustrated above, the `Null` type is unrelated to the type `int`. In fact, as a direct subtype of `Object`, `Null` is only related to `Object` and itself. Hence, the assignment of `$null` to `j` results in a [static warning](#terms "A problem reported by the static checker") just as it would for an instance of any other type (such as `String`) unrelated to `int` ([DSS](http://www.ecma-international.org/publications/standards/Ecma-408.htm) 16.19, “Assignment”, referring to an assignment *v* = *e*):

> It is a static type warning if the static type of *e* may not be assigned to the static type of *v*.

While the static type of `$null` is `Null`, the language specification has a special rule used to establish the static type of `null`. This rule makes `null` [assignment compatible](#assignment-compatible) with any type *T*, including `void` ([DSS](http://www.ecma-international.org/publications/standards/Ecma-408.htm) 16.2, “Null”):

> The static type of `null` is ⊥ (bottom). *(Rationale) The decision to use ⊥ instead of `Null` allows `null` to be assigned everywhere without complaint by the static checker.*

Because bottom is a subtype of every type ([DSS](http://www.ecma-international.org/publications/standards/Ecma-408.htm) 19.7, “Type Void”), `null` can be assigned to or used as an initializer for a variable of any type, without a [static warning](#terms "A problem reported by the static checker") or [dynamic type error](#terms "A type error reported in checked mode") ([DSS](http://www.ecma-international.org/publications/standards/Ecma-408.htm) 16.19; 19.4, “Interface Types”).

<a name="a.1.2-checked-mode-execution"></a>
### A.1.2 Checked mode execution

Execution in checked mode of the program given above results in an exception being reported only for the assignment to `k`:

``` shell
> dart -c null.dart
 Unhandled exception: type 'String' is not a subtype of type 'int' of 'k'.
 #0      main (~/example/null.dart:6:11)
```

The assignment to `j` raises no exception because of this clause ([DSS](http://www.ecma-international.org/publications/standards/Ecma-408.htm) 16.19, “Assignment”, where *o* is the result of evaluating *e* in *v* = *e*):

> In checked mode, it is a dynamic type error if *o* is not `null` and the interface of the class of *o* is not a subtype of the actual type (19.8.1) of *v*.

<a name="a.1.3-production-mode-execution"></a>
### A.1.3 Production mode execution

Production mode execution of our sample code results in successful termination and the following output is generated:

``` shell
i = null, j = null, k = a-string
i is Null, j is Null
```

Note that `Null` is the `runtimeType` of both `null` and `$null`; bottom is not a runtime type.

<a name="def-subtype"></a>
### A.1.4 Relations over types: `<<`, `<:`, and ⟺

We reproduce here the definitions of essential binary relations over Dart types found in [DSS](http://www.ecma-international.org/publications/standards/Ecma-408.htm) 19.4, “Interface Types”. We will appeal to these definitions throughout the proposal. Let *S* and *T* be types.

<a name="assignment-compatible"></a>

-   *T* may be *assigned to* *S*, written *T ⟺ S*, iff either *T \<: S* or *S \<: T*. (Let *T* be the static type of *e*. We will sometimes write “*e* may be assigned to *S*” when we mean that “*T* may be assigned to *S*”. Given that this relation is symmetric, we will sometimes write that *S* and *T* are **assignment compatible**.)

-   *T* is a *subtype* of *S*, written *T \<: S*, iff *[⊥/dynamic]T \<\< S*.

-   *T* is *more specific than* *S*, written *T \<\< S*, if one of the following conditions is met:
    -   *T* is *S*.
    -   T is ⊥.
    -   S is .
    -   *S* is a direct supertype of *T*.
    -   *T* is a type parameter and *S* is the upper bound of *T*.
    -   *T* is a type parameter and *S* is .
    -   *T* is of the form *I\<T\_1, ..., T\_n\>* and *S* is of the form *I\<S\_1, ..., S\_n\>* and: *T\_i \<\< S\_i, 1 ≤ i ≤ n*
    -   *T* and *S* are both function types, and *T \<\< S* under the rules of [DSS](http://www.ecma-international.org/publications/standards/Ecma-408.htm) 19.5.
    -   *T* is a function type and *S* is .
    -   *T \<\< U* and *U \<\< S*.

<a name="non-null-types"></a>
## A.2 Feature details: recovering non-null types

To recover the general interpretation of a class type *T* as non-null, we propose the following changes.

<a name="type-of-null"></a>
### A.2.1 `Null` is the static type of `null`

We drop the rule that attributes a special static type to `null`, and derive the static type of `null` normally as it would be done for any constant declared of type `Null` ([DSS](http://www.ecma-international.org/publications/standards/Ecma-408.htm) 16.2, “Null”): “~~The static type of `null` is ⊥ (bottom). *(Rationale) The decision to use ⊥ … checker*.~~”.

<a name="null-for-void"></a>
### A.2.2 `Null` may be assigned to `void`

As explained in [DSS](http://www.ecma-international.org/publications/standards/Ecma-408.htm) 17.12, “Return”, functions declared `void` must return *some* value. (In fact, in production mode, where static type annotations like `void` are irrelevant, a `void` function can return *any* value.)

> Comment. Interestingly, a `void` function in [Ceylon](http://ceylon-lang.org) is considered to have the return type `Anything`, though such functions always return `null`. Identification with `Anything` is to permit reasonable function subtyping ([[Ceylon functions](http://ceylon-lang.org/documentation/1.1/spec/html/declarations.html#functions)).

In [DartC](#terms "Classic (i.e., current) Dart") checked mode, `void` functions can either implicitly or explicitly return `null` without a [static warning](#terms "A problem reported by the static checker") or [dynamic type error](#terms "A type error reported in checked mode"). As was mentioned, this is because the static type of `null` is taken as ⊥ in [DartC](#terms "Classic (i.e., current) Dart"). In [DartNNBD](#terms "Dart as defined in this proposal with Non-Null By Default semantics"), we make explicit that `Null` can be *assigned to* `void`, by establishing that `Null` is more specific than `void` ([A.1.4](#def-subtype)): `Null << void`.

> Comment. In a sense, this makes explicit the fact that `Null` is being treated as a “carrier type” for `void` in Dart. `Null` is a [unit type](http://en.wikipedia.org/wiki/Unit_type), and hence returning `null` conveys no information. The above also fixes the slight irregularity noted in [A.1.1](#dartc-static-checking): in [DartNNBD](#terms "Dart as defined in this proposal with Non-Null By Default semantics"), no [static warning](#terms "A problem reported by the static checker") will result from a statement like `return $null;` used inside a `void` function (where `$null` is declared as a `const Null`).

<a name="null-not-special"></a>
### A.2.3 Drop other special semantic provisions for `null`

Special provisions made for `null` in the [DartC](#terms "Classic (i.e., current) Dart") semantics are dropped in [DartNNBD](#terms "Dart as defined in this proposal with Non-Null By Default semantics"), such as:

-   [DSS](http://www.ecma-international.org/publications/standards/Ecma-408.htm) 16.19, “Assignment”: In checked mode, it is a dynamic type error if ~~*o* is not null and~~ the interface of the class of *o* is not a subtype of the actual type (19.8.1) of *v*.

-   [DSS](http://www.ecma-international.org/publications/standards/Ecma-408.htm) 17.12, “Return”, e.g., for a synchronous function: it is a dynamic type error if ~~*o* is not `null` and~~ the runtime type of *o* is not a subtype of the actual return type of *f*.

We will address other similar ancillary changes to the semantics once a “critical mass” of this proposal’s features have gained approval ([7](#alt-and-deliverables)).

<a name="a.3-discussion"></a>
## A.3 Discussion

As we do at the end of most parts, we discuss here topics relevant to the changes proposed in this part.

<a name="why-nn-types"></a>
### A.3.1 Why non-null *types*?

Of course, one can appeal to programmer discipline and encourage the use of coding idioms and design patterns as a means of avoiding problems related to `null`. For one thing, an [option type](http://en.wikipedia.org/wiki/Option_type) can be realized in most languages ([including Dart](https://pub.dartlang.org/packages/optional)), as can the *Null Object* pattern ([Fowler](http://refactoring.com/catalog/introduceNullObject.html), [C&C](http://c2.com/cgi/wiki?NullObject)). <a name="NPE"></a> Interestingly, Java 8’s new `java.util.Optional<T>` type is being promoted as a way of avoiding `null` pointer exceptions (**NPE**s) in this Oracle Technology Network article entitled, “[Tired of Null Pointer Exceptions? Consider Using Java SE 8’s Optional!](http://www.oracle.com/technetwork/articles/java/java8-optional-2175753.html)”.

Coding discipline can only go so far. Avoiding problems with `null` is best achieved with proper language support that enables mechanized tooling diagnostics (vs. manual code reviews). Thus, while the use of [option type](http://en.wikipedia.org/wiki/Option_type)s (or any other discipline/strategy for avoiding `null` described in the [survey](#appendix-1-review)) could be applicable to Dart, we do not give serious consideration to any language feature less expressive than non-null types. Given that there is generally *some* effort involved on the part of developers who wish nullable and non-null types to be distinguished in their code, support for non-null *types* offer the <a name="ROI">**highest return on investment** (ROI)</a>, especially in the presence of [generics](#part-generics). Hence, we have chosen to base this proposal on non-null types rather than, e.g., non-null *declarator* annotations ([I.3.1](#lang-extensions)(b), [Dart issue \#5545](https://code.google.com/p/dart/issues/detail?id=5545 "Add non-null accepting type annotations")), which would not impact the type system. Languages like [JML](#JML "Java Modeling Language"), for example, which previously only supported nullity assertion constraints and nullity declaration modifiers, evolved to support non-null types and [NNBD](#part-nnbd "Non-Null By Default") ([I.3.1](#lang-extensions)).

It is interesting to note a similar evolution in tool support for *potential “null dereference” errors* in modern (and popular) IDEs like in [IntelliJ](https://www.jetbrains.com/idea) and the [Eclipse JDT](https://eclipse.org/jdt). Following conventional terminology, we will refer to such errors as [NPE](#why-nn-types "Potential null error")s. As Stephan Herrmann ([Eclipse JDT](https://eclipse.org/jdt) committer) points out ([Herrmann ECE 2014, page 3](https://www.eclipsecon.org/europe2014/sites/default/files/slides/DeepDiveIntoTheVoid.pdf#page=3)), [NPE](#why-nn-types "Potential null error")s remain the most frequent kind of exception in Eclipse. This high rate of occurrence of [NPE](#why-nn-types "Potential null error")s is not particular to the [Eclipse](https://eclipse.org) code base or even to [Java](http://java.com).

[Slide 5 of Stephan Herrmann’s *Advanced Null Type Annotations* talk](https://www.eclipsecon.org/europe2014/sites/default/files/slides/DeepDiveIntoTheVoid.pdf#page=5) summarizes the evolution of support for nullity analysis in the [Eclipse JDT](https://eclipse.org/jdt). While initial analysis was ad hoc, the advent of Java 5 metadata allowed for the introduction of nullity annotations like `@NonNull` and `@Nullable`. Such annotations were used early on by the [Eclipse JDT](https://eclipse.org/jdt) and the popular Java linter [Findbugs](http://findbugs.sourceforge.net) to perform intraprocedural analysis. As of Eclipse Luna (4.4), support is provided for non-null *types* (and interprocedural analysis), and options exist for enabling [NNBD](#part-nnbd "Non-Null By Default") at various levels of granularity. Such an evolution (from ad hoc, to nullity declarator annotations, to non-null types), seems to be part of a general trend that we are witnessing in programming language evolution ([I.4](#modern-lang-nnbd)), towards features that enable efficient and effective static checking, so as to help uncover coding errors earlier—in particular through the use of non-null types, and in many cases, [NNBD](#part-nnbd "Non-Null By Default").

<a name="nullable-by-default"></a>
### A.3.2 Embracing non-null types but preserving nullable-by-default?

As an alternative to the changes proposed in this part, the nullable-by-default semantics of [DartC](#terms "Classic (i.e., current) Dart") could be preserved in favor of the introduction of a *non-null* meta type annotation `!`. Reasons for not doing this are given in the [*Motivation* section](#part-nnbd-motivation) of the next part.

<a name="part-nnbd"></a>
# Part B: Non-null by default (NNBD)

<a name="part-nnbd-motivation"></a>
## B.1 Motivation: nullable-by-default increases migration effort

Several languages (see the [survey](#appendix-1-review)) with nullable-by-default semantics that have been subsequently retrofitted with support for non-null types have achieved this through the introduction of meta type annotations like `?` and `!`, used to indicate the nullable and non-null variants of a type, respectively.

The simplest adaptation to a language with a nullable-by-default semantics like [DartC](#terms "Classic (i.e., current) Dart"), is to leave the default untouched and require developers to explicitly mark types as non-null using the `!` meta type annotation.

``` java
// DartC extended with the meta type annotation `!'
int i = null;     // ok
!String s = null; // error
```

Unfortunately, this would unnecessarily burden developers and negatively impact [G0, ease migration](#g0) as we explain next. An [empirical study of Java code](https://drive.google.com/file/d/0B9T_03RPCjQRcXBKNVpQN1dZTFk/view?usp=sharing) established that 80% of declarations (having a reference type) are meant to be non-null, *by design*. An independent study reports 20 nullity annotations per KLOC ([Dietl, 2014](http://cs.au.dk/~amoeller/tapas2014/dietl.pdf); [Dietl et al., 2011](http://homes.cs.washington.edu/~mernst/pubs/pluggable-checkers-icse2011.pdf "Building and using pluggable type-checkers, ICSE'11")).

We expect the proportion of non-null vs. nullable declarations in Dart to be similarly high; a claim supported by anecdotal evidence—e.g., [Nystrom, 2011](http://journal.stuffwithstuff.com/2011/10/29/a-proposal-for-null-safety-in-dart), and our preliminary experiments in translating the Dart SDK libraries ([Part F](#part-libs)). For example, under a variant of [DartC](#terms "Classic (i.e., current) Dart") extended with `!`, `int.dart` would have to be updated with 38 `!` annotations (that’s 86%) against 6 declarations left undecorated.

<a name="nnbd"></a>
## B.2 Feature details: non-null by default

A consequence of dropping the special semantic rules for `null` ([A.2](#non-null-types)) is that all non-`Null` classes except `Object` lose [assignment compatibility](#assignment-compatible) with `Null`, and hence *naturally recover* their status as *non-null types*. In [DartC](#terms "Classic (i.e., current) Dart"), `Null` directly extends `Object` and so `Null <: Object`. This means that `Null` may still be [assigned to](#def-subtype) `Object`, effectively making `Object` nullable. We ensure that `Object` is non-null as follows.

<a name="new-root"></a>
### B.2.1 Ensuring `Object` is non-null: elect `_Anything` as a new root

We define the internal class `_Anything` as the **new root** of the class hierarchy. Being internal, it cannot be subclassed or instantiated by users. `Object` and `Null` are immediate subclasses of `_Anything`, redeclared as:

``` java
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

The definition of `Null` is the same as in [DartC](#terms "Classic (i.e., current) Dart") except that the class extends `_Anything` and implements `_Basic`. The latter declares all members of [DartC](#terms "Classic (i.e., current) Dart")’s `Object`. Note that the declaration of equality allows a `null` operand (such a definition is needed, e.g., by the [Dart Analyzer](https://www.dartlang.org/tools/analyzer)).

> Comment. Declaring `_Anything` as a class without methods allows us to provide a conventional definition for `void` as an empty interface, realized only by `Null`:
>
> ``` java
> abstract class void extends _Anything {}
> class Null extends _Anything implements _Basic, void { /* Same as in DartC */ }
> ```

The changes proposed in this subsection impact various sections of the language specification, including ([DSS](http://www.ecma-international.org/publications/standards/Ecma-408.htm) 10, “Classes”): “Every class has a single superclass except class ~~`Object`~~[[[`_Anything`]]](#terms "INS: Text added or updated in the DSS") which has no superclass”.

As is discussed below ([B.4.1](#ceylon-root)), [Ceylon](http://ceylon-lang.org) has a class hierarchy like the one proposed here for Dart.

> Comments:
>
> -   `Object` remains the implicit upper bound of classes (i.e., `extends` clause argument).
> -   Under this new hierarchy, `Null` is only [assignable to](#def-subtype) the new root, `void` and itself.

<a name="nullable-type-op"></a>
### B.2.2 Nullable type operator `?`

The **nullable type operator**, **?***T*, is used to introduce a nullable variant of a type *T*.

> Comment. Like other metadata annotations in Dart, `?` is applied as a prefix.

<a name="non-null-type-op"></a>
### B.2.3 Non-null type operator `!`

The **!** (bang) **non-null type operator**, can be thought of as an inverse of the nullable type operator `?`. It also acts as an identity function when applied to non-null types.

<a name="type-test-ambiguity"></a>
### B.2.4 Resolution of negated type test (`is!`) syntactic ambiguity

Unfortunately, the choice of `!` syntax introduces an ambiguity into the grammar relative to negated type tests, such as: `o is !`*T*. The ambiguity shall be resolved in favor of the original negated type test production, requiring parentheses for a type test against a non-null type, as in `o is (!`*T*`)`. See [B.4.5](#type-test-ambiguity-alt) for further discussion and an alternative.

<a name="factory-constructors"></a>
### B.2.5 Syntax for nullable factory constructors

It may seem unnecessary to qualify that factory constructors are non-null, but in [DartC](#terms "Classic (i.e., current) Dart"), a factory constructor for a class *T* is permitted to return an instance of *any* subtype of *T*, including `null` ([DSS](http://www.ecma-international.org/publications/standards/Ecma-408.htm) 10.6.2, “Factories”):

> In checked mode, it is a dynamic type error if a factory returns a non-`null` object whose type is not a subtype of its actual return type. *(Rationale) It seems useless to allow a factory to return `null`. But it is more uniform to allow it, as the rules currently do.*

In support of [G0, compatibility](#g0), we propose to extended the syntax of factory constructors so that they can be marked nullable, as is illustrated next. For further discussion and an alternative see [B.4.3](#factory-constructor-alt).

``` java
// DartNNBD - part of dart.core;
abstract class int extends num {
  external const factory ?int.fromEnvironment(String name, {int defaultValue});
  ...
}
```

<a name="nnbd-function-sig"></a>
### B.2.6 Syntax for nullable parameters declared using function signature syntax

A formal parameter can be declared by means of a function signature ([DSS](http://www.ecma-international.org/publications/standards/Ecma-408.htm) 9.2.1, “Required Formals”) as is done for `f` in: `int applyTo1(int f(int)) => f(1)`.

This, in effect, declares an anonymous class type ([DSS](http://www.ecma-international.org/publications/standards/Ecma-408.htm) 19.5, “Function Types”) “that implements the class `Function` and implements a `call` method with the same signature as the function”. The [NNBD](#part-nnbd "Non-Null By Default") rule also applies to such anonymous class types, so special syntax must be introduced to allow them to be marked as nullable. To declare a such a parameter as nullable, the parameter name can be *suffixed* with `?` as in:

``` java
int applyTo1(int f?(int)) => f == null ? 1 : f(1);
```

This can be thought of as equivalent to:

``` java
typedef int _ANON(int);
int applyTo1(?_ANON f) => f == null ? 1 : f(1);
```

This syntactic extension to function signatures can only be used in formal parameter declarations, not in other places in which function signatures are permitted by the grammar (e.g., class member declarations and type aliases).

> Comment. We avoid suggesting the use of `?` as a *prefix* to the function name since that could be interpreted as an implicitly (nullable) `dynamic` return type when no return type is provided.

<a name="nnbd-semantics"></a>
## B.3 Semantics

<a name="semantics-of-maybe"></a>
### B.3.1 Semantics of `?`

<a name="uti"></a>
#### (a) Union type interoperability

While *union types* are not yet a part of Dart, [they have been discussed](http://news.dartlang.org/2015/01/dart-language-evolution-discussed-in.html) by the Dart standards committee, and a [proposal is anticipated](https://github.com/dart-lang/dart_enhancement_proposals/blob/master/Meetings/2015-03-18%20DEP%20Committee%20Meeting.md#more-proposals). Once introduced, union types and the language features suggested by this proposal—especially the `?` type operator—will need to “interoperate” smoothly. This can be achieved by defining the nullable type operator as:

> **?***T* = *T* | `Null`

The semantics of `?` then follow naturally from this definition. While the Dart union type proposal has yet to be published, it can be safe to assume that its semantics will be *similar* to that of union types in other languages such as:

-   [TypeScript](http://www.typescriptlang.org), see Section 3.4 of the [TypeScript language specification](http://www.typescriptlang.org/Content/TypeScript%20Language%20Specification.pdf); or,
-   [Ceylon](http://ceylon-lang.org), see the language specification Section on [Ceylon union types](http://ceylon-lang.org/documentation/1.1/spec/html/typesystem.html#uniontypes).

From such a semantics it follows that, e.g., `Null <: ?T` and `T <: ?T` for any *T*.

<a name="b-core-properties-of"></a>
#### (b) Core properties of `?`

This proposal does not *require* union types. In the absence of union types we characterize `?` by its core properties. For any type *T*

-   `Null` and *T* are *more specific* than ?*T* ([A.1.4](#def-subtype)):
    -   `Null` \<\< ?*T*,
    -   *T* \<\< ?*T*;
-   ??*T* = ?*T* (idempotence),
-   ?`Null` = `Null` (fixed point),
-   ?`dynamic` = `dynamic` (fixed point, [D.2.1](#dynamic-and-type-operators)).

These last three equations are part of the rewrite rules for the **normalization** of ?*T* expressions ([B.3.3](#shared-type-op-semantics)).

It is a compile-time error if `?` is applied to `void`. It is a [static warning](#terms "A problem reported by the static checker") if an occurrence of ?*T* is not in normal form.

<a name="semantics-of-bang"></a>
### B.3.2 Semantics of `!`

When regarding ?*T* as the union type *T* | `Null`, then `!` can be seen as a projection operator that yields the non-`Null` union member *T*. For all non-null class types *T* `<: Object`

-   !?*T* = *T* (inverse of `?`)
-   !*T* = *T* (identity over non-null types)

These equations are part of the rewrite rules for the **normalization** of !*T* expressions ([B.3.3](#shared-type-op-semantics)).

It is a compile-time error if `!` is applied to `void`. Application of `!` to an element outside its domain is considered a *malformed* type ([DSS](http://www.ecma-international.org/publications/standards/Ecma-408.htm) 19.1, “Static Types”) and “any use of a malformed type gives rise to a static warning. A malformed type is then interpreted as `dynamic` by the static type checker and the runtime unless explicitly specified otherwise”. Alternatives are presented in [B.4.4](#semantics-of-bang-alt).

> Comment. Currently in [DartNNBD](#terms "Dart as defined in this proposal with Non-Null By Default semantics"), the only user expressible type outside of the domain of `!` is `Null` since `_Anything` is not accessible to users ([B.2.1](#new-root)).

<a name="shared-type-op-semantics"></a>
### B.3.3 Runtime representation of type operators and other shared semantics

Besides the semantic rules presented in the previous two subsections for their respective type operators, all other checked mode semantics ([static warning](#terms "A problem reported by the static checker")s or [dynamic type error](#terms "A type error reported in checked mode")s) for both `?` and `!` follow from those of [DartC](#terms "Classic (i.e., current) Dart") and the semantics of [DartNNBD](#terms "Dart as defined in this proposal with Non-Null By Default semantics") presented thus far.

Type expressions involving type operators shall be represented at runtime, in normalized form ([E.1.2](#normalization), for use in:

-   Reflection.
-   Reification ([C.4](#semantics-of-generics)).
-   Structural type tests of function types ([E.3.4](#function-subtype)).

<a name="var-init"></a>
### B.3.4 Default initialization of non-null variables is like [DartC](#terms "Classic (i.e., current) Dart")

We make no changes to the rules regarding default variable initialization, even if a variable is statically declared as non-null. In particular, the following rule still applies ([DSS](http://www.ecma-international.org/publications/standards/Ecma-408.htm) 8, “Variables”): “A variable that has not been initialized has the initial value `null`”.

> Comment. The term *variable* refers to a “storage location in memory”, and encompasses local variables, library variables, instance variables, etc. ([DSS](http://www.ecma-international.org/publications/standards/Ecma-408.htm) 8).

Explicit initialization checks are extended to also address cases of implicit initialization with `null`.

> Comments:
>
> -   Thus, explicit or implicit initialization of a variable with a value whose static type cannot be [assigned to](#def-subtype) the variable, will result in:
>
>     -   [Static warning](#terms "A problem reported by the static checker").
>     -   [Dynamic type error](#terms "A type error reported in checked mode").
>     -   No effect on production mode execution.
> -   In the case of a local variable statically declared non-null but not explicitly initialized, a problem ([static warning](#terms "A problem reported by the static checker") or [dynamic type error](#terms "A type error reported in checked mode")) need only be reported if there is an attempt to use the local variable before it is explicitly assigned to.
>
 

<a name="new-assignment-semantics"></a>
### B.3.5 Adjusted semantics for “assignment compatible” (⟺)

Consider the following [DartNNBD](#terms "Dart as defined in this proposal with Non-Null By Default semantics") code:

``` java
?int i = 1; // ok
class C1<T1 extends int> { T1 i1 = 1; } // ok
class C2<T2 extends int> { ?T2 i2 = 1; } // should be ok
```

According to the [DartC](#terms "Classic (i.e., current) Dart") definition of [assignment compatible](#assignment-compatible) described in [A.1.4](#def-subtype), a [static warning](#terms "A problem reported by the static checker") should be reported for the initialization of `i2`. To understand why, let us examine the general case of

``` java
class C<T extends B> { T o = s; }
```

where `s` is some expression of type *S*. Let us write *T<sup>B</sup>* to represent that the type parameter *T* has upper bound *B*. The assignment to `o` is valid if *S* is [assignment compatible](#assignment-compatible) with *T*, i.e., *S ⟺ T<sup>B</sup>* (by definition of ⟺). But *T<sup>B</sup>* is incomparable when it is not instantiated. The best we can do is compare *S* to *B* and try to establish that *B \<: S*. Thus, *S ⟺ T<sup>B</sup>*

*= S \<: T<sup>B</sup> ∨ T<sup>B</sup> \<: S* (by definition of ⟺) <br/>
*⟸ S \<: T<sup>B</sup> ∨ T<sup>B</sup> \<: B ∧ B \<: S* <br/>
*= S \<: T<sup>B</sup> ∨ B \<: S* (simplified because *B* is the upper bound of *T<sup>B</sup>*).

where *⟸* is reverse implication. In the case of class `C2` above, the field `i2` is of type ?`T2`, hence we are dealing with the general case: *S ⟺ ?T<sup>B</sup>*

*= S \<: ?T<sup>B</sup> ∨ ?T<sup>B</sup> \<: S* (by definition of ⟺) <br/>
*= S \<: Null ∨ S \<: T<sup>B</sup> ∨ ?T<sup>B</sup> \<: S* (property of ?) <br/>
*= S \<: Null ∨ S \<: T<sup>B</sup> ∨ (Null \<: S ∧ T<sup>B</sup> \<: S)* (property of ?) <br/>
*⟸ S \<: Null ∨ S \<: T<sup>B</sup> ∨ (Null \<: S ∧ T<sup>B</sup> \<: B ∧ B \<: S)* <br/>
*= S \<: Null ∨ S \<: T<sup>B</sup> ∨ (Null \<: S ∧ B \<: S)*. (\*)

If we substitute the type of `i2` and the bound of `T2` for *S* and *B* in (\*) and we get:

*int \<: Null ∨ int \<: T<sup>int</sup> ∨ (Null \<: int ∧ int \<: int)* <br/>
*= false ∨ int \<: T<sup>int</sup> ∨ (false ∧ true)* <br/>
*= int \<: T<sup>int</sup> ∨ false* <br/>
*= false*.

This seems counter intuitive: if `i2` is (at least) a nullable `int`, then it should be valid to assign an `int` to it. The problem is that the definition of [assignment compatible](#assignment-compatible) is too strong in the presence of union types. Before proposing a relaxed definition we repeat the definition of assignability given in [A.1.4](#def-subtype), along with the associated commentary from ([DSS](http://www.ecma-international.org/publications/standards/Ecma-408.htm) 19.4):

> An interface type *T* may be assigned to a type *S*, written *T ⟺ S*, iff either *T \<: S* or *S \<: T*. *This rule may surprise readers accustomed to conventional typechecking. The intent of the ⟺ relation is not to ensure that an assignment is correct. Instead, it aims to only flag assignments that are almost certain to be erroneous, without precluding assignments that may work.*

In the spirit of the commentary, we redefine “[assignment compatible](#assignment-compatible)” as follows: if *T* and *S* are non-null types, then the definition is as in [DartC](#terms "Classic (i.e., current) Dart"). Otherwise, suppose *T* is the nullable union type *?U*, then *?U* and *S* are assignment compatible iff *S* is assignment compatible with `Null` *or* with *U*. I.e., *?U ⟺ S* iff

*Null ⟺ S ∨ U ⟺ S*.

If we expand this new definition, we end up with the formula (\*) as above, except that the last logical operator is a disjunction rather than a conjunction. Under this new relaxed definition of [assignment compatible](#assignment-compatible), `i2` can be initialized with an `int` in [DartNNBD](#terms "Dart as defined in this proposal with Non-Null By Default semantics").

<a name="multi-members"></a>
### B.3.6 Static semantics of members of ?T

We define the static semantics of the members of ?*T* as if it were an anonymous class with `Null` and *T* as superinterfaces. Then the rules of member inheritance and type overrides as defined in ([DSS](http://www.ecma-international.org/publications/standards/Ecma-408.htm) 11.1.1) apply.

<a name="b.4-discussion"></a>
## B.4 Discussion

<a name="ceylon-root"></a>
### B.4.1 Precedent: [Ceylon](http://ceylon-lang.org)’s root is `Object` | `Null`

The [Ceylon](http://ceylon-lang.org) language essentially has the nullity semantics established so far in this proposal but without `!`, i.e.: types are non-null by default, `?` is a (postfix) nullable meta type annotation, and the top of the [Ceylon](http://ceylon-lang.org) type hierarchy is defined with a structure identical to that proposed in [B.2.1](#new-root) for [DartNNBD](#terms "Dart as defined in this proposal with Non-Null By Default semantics"), namely:

``` java
abstract class Anything of Object | Null
class Null of null extends Anything
class Object extends Anything
```

Thus, [`Anything`](http://ceylon-lang.org/documentation/1.0/api/ceylon/language/Anything.type.html) is defined as the *union type* of `Object` and `Null`.

<a name="var-init-alt"></a>
### B.4.2 Default initialization of non-null variables, alternative approaches

<a name="a-preserving-dartc-semantics-is-consistent-with-javascript-typescript"></a>
#### (a) Preserving [DartC](#terms "Classic (i.e., current) Dart") semantics is consistent with JavaScript & TypeScript

Our main proposal ([B.3.4](#var-init)) preserves the [DartC](#terms "Classic (i.e., current) Dart") semantics, i.e., a variable not explicitly initialized is set to `null`. In JavaScript, such variables are set to `undefined` ([ES5 8.1](http://ecma-international.org/ecma-262/5.1/#sec-8.1)), and [TypeScript](http://www.typescriptlang.org) conforms to this behavior as well ([TSLS 3.2.6](https://github.com/Microsoft/TypeScript/blob/master/doc/spec.md#3.2.6)).

For variables statically declared as non-null, some might prefer to see this proposal *mandate* (i.e., issue a compile-time error) if the variable is not explicitly initialized (with a value assignable to its statically declared type, and hence not `null`) but this would go against [G0, optional types](#g0).

In our opinion, preserving the default variable initialization semantics of [DartC](#terms "Classic (i.e., current) Dart") is the only approach that is consistent with [G0, optional types](#g0). Also see [I.3.2](#language-evolution) for a discussion of issues related to soundness. Although Dart’s static type system is already unsound by design ([Brandt, 2011](https://www.dartlang.org/articles/why-dart-types "Why Dart Types Are Optional and Unsound")), this proposal does not contribute to (increase) the unsoundness because of non-null types. [NNBD](#part-nnbd "Non-Null By Default") scope and local variables are also discussed in [E.3.2(a)](#local-var-alt).

<a name="type-specific-init"></a>
#### (b) Implicit type-specific initialization of non-null variables

In some other languages (especially in the presence of primitive types), it is conventional to have type-specific default initialization rules—e.g., integers and booleans are initialized to 0 and false, respectively. Due to our desired conformance to [G0, optional types](#g0), it is not possible to infer such type-specific default initialization from a static type annotation *alone*. On the other hand, special declarator syntax, such as (where `T` is a class type and `<U,...>` represents zero or more type arguments):

``` java
  !T<U,...> v;
```

could be treated as syntactic sugar for

``` java
  T<U,...> v = T<U,...>.DEFAULT_INIT();
```

In production mode this would be interpreted as:

``` java
  var v = T<U,...>.DEFAULT_INIT();
```

Any class type `T`, for which this form of initialization is desired, would provide `DEFAULT_INIT()` as a factory constructor, e.g.:

``` java
abstract class int extends num {
  factory int.DEFAULT_INIT() => 0;
  ...
}
```

Although what we are proposing here effectively overloads the meaning of meta type annotation `!`, there is no ambiguity since, in an [NNBD](#part-nnbd "Non-Null By Default") context, a class type *T* is already non-null, and hence !*T*—which is not in normal form ([B.3.3](#shared-type-op-semantics))—can be interpreted as a request for an implicit type-specific initialization. This even extends nicely to handle `!T` optional parameter declarations ([E.1.1](#opt-func-param)).

<a name="factory-constructor-alt"></a>
### B.4.3 Factory constructors, an alternative

In [B.3.2](#factory-constructors) we extended the syntax of factory constructors so that they could be marked as nullable. Allowing a factory constructor to return `null` renders *all* `new`/`const` expressions *potentially nullable*. This is an unfortunate complication in the semantics of Dart (and hence goes against [G0, usability](#g0)).

As was mentioned earlier, in [DartC](#terms "Classic (i.e., current) Dart"), a factory constructor for a class *T* is permitted to return an instance of *any* subtype of *T*, including `null` ([DSS](http://www.ecma-international.org/publications/standards/Ecma-408.htm) 10.6.2, “Factories”): “In checked mode, it is a dynamic type error if a factory returns a non-`null` object whose type is not a subtype of its actual return type. *(Rationale) It seems useless to allow a factory to return `null`. But it is more uniform to allow it, as the rules currently do*”. From the statement of rationale, it seems that factory constructors have been permitted to return `null` out of a desired uniformity in the application of the semantic constraint on factory results (which is based on subtyping).

Given that `Null` is no longer a subtype of every type in [DartNNBD](#terms "Dart as defined in this proposal with Non-Null By Default semantics"), we could also choose to (strictly) uphold the uniformity of the subtype constraint, thus *disallowing* a factory *constructor* from returning `null`—of course, factory *methods* could be nullable. Unfortunately, this would be a breaking change impacting features of the Dart core library, in particular `const` `factory` constructors like `int.fromEnvironment()` and `String.fromEnvironment()`. Because of the `const` nature of these factories, they have proven useful in “*compile-time dead code elimination*” ([Ladd, 2013](http://blog.sethladd.com/2013/12/compile-time-dead-code-elimination-with.html)). We suspect that few other factory constructors return `null` other than in the context of this idiom, and those that do, could provide a non-null default return value.

There has been some discussions of the possible elimination of `new` and/or `const` as constructor qualifiers (e.g., [Nielsen, 2015](https://groups.google.com/a/dartlang.org/d/msg/core-dev/4gMYdO-5BIg/AaHVYR3xXHQJ "Dart Core Development › const/new")), in which case the attempted distinction made here of factory constructors vs. factory methods would be moot.

<a name="semantics-of-bang-alt"></a>
### B.4.4 Dealing with `!Null`, alternatives

In the absence of generics, `!Null` could simply be reported as a compile-time error. With generics, the issue is more challenging since we must deal with type expressions like `!T` possibly when type parameter `T` is instantiated with `Null` ([Part C](#part-generics)).

While we proposed, in [B.3.2](#semantics-of-bang), to define !*T* as malformed when *T* is `Null`, alternatives include treating it as (i) ⊥, or (ii) a distinct empty (error) type that is assignment compatible with no other type. The latter would introduce a new way of handling type errors to Dart, in contrast to the current uniform treatment of such “errored types” as malformed instead. Use of ⊥ would also be a new feature since, to our knowledge, no type expression can be ⊥ in [DartC](#terms "Classic (i.e., current) Dart"). Hence both of these alternatives introduce extra complexity, thus decreasing [G0, usability](#g0) and increasing retooling costs ([G0, ease migration](#g0)).

<a name="type-test-ambiguity-alt"></a>
### B.4.5 Resolution of negated type test (`is!`) syntactic ambiguity, an alternative

Syntactic ambiguity between a negated type test and a type test against a non-null type ([B.2.4](#type-test-ambiguity)) could be avoided by adopting a different symbol, such as `~`, for the non-null type operator, but `!` is conventional. It helps somewhat that there is a lexical convention (enforced by the [Dart Code Formatter](https://www.dartlang.org/tools/dartfmt)) of writing the tokens `is` and `!` immediately adjacent to each other. It might further help if the analyzer reported a hint when the tokens `is` and `!` are separated by whitespace, inquiring (something like): “did you intend to write `o is (!`*T*`)`?”.

Note that there is no *class name* *T* that can be written in a non-null type test `o is (!`*T*`)` because `!Null` is malformed and !*T* will not be in normal form otherwise ([B.3.2](#semantics-of-bang)). But as we shall see in [Part C](#part-generics), it is legal to write !*T* when *T* is a type parameter name.

<a name="type-anno-alt"></a>
### B.4.6 Encoding `?` and `!` as metadata

Use of specialized syntax for meta type annotations `?` and `!` requires changes to Dart tooling front ends, impacting [G0, ease migration](#g0). We can *almost* do away with such front-end changes by encoding the meta type annotations as metadata such as `@NonNull` and `@Nullable`. We write “almost” because Dart metadata annotations would first need to be (fully) extended to types through an equivalent of [JSR-308](https://jcp.org/en/jsr/detail?id=308) which extended Java’s [metadata facility to types](http://www.oracle.com/technetwork/articles/java/ma14-architect-annotations-2177655.html). Broadened support for type metadata (which was mentioned in the [DEP 2015/03/18](https://github.com/dart-lang/dart_enhancement_proposals/blob/master/Meetings/2015-03-18%20DEP%20Committee%20Meeting.md#more-proposals) meeting) could be generally beneficial since nullity type annotations are only one among a variety of useful kinds of type annotation. E.g., the [Checker Framework](http://checkerframework.org), created jointly with JSR itself by the team that realized [JSR-308](https://jcp.org/en/jsr/detail?id=308), offers 20 checkers as examples, not the least of which is the [Nullness Checker](http://types.cs.washington.edu/checker-framework/current/checker-framework-manual.html#nullness-checker). It might also make sense to consider *internally* representing `?` and `!` as type metadata. But then again, special status may make processing of this core feature more efficient in both tooling and runtimes.

Regardless, the use of the single character meta type annotations `?` and `!` seems to have become quite common: it is certainly much shorter to type and it makes for a less noisy syntax.

<a name="object-not-nullable-alt"></a>
### B.4.7 Ensuring `Object` is non-null: making `Null` a root too

An alternative to creating a new class hierarchy root ([B.2.1](#new-root)) is to create a class hierarchy *forest* with two roots `Object` and `Null`. This has the advantage of being a less significant change to the class hierarchy, benefiting [G0, ease migration](#g0), though it is less conventional.

``` diff
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

<a name="part-generics"></a>
# Part C: Generics

<a name="c.1-motivation-enhanced-generics-through-non-null-types"></a>
## C.1 Motivation: enhanced generics through non-null types

One of the main benefits of a non-null type system is its potential interplay with generics. It is quite useful, for example, to be able to declare a `List` of non-null elements, and know that list element access will yield non-null instances.

<a name="generics-design-goals"></a>
## C.2 Design goals for this part

<a name="generics-g1"></a>
### G1: Support three kinds of formal type parameter

Support three kinds of formal type parameter: i.e., formal type parameters that constrain arguments to be

1.  Non-null.
2.  Nullable.
3.  Either non-null or nullable.

(We address whether the last two cases should be distinguished in [C.3.2](#generics-g1-2) and [C.5.2](#lower-bound-for-maybe).)

<a name="generics-g2"></a>
### G2: Support three kinds of type parameter expression in a class body

Within the body of a generic class, we wish to be able to represent three kinds of type parameter expression for any given formal type parameter: i.e., use of a type parameter name as part of a type expression, occurring in the class body, that is

1.  Non-null.
2.  Nullable.
3.  Matching the nullity of the argument.

<a name="running-example"></a>
### Running example

Defining and assessing suitable [DartNNBD](#terms "Dart as defined in this proposal with Non-Null By Default semantics") language features in support of Goals [G1](#generics-g1) and [G2](#generics-g2) has been one of the most challenging aspects of this proposal. To help us understand the choices we face, we will use the following Dart code as a running example. Note that this code uses `/*(...)*/` comments to mark those places where we want to come up with appropriate syntax. Each of the three cases of Goal [G2](#generics-g2) is represented in the class body.

``` java
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

<a name="generics"></a>
## C.3 Feature details: generics

We now work through the three cases of Goal [G1](#generics-g1) in reverse order.

<a name="generic-param-maybe-null"></a>
### C.3.1 Maybe-nullable formal type parameter, case [G1](#generics-g1).3

Here is an illustration of the base syntax (without any syntactic sugar or abbreviations) for the maybe-nullable formal type parameter case (code inessential to presentation has been elided, “`...`”):

``` java
// DartNNBD
class Box<T extends ?Object> {
  final !T _default;     // non-null (G2.1)
  T value;               // nullity matching parameter (G2.3)
  ?T maybeNull() => ...; // nullable (G2.2)
  ...
}
```

<a name="generics-g1-2"></a>
### C.3.2 Nullable formal type parameter, case [G1](#generics-g1).2

Given that Dart generics are covariant and that `T <: ?T`, it would be a significant departure from the current Dart semantics if we were to define static checking rules *requiring* that a type argument be nullable while rejecting non-null arguments. Thus, we propose that cases [G1](#generics-g1).2 and [G1](#generics-g1).3 be indistinguishable in [DartNNBD](#terms "Dart as defined in this proposal with Non-Null By Default semantics"). For an alternative, see [C.5.2](#lower-bound-for-maybe).

<a name="generic-param-non-null"></a>
### C.3.3 Non-null formal type parameter, case [G1](#generics-g1).1

For a non-null formal type parameter `T` we simply have `T` extend `Object`; again, here is the syntax without any sugar or abbreviations:

``` java
// DartNNBD
class Box<T extends Object> {
  final !T _default;     // non-null (G2.1)
  T value;               // nullity matching parameter (G2.3)
  ?T maybeNull() => ...; // nullable (G2.2)
  ...
}
```

> Comment. Given that `T` is non-null, the use of `!` could be dropped in the body.

<a name="default-type-param-bound"></a>
### C.3.4 Default type parameter upper bound is `?Object`

When no explicit upper bound is provided for a type parameter it is assumed to be `?Object`, thus providing clients of a generic type the most flexibility in instantiating parameters with either a nullable or non-null type (cf. [E.3.2](#discussion-nnbd-scope)). The following are equivalent:

``` java
// DartNNBD
class Box<T extends ?Object> {...}
class Box<T> {...}                 // Implicit upper bound of ?Object.
```

<a name="semantics-of-generics"></a>
## C.4 Semantics

While the static and dynamic semantics of generics follow from those of [DartC](#terms "Classic (i.e., current) Dart") and the semantics of [DartNNBD](#terms "Dart as defined in this proposal with Non-Null By Default semantics") introduced in the previous parts, there are quite a few alternative ways of dealing with certain aspects of generics. These are presented in the next section.

<a name="c.5-discussion"></a>
## C.5 Discussion

<a name="nullable-type-op-alt"></a>
### C.5.1 Loss of expressivity due to union type interoperability, an alternative

One caveat of “future proofing” the nullable type operator ?*T*, so that its semantics are compatible with the union type *T* | `Null` ([B.3.1](#uti)), is that we lose the ability to statically constrain a generic type parameter to be nullable but *not* `Null`—we discuss *why* we might want to do this in [C.5.3](#type-param-not-null). We lose this ability because ?*T* is not a type *constructor*, which would yield a unique (tagged) type, but rather just a type *operator* mapping *T* to the equivalent of the (untagged) union type *T* | `Null`. Thus, e.g., no distinction is made between `Null` and `?Null`.

We could alternatively define ?*T* as a type constructor (as if it were introducing a new type like `_$Nullable<`*T*`>`), orthogonal to union types, but there seems to be little to justify this complexity—future interoperability with union types seems more important and would be much more supportive of [G0, usability](#g0) and [G0, ease migration](#g0).

<a name="lower-bound-for-maybe"></a>
### C.5.2 Lower bounds to distinguish nullable/maybe-nullable parameters

The [Checker Framework](http://checkerframework.org) supports case [G1](#generics-g1).2 (nullable type parameter) distinctly from [G1](#generics-g1).3 (maybe-nullable type parameter) by allowing a type parameter lower bound to be defined ([Checker Framework Manual, 23.1.2](http://types.cs.washington.edu/checker-framework/current/checker-framework-manual.html#generics)) in addition to an upper bound (via `extends`). This is a natural fit for [Java](http://java.com) since the language already has some support for lower bounds through [lower bounded wildcards](https://docs.oracle.com/javase/tutorial/java/generics/lowerBounded.html).

Without introducing general support for lower bounds, such an approach could be adopted for [DartNNBD](#terms "Dart as defined in this proposal with Non-Null By Default semantics") as well. In our notation, it would look like this: `class Box<?T extends ?Object>`, which would require an argument *U* to satisfy `?T <:`*U* `<: ?Object`, which is only possible if *U* is nullable.

<a name="type-param-not-null"></a>
### C.5.3 Statically constraining a type parameter to be nullable but *not* `Null`

Consider the following code:

``` java
// DartNNBD
class C<T extends ?Object> { List<!T> list; ... }
var c = new C<Null>();
```

In the current form of the proposal, when a type parameter `T` is instantiated with `Null` then `!T` is considered malformed ([B.3.2](#semantics-of-bang)), as is the case for the type of `c.list` from the code sample above. Ideally, we would like to statically constrain `T` so that it cannot be `Null`. This would inform the clients of such a generic class that `T` should not be instantiated with `Null` and if it is, then a [static warning](#terms "A problem reported by the static checker") could be reported at the earliest point possible, i.e., instantiation expressions like `new C<Null>()`.

It is possible to statically avoid malformed types that arise from such `!T` type expressions. One way is to adopt a completely different semantics for ?*T* as was presented in [C.5.1](#nullable-type-op-alt). Another approach is to make use of type parameter lower bounds using syntax similar to what was presented in [C.5.2](#lower-bound-for-maybe): e.g., `class Box<!T extends ?Object>` would constrain an argument *U* to satisfy `T <:`*U* `<: ?Object`. The absence of an explicit lower-bound qualifier would be interpreted as `!`.

<a name="generics-alt"></a>
### C.5.4 Parametric nullity abstraction, an alternative approach to generics

There are a few alternatives to the proposal of [C.3](#generics) for handling generics. We mention only one here. It consists of broadening the scope of the [NNBD](#part-nnbd "Non-Null By Default") rule to encompass type parameter occurrences inside the body of a generic class; i.e., an *undecorated* occurrence of a type parameter would *always* represent a non-null type. Such an alternative is best introduced by an example covering cases [G1](#generics-g1).2 and [G1](#generics-g1).3:

``` java
// DartNNBD
class Box<&T extends ?Object> {
  final T _default;      // non-null (G2.1)
  &T value;              // nullity matching parameter (G2.3)
  ?T maybeNull() => ...; // nullable (G2.2)
  ...
}
```

One can think of the type parameter decorator `&` as a symbol acting as a “formal parameter” for the nullity of the corresponding type argument—i.e., as a form of *parametric nullity abstraction*—which will be instantiated as either `?` or `!`. (This is similar in spirit to the [Checker Framework qualifier parameters](http://types.cs.washington.edu/checker-framework/current/checker-framework-manual.html#qualifier-parameters).) Thus, `Box` could be instantiated as `Box<?int>` or `Box<int>`, with `&` denoting `?` and (an implicit) `!`, respectively.

Case [G1](#generics-g1).1, for a non-null type parameter, could be written as `class Box<&T extends Object> {...}` or more simply as `class Box<T extends Object> {...}`.

The **main advantage** of this approach is that it upholds *nullity notational consistency* (NNC). That is, just like for class names,

-   An *undecorated* type parameter name *T* represents a non-null type ([G2](#generics-g2).1),
-   ?*T* is its nullable variant ([G2](#generics-g2).2), and
-   &*T* matches the nullity of the corresponding type argument ([G2](#generics-g2).3).

The **main disadvantage** of this alternative is that it introduces a new concept (parametric nullity abstraction) which increases the complexity of the language, impacting [G0, usability](#g0) as well as [G0, ease migration](#g0). Code migration effort is especially impacted because, in practice, case [G2](#generics-g2).3 is most frequent; hence, in porting [DartC](#terms "Classic (i.e., current) Dart") code to [DartNNBD](#terms "Dart as defined in this proposal with Non-Null By Default semantics"), most type parameter uses would need to be annotated with `&` vs. no annotation for our main alternative ([C.3](#generics)).

<a name="generics-related-work"></a>
### C.5.5 Generics and nullity in other languages or frameworks

<a name="a-default-type-parameter-upper-bound"></a>
#### (a) Default type parameter upper bound

As we have done here, the [Nullness Checker](http://types.cs.washington.edu/checker-framework/current/checker-framework-manual.html#nullness-checker) of the [Checker Framework](http://checkerframework.org) has `@Nullable Object` as the implicit upper bound for type parameters, following its general [CLIMB-to-top](http://types.cs.washington.edu/checker-framework/current/checker-framework-manual.html#climb-to-top) principle (which is further discussed in [E.3.2](#discussion-nnbd-scope)). [Ceylon](http://ceylon-lang.org)’s implicit type parameter upper bound is `Anything`, i.e., `Object | Null`, which is also nullable.

<a name="b-nullity-polymorphism"></a>
#### (b) Nullity polymorphism

Because Java generics are invariant, the [Checker Framework](http://checkerframework.org) [Nullness Checker](http://types.cs.washington.edu/checker-framework/current/checker-framework-manual.html#nullness-checker) originally resorted to defining a special annotation to handle some common cases of polymorphism in type parameter nullities. E.g.,

``` java
@PolyNull T m(@PolyNull Object o) { ... }
```

The above constrains the return type of `m` to have a nullity that matches that of `o`. Since February 2015, a new form of polymorphism was introduced into the [Checker Framework](http://checkerframework.org), namely the [qualifier parameters](http://types.cs.washington.edu/checker-framework/current/checker-framework-manual.html#qualifier-parameters) mentioned in [C.5.3](#generics-alt).

<a name="c-ceylon-cannot-represent-g2.1"></a>
#### (c) [Ceylon](http://ceylon-lang.org) cannot represent [G2](#generics-g2).1

It is interesting to note that case [G2](#generics-g2).1 cannot be represented in [Ceylon](http://ceylon-lang.org) due to the absence of a non-null type operator `!`:

``` java
// Ceylon
class Box<T> {
  final T _default;      // can't enforce non-null; fall back to nullity matching param.
  T value;               // nullity matching parameter (G2.3)
  ?T maybeNull() => ...; // nullable (G2.2)
  ...
}
```

<a name="part-dynamic"></a>
# Part D: Dealing with `dynamic` and missing static type annotations

<a name="d.1-type-dynamic-in-dartc"></a>
## D.1 Type `dynamic` in [DartC](#terms "Classic (i.e., current) Dart")

In [DartC](#terms "Classic (i.e., current) Dart"), `dynamic`

-   “denotes the *unknown type*” ([DSS](http://www.ecma-international.org/publications/standards/Ecma-408.htm) 19.6, “Type dynamic”), and
-   is a supertype of all types ([DSS](http://www.ecma-international.org/publications/standards/Ecma-408.htm) 19.7, “Type Void”).

The type `dynamic` is used/assumed when, e.g.:

-   A type is malformed ([DSS](http://www.ecma-international.org/publications/standards/Ecma-408.htm) 19.1, “Static Types”).
-   No static type annotation is provided, or type arguments are missing ([DSS](http://www.ecma-international.org/publications/standards/Ecma-408.htm) 19.6, “Type dynamic”).
-   An incorrect number of type arguments are provided for a generic class ([DSS](http://www.ecma-international.org/publications/standards/Ecma-408.htm) 19.8, “Parameterized Types”).

<a name="dynamic"></a>
## D.2 Feature details: dynamic

The [DartC](#terms "Classic (i.e., current) Dart") role and static and dynamic semantics of `dynamic` are preserved in [DartNNBD](#terms "Dart as defined in this proposal with Non-Null By Default semantics").

<a name="dynamic-and-type-operators"></a>
### D.2.1 `!dynamic` is the unknown non-null type, and `?dynamic` is `dynamic`

The authors of [Ceylon](http://ceylon-lang.org) suggest that its `Anything` type [can be interpreted](http://ceylon-lang.org/documentation/1.1/reference/structure/type-declaration/#selected_important_type_declarations) as a union of all possible types. Such an interpretation leads to a natural understanding of the meaning of `dynamic` possibly decorated with the type operators `?` and `!`:

-   `dynamic`, *the* unknown type, can be interpreted as the union of all types, and hence the supertype of all types.
-   `!dynamic` can be interpreted as the union of all *non-null* types, and hence a supertype of all non-null types.
-   `?dynamic` = `dynamic` | `Null` = `dynamic`.

Thus, `T << !dynamic` precisely when `T << Object` ([A.1.4](#def-subtype)). It follows that `T <: !dynamic` for any class type *T* other than `Null` and `_Anything`.

> Comment. From another perspective, we can say that `!dynamic` represents an unknown non-null type rooted at `Object`, and `?dynamic` represents an unknown type rooted at `_Anything`.

<a name="bang-dynamic-subtype-of"></a>
### D.2.2 Defining `!dynamic <:` *S*

Let *T* and *S* be normalized types ([E.1.2](#normalization)). We introduce, *⊥\_Object* to represent the bottom element of the non-null type subhierarchy and add the following as one of the conditions to be met for *T \<\< S* to hold ([A.1.4](#def-subtype)):

> *T* is *⊥\_Object* and *S \<\< Object*.

We refine `<:` in the following backwards compatible manner: *T \<: S* iff

> *[⊥/dynamic]U \<\< S* where *U = [⊥\_Object/!dynamic]T*.

See [D.3.3](#bang-dynamic-subtype-of-alt) for a discussion and alternative.

<a name="d.3-discussion"></a>
## D.3 Discussion

<a name="extends-bang-dynamic"></a>
### D.3.1 Clarification of the semantics of `T extends !dynamic`

As a point of clarification, we note that a generic class declared with a type parameter `T extends !dynamic`:

-   is equivalent to `T extends Object`, except that;
-   for the purpose of static checking, *T* is treated as an unknown type.

This is semantically consistent with the manner in which `T extends dynamic` is treated in [DartC](#terms "Classic (i.e., current) Dart").

<a name="dynamic-alt"></a>
### D.3.2 Semantics for `dynamic`, an alternative

The main alternative relevant to this part, consists of interpreting an undecorated occurrence of `dynamic` as `!dynamic`. This would broaden the scope of the [NNBD](#part-nnbd "Non-Null By Default") rule to encompass `dynamic`.

This corresponds to the choice made in the [Kotlin](http://kotlinlang.org) language which has types `Any` and `Any?` as representative of “any non-null type”, and “any type”, respectively. Notice how the unadorned type `Any` is non-null.

The main disadvantage of this alternative is that [static warning](#terms "A problem reported by the static checker")s could be reported for programs without any static type annotations—such as for the statement `var o = null`, because the static type of `o` would be `!dynamic`. This goes contrary to [G0, optional types](#g0).

<a name="bang-dynamic-subtype-of-alt"></a>
### D.3.3 Defining `!dynamic <:` *S*, an alternative

The [DartC](#terms "Classic (i.e., current) Dart") definition of the subtype relation ([A.1.4](#def-subtype)) states that *S* `<:` *T* iff

> *[⊥/dynamic]S \<\< T*.

Replacing `dynamic` by ⊥ ensures that expressions having the static type `dynamic` can “be assigned everywhere without complaint by the static checker” ([DSS](http://www.ecma-international.org/publications/standards/Ecma-408.htm) 16.2, “Null”), and that `dynamic` is a valid type argument for any type parameter.

The refined definitions of `<<` and `<:` given in [D.2.2](#bang-dynamic-subtype-of) allows `!dynamic` to be:

-   Assigned everywhere a non-`Null` type is expected without complaint by the static checker, and;
-   Used as a valid type argument for any non-`Null` type parameter.

Introducing a new bottom element for the `Object` subhierarchy most accurately captures our needs thought it renders the semantics more complex, decreasing [G0, usability](#g0) and increasing tool reengineering costs.

An alternative, allowing us to avoid this extra complexity, is to treat `!dynamic` simply as ⊥. What we lose, are [static warning](#terms "A problem reported by the static checker")s and/or [dynamic type error](#terms "A type error reported in checked mode")s when: an expression of the static type `!dynamic` is assigned to variable declared as `Null` and, when `!dynamic` is used as a type argument for a `Null` type parameter. But such uses of `Null` are likely to be rare.

<a name="part-misc"></a>
# Part E: Miscellaneous, syntactic sugar and other conveniences

<a name="e.1-feature-details-miscellaneous"></a>
## E.1 Feature details: miscellaneous

In this section we cover some features, and present features summaries, that require concepts from all of the previous parts.

<a name="opt-func-param"></a>
### E.1.1 Optional parameters are nullable-by-default in function bodies only

Dart supports positional and named optional parameters, as illustrated here:

``` java
int f([int i = 0]) => i; // i is an optional positional parameter
int g({int j : 0}) => j; // j is an optional named parameter
```

Within a function’s body, its optional parameters are naturally nullable, since they are initialized to `null` when no default value is provided and corresponding optional arguments are omitted at a point of call. I.e., `null` is used as a default mechanism by which missing optional arguments can be *detected*.

We adopt a *dual view* for the types of optional parameters as is explained next. Suppose that an optional parameter `p` is declared to be of the normalized type *T* ([E.1.2](#normalization)):

1.  **Within the scope of the function’s body**, `p` will have static type:

    -   *T* if `p`:
        -   is *explicitly* declared non-null—i.e., *T* is !*U* for some *U*;
        -   has no meta type annotation, and has a non-null default value (see [E.1.1.1](#non-null-init));
        -   is a field parameter (see [E.1.1.2](#field-param)).
    -   ?*T* otherwise. (Note that if *T* has type arguments, then the interpretation of the nullity of these type arguments is not affected.)

2.  **In any other context**, the type of `p` is *T*.

<a name="guideline"></a> This helps enforce the following **guideline**: from a caller’s perspective, an optional parameter can either be *omitted*, or given a value matching its declared type.

> Comments:
>
> -   E.g., one can invoke `f`, defined above, as either `f()` or `f(1)`, but `f(null)` would result in a [static warning](#terms "A problem reported by the static checker") and [dynamic type error](#terms "A type error reported in checked mode").
> -   Just like for any other declaration, an optional parameter can be marked as nullable. So `f([?int j])` would permit `f(null)` without warnings or errors.
> -   Explicitly marking an optional parameter as non-null, e.g., `int h([!int i = 0]) => i`, makes it non-null in both views. But, if a non-null default value is not provided, then a [static warning](#terms "A problem reported by the static checker") and [dynamic type error](#terms "A type error reported in checked mode") will be reported.
> -   *T*, the type of `p`, might implicitly be `dynamic` if no static type annotation is given ([D.2](#dynamic)). By the rules above, `p` has type `?dynamic`, i.e., `dynamic` ([D.2.1](#dynamic-and-type-operators)), in the context of the declaring function’s body. Hence, a caveat is that we cannot declare `p` to have type `dynamic` in the function body scope and type `!dynamic` otherwise.
> -   The dual view presented here is an example of an application of [G0, utility](#g0-utility). This is further discussed, and an alternative is presented, in [E.3.3](#opt-param-alt).
> -   Also see [E.3.4](#function-subtype) for a discussion of function subtype tests.

<a name="non-null-init"></a>
#### E.1.1.1 Optional parameters with non-null initializers are non-null

In Dart, the initializer of an optional parameter must be a compile time constant ([DSS](http://www.ecma-international.org/publications/standards/Ecma-408.htm) 9.2.2). Thus, in support of [G0, ease migration](#g0), an optional parameter with a non-null default value is considered non-null.

<a name="field-param"></a>
#### E.1.1.2 Default field parameters are single view

Dart field constructor parameters can also be optional, e.g.:

``` java
class C {
  num n;
  C([this.n]);
  C.fromInt([int this.n]);
}
```

While `this.n` may have a type annotation (as is illustrated for the named constructor `C.fromInt()`), the notion of dual view does not apply to optional field parameters since they do not introduce a new variable into the constructor body scope.

<a name="normalization"></a>
### E.1.2 Normalization of type expressions

A *normalized* type expression has no *superfluous* applications of a type operator ([B.3.1](#semantics-of-maybe), [B.3.2](#semantics-of-bang)).

Let *P* be a type parameter name and *N* a non-null class type, *N* `<: Object`. In all contexts where [NNBD](#part-nnbd "Non-Null By Default") applies ([E.3.1](#nnbd-scope)), the following type expressions, used as static type annotations or type arguments, are in *normal form*:

-   *N*, and ?*N*
-   *P*, ?*P*, and !*P*
-   `dynamic` and `!dynamic`
-   `Null`

In the context of an optional function parameter `p` as viewed from within the scope of the declaring function body ([E.1.1](#opt-func-param)(a)), the following is also a normal form (in addition to the cases listed above): !*N*.

> Comment. Excluded are `void`, to which type operators cannot be applied ([B.3.1](#semantics-of-maybe), [B.3.2](#semantics-of-bang)), `?dynamic`, `?Null` and various repeated and/or canceling applications of `?` and `!` ([B.3](#nnbd-semantics)).

<a name="sugar"></a>
## E.2 Feature details: syntactic sugar and other conveniences

We define various syntactic sugars and other syntactic conveniences in this section. Being conveniences, they are **not essential to the proposal** and their eventual adoption may be subject to an “applicability survey”, in particular through analysis of existing code.

<a name="e.2.1-non-null-var"></a>
### E.2.1 Non-null `var`

While `var x` introduces `x` with static type `dynamic`, we propose that `var !x` be a shorthand for `!dynamic x`. Note that this shorthand is applicable to all kinds of variable declaration as well as function parameters.

<a name="e.2.2-formal-type-parameters"></a>
### E.2.2 Formal type parameters

In [C.3.4](#default-type-param-bound) we defined the default type parameter upper bound as `?Object`; i.e., `class Box<T>` is equivalent to `class Box<T extends ?Object>`. We define `class Box<T!>` as a shorthand for `class Box<T extends Object>`. Note that `!` is used as a *suffix* to `T`; though it is a meta type annotation *prefix* to the implicit `Object` type upper bound.

> Comment. We avoid suggesting `class Box<!T>` as a sugar because it opens the door to `class Box<?T>` and `class Box<?T extends Object>`. The latter is obviously be an error, and for novices the former might lead to confusion about the meaning of an undecorated type parameter `class Box<T>` (which could quite reasonably arise if there is a lack of understanding of the scope of the [NNBD](#part-nnbd "Non-Null By Default") rule). Also, `class Box<!T>` would conflict with the use of the same notation for the purpose of excluding `Null` type arguments ([C.5.3](#type-param-not-null)).

<a name="e.2.3-non-null-type-arguments"></a>
### E.2.3 Non-null type arguments

We define `!` as a shorthand for `!dynamic` when used as a type argument as in

``` java
List listOfNullableAny = ...
List<!> listOfNonnullAny = ...
```

<a name="e.2.4-non-null-type-cast"></a>
### E.2.4 Non-null type cast

The following extension of type casts ([DSS](http://www.ecma-international.org/publications/standards/Ecma-408.htm) 16.34, “Type Cast”) allows an expression to be projected into its non-null type variant, if it exists. Let *e* have the static type *T*, then *e* `as! Null` has static type !*T*.

> Comments:
>
> -   If *T* is outside the domain of `!`, then !*T* is malformed ([B.3.2](#semantics-of-bang)).
> -   Syntactic ambiguity, between `as!` and a cast to a non-null type !*T*, is addressed as it was for type tests ([B.2.4](#type-test-ambiguity)).
> -   In the presence of union types, `as!` might be generalized as follows. If the static type of *e* is the (normalized) union type *U* | *T*, then the static type of *e* `as!` *U* could be defined as *T*.

<a name="e.3-discussion"></a>
## E.3 Discussion

<a name="nnbd-scope"></a>
### E.3.1 Scope of [NNBD](#part-nnbd "Non-Null By Default") in [DartNNBD](#terms "Dart as defined in this proposal with Non-Null By Default semantics")

We clarify here the scope of [NNBD](#part-nnbd "Non-Null By Default") as defined in this proposal. This will be contrasted with the scope of [NNBD](#part-nnbd "Non-Null By Default") in other languages or frameworks in ([E.3.2](#discussion-nnbd-scope)).

1.  The [NNBD](#part-nnbd "Non-Null By Default") rule states that for *all* class types *T* `<: Object`, it is false that `Null` can be *assigned to* *T* ([A.1.4](#def-subtype)). This includes class types introduced via function signatures in the context of a

    -   Formal parameter declaration—these are anonymous class types ([B.2.6](#nnbd-function-sig)).
    -   `typedef`—these are named, possibly generic, class types ([DSS](http://www.ecma-international.org/publications/standards/Ecma-408.htm) 19.3, “Type Declarations”).

    Thus *T*, unadorned with any type operator, (strictly) represents instances of *T* (excluding `null`).

2.  The [NNBD](#part-nnbd "Non-Null By Default") rule applies to **class types** *only*. In particular, it does **not** apply to:

    -   Type parameters ([Part C](#part-generics)).
    -   Implicit or explicit occurrences of `dynamic` ([D.2](#dynamic)).

3.  The [NNBD](#part-nnbd "Non-Null By Default") rule applies in *all* contexts where a class type is *explicitly* given, *except one*: static type annotations of optional function parameters as viewed from within the scope of the declaring function’s body ([E.1.1](#opt-func-param)).

<a name="discussion-nnbd-scope"></a>
### E.3.2 Scope of [NNBD](#part-nnbd "Non-Null By Default") in other languages or frameworks

In contrast to this proposal, the scope of the [NNBD](#part-nnbd "Non-Null By Default") rule in other languages or frameworks often has more exceptions. This is the case for [Spec\#](http://research.microsoft.com/en-us/projects/specsharp) ([Fahndrich and Leino, 2003](http://doi.acm.org/10.1145/949305.949332 "Declaring and checking non-null types in an object-oriented language, OOPSLA'03")), [JML](#JML "Java Modeling Language") ([Chalin et al., 2008](https://drive.google.com/file/d/0B9T_03RPCjQRcXBKNVpQN1dZTFk/view?usp=sharing)) and Java enhanced with nullity annotations from the [Checker Framework](http://checkerframework.org). Next, we compare and contrast [DartNNBD](#terms "Dart as defined in this proposal with Non-Null By Default semantics") with the latter, partly with the purpose of justifying the language design decisions made in this proposal, and implicitly for the purpose of presenting potential alternatives for [DartNNBD](#terms "Dart as defined in this proposal with Non-Null By Default semantics").

The Java [Checker Framework](http://checkerframework.org) has a principle named [CLIMB-to-top](http://types.cs.washington.edu/checker-framework/current/checker-framework-manual.html#climb-to-top) which, in the case of the [Nullness Checker](http://types.cs.washington.edu/checker-framework/current/checker-framework-manual.html#nullness-checker), means that types are interpreted as *nullable-by-default* in the following contexts:

-   Casts,
-   Locals,
-   Instanceof, and
-   iMplicit (type parameter) Bounds

(CLIMB). We adhere to this principle for *implicit* type parameter bounds ([C.3.4](#default-type-param-bound)) and discuss other cases next.

<a name="local-var-alt"></a>
#### (a) Local variables

When retrofitting a strongly (mandatorily) typed nullable-by-default language (like Java) with [NNBD](#part-nnbd "Non-Null By Default") it is common to relax [NNBD](#part-nnbd "Non-Null By Default") for local variables since standard flow analysis can determine if a local variable is potentially `null` or not, and to do otherwise would result in the need to annotate many local variables as nullable. Unfortunately, excluding local variables from the scope of [NNBD](#part-nnbd "Non-Null By Default") is at the cost of loss of a form of *referential transparency*: consider the following declaration

``` java
List<String> guestList;
```

Is `guestList` nullable? In the [Checker Framework](http://checkerframework.org), it is not possible to tell without knowing the context: `guestList` is [NNBD](#part-nnbd "Non-Null By Default") if this is a (package) field declaration, but nullable if it is a local variable.

In contrast, static type annotations are optional in Dart, and a common idiom is to omit them for local variables. This idiom is in fact prescribed in the [Dart Style Guide](https://www.dartlang.org/articles/style-guide) section on [type annotations](https://www.dartlang.org/articles/style-guide/#prefer-using-var-without-a-type-annotation-for-local-variables):

> PREFER using `var` without a type annotation for local variables.

In light of this idiom, if a developer goes out of his or her way to write an explicit static type annotation, then we believe that the type should be interpreted literally; it is for this reason that we have chosen to include local variable declarations in the scope of [NNBD](#part-nnbd "Non-Null By Default"). As a benefit, we retain referential transparency for all ([non-optional](#opt-func-param)) variable declaration kinds—in particular instance variables and local variables.

As applied to local variables, the [NNBD](#part-nnbd "Non-Null By Default") rule of this proposal may result in extra warnings when [DartC](#terms "Classic (i.e., current) Dart") code is migrated to [DartNNBD](#terms "Dart as defined in this proposal with Non-Null By Default semantics"), but such warnings will *not* prevent the code from being executed in production mode—in strongly typed languages like Java, such migrated code would simply *not run*, and so our approach would not be a realistic alternative. Also, in the case of Dart code migration, tooling can contribute to the elimination of such warnings by automatically annotating explicitly typed local variables determined to be nullable ([G0, ease migration](#g0)).

<a name="b-type-tests"></a>
#### (b) Type tests

In [DartC](#terms "Classic (i.e., current) Dart"), the type test expression *e* `is` *T* holds only if the result of evaluating *e* is a value *v* that is an instance of *T* ([DSS](http://www.ecma-international.org/publications/standards/Ecma-408.htm) 16.33, “Type Test”). Hence, in [DartNNBD](#terms "Dart as defined in this proposal with Non-Null By Default semantics"), this naturally excludes `null` for all *T* `<: Object`.

<a name="c-type-casts"></a>
#### (c) Type casts

Out of the 150K physical [Source Lines Of Code (SLOC)](http://www.dwheeler.com/sloccount) of the Dart SDK libraries, there are only 30 or so occurrences of the `as` operator and most clearly assume that their first operand is non-null. Based on such a usage profile, and for reasons similar to those given for local variables (i.e., explicitly declared types interpreted literally), we have chosen to include Dart type casts in the scope of the [NNBD](#part-nnbd "Non-Null By Default") rule.

<a name="broad-applicability-of-nnbd-rule-for-dartnnbd"></a>
#### Broad applicability of [NNBD](#part-nnbd "Non-Null By Default") rule for [DartNNBD](#terms "Dart as defined in this proposal with Non-Null By Default semantics")

While balancing all [G0](#g0) language design goals, we have chosen to make the [NNBD](#part-nnbd "Non-Null By Default") rule as broadly applicable as possible, thus making the language simpler and hence increasing [G0, usability](#g0).

<a name="opt-param-alt"></a>
### E.3.3 Optional parameters are always nullable-by-default, an alternative

The “dual view” semantics proposed above ([E.1.1](#opt-func-param)) for optional parameters is an example of a language design feature which is slightly more complex (and hence penalizes [G0, usability](#g0)) but which we believe offers more utility ([G0, utility](#g0-utility)). A simpler alternative is to adopt (a) as the sole view: i.e., optional parameters would be nullable-by-default in all contexts.

<a name="function-subtype"></a>
### E.3.4 Subtype relation over function types unaffected by nullity

In contexts were a function’s type might be used to determine if it is a subtype of another type, then optional parameters are treated as [NNBD](#part-nnbd "Non-Null By Default") (view [E.1.1](#opt-func-param)(b)). But as we explain next, whether optional parameter semantics are based on a “dual” ([E.1.1](#opt-func-param)) or “single” ([E.3.3](#opt-param-alt)) view, this will have no impact on subtype tests.

Subtype tests of function types ([DSS](http://www.ecma-international.org/publications/standards/Ecma-408.htm) 19.5 “Function Types”) are structural, in that they depend on the types of parameters and return types ([DSS](http://www.ecma-international.org/publications/standards/Ecma-408.htm) 6, “Overview”). Nullity type operators have no bearing on function subtype tests. This is because the subtype relation over function types is defined in terms of the “assign to” (⟺) relation over the parameter and/or return types. The “assign to” relation ([A.1.4](#def-subtype)), in turn, is unaffected by the nullity: if types *S* and *T* differ only in that one is an application of `?` over the other, then either *S* `<:` *T* or *T* `<:` *S* and hence *S* ⟺ *T*. Similar arguments can be made for `!`.

<a name="catch-type-qualification"></a>
### E.3.5 Catch target types and meta type annotations

The following illustrates a try-catch statement:

``` java
class C<T> {}
main() {
  try {
    ...
  } on C<?num> catch (e) {
    ...
  }
}
```

Given that `null` cannot be thrown ([DSS](http://www.ecma-international.org/publications/standards/Ecma-408.htm) 16.9), it is meaningless to have a catch target type qualified with `?`; a [static warning](#terms "A problem reported by the static checker") results if `?` is used in this way. Any such qualification is ignored at runtime. Note that because meta type annotations are reified ([C.4](#semantics-of-generics)), they can be meaningfully applied to catch target type arguments as is illustrated above.

<a name="local-var-analysis"></a>
### E.3.6 Reducing the annotation burden for local variables, an alternative

As an alternative to the strict initialization rules for variables (including local variables) discussed in [E.3.2(a)](#local-var-alt), we propose as an alternative that standard read-before-write analysis be used for non-null *local variables* without an explicit initializer, to determine if its default initial value of `null` has the potential of being read before the variable is initialized.

Consider the following illustration of a common coding idiom:

``` java
int v; // local variable left uninitialized
if (...) {
  // possibly nested conditionals, each initializing v
} else {
  // possibly nested conditionals, each initializing v
}
// v is initialized to non-null by this point
```

Without the feature described in this subsection, `v` would need to be declared nullable.

<a name="style-guide-object"></a>
### E.3.7 Dart Style Guide on `Object` vs. `dynamic`

The [Dart Style Guide](https://www.dartlang.org/articles/style-guide) recommends [DO annotate with `Object` instead of `dynamic` to indicate any object is accepted](https://www.dartlang.org/articles/style-guide/#do-annotate-with-object-instead-of-dynamic-to-indicate-any-object-is-accepted). Of course, this will need to be adapted to recommend use of `?Object` instead.

<a name="part-libs"></a>
# Part F: Impact on Dart SDK libraries

The purpose of this part is to illustrate what some of the Dart SDK libraries might look like in [DartNNBD](#terms "Dart as defined in this proposal with Non-Null By Default semantics") and, in some cases, how they might be adapted to be more useful, through stricter type signatures or other enhancements.

<a name="f.1-examples"></a>
## F.1 Examples

The examples presented in this section are of types migrated to [DartNNBD](#terms "Dart as defined in this proposal with Non-Null By Default semantics") that *only* require updates through the addition of meta type annotations. Types potentially requiring behavioral changes are addressed in [F.2](#better-libs).

<a name="int-nnbd"></a>
### F.1.1 `int.dart`

We present here the `int` class with nullity annotations. There are only 3 nullable meta type annotations out of 44 places were such annotations could be placed (3/44 = 7% are nullable).

``` java
// DartNNBD - part of dart.core;
abstract class int extends num {
  external const factory ?int.fromEnvironment(String name, {int defaultValue});
  int operator &(int other);
  int operator |(int other);
  int operator <sup>(</sup>int other);
  int operator ~();
  int operator <<(int shiftAmount);
  int operator >>(int shiftAmount);
  int modPow(int exponent, int modulus);
  bool get isEven;
  bool get isOdd;
  int get bitLength;
  int toUnsigned(int width);
  int toSigned(int width);
  int operator -();
  int abs();
  int get sign;
  int round();
  int floor();
  int ceil();
  int truncate();
  double roundToDouble();
  double floorToDouble();
  double ceilToDouble();
  double truncateToDouble();
  String toString();
  String toRadixString(int radix);
  external static ?int parse(String source,
                             {int radix /* = 10 */,
                              ?int onError(String source) });
}
```

With the eventual added support for [generic functions](https://github.com/leafpetersen/dep-generic-methods), `parse()` could more usefully redeclared as:

``` java
  external static I parse<I extends ?int>(..., {..., I onError(String source)});
```

Notes:

-   The `source` argument of `parse()` should be non-null, see [dart/runtime/lib/integers\_patch.dart\#L48](https://github.com/dart-lang/sdk/blob/master/runtime/lib/integers_patch.dart#L48).
-   In conformance to the [guideline of E.1.1](#guideline), the following optional parameters are left as [NNBD](#part-nnbd "Non-Null By Default"):

    -   `defaultValue` of `factory int.fromEnvironment()`.
    -   `radix` and `onError` of `parse()`. Since `radix` has a non-null default value, it could be declared as `!int`, though there is little value in doing so given that `parse()` is `external`.

    (In opposition to the guideline, if we declare `defaultValue` and `onError` as nullable, that would make for 5/44 = 11% of declarators with nullable annotations.)

We have noted that conforming to the [guideline for optional parameters](#guideline) of [E.1.1](#opt-func-param) may result in breaking changes for some functions of SDK types. Other SDK type members explicitly document their adherence to the guideline: e.g., the `List([int length])` [constructor](https://api.dartlang.org/apidocs/channels/stable/dartdoc-viewer/dart:core.List#id_List-).

<a name="iterable-nnbd"></a>
### F.1.2 Iterable

The `Iterable<E>` type requires no `?` annotations (thought the optional `separator` parameter of `join()` could be declared as `!String`).

``` java
// DartNNBD - part of dart.core;
abstract class Iterable<E> {
  const Iterable();
  factory Iterable.generate(int count, [E generator(int index)]);
  Iterator<E> get iterator;
  Iterable map(f(E element));
  Iterable<E> where(bool f(E element));
  Iterable expand(Iterable f(E element));
  bool contains(Object element);
  void forEach(void f(E element));
  E reduce(E combine(E value, E element));
  dynamic fold(var initialValue,
               dynamic combine(var previousValue, E element));
  bool every(bool f(E element));
  String join([String separator = ""]);
  bool any(bool f(E element));
  List<E> toList({ bool growable: true });
  Set<E> toSet();
  int get length;
  bool get isEmpty;
  bool get isNotEmpty;
  Iterable<E> take(int n);
  Iterable<E> takeWhile(bool test(E value));
  Iterable<E> skip(int n);
  Iterable<E> skipWhile(bool test(E value));
  E get first;
  E get last;
  E get single;
  E firstWhere(bool test(E element), { E orElse() });
  E lastWhere(bool test(E element), {E orElse()});
  E singleWhere(bool test(E element));
  E elementAt(int index);
  String toString();
}
```

<a name="f.1.3-futuret"></a>
### F.1.3 `Future<T>`

We mention in passing that the use of `Future<Null>` remains a valid idiom in [DartNNBD](#terms "Dart as defined in this proposal with Non-Null By Default semantics") since the generic class is declared as:

``` java
abstract class Future<T> {...}
```

Hence `T` is nullable ([C.3.4](#default-type-param-bound)).

<a name="better-libs"></a>
## F.2 Suggested library improvements

<a name="f.2.1-iterator"></a>
### F.2.1 Iterator

<a name="dartc"></a>
#### [DartC](#terms "Classic (i.e., current) Dart")

An [`Iterator<E>`](https://api.dartlang.org/apidocs/channels/be/dartdoc-viewer/dart:core.Iterator) is “an interface for getting items, one at a time, from an object” via the following API:

``` java
// DartC - part of dart.core;
abstract class Iterator<E> {
  bool moveNext();
  E get current;
}
```

Here is an example of typical use (excerpt from the [API documentation](https://api.dartlang.org/apidocs/channels/be/dartdoc-viewer/dart:core.Iterator)):

``` java
var it = obj.iterator;
while (it.moveNext()) {
  use(it.current);
}
```

Dart’s API documentation for `current` is nonstandard in that it specifies that `current` shall be `null` “*if the iterator has not yet been moved to the first element, or if the iterator has been moved past the last element*”. This has the unfortunate consequence of forcing the return type of `current` to be nullable, even if the element type `E` is non-null. Iterators in other languages (such as Java and .Net languages) either [raise an exception](https://docs.oracle.com/javase/8/docs/api/java/util/Iterator.html) or document the behavior of `current` as *undefined* under such circumstances—for the latter see, e.g., the [.Net IEnumerator<T>.Current Property API](https://msdn.microsoft.com/en-us/library/58e146b7(v=vs.110).aspx).

<a name="dartnnbd"></a>
#### [DartNNBD](#terms "Dart as defined in this proposal with Non-Null By Default semantics")

We suggest that that [Dart Iterator API](https://api.dartlang.org/apidocs/channels/be/dartdoc-viewer/dart:core.Iterator) documentation be updated to state that the behavior of `current` is unspecified when the last call to `moveNext()` returned false (implicit in this statement is that `moveNext()` *must* be called at least once before `current` is used). This would allow us to usefully preserve the interface definition of `Iterator<E>` as:

``` java
// DartNNBD - part of dart.core;
abstract class Iterator<E> {
  bool moveNext();
  E get current;
}
```

Note that the type and nullity of `current` matches that of the type parameter.

Independent of nullity, the behavior of `current` might be adapted so that it throws an exception if it is invoked in situations where its behavior is undefined. But this would be a potentially breaking change (which, thankfully, would not impact uses of iterators in `for`-`in` loops).

<a name="f.2.2-liste"></a>
### F.2.2 `List<E>`

We comment on two members of the [`List<E>`](https://api.dartlang.org/apidocs/channels/stable/dartdoc-viewer/dart:core.List) type.

<a name="factory-listeint-length"></a>
#### `factory List<E>([int length])`

In [DartNNBD](#terms "Dart as defined in this proposal with Non-Null By Default semantics"), a [dynamic type error](#terms "A type error reported in checked mode") will be raised if `length` is positive and `E` is non-null. The error message could suggest using `List<E>.filled(int length, E fill)` instead.

<a name="liste.length"></a>
#### `List<E>.length=`

The [`List<E>.length=`](https://api.dartlang.org/apidocs/channels/stable/dartdoc-viewer/dart:core.List#id_length=) setter changes the length of a list. If the new length is greater than the current length, then new entries are initialized to `null`. This will cause a [dynamic type error](#terms "A type error reported in checked mode") to be issued when `E` is non-null.

Alternatives to growing a list of non-null elements includes:

-   Define a mechanism by which an “filler field” could be associated with a list. The filler field could then be used by the length setter when growing a list of non-null elements. E.g.,

    -   Add a `List<E>.setFiller(E filler)` method, or;
    -   Reuse the filler provided, say, as argument to `List<E>.filled(int length, E fill)`.
-   Add a new mutator, `setLength(int newLength, E filler)`.

<a name="f.3-other-classes"></a>
## F.3 Other classes

<a name="object"></a>
### Object

The `Object` class requires no textual modifications:

``` java
class Object {
  const Object();
  bool operator ==(other) => identical(this, other);
  external int get hashCode;
  external String toString();
  external dynamic noSuchMethod(Invocation invocation);
  external Type get runtimeType;
}
```

<a name="part-migration"></a>
# Part G: Migration strategy (sketch)

> Comment. An effective migration plan depends on several factors including, for example, whether union types will soon added to Dart or not. Regardless, this part sketches some initial ideas.

<a name="g.1-precedent"></a>
## G.1 Precedent

As is mentioned in the survey ([I.3](#retrofit)), both commercial and research languages have successfully migrated from a nullable-by-default to a [NNBD](#part-nnbd "Non-Null By Default") semantics. To our knowledge, [Eiffel](https://www.eiffel.com), in 2005, was the first commercial language to have successfully made this transition. [JML](#JML "Java Modeling Language"), a Java [BISL](#BISL "Behavioral Interface Specification Languages"), made the transition a few years later ([Chalin et al., 2008](https://drive.google.com/file/d/0B9T_03RPCjQRcXBKNVpQN1dZTFk/view?usp=sharing)). More recently, the [Eclipse JDT](https://eclipse.org/jdt) has been allowing developers to enable [NNBD](#part-nnbd "Non-Null By Default") at [various levels of granularity](http://help.eclipse.org/luna/index.jsp?topic=%2Forg.eclipse.jdt.doc.user%2Ftasks%2Ftask-improve_code_quality.htm), including at the level of an entire project or workspace, and work is underway to provide nullity annotations for the types in the SDK.

<a name="g.2-migration-aids"></a>
## G.2 Migration aids

It is interesting to note that [Eiffel](https://www.eiffel.com) introduced the `!` meta type annotation solely for purpose of code migration. [DartNNBD](#terms "Dart as defined in this proposal with Non-Null By Default semantics") also has `!` at its disposal, though in our case it is a core feature.

We propose (as has been done in [JML](#JML "Java Modeling Language") and the [Eclipse JDT](https://eclipse.org/jdt)) that the following lexically scoped, non-inherited library, part and class level annotations be made available: `@nullable_by_default` and `@non_null_by_default`. Such annotations establish the default nullity in the scope of the entity thus annotated.

Within the scope of an `@nullable_by_default` annotation, every type name *T* is taken as implicitly ?*T* except for the following: a type name that names

-   a constructor in a constructor declaration
-   a type target to a catch clause
-   the argument type of a type test (`is` expression)

Despite the exclusions above, if any such type name has type arguments then the nullable-by-default rule applies to the type arguments.

<a name="g.3-impact"></a>
## G.3 Impact

Tool impacted include (some common subsystems overlap):

-   [Dart Analyzer](https://www.dartlang.org/tools/analyzer).
-   [Dart Dev Compiler](https://github.com/dart-lang/dev_compiler).
-   [Dart VM](https://www.dartlang.org/tools/dart-vm).
-   [dart2js](https://www.dartlang.org/tools/dart2js).
-   [Dart Code Formatter](https://www.dartlang.org/tools/dartfmt).
-   [Dart docgen](https://www.dartlang.org/tools/dartdocgen).

<a name="g.4-migration-steps"></a>
## G.4 Migration steps

It seems desirable to target Dart 2.0 as a first release under which [NNBD](#part-nnbd "Non-Null By Default") would be the *default* semantics. In Dart 2.0, a command line option could be provided to recover nullable-by-default semantics. Initial steps in preparation of this switch would be accomplished in stages in the remaining releases of the 1.x stream.

Here is a preliminary list of possible steps along this migration path, not necessarily in this order:

-   (SDK) Create `@nullable_by_default` and `@non_null_by_default` annotations.
-   (Tooling) Add support for:
    -   Meta type annotation *syntax* (excluding most sugars).
    -   Static checks. This includes processing of `@*_by_default` annotations.
    -   Runtime support ([B.3.3](#shared-type-op-semantics)) for nullity type operators, and dynamic checks.
-   (SDK) Re-root the class hierarchy ([B.2.1](#new-root)).
-   (Tooling) Global option to turn on [NNBD](#part-nnbd "Non-Null By Default").
-   …

<a name="g.5-migration-plan-details"></a>
## G.5 Migration plan details

> Comment. TODO.

<a name="appendix-1-review"></a>
# Appendix I. Nullity in programming languages, an abridged survey

Problems arising from the presence of `null` have been well articulated over the years. Programming language designers have proposed various approaches to dealing with these problems, including the elimination of `null` entirely. For a survey of the alternate strategies to `null`, and the use of *nullity annotations* and *non-null types* in programming languages circa 2008 see *Chalin et al., 2008*, Section 4 ([IEEE](http://ieeexplore.ieee.org/xpl/articleDetails.jsp?arnumber=4717283), [preprint](https://drive.google.com/file/d/0B9T_03RPCjQRcXBKNVpQN1dZTFk/view?usp=sharing)). Below we summarize the survey and include recent developments.

In `null`-enabled languages, `null` is conveniently used to represent a value of any type *T*, when there is no *T* value at hand. This, in particular, allows for simple initialization rules: any variable not explicitly initialized can be set to `null`.

<a name="i.1-languages-without-null"></a>
## I.1 Languages without null

One way to avoid problems with `null` is to avoid making it part of the language. To address the main use case of `null` as *a substitute for a value of type *T* when you don’t have a value of type *T** many languages without `null` resort to use of [option type](http://en.wikipedia.org/wiki/Option_type)s. This is the case of:

-   Most functional programming languages, like [ML](http://en.wikipedia.org/wiki/ML_%28programming_language%29) and [Haskell](https://www.haskell.org), as well as
-   Some object-oriented languages, like [CLU](http://en.wikipedia.org/wiki/CLU_(programming_language)), [OCaml](https://ocaml.org) and, as was mentioned in the [introduction](#precedent), Apple’s recently released [Swift](https://developer.apple.com/swift/) language.

<a name="strategies"></a>
## I.2 Strategies for dealing with null in null-enabled languages

Most imperative programming languages having reference types also support `null`. This is certainly true for mainstream languages of C descent. Various strategies for dealing with `null` and attempting to detect [NPE](#why-nn-types "Potential null error")s are detailed next.

-   **Tools**, such as *linters*, have been used to perform nullity analysis (among other checks) in the hope of detecting potential [NPE](#why-nn-types "Potential null error")s. A notable mention is [Splint](http://www.splint.org), which actually assumes that unannotated reference types are non-null.

-   **Special macros/annotations** allowing developers to mark *declarators* as non-null, can guide:

    -   *Runtime instrumentation* of code so as to eagerly perform runtime checks—e.g., argument checks on function entry rather than throwing an [NPE](#why-nn-types "Potential null error") at some later point in the call chain. There was early support for such macros/annotation in, e.g., GNU’s gcc and Microsoft’s Source-code Annotation Language (SAL) for C/C++ ([Chalin et al., 2008](https://drive.google.com/file/d/0B9T_03RPCjQRcXBKNVpQN1dZTFk/view?usp=sharing)).
    -   *Static checking*. E.g., [Findbugs](http://findbugs.sourceforge.net) which makes use of Java 5 metadata annotations such as `@NonNull` and `@CheckForNull`. Modern IDEs like the [Eclipse JDT](https://eclipse.org/jdt) and [IntelliJ](https://www.jetbrains.com/idea) have been systematically improving their static [NPE](#why-nn-types "Potential null error") detection capabilities using such annotations as well, as we have discussed in [A.3.1](#why-nn-types).
-   **Language subsets** (sometimes qualified as “safe” subsets) have been defined so as to allow tool analysis to be more effective at flagging potential [NPE](#why-nn-types "Potential null error")s while reducing false positives. Pure subsets are rare. Most often they are combined with some form of extension. Examples include:

    -   [Spark Ada](http://www.spark-2014.org), which eliminated `null` by eliminating references!
    -   [Cyclone](http://cyclone.thelanguage.org), a safe dialect of C, which introduces the concept of safe/never-`null` pointers. The design of [Rust](http://www.rust-lang.org), which is still in beta (2015Q2), was influenced by [Cyclone](http://cyclone.thelanguage.org); it also distinguishes safe from raw pointers.
-   **Language extensions** and **language evolution**, which are the topic of the next section.

<a name="retrofit"></a>
## I.3 Retrofitting a null-enabled language with support for non-null

Retrofitting a fielded language is a challenge due to the presence of legacy code. We have seen two main approaches to tackling this challenge: language extensions and language evolution.

<a name="lang-extensions"></a>
### I.3.1 Language extensions

Language extensions are, as the name implies, defined atop (and outside of) a given base language. This means that the base language remains unaffected, and hence extensions have no impact on (standard) language tooling. This also implies that code elements from extensions are often encoded in specially marked comments (e.g., `/*@non_null*/`) or metadata.

<a name="a-contracts"></a>
#### (a) Contracts

One example, is the still very active Microsoft [Code Contracts](http://research.microsoft.com/en-us/projects/contracts) project, which provides a language-agnostic (i.e., library-based) way to express contracts (preconditions, postconditions, and object invariants) in programs written in most of the .Net family of languages. Contracts can be used to constrain fields, parameters and function results to be non-null, as is illustrated by the following excerpt of the [NonNullStack.cs](https://github.com/Microsoft/CodeContracts/blob/master/Demo/Stack/NonNullStack.cs) example taken from [Fahndrich and Logozzo, 2010](http://research.microsoft.com/apps/pubs/default.aspx?id=138696 "Clousot: Static Contract Checking with Abstract Interpretation, FoVeOOS'10"):

``` java
public class NonNullStack<T> where T : class {
  protected T[] arr;
  private int nextFree;

  [ContractInvariantMethod]
  void ObjectInvariant() {
    Contract.Invariant(arr !=null);
    Contract.Invariant(Contract.ForAll(0, nextFree, i => arr[i] != null));
    ...
  }

  public void Push(T x) {
    Contract.Requires(x != null);
    ...
  }

  public T Pop() {
    Contract.Requires(!this.IsEmpty);
    Contract.Ensures(Contract.Result<T>() != null);
    ...
  }
  ...
}
```

Notice the predicates constraining the following elements to be non-null:

-   `arr` field, as well as elements of the `arr` array, in the object invariant,
-   `x` parameter of `Push()` in the requires clause,
-   return result of `Pop()` in the ensures clause.

Of course, a contract language like this can be used to do much more than assert that fields, variables and results are non-null.

<a name="b-non-null-declarators"></a>
#### (b) Non-null declarators

The same approach to nullity as [Code Contracts](http://research.microsoft.com/en-us/projects/contracts) was originally adopted in <a name="JML">[Java Modeling Language](http://www.jmlspecs.org "JML") (**JML**)</a>, a <a name="BISL">[Behavioral Interface Specification Language](http://research.microsoft.com/en-us/um/people/leino/papers/krml188.pdf "Behavioral Interface Specification Languages") (**BISL**)</a> for Java. But nullity constraints were so common that declarator annotations were defined as “syntactic sugar” for corresponding contract clauses. E.g., the `NonNullStack` example from above could have been written as:

``` java
public class NonNullStack<T> ... {
  protected /*@non_null*/ T /*@non_null*/ [] arr;
  public void Push(/*@non_null*/T x) { ... }
  public /*@non_null*/T Pop() { ... }
  ...
}
```

But such an approach actually arose in [JML](#JML "Java Modeling Language") prior to the advent of Java generics. Nullity declarator constraints cannot be used to qualify type parameters, a feature often requested by developers.

Other languages supporting nullity declarators include the [Larch](http://www.sds.lcs.mit.edu/spd/larch) family of [BISL](#BISL "Behavioral Interface Specification Languages")s, notably Larch/C (LCL) and [Larch/C++](http://www.eecs.ucf.edu/~leavens/larchc++.html). The [Splint](http://www.splint.org) linter mentioned above ([I.2](#strategies)) grew out of Larch/C work.

<a name="c-non-null-types"></a>
#### (c) Non-null types

Evolution of language extensions has sometimes been from nullity annotations applied to *declarators* to support for *non-null types*. This has been the case for [JML](#JML "Java Modeling Language") ([Chalin et al., 2008](https://drive.google.com/file/d/0B9T_03RPCjQRcXBKNVpQN1dZTFk/view?usp=sharing)). In fact, the need to fully support non-null types in Java led to the creation of [JSR-308](https://jcp.org/en/jsr/detail?id=308), “[Java Type Annotations](http://www.oracle.com/technetwork/articles/java/ma14-architect-annotations-2177655.html)” which extends support for annotations to all places type expressions can appear. There has been hints that a similar extension might be considered useful for Dart as well ([B.4.6](#type-anno-alt)). [JSR-308](https://jcp.org/en/jsr/detail?id=308) was included in the March 2014 release of Java 8.

Other language extensions supporting non-null types include:

-   [Eclipse JDT](https://eclipse.org/jdt). The progression, from support of nullity declarator annotations to non-null types, in the context of the [Eclipse JDT](https://eclipse.org/jdt), was discussed in [A.3.1](#why-nn-types). Not only does the most recent release of the [Eclipse JDT](https://eclipse.org/jdt) support non-null types, but it also allows developers to enable [NNBD](#part-nnbd "Non-Null By Default") at [various levels of granularity](http://help.eclipse.org/luna/index.jsp?topic=%2Forg.eclipse.jdt.doc.user%2Ftasks%2Ftask-improve_code_quality.htm), including the project and workspace levels.
-   [Nullness Checker](http://types.cs.washington.edu/checker-framework/current/checker-framework-manual.html#nullness-checker) of the Java [Checker Framework](http://checkerframework.org).
-   [JastAdd](http://jastadd.org), a “meta-compilation system that supports Reference Attribute Grammars” and one of its instances, the JastAddJ compiler for Java, has an extension supporting [non-null types](http://jastadd.org/web/jastaddj/extensions.php).
-   [Spec\#](http://research.microsoft.com/en-us/projects/specsharp) a [BISL](#BISL "Behavioral Interface Specification Languages") for [C\#](https://msdn.microsoft.com/en-us/library/ms228593.aspx).

All of these language extensions, except possibly [JastAdd](http://jastadd.org) also support [NNBD](#part-nnbd "Non-Null By Default").

<a name="language-evolution"></a>
### I.3.2 Language evolution

As was mentioned earlier, adopting non-null types and/or [NNBD](#part-nnbd "Non-Null By Default") can be a challenge for languages with a sufficiently large deployed code base. Having a proper [migration strategy](#part-migration) is key.

To our knowledge, [Eiffel](https://www.eiffel.com) is the first *commercial language* to have made the switch, in 2005, from non-null types with a nullable-by-default semantics to [NNBD](#part-nnbd "Non-Null By Default"). [Eiffel](https://www.eiffel.com) introduced the `!` meta type annotation solely for easing migration efforts.

Adopting non-null types can lead to unsoundness if one is not careful, particularly with respect to the initialization of fields declared non-null ([B.4.2](#var-init-alt))—e.g., due to possible calls to helper methods from within constructors. [Fahndrich and Leino, 2003](http://doi.acm.org/10.1145/949305.949332 "Declaring and checking non-null types in an object-oriented language, OOPSLA'03"), detail the challenges they faced in bringing non-null types to [Spec\#](http://research.microsoft.com/en-us/projects/specsharp). [Swift](https://developer.apple.com/swift/), in which types are non-null by default, adopts [such a position](https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Initialization.html#//apple_ref/doc/uid/TP40014097-CH18-ID203) for classes and structures which: “*must set all of their stored properties to an appropriate initial value by the time an instance of that class or structure is created. Stored properties cannot be left in an indeterminate state*”.

Some feel that the cost of preserving type soundness is too high with respect to language usability. Eberhardt discusses the challenges in writing proper class/structure initialization code in [Swift](https://developer.apple.com/swift/) ([Eberhardt, 2014](http://blog.scottlogic.com/2014/11/20/swift-initialisation.html)). Similar initialization rules are also know to be one of the difficulties facing language designers attempting to add [support for non-null types](https://gist.github.com/olmobrutall/31d2abafe0b21b017d56 "Proposal for C# Non-Nullable Reference Types") to [C\#](https://msdn.microsoft.com/en-us/library/ms228593.aspx). In fact, Lippert believes that it is completely impractical to retrofit [C\#](https://msdn.microsoft.com/en-us/library/ms228593.aspx) with non-null types and instead proposes use of [Code Contracts](http://research.microsoft.com/en-us/projects/contracts) ([Lippert, 2013](http://blog.coverity.com/2013/11/20/c-non-nullable-reference-types/#.VUJhoNNVhBd)).

We mention in passing that in 2005, .Net was extended with support for nullable *primitive* types. This was done to achieve (uniform) native support for data coming from datasources in which all types are nullable. But this is creating an extra challenge, in terms of notational consistency, for C\# language designers who are considering the introduction of [non-null types into C\# 7](https://gist.github.com/olmobrutall/31d2abafe0b21b017d56 "Proposal for C# Non-Nullable Reference Types"), as is illustrated by the following sample declarations:

``` java
// C# + nullity proposal
int a; //non-nullable value type
int? a; //nullable value type
string! a; //non-nullable reference type
string a; //nullable reference type
```

<a name="modern-lang-nnbd"></a>
## I.4 Modern web/mobile languages with non-null types and [NNBD](#part-nnbd "Non-Null By Default")

[Fletch](https://github.com/dart-lang/fletch) is an experimental runtime (VM) for Dart “that makes it possible to implement highly concurrent programs in the Dart”. Meant to address problems in a similar space, is the [Pony](http://www.ponylang.org) language ([@0.1.5](https://github.com/CausalityLtd/ponyc) 2015Q2), a statically typed actor-based language (with concurrent garbage collection). [Pony](http://www.ponylang.org) has non-null types and [NNBD](#part-nnbd "Non-Null By Default") with nullable types introduced via a union with special [unit type](http://en.wikipedia.org/wiki/Unit_type) `None`.

For sake of completeness, we also reproduce here (from [2.2](#precedent)) the list of programming languages, many recently released, that are relevant to web applications (either dialects of [JS](https://developer.mozilla.org/en-US/docs/Web/JavaScript "JavaScript") or that compile to [JS](https://developer.mozilla.org/en-US/docs/Web/JavaScript "JavaScript")) and/or mobile, and that support *non-null types* and [NNBD](#part-nnbd "Non-Null By Default").

| Language                                            | About                                                                                                                                                                        | v1.0?  | Nullable via                                            | Reference                                                                                                                                                                        |
|-----------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------|---------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [Ceylon](http://ceylon-lang.org) (Red Hat)          | Compiles to [JS](https://developer.mozilla.org/en-US/docs/Web/JavaScript "JavaScript"), [Java Bytecode](http://en.wikipedia.org/wiki/Java_bytecode "Java Bytecode") (**JB**) | 2013Q4 | *T*?                                                    | [Ceylon optional types](http://ceylon-lang.org/documentation/1.1/tour/basics/#optional_types)                                                                                    |
| [Fantom](http://fantom.org)                         | Compiles to [JS](https://developer.mozilla.org/en-US/docs/Web/JavaScript "JavaScript"), [JB](http://en.wikipedia.org/wiki/Java_bytecode "Java Bytecode"), .Net CLR           | 2005   | *T*?                                                    | [Fantom nullable types](http://fantom.org/doc/docLang/TypeSystem#nullableTypes)                                                                                                  |
| [Flow](http://flowtype.org) (Facebook)              | [JS](https://developer.mozilla.org/en-US/docs/Web/JavaScript "JavaScript") superset and static checker                                                                       | 2014Q4 | *T*?                                                    | [Flow maybe types](http://flowtype.org/docs/nullable-types.html)                                                                                                                 |
| [Kotlin](http://kotlinlang.org) (JetBrains)         | Compiles to [JS](https://developer.mozilla.org/en-US/docs/Web/JavaScript "JavaScript") and [JB](http://en.wikipedia.org/wiki/Java_bytecode "Java Bytecode")                  | 2011Q3 | *T*?                                                    | [Kotlin null safety](http://kotlinlang.org/docs/reference/null-safety.html)                                                                                                      |
| [Haste](http://haste-lang.org/)                     | [Haskell](https://www.haskell.org) to [JS](https://developer.mozilla.org/en-US/docs/Web/JavaScript "JavaScript") compiler                                                    | @0.4.4 | [option type](http://en.wikipedia.org/wiki/Option_type) | [Haskell maybe type](https://wiki.haskell.org/Maybe)                                                                                                                             |
| [Swift](https://developer.apple.com/swift/) (Apple) | iOS/OS X Objective-C successor                                                                                                                                               | 2014Q4 | [option type](http://en.wikipedia.org/wiki/Option_type) | [Swift optional type](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/TheBasics.html#//apple_ref/doc/uid/TP40014097-CH5-ID330) |

As was mentioned earlier, there is also [discussion](#precedent) of introducing non-null types to [TypeScript](http://www.typescriptlang.org).

<a name="appendix-tooling"></a>
# Appendix II. Tooling and preliminary experience report

<a name="proposal-variant"></a>
## II.1 Variant of proposal implemented in the Dart Analyzer

We describe here a *version* of this proposal as implemented in the [Dart Analyzer](https://www.dartlang.org/tools/analyzer). It is “a version” in that we have adopted all core ideas ([8.1](#lang-changes)) but we have made a particular choice of alternatives ([8.3](#alternatives)). Choices have been driven by the need to create a solution that is **fully backwards compatible**, as will be explained below.

Core language design decisions (cf. [8.1](#lang-changes)) and main alternatives:

-   [A.2](#non-null-types). Drop semantic rules giving special treatment to `null`.
-   [B.2](#nnbd). Ensure `Object` is non-null by making `Null` a root ([B.4.7](#object-not-nullable-alt)).
-   [B.2](#nnbd). Support meta type annotations
    -   `@nullable` and `@non_null` ([B.4.6](#type-anno-alt)), and in those places where [DartC](#terms "Classic (i.e., current) Dart") does not currently support metadata,
    -   allow the use of specialized comments `/*?*/` and `/*!*/`.
-   [C.3](#generics). Support for generics matches the proposal.
-   [G.2](#g-2-migration-aids). Support `library`, `part` and `class` level `@nullable_by_default` annotations.

By our choice of input syntax, [DartNNBD](#terms "Dart as defined in this proposal with Non-Null By Default semantics") annotated code can be **analyzed and executed in DartC** without any impact on DartC tooling.

<a name="ii.2-dart-analyzer"></a>
## II.2 Dart Analyzer

We describe here a realization of this proposal in the [Dart Analyzer](https://www.dartlang.org/tools/analyzer).

<a name="ii.2.1-design-outline"></a>
### II.2.1 Design outline

The dart analyzer processes compilation units within a collection of libraries. The processing of each library is done in multiple phases on the Abstract Syntax Tree (AST) provided by the parser.

<a name="a-ast"></a>
#### (a) AST

No structural changes have been done to the AST types since nullity annotations are represented by metadata and comments. Also, `NullityElement`s, described next, are attached to `TypeName`s via the generic AST property mechanism (a hash map associated with any AST node).

<a name="b-element-model"></a>
#### (b) Element model

-   We introduce two `DartType` subtypes, one for each of `?` and `!` meta type annotations, named `UnionWithNullType` and `NonNullType`, respectively. These represent normalized types ([E.1.2](#normalization)).
-   The model `Element` representing a `UnionWithNullType` is `UnionWithNullElement`. Its is a representation of a (synthetic) `ClassElement`-like entity that can be queried for members via methods like `lookUpMethod(methodName)`, etc. When queried for a member with a given name *n*, a (synthetic) multi-member is returned which represents the collection of members matching declarations of *n* in `Null` and/or the other type argument of `UnionWithNullType`.
-   The dual-view for optional function parameters ([E.1.1](#opt-func-param)) is realized by associating to each optional parameter (`DefaultParameterElementImpl`) a synthetic counterpart (`DefaultParameterElementWithCalleeViewImpl`) representing the declared parameter from the function-body/callee view ([E.1.1(a)](#opt-func-param)). All identifier occurrences within the function body scope have the callee-view parameter instance as an associated static element.

<a name="c-resolution"></a>
#### (c) Resolution

We describe here the *added* / *adapted* analyzer processing (sub-)phases:

1.  Nullity annotation processing:

    1.  Nullity annotation resolution (earlier than would normally be done since nullity annotations impact *types* in [DartNNBD](#terms "Dart as defined in this proposal with Non-Null By Default semantics")). Note that we currently match annotation names only, regardless of library of origin so as to facilitate experimentation.
    2.  `NullityElement`s (see (b) below) are computed in a top-down manner, and attached to the AST nodes that they decorate (e.g., `TypeName`, `LibraryDirective`, etc.). The final nullity of a type name depends on: global defaults (whether [NNBD](#part-nnbd "Non-Null By Default") is enabled or not), `@nullable_by_default` nullity scope annotations, and individual declarator annotations.

2.  Element resolution (via `ElementResolver`) is enhanced to:

    1.  Adjust the static type associated with a, e.g., a `TypeName` based on its nullities.
    2.  Handle problem reporting for operator and method (including getter and setter) invocation over nullable targets.

3.  A late phase (after types have been resolved and compile-time constants computed) is used to adjust, if necessary, the types of optional parameters based on their default values ([E.1.1.1](#non-null-init)).

4.  Error verification has been adapted to, e.g., check for invalid implicit initialization of variables with `null` ([B.3.4](#var-init)); with the exclusion of final fields (whose initialization is checked separately).

The [NNBD](#part-nnbd "Non-Null By Default") analyzer also builds upon existing [DartC](#terms "Classic (i.e., current) Dart") flow analysis and type propagation facilities so that an expression *e* is of type ?*T* can have its type promoted in `if` statements and conditional expressions as follows:

| Condition   | True context  | False context |
|-------------|---------------|---------------|
| *e* == null | *e* is `Null` | *e* is *T*    |
| *e* != null | *e* is *T*    | *e* is `Null` |
| *e* is *T*  | *e* is *T*    | -             |
| *e* is! *T* | -             | *e* is *T*    |

> Caveat excerpt from a code comment: TODO(scheglov) type propagation for instance/top-level fields was disabled because it depends on the order or visiting. If both field and its client are in the same unit, and we visit the client before the field, then propagated type is not set yet.

<a name="analyzer-code-changes"></a>
### II.2.2 Source code and change footprint

The [NNBD](#part-nnbd "Non-Null By Default")-enabled analyzer sources are in the author’s GitHub Dart SDK fork @[chalin/sdk, dep30 branch](https://github.com/chalin/sdk/tree/dep30), under `pkg/analyzer`. This SDK fork also contains updates to the SDK library and sample projects which have been subject to nullity analysis (as documented in [II.3](#experience-report)). Note that

-   All code changes are marked with comments containing the token `DEP30` to facilitate identification (and merging of upstream changes from @[dart-lang/sdk](https://github.com/dart-lang/sdk/)).
-   Most significant code changes are marked with appropriate references to sections of this proposal for easier feature implementation tracking.

As of the time of writing, the [Dart Analyzer](https://www.dartlang.org/tools/analyzer) code change footprint (presented as a git diff summary) is:

    Showing  8 changed files  with 236 additions and 34 deletions.
    +3   −2  pkg/analyzer/lib/src/generated/ast.dart
    +5   −3  pkg/analyzer/lib/src/generated/constant.dart
    +39  −5  pkg/analyzer/lib/src/generated/element.dart
    +54  −9  pkg/analyzer/lib/src/generated/element_resolver.dart
    +17  −1  pkg/analyzer/lib/src/generated/engine.dart
    +24  −6  pkg/analyzer/lib/src/generated/error_verifier.dart
    +90  −7  pkg/analyzer/lib/src/generated/resolver.dart
    +4   −1  pkg/analyzer/lib/src/generated/static_type_analyzer.dart

There is approximately 1K [Source Lines Of Code (SLOC)](http://www.dwheeler.com/sloccount) of new code (or 3K LOC including comments and whitespace).

<a name="analyzer-status"></a>
### II.2.3 Status

The variant of the proposal described in [II.1](#proposal-variant) has been implemented except for the following features which are planed, but not yet supported:

-   [B.2.5](#factory-constructors). Syntax for nullable factory constructors.
-   [D.2.1](#dynamic-and-type-operators). `!dynamic`. (partially supported)
-   [D.2.2](#bang-dynamic-subtype-of). Defining `!dynamic <:` *S*. (partially supported)
-   [E.3.6](#local-var-analysis). Reducing the annotation burden for local variables.

Also, issues with flow analysis and function literal types are currently being addressed.

Caveat: being a *prototype* with experimental input syntax via annotations and comments, there is currently no checking of the validity of annotations (e.g., duplicate or misplaced annotations).

To run the [NNBD](#part-nnbd "Non-Null By Default") analyzer from the command line one can use the author’s [analyzer\_cli fork (non-null branch)](https://github.com/chalin/analyzer_cli/tree/non-null) with the `--enable-non-null` option *and* by setting the environment variable `DEP_NNBD` to 1 (this latter requirement will be lifted at some point). Leaving `DEP_NNBD` undefined causes [NNBD](#part-nnbd "Non-Null By Default") code changes to be eliminated (at compile time) and hence the analyzer behaves as it would in [DartC](#terms "Classic (i.e., current) Dart").

<a name="experience-report"></a>
## II.3 Preliminary experience report

We stress from the outset that this is a **preliminary** report.

Our initial objective has been to test run the new analyzer on sample projects. Our first target has been the SDK library Dart sources. We have also used some sample projects found in the Dart SDK `pkg` directory. So far, results are encouraging in that the nullable annotation burden seems to be low as we quantify in detail below.

<a name="ii.3.1-nullity-annotation-density"></a>
### II.3.1 Nullity annotation density

[Dietl, 2014](http://cs.au.dk/~amoeller/tapas2014/dietl.pdf), reports 20 nullity annotations / KLOC (anno/KLOC). So far, nullable annotation density for the SDK sources have been:

-   \<1 anno/KLOC for the library core (with \<2 line/KLOC of general changes related to nullity);
-   1 anno/KLOC for the samples.

We attribute such a low annotation count to Dart’s relaxed definition of assignability (see [A.1.4](#assignment-compatible) and [B.3.5](#new-assignment-semantics)), and a judicious choice in the scope of [NNBD](#part-nnbd "Non-Null By Default") ([E.3.1](#nnbd-scope)), in particular for optional parameters—namely our dual-view approach and use of compile-time default values to influence the nullability ([E.1.1](#opt-func-param)).

We are not claiming that such a low annotation count will be typical (it certainly is not the case for the analyzer code itself, in part due to most AST fields being nullable), but results are encouraging.

<a name="ii.3.2-dart-sdk-library"></a>
### II.3.2 Dart SDK library

Our strategy has been to run the [NNBD](#part-nnbd "Non-Null By Default") analyzer over the SDK library and address any reported issues. In addition, we added the nullable annotations mentioned in [Part F](#part-libs). Here is a summary, to date, of the changes.

-   `sdk/lib/core/core.dart` updated to include the definition of nullity annotations `@nullable`, `@non_null`, etc. (19 lines).

-   Nullable annotations were added in 70 locations. Most (64) were occurrences of `Object`.

-   The remaining updates (10 lines) were necessary to overcome the limitations in the analyzer’s flow analysis capabilities. For example, when an optional nullable parameter is initialized to a non-null value when it is null at the point of call. This is a typical code change of this nature:

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

-   There remain two false positives related to limitations in the analyzer’s flow analysis.

<a name="ii.3.3-sample-projects"></a>
### II.3.3 Sample projects

As a sanity test we have run the [NNBD](#part-nnbd "Non-Null By Default") analyzer on itself. As expected, a large number of problems are reported, due the nullable nature of AST class type fields. We have chosen not to tackle the annotation of the full analyzer code itself at the moment. On the other hand, we have annotated the nullity specific code, for which we have a nullity annotation ratio is 10 anno/KLOC.

As for other projects, to date, we have run the [NNBD](#part-nnbd "Non-Null By Default") analyzer over the following SDK `pkg` projects totaling 2K LOC:

-   `expect`
-   `fixnum`

Each projects required only a single nullity annotation. The remaining changes to `expect` were to remove redundant (in [DartC](#terms "Classic (i.e., current) Dart")) explicit initialization of the optional `String reason` parameter with `null` (16 lines).

<a name="revision-history"></a>
# Revision History

Major updates are documented here.

<a name="section"></a>
## 2016.02.24 (0.5.0)

The main change is the addition of [Appendix II. Tooling and preliminary experience report](#appendix-tooling). In terms of individuals section changes we have:

**New**

-   [B.3.5](#new-assignment-semantics). Adjusted semantics for “assignment compatible” (⟺).
-   [B.3.6](#multi-members). Static semantics of members of ?T.
-   [E.1.1.1](#non-null-init). Optional parameters with non-null initializers are non-null.
-   [E.1.1.2](#field-param). Default field parameters are single view.
-   [E.3.5](#catch-type-qualification). Catch target types and meta type annotations.
-   [E.3.6](#local-var-analysis). Reducing the annotation burden for local variables, an alternative.
-   [E.3.7](#style-guide-object). Dart Style Guide on `Object` vs. `dynamic`.

**Updated**

-   [B.2.1](#new-root). Ensuring `Object` is non-null: elect `_Anything` as a new root. Updated `_Basic` declaration and associated prose since the analyzer expects the `==` operator to be defined for `Null`.
-   [E.1.1](#opt-func-param). Optional parameters are nullable-by-default in function bodies only. Now makes reference to cases [E.1.1.1](#non-null-init) and [E.1.1.2](#field-param).
-   [G.2](#g-2-migration-aids). Adjusted name of nullity-scope annotations. Clarified the extent of the scope of `@nullable_by_default`, and that such annotations can also be applied to `part`s.
