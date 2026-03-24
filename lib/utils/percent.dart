double percent(num actual, num total, [int precision = 2]) {
  return .parse((actual / total * 100).toStringAsPrecision(precision));
}
