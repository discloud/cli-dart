import "package:discloud/services/discloud/exception.dart";

String resolveResponseMessage<T>(T response) {
  switch (response) {
    case final Map r:
      String message = "${r["status"]}: ${r["message"]}";
      if (r["logs"] case final String logs? when logs.isNotEmpty) {
        message += "\n$logs";
      }
      return message;
    case final DiscloudApiException r:
      String message = "[Error ${r.code}]: ${r.message}";
      if (r.logs case final logs? when logs.isNotEmpty) {
        message += "\n$logs";
      }
      return message;
    case final Exception e:
      return e.toString();
    case final Error e:
      return e.toString();
    default:
      return "";
  }
}
