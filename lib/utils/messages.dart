import "package:discloud/extensions/string.dart";
import "package:discloud/services/discloud/exception.dart";

String resolveResponseMessage<T>(T response) {
  switch (response) {
    case final Map r:
      final buffer = StringBuffer();

      buffer.writeAll([?r["status"], ?r["message"]], ": ");

      if (r["logs"] case final String logs? when logs.isNotEmpty) {
        if (buffer.isNotEmpty) buffer.write("\n");
        buffer.write(logs);
      }

      return buffer.toString().capitalize();
    case final DiscloudApiException e:
      final buffer = StringBuffer();

      buffer.write("[Error ${e.code}]: ${e.message}");

      if (e.localeList case final localeList? when localeList.isNotEmpty) {
        buffer.write(" (${localeList.join(", ")})");
      }

      if (e.logs case final logs? when logs.isNotEmpty) buffer.write("\n$logs");

      return buffer.toString();
    case final Exception e:
      return e.toString();
    case final Error e:
      return e.toString();
    default:
      return "";
  }
}
