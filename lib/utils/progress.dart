import "package:discloud/utils/bytes.dart";
import "package:discloud/utils/formatters.dart";

enum SpeedSymbol {
  up("↑"),
  down("↓");

  const SpeedSymbol(this.symbol);

  final String symbol;

  @override
  String toString() => symbol;
}

String formatProgressMessage({
  required int processed,
  required int total,
  double? speed,
  SpeedSymbol? symbol,
  String prefixText = "Processing:",
}) {
  final buffer = StringBuffer("$prefixText ");

  if (speed case final speed?) {
    buffer.writeAll([?symbol, Bytes.bits(speed), "/s "]);
  }

  buffer.write(percentFormatter.format(processed / total));

  return buffer.toString();
}
