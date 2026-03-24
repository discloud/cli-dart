String percent(num actual, num total, [int precision = 2]) {
  return (actual / total * 100).toStringAsPrecision(precision);
}
