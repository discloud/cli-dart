import "dart:convert";
import "dart:io";

import "package:discloud/extensions/io_http_client.dart";
import "package:discloud/services/discloud/exception.dart";
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
    if (response.headers.contentType case final contentType?) {
      switch (contentType.mimeType) {
        case _jsonContentType:
          return response.json();
      }
    }

    return null;
  }

  factory DiscloudApiClient({HttpClient? client}) =>
      DiscloudApiClient._(client: client ?? .new());

  const DiscloudApiClient._({required HttpClient client}) : _client = client;

  final HttpClient _client;

  @override
  void dispose() {
    _client.close();
  }

  Future<T> delete<T extends Map>(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? query,
  }) async {
    final url = _resolveUrl(path, query: query);

    final request = await _client.deleteUrl(url);

    _prepareRequest(request, headers: headers);

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

  Future<T> get<T extends Map>(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? query,
  }) async {
    final url = _resolveUrl(path, query: query);

    final request = await _client.getUrl(url);

    _prepareRequest(request, headers: headers);

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

    _prepareRequest(request, body: body, headers: headers);

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

    _prepareRequest(request, body: body, headers: headers);

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

  void _prepareRequest(
    HttpClientRequest request, {
    Map<String, String>? headers,
    Map? body,
  }) {
    if (Platform.environment["DISCLOUD_TOKEN"] case final value?) {
      request.headers.add("api-token", value);
    }

    if (headers case final headers?) {
      for (final entry in headers.entries) {
        request.headers.add(entry.key, entry.value);
      }
    }

    if (body case final body?) {
      request
        ..headers.contentType = .json
        ..write(jsonEncode(body));
    }
  }
}
