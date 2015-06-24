# Part F: Impact on Dart SDK libraries {- #part-libs}

The purpose of this part is to illustrate what some of the Dart SDK libraries might look like in [DartNNBD][] and, in some cases, how they might be adapted to be more useful, through stricter type signatures or other enhancements.

## F.1 Examples

The examples presented in this section are of types migrated to [DartNNBD][] that _only_ require updates through the addition of meta type annotations. Types potentially requiring behavioral changes are addressed in [F.2](#better-libs).

### F.1.1 `int.dart`{} {#int-nnbd}

We present here the `int` class with nullity annotations. There are only 3 nullable meta type annotations out of 44 places were such annotations could be placed (3/44 = 7% are nullable).

```dart
// DartNNBD - part of dart.core;
abstract class int extends num {
  external const factory ?int.fromEnvironment(String name, {int defaultValue});
  int operator &(int other);
  int operator |(int other);
  int operator ^(int other);
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

With the eventual added support for [generic functions][DEP-generic-functions], `parse()` could more usefully redeclared as:

```dart
  external static I parse<I extends ?int>(..., {..., I onError(String source)});
```

Notes:

- The `source` argument of `parse()` should be non-null, see [dart/runtime/lib/integers_patch.dart#L48][].
- In conformance to the [guideline of E.1.1](#guideline), the following optional parameters are left as [NNBD][]:

    - `defaultValue` of `factory int.fromEnvironment()`.
    - `radix` and `onError` of `parse()`. Since `radix` has a non-null default value, it could be declared as `!int`, though there is little value in doing so given that `parse()` is `external`.

    (In opposition to the guideline, if we declare `defaultValue` and `onError` as nullable, that would make for 5/44 = 11% of declarators with nullable annotations.)

We have noted that conforming to the [guideline for optional parameters](#guideline) of  [E.1.1](#opt-func-param) may result in breaking changes for some functions of SDK types. Other SDK type members explicitly document their adherence to the guideline: e.g., the `List([int length])` [constructor][Dart List constructor API].

### F.1.2 Iterable {#iterable-nnbd}

The `Iterable<E>` type requires no `?` annotations (thought the optional `separator` parameter of `join()` could be declared as `!String`).

```dart
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

### F.1.3 `Future<T>`

We mention in passing that the use of `Future<Null>` remains a valid idiom in [DartNNBD][] since the generic class is declared as:

```dart
abstract class Future<T> {...}
```

Hence `T` is nullable ([C.3.4](#default-type-param-bound)).

## F.2 Suggested library improvements {#better-libs}

### F.2.1 Iterator

#### [DartC][] {-}

An [`Iterator<E>`][Dart Iterator API] is "an interface for getting items, one at a time, from an object" via the following API:

```dart
// DartC - part of dart.core;
abstract class Iterator<E> {
  bool moveNext();
  E get current;
}
```

Here is an example of typical use (excerpt from the [API documentation][Dart Iterator API]):

```dart
var it = obj.iterator;
while (it.moveNext()) {
  use(it.current);
}
```

Dart's API documentation for `current` is nonstandard in that it specifies that `current` shall be `null` "_if the iterator has not yet been moved to the first element, or if the iterator has been moved past the last element_". This has the unfortunate consequence of forcing the return type of `current` to be nullable, even if the element type `E` is non-null. Iterators in other languages (such as Java and .Net languages) either [raise an exception][Iterator API, Java] or document the behavior of `current` as *undefined* under such circumstances---for the latter see, e.g., the [.Net IEnumerator<T>.Current Property API][].

#### [DartNNBD][] {-}

We suggest that that [Dart Iterator API][] documentation be updated to state that the behavior of `current` is unspecified when the last call to `moveNext()` returned false (implicit in this statement is that `moveNext()` *must* be called at least once before `current` is used). This would allow us to usefully preserve the interface definition of `Iterator<E>` as:

```dart
// DartNNBD - part of dart.core;
abstract class Iterator<E> {
  bool moveNext();
  E get current;
}
```

Note that the type and nullity of `current` matches that of the type parameter.

Independent of nullity, the behavior of `current` might be adapted so that it throws an exception if it is invoked in situations where its behavior is undefined. But this would be a potentially breaking change (which, thankfully, would not impact uses of iterators in `for`-`in` loops).

[.Net IEnumerator<T>.Current Property API]: https://msdn.microsoft.com/en-us/library/58e146b7(v=vs.110).aspx
[Iterator API, Java]: https://docs.oracle.com/javase/8/docs/api/java/util/Iterator.html

### F.2.2 `List<E>` {#list}

We comment on two members of the [`List<E>`][Dart List API] type.

#### `factory List<E>([int length])`{} {-}

In [DartNNBD][], a [dynamic type error][] will be raised if `length` is positive and `E` is non-null. The error message could suggest using `List<E>.filled(int length, E fill)` instead. 

#### `List<E>.length=`{} {-}

The [`List<E>.length=`][Dart List set length API] setter changes the length of a list. If the new length is greater than the current length, then new entries are initialized to `null`. This will cause a [dynamic type error][] to be issued when `E` is non-null.

Alternatives to growing a list of non-null elements includes:

- Define a mechanism by which an "filler field" could be associated with a list. The filler field could then be used by the length setter when growing a list of non-null elements. E.g.,

    - Add a `List<E>.setFiller(E filler)` method, or;
    - Reuse the filler provided, say, as argument to `List<E>.filled(int length, E fill)`.

- Add a new mutator, `setLength(int newLength, E filler)`.

## F.3 Other classes

### Object

The `Object` class requires no textual modifications:

```dart
class Object {
  const Object();
  bool operator ==(other) => identical(this, other);
  external int get hashCode;
  external String toString();
  external dynamic noSuchMethod(Invocation invocation);
  external Type get runtimeType;
}
```
