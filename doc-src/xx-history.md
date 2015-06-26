# Revision History {-}

Major updates are documented here.

## 2016.02.26 (0.6.0) {#rev-060}

**New**

- [B.3.7](#type-promotion). Type promotion.
- [B.3.8](#lub). Type least upper bound.
- [B.3.9](#null-awareoperators). Null-aware operators. (Placeholder, section TBC)

## 2016.02.24 (0.5.0) {#rev-050}

The main change is the addition of [Appendix II. Tooling and preliminary experience report](#appendix-tooling). In terms of individuals section changes we have:

**New**

- [B.3.5](#new-assignment-semantics). Adjusted semantics for "assignment compatible" ($\Longleftrightarrow$).
- [B.3.6](#multi-members). Static semantics of members of ?T.
- [E.1.1.1](#non-null-init). Optional parameters with non-null initializers are non-null.
- [E.1.1.2](#field-param). Default field parameters are single view.
- [E.3.5](#catch-type-qualification). Catch target types and meta type annotations.
- [E.3.6](#local-var-analysis). Reducing the annotation burden for local variables, an alternative.
- [E.3.7](#style-guide-object). Dart Style Guide on `Object` vs. `dynamic`.

**Updated**

- [B.2.1](#new-root). Ensuring `Object` is non-null: elect `_Anything` as a new root. Updated `_Basic` declaration and associated prose since the analyzer expects the `==` operator to be defined for `Null`.
- [E.1.1](#opt-func-param). Optional parameters are nullable-by-default in function bodies only. Now makes reference to cases [E.1.1.1](#non-null-init) and [E.1.1.2](#field-param).
- [G.2](#g-2-migration-aids). Adjusted name of nullity-scope annotations. Clarified the extent of the scope of `@nullable_by_default`, and that such annotations can also be applied to `part`s.
