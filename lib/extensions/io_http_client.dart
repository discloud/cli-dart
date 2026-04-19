import "dart:convert";
import "dart:io";
import "dart:isolate";

extension HttpClientResponseExtension on HttpClientResponse {
  static const _badRequestStatusCode = 400;

  bool get ok => statusCode < _badRequestStatusCode;

  Future<List<int>> get bodyBytes async => [await for (final e in this) ...e];

  Future<String> get body => transform(utf8.decoder).join();

  Future<Map<String, dynamic>> json() async {
    final body = await this.body;
    return Isolate.run(() => jsonDecode(body));
  }
}
