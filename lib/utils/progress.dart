import "package:discloud/extensions/num.dart";
import "package:discloud/utils/bytes.dart";
import "package:discloud/utils/formatters.dart";

enum UnitDirection {
  up("↑"),
  down("↓"),
  both("⇅");

  const UnitDirection(this.symbol);

  final String symbol;

  @override
  String toString() => symbol;
}

String formatProgressMessage({
  required int processed,
  required int total,
  double? speed,
  UnitDirection? direction,
  String prefixText = "Processing:",
}) {
  final StringBuffer buffer = .new(prefixText);

  if (speed case final speed?) {
    buffer.writeAll([" ", ?direction, Bytes.bits(speed * 8), "/s "]);
  }

  if (total.isNegativeOrZero) {
    buffer.write(Bytes(processed));
  } else {
    buffer.write(percentFormatter.format(processed / total));
  }

  return buffer.toString();
}
