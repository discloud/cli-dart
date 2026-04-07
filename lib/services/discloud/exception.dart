import "package:freezed_annotation/freezed_annotation.dart";

part "exception.freezed.dart";

@Freezed(map: .all, unionKey: "code", when: .all)
abstract interface class DiscloudApiException
    with _$DiscloudApiException
    implements Exception {
  const factory DiscloudApiException({
    @Default(500) final int code,
    @Default("Unknown") final String message,
    @Default("/") final String path,
    final Map? body,
    final String? logs,
    final List<dynamic>? localeList,
  }) = _DiscloudApiException;

  @override
  String toString() {
    final buffer = StringBuffer("[Error $code]: $message");

    if (localeList case final localeList? when localeList.isNotEmpty) {
      buffer.write(" (${localeList.join(", ")})");
    }

    if (logs case final logs? when logs.isNotEmpty) buffer.write("\n$logs");

    return buffer.toString();
  }
}
