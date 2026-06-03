import "dart:convert";
import "dart:io";
import "dart:isolate";
import "dart:typed_data";

extension HttpClientResponseExtension on HttpClientResponse {
  static const _badRequestStatusCode = 400;

  bool get ok => statusCode < _badRequestStatusCode;

  Future<Uint8List> get bodyBytes async {
    if (contentLength case final length when !length.isNegative) {
      int index = 0;
      final Uint8List bytes = .new(length);
      await for (final e in this) {
        bytes.setAll(index, e);
        index += e.length;
      }
      return bytes;
    }

    final bytes = <int>[];
    await for (final e in this) {
      bytes.addAll(e);
    }
    return .fromList(bytes);
  }

  Future<String> get body => transform(utf8.decoder).join();

  Future<Map<String, dynamic>> json() async {
    final body = await this.body;
    return Isolate.run(() => jsonDecode(body));
  }
}
