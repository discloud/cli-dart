import "dart:io";

import "package:discloud/prompts/utils.dart";

Future<String> promptApiToken({String? message}) async {
  if (message case final message) stdout.write(message);

  stdin.echoMode = false;

  final charCodes = await stdin.first;

  goUpLine(stdout);

  return String.fromCharCodes(charCodes, 0, charCodes.length - 2);
}
