import "dart:convert";
import "dart:io";

import "package:discloud/cli/context.dart";
import "package:discloud/extensions/io_http_client.dart";
import "package:discloud/extensions/string.dart";
import "package:discloud/services/discloud/exception.dart";
import "package:discloud/services/discloud/utils.dart";
import "package:discloud/structures/disposable.dart";

class DiscloudApiClient implements Disposable {
  static const _apiVersion = 2;
  static const _jsonContentType = "application/json";

  static Uri _resolveUrl(String path, {Map<String, String>? query}) {
    return .new(
      scheme: "https",
      host: "api.discloud.app",
      pathSegments: const ["v$_apiVersion"].followedBy(path.split("/")),
      queryParameters: query,
    );
  }

  static Future<Map?> _resolveResponseBody(HttpClientResponse response) async {
    CliContext.I.debug(
      "Response status: ${response.statusCode} ${response.reasonPhrase}"
      "\n"
      "Response content length: ${response.contentLength}",
    );

    if (response.headers.contentType case final contentType?) {
      CliContext.I.debug("Response content type: $contentType");

      switch (contentType.mimeType) {
        case _jsonContentType:
          final body = await response.json();
          CliContext.I.debug(body);
          return body;
      }
    }

    return null;
  }

  factory DiscloudApiClient({HttpClient? client}) =>
      DiscloudApiClient._(client: client ?? .new());

  const DiscloudApiClient._({required HttpClient client}) : _client = client;

  final HttpClient _client;

  CliContext get context => .I;

  Future<String?> get _maybeToken async =>
      Platform.environment["DISCLOUD_TOKEN"] ??
      await context.store.get("token");

  @override
  void dispose() {
    _client.close();
  }

  Future<T> delete<T extends Map>(
    String path, {
    Map? body,
    Map<String, String>? headers,
    Map<String, String>? query,
  }) async {
    final url = _resolveUrl(path, query: query);

    final request = await _client.deleteUrl(url);

    await _prepareRequest(request, body: body, headers: headers);

    final response = await request.close();

    final responseBody = await _resolveResponseBody(response);

    if (response.ok) return responseBody as T;

    throw DiscloudApiException(
      code: responseBody?["code"] ?? response.statusCode,
      message: responseBody?["message"] ?? response.reasonPhrase,
      logs: responseBody?["logs"],
      path: path,
      body: body,
    );
  }

  Future<T> get<T extends Map>(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? query,
  }) async {
    final url = _resolveUrl(path, query: query);

    final request = await _client.getUrl(url);

    await _prepareRequest(request, headers: headers);

    final response = await request.close();

    final responseBody = await _resolveResponseBody(response);

    if (response.ok) return responseBody as T;

    throw DiscloudApiException(
      code: responseBody?["code"] ?? response.statusCode,
      message: responseBody?["message"] ?? response.reasonPhrase,
      logs: responseBody?["logs"],
      path: path,
    );
  }

  Future<T> post<T extends Map>(
    String path, {
    Map? body,
    Map<String, String>? headers,
    Map<String, String>? query,
  }) async {
    final url = _resolveUrl(path, query: query);

    final request = await _client.postUrl(url);

    await _prepareRequest(request, body: body, headers: headers);

    final response = await request.close();

    final responseBody = await _resolveResponseBody(response);

    if (response.ok) return responseBody as T;

    throw DiscloudApiException(
      code: responseBody?["code"] ?? response.statusCode,
      message: responseBody?["message"] ?? response.reasonPhrase,
      logs: responseBody?["logs"],
      path: path,
      body: body,
    );
  }

  Future<T> put<T extends Map>(
    String path, {
    Map? body,
    Map<String, String>? headers,
    Map<String, String>? query,
  }) async {
    final url = _resolveUrl(path, query: query);

    final request = await _client.putUrl(url);

    await _prepareRequest(request, body: body, headers: headers);

    final response = await request.close();

    final responseBody = await _resolveResponseBody(response);

    if (response.ok) return responseBody as T;

    throw DiscloudApiException(
      code: responseBody?["code"] ?? response.statusCode,
      message: responseBody?["message"] ?? response.reasonPhrase,
      localeList: responseBody?["localeList"],
      logs: responseBody?["logs"],
      path: path,
      body: body,
    );
  }

  Future<HttpClientResponse> postMultipart(
    String path, {
    required File file,
    Map<String, String>? fields,
    Map<String, String>? headers,
  }) async {
    final url = _resolveUrl(path);

    final request = await _client.postUrl(url);

    await _uploadMultipart(
      request: request,
      file: file,
      fields: fields,
      headers: headers,
    );

    final response = await request.close();

    if (response.ok) return response;

    final body = await response.json();

    throw DiscloudApiException(
      code: response.statusCode,
      message: body["message"] ?? response.reasonPhrase,
      logs: body["logs"],
    );
  }

  Future<HttpClientResponse> putMultipart(
    String path, {
    required File file,
    Map<String, String>? fields,
    Map<String, String>? headers,
  }) async {
    final url = _resolveUrl(path);

    final request = await _client.putUrl(url);

    await _uploadMultipart(
      request: request,
      file: file,
      fields: fields,
      headers: headers,
    );

    final response = await request.close();

    if (response.ok) return response;

    final body = await response.json();

    throw DiscloudApiException(
      code: response.statusCode,
      message: body["message"] ?? response.reasonPhrase,
      logs: body["logs"],
    );
  }

  Future<void> _uploadMultipart({
    required HttpClientRequest request,
    required File file,
    Map<String, String>? fields,
    Map<String, String>? headers,
  }) async {
    final now = DateTime.now();
    final boundary = "formBoundary${now.microsecondsSinceEpoch}";
    final fileName = file.uri.pathSegments.last;

    await _prepareRequest(request, headers: headers ??= {});

    for (final e in headers.entries) {
      request.headers.add(e.key, e.value);
    }

    request.headers.contentType = .new(
      "multipart",
      "form-data",
      parameters: {"boundary": boundary},
    );

    if (fields case final fields?) {
      for (final e in fields.entries) {
        request
          ..write("--$boundary\r\n")
          ..write('Content-Disposition: form-data; name="${e.key}"\r\n\r\n')
          ..write("${e.value}\r\n");
      }
    }

    request
      ..write("--$boundary\r\n")
      ..write(
        'Content-Disposition: form-data; name="file"; filename="$fileName"\r\n',
      )
      ..write("Content-Type: application/zip\r\n\r\n");

    await request.addStream(file.openRead());

    await file.delete();

    request.write("\r\n--$boundary--\r\n");
  }

  Future<void> _prepareRequest(
    HttpClientRequest request, {
    Map<String, String>? headers,
    Map? body,
  }) async {
    if (await _maybeToken case final value?) {
      request.headers.set("api-token", value);
    }

    if (headers case final headers?) {
      for (final entry in headers.entries) {
        request.headers.set(entry.key, entry.value);
      }
    }

    if (!isDiscloudJwt(request.headers.value("api-token").orEmpty)) {
      throw const DiscloudApiException(
        code: 401,
        message: "Please use the discloud login command first.",
      );
    }

    if (body case final body?) {
      request
        ..headers.contentType = .json
        ..write(jsonEncode(body));
    }
  }
}
