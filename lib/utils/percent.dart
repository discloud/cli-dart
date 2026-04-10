import "package:intl/intl.dart";

final Map<int, NumberFormat> _formatters = .new();

String percent(
  num actual,
  num total, {
  int minimumFractionDigits = 1,
  int maximumFractionDigits = 2,
}) {
  final formatter = _formatters.putIfAbsent(
    minimumFractionDigits,
    () => .percentPattern()
      ..minimumFractionDigits = minimumFractionDigits
      ..maximumFractionDigits = maximumFractionDigits,
  );
  return formatter.format(actual / total);
}
