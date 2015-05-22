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
