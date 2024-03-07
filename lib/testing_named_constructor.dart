class A {
  int a = 1;
  A.fromInt(int a) {
    this.a = a;
  }
  @override
  String toString() {
    return 'a = $a';
  }
}

A createFromInt(int a) {
  return A.fromInt(a);
}

List<A> testList = [
  A.fromInt(1),
  A.fromInt(2),
  A.fromInt(3),
];

void main() {
  print(testList);
  print(createFromInt(4));
}
