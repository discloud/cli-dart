import "package:dart_jsonwebtoken/dart_jsonwebtoken.dart";

bool isDiscloudJwt(String token) {
  try {
    final jwt = JWT.decode(token);
    final payload = jwt.payload;
    return payload is Map &&
        payload.containsKey("id") &&
        payload.containsKey("key");
  } catch (_) {
    return false;
  }
}
