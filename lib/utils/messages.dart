import "package:discloud/extensions/string.dart";
import "package:discloud/services/discloud/exception.dart";

String resolveResponseMessage<T>(T response) {
  switch (response) {
    case final Map r:
      String message = "${r["status"]}: ${r["message"]}".capitalize();
      if (r["logs"] case final String logs? when logs.isNotEmpty) {
        message += "\n$logs";
      }
      return message;
    case final DiscloudApiException e:
      String message = "[Error ${e.code}]: ${e.message}";
      if (e.localeList case final localeList? when localeList.isNotEmpty) {
        message += " (${localeList.join(", ")})";
      }
      if (e.logs case final logs? when logs.isNotEmpty) {
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
