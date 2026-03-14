import "dart:convert";
import "dart:io";
import "dart:isolate";

extension HttpClientResponseExtension on HttpClientResponse {
  Future<List<int>> get bodyBytes => reduce((p, e) => p..addAll(e));

  bool get ok => statusCode < 400;

  Future<String> get body => transform(utf8.decoder).join();

  Future<Map<String, dynamic>> json() async {
    final body = await this.body;
    return Isolate.run(() => jsonDecode(body));
  }
}
