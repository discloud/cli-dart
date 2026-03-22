import "package:interact/src/theme/theme.dart";

/// Generates a formatted input message to prompt.
String promptInput({
  required Theme theme,
  required String message,
  String? hint,
}) {
  final buffer = StringBuffer()
    ..write(theme.inputPrefix)
    ..write(theme.messageStyle(message));

  if (hint != null) {
    buffer
      ..write(" ")
      ..write(theme.hintStyle(hint));
  }

  buffer
    ..write(theme.inputSuffix)
    ..write(" ");

  return buffer.toString();
}

/// Generates a success prompt, a message to indicates
/// the interaction is successfully finished.
String promptSuccess({
  required Theme theme,
  required String message,
  required String value,
}) {
  final buffer = StringBuffer()
    ..write(theme.successPrefix)
    ..write(theme.messageStyle(message))
    ..write(theme.successSuffix)
    ..write(theme.valueStyle(" $value "));

  return buffer.toString();
}

/// Generates a message to use as an error prompt.
String promptError({required Theme theme, required String message}) {
  final buffer = StringBuffer()
    ..write(theme.errorPrefix)
    ..write(theme.errorStyle(message));

  return buffer.toString();
}
