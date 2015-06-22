# Appendix I. Nullity in programming languages, an abridged survey {- #appendix-1-review}

Problems arising from the presence of `null` have been well articulated over the years. Programming language designers have proposed various approaches to dealing with these problems, including the elimination of `null` entirely. For a survey of the alternate strategies to `null`, and the use of *nullity annotations* and *non-null types* in programming languages circa 2008 see *Chalin et al., 2008*, Section 4 ([IEEE][Chalin et al., 2008 IEEE], [preprint][Chalin et al., 2008]). Below we summarize the survey and include recent developments.

In `null`-enabled languages, `null` is conveniently used to represent a value of any type *T*, when there is no *T* value at hand. This, in particular, allows for simple initialization rules: any variable not explicitly initialized can be set to `null`.

## I.1 Languages without null

One way to avoid problems with `null` is to avoid making it part of the language. To address the main use case of `null` as _a substitute for a value of type *T* when you don't have a value of type *T*_ many languages without `null` resort to use of [option type][]s. This is the case of:

- Most functional programming languages, like [ML][] and [Haskell][], as well as
- Some object-oriented languages, like [CLU][], [OCaml][] and, as was mentioned in the [introduction](#precedent), Apple's recently released [Swift][] language.

## I.2 Strategies for dealing with null in null-enabled languages {#strategies}

Most imperative programming languages having reference types also support `null`. This is certainly true for mainstream languages of C descent. Various strategies for dealing with `null` and attempting to detect [NPE][]s are detailed next.

+ **Tools**, such as *linters*, have been used to perform nullity analysis (among other checks) in the hope of detecting potential [NPE][]s. A notable mention is [Splint][], which actually assumes that unannotated reference types are non-null.

+ **Special macros/annotations** allowing developers to mark _declarators_ as non-null, can guide:

    - *Runtime instrumentation* of code so as to eagerly perform runtime
      checks---e.g., argument checks on function entry rather than throwing
      an [NPE][] at some later point in the call chain. There was early support
      for such macros/annotation in, e.g., GNU's gcc and Microsoft's
      Source-code Annotation Language (SAL) for C/C++ ([Chalin et al., 2008][]).
    - *Static checking*. E.g., [Findbugs][] which makes use of Java 5 metadata
      annotations such as `@NonNull` and `@CheckForNull`. Modern IDEs like the
      [Eclipse JDT][] and [IntelliJ][] have been systematically improving their 
      static [NPE][] detection capabilities using such annotations as well, as we
      have discussed in [A.3.1](#why-nn-types).

+ **Language subsets** (sometimes qualified as "safe" subsets) have been defined so as to allow tool analysis to be more effective at flagging potential [NPE][]s while reducing false positives. Pure subsets are rare. Most often they are combined with some form of extension. Examples include:

    - [Spark Ada][], which eliminated `null` by eliminating references!
    - [Cyclone][], a safe dialect of C, which introduces the concept of safe/never-`null`
      pointers. The design of [Rust][], which is still in beta (2015Q2), was influenced
      by [Cyclone][]; it also distinguishes safe from raw pointers.

+ **Language extensions** and **language evolution**, which are the topic of the next section.

## I.3 Retrofitting a null-enabled language with support for non-null {#retrofit}

Retrofitting a fielded language is a challenge due to the presence of legacy code. We have seen two main approaches to tackling this challenge: language extensions and language evolution.

### I.3.1 Language extensions {#lang-extensions}

Language extensions are, as the name implies, defined atop (and outside of) a given base language. This means that the base language remains unaffected, and hence extensions have no impact on (standard) language tooling. This also implies that code elements from extensions are often encoded in specially marked comments (e.g., `/*@non_null*/`) or metadata.

#### (a) Contracts {-}

One example, is the still very active Microsoft [Code Contracts][] project, which provides a language-agnostic (i.e., library-based) way to express contracts (preconditions, postconditions, and object invariants) in programs written in most of the .Net family of languages. Contracts can be used to constrain fields, parameters and function results to be non-null, as is illustrated by the following excerpt of the [NonNullStack.cs][] example taken from [Fahndrich and Logozzo, 2010][]:

```java
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

- `arr` field, as well as elements of the `arr` array, in the object invariant,
- `x` parameter of `Push()` in the requires clause,
- return result of `Pop()` in the ensures clause.

Of course, a contract language like this can be used to do much more than assert that fields, variables and results are non-null. 

#### (b) Non-null declarators {-}

The same approach to nullity as [Code Contracts][] was originally adopted in \label{JML}<a name="JML">[Java Modeling Language][] (**JML**)</a>, a <a name="BISL">[Behavioral Interface Specification Language][BISL paper] (**BISL**)</a> for Java. But nullity constraints were so common that declarator annotations were defined as "syntactic sugar" for corresponding contract clauses. E.g., the `NonNullStack` example from above could have been written as:

```java
public class NonNullStack<T> ... {
  protected /*@non_null*/ T /*@non_null*/ [] arr;
  public void Push(/*@non_null*/T x) { ... }
  public /*@non_null*/T Pop() { ... }
  ...
}
```

But such an approach actually arose in [JML][] prior to the advent of Java generics. Nullity declarator constraints cannot be used to qualify type parameters, a feature often requested by developers.

Other languages supporting nullity declarators include the [Larch][] family of [BISL][]s, notably Larch/C (LCL) and [Larch/C++][]. The [Splint][] linter mentioned above ([I.2](#strategies)) grew out of Larch/C work.

#### (c) Non-null types {-}

Evolution of language extensions has sometimes been from nullity annotations applied to *declarators* to support for *non-null types*. This has been the case for [JML][] ([Chalin et al., 2008][]). In fact, the need to fully support non-null types in Java led to the creation of [JSR-308][], "[Java Type Annotations][JSR-308 explained]" which extends support for annotations to all places type expressions can appear. There has been hints that a similar extension might be considered useful for Dart as well ([B.4.6](#type-anno-alt)). [JSR-308][] was included in the March 2014 release of Java 8.

Other language extensions supporting non-null types include:

- [Eclipse JDT][]. The progression, from support of nullity declarator annotations to non-null types, in the context of the [Eclipse JDT][], was discussed in [A.3.1](#why-nn-types). Not only does the most recent release of the [Eclipse JDT][] support non-null types, but it also allows developers to enable [NNBD][] at [various levels of granularity][Eclipse help, improve code quality], including the project and workspace levels.
- [Nullness Checker][] of the Java [Checker Framework][].
- [JastAdd][], a "meta-compilation system that supports Reference Attribute Grammars" and one of its instances, the JastAddJ compiler for Java, has an extension supporting [non-null types][JastAddJ non-null extension].
- [Spec#][] a [BISL][] for [C#][].

All of these language extensions, except possibly [JastAdd][] also support [NNBD][].

### I.3.2 Language evolution {#language-evolution}

As was mentioned earlier, adopting non-null types and/or [NNBD][] can be a challenge for languages with a sufficiently large deployed code base. Having a proper [migration strategy](#part-migration) is key.

To our knowledge, [Eiffel][] is the first _commercial language_ to have made the switch, in 2005, from non-null types with a nullable-by-default semantics to [NNBD][]. [Eiffel][] introduced the `!` meta type annotation solely for easing migration efforts.

Adopting non-null types can lead to unsoundness if one is not careful, particularly with respect to the initialization of fields declared non-null ([B.4.2](#var-init-alt))---e.g., due to possible calls to helper methods from within constructors. [Fahndrich and Leino, 2003][], detail the challenges they faced in bringing non-null types to [Spec#][]. [Swift][], in which types are non-null by default, adopts [such a position][Swift on initialization] for classes and structures which: "_must set all of their stored properties to an appropriate initial value by the time an instance of that class or structure is created. Stored properties cannot be left in an indeterminate state_".

Some feel that the cost of preserving type soundness is too high with respect to language usability. Eberhardt discusses the challenges in writing proper class/structure initialization code in [Swift][] ([Eberhardt, 2014][]). Similar initialization rules are also know to be one of the difficulties facing language designers attempting to add [support for non-null types][C# non-nullable proposal] to [C#][]. In fact, Lippert believes that it is completely impractical to retrofit [C#][] with non-null types and instead proposes use of [Code Contracts][] ([Lippert, 2013][]).

We mention in passing that in 2005, .Net was extended with support for nullable _primitive_ types. This was done to achieve (uniform) native support for data coming from datasources in which all types are nullable. But this is creating an extra challenge, in terms of notational consistency, for C# language designers who are considering the introduction of [non-null types into C# 7][C# non-nullable proposal], as is illustrated by the following sample declarations:

```java
// C# + nullity proposal
int a; //non-nullable value type
int? a; //nullable value type
string! a; //non-nullable reference type
string a; //nullable reference type
```

## I.4 Modern web/mobile languages with non-null types and [NNBD][] {#modern-lang-nnbd}

[Fletch][] is an experimental runtime (VM) for Dart "that makes it possible to implement highly concurrent programs in the Dart". Meant to address problems in a similar space, is the [Pony][] language ([@0.1.5][Pony GitHub] 2015Q2), a statically typed actor-based language (with concurrent garbage collection). [Pony][] has non-null types and [NNBD][] with nullable types introduced via a union with special [unit type][] `None`.

For sake of completeness, we also reproduce here (from [2.2](#precedent)) the list of programming languages, many recently released, that are relevant to web applications (either dialects of [JS][] or that compile to [JS][]) and/or mobile, and that support _non-null types_ and [NNBD][].

|      Language        |                 About              | v1.0?  | Nullable via  | Reference
| -------------------- | ---------------------------------- | ------ | ------------- | ---------
|[Ceylon][] (Red Hat)|Compiles to [JS][], [Java Bytecode][JB] (**JB**)|2013Q4| *T*?  | [Ceylon optional types][]
| [Fantom][]         | Compiles to [JS][], [JB][], .Net CLR | 2005   | *T*?          | [Fantom nullable types][]
| [Flow][] (Facebook)  | [JS][] superset and static checker | 2014Q4 | *T*?          | [Flow maybe types][]
| [Kotlin][] (JetBrains)| Compiles to [JS][] and [JB][]     | 2011Q3 | *T*?          | [Kotlin null safety][]
| [Haste][]            | [Haskell][] to [JS][] compiler     | @0.4.4 |[option type][]| [Haskell maybe type][]
| [Swift][] (Apple)    | iOS/OS X Objective-C successor     | 2014Q4 |[option type][]| [Swift optional type][]

As was mentioned earlier, there is also [discussion](#precedent) of introducing non-null types to [TypeScript][].
