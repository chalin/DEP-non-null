class Box< /*(...)*/ T /*extends (...) Object*/ > {
  final /*(non-null)*/ T _default; // non-null (G2.1)
  /*(matching)*/ T value; // match nullity of type parameter T (G2.3)

  Box(this._default, this.value);

  /*(nullable)*/ T maybeNull() => // nullable (G2.2)
      value == _default ? null : value;

  /*(non-null)*/ T neverNull() => value == null ? _default : value;
}
