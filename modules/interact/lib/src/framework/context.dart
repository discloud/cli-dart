part of "framework.dart";

const _ansiEraseInLineAll = "\x1b[2K";
const _resetCursorPosition = "\x1b[0G";

/// [Context] is used by [Component] and [State] to actually render
/// things to the console, and to act as a state store during rendering,
/// which will store things such as the number or renderings done and the
/// amount of lines used by a specific render, so that the [State] can
/// clear old lines and render new stuffs automatically.
class Context {
  static final _console = Console();

  /// Resets the Console.
  static void reset() {
    _console
      ..showCursor()
      ..resetColorAttributes();
  }

  int _renderCount = 0;

  /// Indicates how many times the [Context] has rendered.
  int get renderCount => _renderCount;

  /// Increases the [renderCount] by one.
  void increaseRenderCount() => _renderCount++;

  /// Sets the [renderCount] to `0`.
  void resetRenderCount() => _renderCount = 0;

  int _linesCount = 0;

  /// Indicates how many lines the context is used for rendering.
  int get linesCount => _linesCount;

  /// Increases the [linesCount] by one.
  void increaseLinesCount() => _linesCount++;

  /// Sets the [linesCount] to `0`.
  void resetLinesCount() => _linesCount = 0;

  /// Removes the lines from the last render and reset the lines count.
  void wipe() {
    erasePreviousLine(linesCount);
    resetLinesCount();
  }

  /// Returns terminal width in terms of characters.
  int get windowWidth => _console.windowWidth;

  /// Shows the cursor.
  void showCursor() => _console.showCursor();

  /// Hide the cursor.
  void hideCursor() => _console.hideCursor();

  /// Writes a string to the console.
  void write(Object text) => _console.write(text);

  /// Increases the number of lines written for the current render,
  /// and writes a line to the the console.
  void writeln([Object? text]) {
    increaseLinesCount();
    _console.writeLine(text);
  }

  /// Erase one line above the current cursor by default.
  ///
  /// If the argument [n] is supplied, it will repeat the process
  /// to [n] times.
  void erasePreviousLine([int n = 1]) {
    for (int i = 0; i < n; i++) {
      _console
        ..cursorUp()
        ..eraseLine();
    }
  }

  void eraseLine() {
    _console.write(_ansiEraseInLineAll + _resetCursorPosition);
  }

  void eraseLineAndWrite(Object message) {
    _console.write("$_ansiEraseInLineAll$_resetCursorPosition$message");
  }

  /// Reads a key press, same as dart_console library's
  /// `readKey()` function but this function handles the `Ctrl+C` key
  /// press to immediately exit from the process.
  Key readKey() => _handleKey(_console.readKey());

  /// Reads a line, same as dart_console library's `readLine()` function,
  /// and it's partially taken from the source code of it and modified
  /// for custom use cases, such as accepting initial text as an argument,
  /// and allowing to disable rendering the key press, to use in the [Password]
  /// component.
  String readLine({String initialText = "", bool noRender = false}) {
    var buffer = initialText;
    var index = buffer.length;

    final screenRow = _console.cursorPosition?.row ?? 0;
    final screenColOffset = _console.cursorPosition?.col ?? 0;
    final bufferMaxLength = _console.windowWidth - screenColOffset - 3;

    if (buffer.isNotEmpty && !noRender) write(buffer);

    while (true) {
      final key = readKey();

      if (key.isControl) {
        switch (key.controlChar) {
          case .enter:
            writeln();
            return buffer;
          case .backspace:
          case .ctrlH:
            if (index > 0) {
              buffer = buffer.substring(0, index - 1) + buffer.substring(index);
              index--;
            }
            break;
          case .delete:
          case .ctrlD:
            if (index < buffer.length - 1) {
              buffer = buffer.substring(0, index) + buffer.substring(index + 1);
            }
            break;
          case .ctrlU:
            buffer = "";
            index = 0;
            break;
          case .ctrlK:
            buffer = buffer.substring(0, index);
            break;
          case .arrowLeft:
          case .ctrlB:
            index = index > 0 ? index - 1 : index;
            break;
          case .arrowRight:
          case .ctrlF:
            index = index < buffer.length ? index + 1 : index;
            break;
          case .wordLeft:
            if (index > 0) {
              final bufferLeftOfCursor = buffer.substring(0, index - 1);
              final lastSpace = bufferLeftOfCursor.lastIndexOf(" ");
              index = lastSpace != -1 ? lastSpace + 1 : 0;
            }
            break;
          case .home:
          case .ctrlA:
            index = 0;
            break;
          case .end:
          case .ctrlE:
            index = buffer.length;
            break;
          default:
            break;
        }
      } else {
        if (buffer.length < bufferMaxLength) {
          if (index == buffer.length) {
            buffer += key.char;
            index++;
          } else {
            buffer =
                buffer.substring(0, index) + key.char + buffer.substring(index);
            index++;
          }
        }
      }

      if (!noRender) {
        _console
          ..hideCursor() // Prevents the cursor jumping being seen
          ..cursorPosition = .new(screenRow, screenColOffset)
          ..eraseCursorToEnd();
        write(buffer);
        _console.cursorPosition = .new(screenRow, screenColOffset + index);
        _console.showCursor();
      }
    }
  }

  Key _handleKey(Key key) {
    if (key.isControl && key.controlChar == .ctrlC) {
      reset();
      exit(1);
    }
    return key;
  }
}

/// Unlike a normal [Context], [BufferContext] writes lines to a specified
/// [StringBuffer] and run a reload function on every line written.
///
/// Useful when waiting for a rendering context when there is multiple
/// of them rendering at the same time. [MultipleSpinner] component used it
/// so when [Spinner]s are being rendered, they get rendered to a [String].
/// It later used the [setState] function to rendered the whole [String]
/// containing multiple [BufferContext]s to the console.
class BufferContext extends Context {
  /// Constructs a [BufferContext] with given properties.
  BufferContext({required this.buffer, required this.setState});

  /// Buffer stores the lines written to the context.
  final StringBuffer buffer;

  /// Runs everytime something was written to the buffer.
  final void Function() setState;

  @override
  void writeln([Object? text]) {
    buffer
      ..clear()
      ..write(text);
    setState();
  }
}
