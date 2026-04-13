import "dart:convert";
import "dart:io";
import "dart:math";

import "package:discloud/cli/context.dart";
import "package:discloud/cli/disposable.dart";
import "package:discloud/extensions/file.dart";
import "package:discloud/extensions/io_http_client.dart";
import "package:discloud/extensions/string.dart";
import "package:discloud/services/discloud/exception.dart";
import "package:discloud/services/discloud/user_agent.dart";
import "package:discloud/services/discloud/utils.dart";
import "package:path/path.dart";

typedef VoidUploadProgressCallback = void Function(int processed);
typedef VoidUploadDoneCallback = void Function();

class DiscloudApiClient implements Disposable {
  static const _apiScheme = "https";
  static const _apiHost = "api.discloud.app";
  static const _apiVersion = 2;
  static const _apiVersionPath = "v$_apiVersion";
  static const _slash = "/";
  static const _jsonContentType = "application/json";
  static const _apiTokenHeader = "api-token";
  static const UserAgent _userAgent = .new();

  static CliContext get _context => .I;

  static Uri _resolveUrl(String path, {Map<String, String>? query}) {
    Iterable<String> segments = path.split(_slash);
    if (segments.first.isEmpty) segments = segments.skip(1);
    return .new(
      scheme: _apiScheme,
      host: _apiHost,
      pathSegments: const [_apiVersionPath].followedBy(segments),
      queryParameters: query,
    );
  }

  static Future<Map?> _resolveResponseBody(HttpClientResponse response) async {
    _context.printer.debug(
      StringBuffer()..writeAll([
        "[Response] status: ${response.statusCode} ${response.reasonPhrase}",
        "[Response] content length: ${response.contentLength}",
      ], "\n"),
    );

    if (response.headers.contentType case final contentType?) {
      _context.printer.debug("[Response] content type: $contentType");

      switch (contentType.mimeType) {
        case _jsonContentType:
          final body = await response.json();
          _context.printer.debug(body);
          return body;
      }
    }

    return null;
  }

  factory DiscloudApiClient({HttpClient? client}) =>
      DiscloudApiClient._(client: client ?? .new());

  const DiscloudApiClient._({required HttpClient client}) : _client = client;

  final HttpClient _client;

  Future<String?> get _maybeToken async =>
      Platform.environment["DISCLOUD_TOKEN"] ??
      await _context.store.get("token");

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

    _context.printer.debug("DELETE ${url.path}");

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

    _context.printer.debug("GET ${url.path}");

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

    _context.printer.debug("POST ${url.path}");

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

    _context.printer.debug("PUT ${url.path}");

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

  Future<T> postMultipart<T extends Map>(
    String path, {
    required File file,
    Map<String, String>? fields,
    Map<String, String>? headers,
    VoidUploadDoneCallback? onUploadDone,
    VoidUploadProgressCallback? onUploadProgress,
  }) async {
    final url = _resolveUrl(path);

    final request = await _client.postUrl(url);

    await _uploadMultipart(
      request: request,
      file: file,
      fields: fields,
      headers: headers,
      onUploadDone: onUploadDone,
      onUploadProgress: onUploadProgress,
    );

    final response = await request.close();

    final body = await _resolveResponseBody(response);

    if (response.ok) return body as T;

    throw DiscloudApiException(
      code: response.statusCode,
      message: body?["message"] ?? response.reasonPhrase,
      logs: body?["logs"],
      path: path,
    );
  }

  Future<T> putMultipart<T extends Map>(
    String path, {
    required File file,
    Map<String, String>? fields,
    Map<String, String>? headers,
    VoidUploadDoneCallback? onUploadDone,
    VoidUploadProgressCallback? onUploadProgress,
  }) async {
    final url = _resolveUrl(path);

    final request = await _client.putUrl(url);

    await _uploadMultipart(
      request: request,
      file: file,
      fields: fields,
      headers: headers,
      onUploadDone: onUploadDone,
      onUploadProgress: onUploadProgress,
    );

    final response = await request.close();

    final body = await _resolveResponseBody(response);

    if (response.ok) return body as T;

    throw DiscloudApiException(
      code: response.statusCode,
      message: body?["message"] ?? response.reasonPhrase,
      logs: body?["logs"],
      path: path,
    );
  }

  Future<void> _uploadMultipart({
    required HttpClientRequest request,
    required File file,
    VoidUploadProgressCallback? onUploadProgress,
    VoidUploadDoneCallback? onUploadDone,
    Map<String, String>? fields,
    Map<String, String>? headers,
  }) async {
    final now = DateTime.now();
    final boundary = "formBoundary${now.microsecondsSinceEpoch}";
    final filename = file.uri.pathSegments.last;
    final fileExtension = extension(filename);

    await _prepareRequest(request, headers: headers ??= {});

    request.headers.contentType = .new(
      "multipart",
      "form-data",
      parameters: {"boundary": boundary},
    );

    if (fields case final fields?) {
      for (final e in fields.entries) {
        request.write(
          "--$boundary\r\n"
          "Content-Disposition: form-data; "
          'name="${e.key}"\r\n\r\n${e.value}\r\n',
        );
      }
    }

    request.write(
      "--$boundary\r\n"
      "Content-Disposition: form-data; "
      'name="file"; '
      'filename="$filename"\r\n'
      "Content-Type: application/$fileExtension\r\n\r\n",
    );

    int processed = 0;
    await for (final data in file.openRead()) {
      request.add(data);

      onUploadProgress?.call(processed += data.length);
    }

    request.write("\r\n--$boundary--\r\n");

    await file.safeDelete();

    onUploadDone?.call();
  }

  Future<void> _prepareRequest(
    HttpClientRequest request, {
    Map<String, String>? headers,
    Map? body,
  }) async {
    final sb = StringBuffer();

    bool hasApiToken = false;
    if (headers case final headers?) {
      hasApiToken = headers.containsKey(_apiTokenHeader);

      for (final entry in headers.entries) {
        request.headers.set(entry.key, entry.value);
        sb.writeln("[Request] Header: ${entry.key}:${entry.value.length}");
      }
    }

    if (!hasApiToken) {
      if (await _maybeToken case final value?) {
        request.headers.set(_apiTokenHeader, value);
        sb.writeln("[Request] Header: $_apiTokenHeader:${value.length}");
      }
    }

    if (!isDiscloudJwt(request.headers.value(_apiTokenHeader).orEmpty)) {
      _context.printer.debug(sb);
      throw const DiscloudApiException(
        code: 401,
        message: "Please use the discloud login command first.",
      );
    }

    final userAgent = _userAgent.toString();

    request.headers.set(HttpHeaders.userAgentHeader, userAgent);

    sb.writeln("[Request] Header: ${HttpHeaders.userAgentHeader}:$userAgent");

    if (body case final body?) {
      request
        ..headers.contentType = .json
        ..write(jsonEncode(body));
    }

    sb.write("[Request] Body: ${body?.length}");

    _context.printer.debug(sb);
  }
}
