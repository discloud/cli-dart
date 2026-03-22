import "package:interact/src/framework/framework.dart";
import "package:interact/src/theme/theme.dart";
import "package:interact/src/utils/prompt.dart";

const _maxInt = 9223372036854775807;
const _minInt = -9223372036854775808;
const _numbers = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "0"};
const _signSymbol = "-";

class Integer extends Component<int> {
  Integer({required this.prompt, this.max, this.min})
    : assert(max == null || min == null || min <= max),
      theme = Theme.defaultTheme;

  final String prompt;

  final int? max;
  final int? min;

  final Theme theme;

  @override
  State<Integer> createState() => _Integer();
}

class _Integer extends State<Integer> {
  int value = 0;
  late final prompt = promptInput(
    theme: component.theme,
    message: component.prompt,
  );

  int get maxValue => component.max ?? _maxInt;
  int get minValue => component.min ?? _minInt;

  @override
  void init() {
    super.init();
    context.hideCursor();
  }

  @override
  void dispose() {
    context.writeln();
    super.dispose();
  }

  @override
  int interact() {
    while (true) {
      final key = context.readKey();

      if (key.isControl) {
        switch (key.controlChar) {
          case .backspace:
            setState(() {
              value ~/= 10;
            });
            break;
          case .enter:
            return value;
          default:
            break;
        }
        continue;
      }

      if (_numbers.contains(key.char)) {
        setState(() {
          final int newValue = value * 10 + .parse(key.char);
          value = newValue.clamp(minValue, maxValue);
        });
        continue;
      }

      if (key.char == _signSymbol) {
        setState(() {
          value *= -1;
        });
        continue;
      }
    }
  }

  @override
  void render() {
    final line = StringBuffer()
      ..write(prompt)
      ..write("$value");
    context.eraseLineAndWrite(line);
  }
}
