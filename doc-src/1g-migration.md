# Part G: Migration strategy (sketch) {- #part-migration}

> Comment. An effective migration plan depends on several factors including, for example, whether union types will soon added to Dart or not. Regardless, this part sketches some initial ideas.

## G.1 Precedent

As is mentioned in the survey ([I.3](#retrofit)), both commercial and research languages have successfully migrated from a nullable-by-default to a [NNBD][] semantics. To our knowledge, [Eiffel][], in 2005, was the first commercial language to have successfully made this transition. [JML][], a Java [BISL][], made the transition a few years later ([Chalin et al., 2008][]). More recently, the [Eclipse JDT][] has been allowing developers to enable [NNBD][] at [various levels of granularity][Eclipse help, improve code quality], including at the level of an entire project or workspace, and work is underway to provide nullity annotations for the types in the SDK.

## G.2 Migration aids

It is interesting to note that [Eiffel][] introduced the `!` meta type annotation solely for purpose of code migration. [DartNNBD][] also has `!` at its disposal, though in our case it is a core feature.

We propose (as has been done in [JML][] and the [Eclipse JDT][]) that the following lexically scoped, non-inherited library and class level annotations be made available: `@NullableByDefault` and `@NonNullByDefault`. Such annotations establish the default nullity in the scope of the entity thus annotated.

## G.3 Impact

Tool impacted include (some common subsystems overlap):

- [Dart Analyzer][].
- [Dart Dev Compiler][].
- [Dart VM][].
- [dart2js][].
- [Dart Code Formatter][].
- [Dart docgen][].

## G.4 Migration steps

It seems desirable to target Dart 2.0 as a first release under which [NNBD][] would be the _default_ semantics. In Dart 2.0, a command line option could be provided to recover nullable-by-default semantics. Initial steps in preparation of this switch would be accomplished in stages in the remaining releases of the 1.x stream.

Here is a preliminary list of possible steps along this migration path, not necessarily in this order:

- (SDK) Create `@NullableByDefault` and `@NonNullByDefault` annotations.
- (Tooling) Add support for:
    - Meta type annotation _syntax_ (excluding most sugars).
    - Static checks. This includes processing of `@*ByDefault` annotations.
    - Runtime support ([B.3.3](#shared-type-op-semantics)) for nullity type operators, and dynamic checks.
- (SDK) Re-root the class hierarchy ([B.2.1](#new-root)).
- (Tooling) Global option to turn on [NNBD][].
- ...

## G.5 Migration plan details

> Comment. TODO.
