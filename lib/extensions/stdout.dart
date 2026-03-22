import "dart:io";
import "dart:math";

import "package:charcode/ascii.dart";

const _clearLineChars = [$esc, $lbracket, $0, $K];

const _goUpLineChars = [$esc, $lbracket, $1, $A];

const _maxGoLines = 100_000;

extension StdoutExtension on Stdout {
  void clearLine() {
    add(_clearLineChars);
  }

  void goUpLine() {
    add(_goUpLineChars);
  }

  void goUpAndClearLine({int lines = 1}) {
    lines = min(lines, _maxGoLines);
    final chars = _goUpLineChars.followedBy(_clearLineChars);
    add([for (int i = 0; i < lines; i++) ...chars]);
  }
}
