part of "context.dart";

const String _localePattern = r"^\w{2}[-_]\w{2}$";
final RegExp _localeRegexp = .new(_localePattern);
final String _localeName =
    _localeRegexp.firstMatch(Platform.localeName)?.input ??
    Intl.getCurrentLocale();
