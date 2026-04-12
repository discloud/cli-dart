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
  final buffer = StringBuffer("$prefixText ");

  if (speed case final speed?) {
    buffer.writeAll([?direction, Bytes.bits(speed), "/s "]);
  }

  buffer.write(percentFormatter.format(processed / total));

  return buffer.toString();
}
