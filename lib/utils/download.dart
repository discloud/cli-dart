import "dart:io";

import "package:discloud/extensions/io_http_client.dart";

typedef VoidProgressCallback = void Function(int processed, int total);

Future<void> download(
  Uri url, {
  File? file,
  HttpClient? client,
  VoidProgressCallback? onProgress,
}) async {
  final client0 = client ?? .new();

  final request = await client0.getUrl(url);

  HttpClientResponse? response;
  try {
    response = await request.close();

    if (!response.ok) {
      throw HttpException(
        "Download failed: ${response.statusCode} ${response.reasonPhrase}",
        uri: url,
      );
    }
  } catch (e) {
    rethrow;
  } finally {
    if (client == null) client0.close();
  }

  file ??= .new(url.pathSegments.last);
  await file.parent.create(recursive: true);
  final sink = file.openWrite();

  try {
    if (onProgress case final onProgress?) {
      await _downloadWithProgress(
        onProgress: onProgress,
        response: response,
        sink: sink,
      );
    } else {
      await sink.addStream(response);
    }
  } catch (_) {
    await sink.close();
    await file.delete();
    rethrow;
  } finally {
    await sink.close();
    if (client == null) client0.close();
  }
}

Future<void> _downloadWithProgress({
  required VoidProgressCallback onProgress,
  required HttpClientResponse response,
  required IOSink sink,
}) async {
  final total = response.contentLength;

  int processed = 0;
  await for (final data in response) {
    sink.add(data);

    onProgress(processed += data.length, total);
  }
}
