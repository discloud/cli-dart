import "dart:io";
import "dart:math";

import "package:charcode/ascii.dart";

const _clearLineChars = [$esc, $lbracket, $0, $K];

const _goUpLineChars = [$esc, $lbracket, $1, $A, ..._clearLineChars];

const _maxGoLines = 100_000;

void clearLine(Stdout stdout) {
  stdout.add(_clearLineChars);
}

void goUpLine(Stdout stdout, {int lines = 1}) {
  lines = min(lines, _maxGoLines);
  stdout.add([for (int i = 0; i < lines; i++) ..._goUpLineChars]);
}
