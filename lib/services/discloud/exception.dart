import "package:freezed_annotation/freezed_annotation.dart";

part "exception.freezed.dart";

@Freezed(map: .all, unionKey: "code", when: .all)
abstract interface class DiscloudApiException
    with _$DiscloudApiException
    implements Exception {
  const factory({
    @Default(500) int code,
    @Default("Unknown") String message,
    @Default("/") String path,
    Map? body,
    String? logs,
    List<dynamic>? localeList,
  }) = _DiscloudApiException;
}
