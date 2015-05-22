const Null $null = null;

void main() {
  int i = null,
      j = $null,
      k = "a-string";
  print("i = $i, j = $j, k = $k");
  print("i is ${i.runtimeType}, j is ${j.runtimeType}");
  
  //---
  print(null is int); 
  // Output in production mode:
  // i = null, j = null, k = a-string
  // i is Null, j is Null
  // false
}
