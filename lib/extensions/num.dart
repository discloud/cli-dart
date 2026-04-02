extension NumExtension on num {
  static const _zero = 0;

  bool get isPositive => !isNegative;
  bool get isZero => this == _zero;
}
