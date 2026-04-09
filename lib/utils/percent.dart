String percent(num actual, num total, [int fractionDigits = 2]) {
  return (actual / total * 100).toStringAsFixed(fractionDigits);
}
