import "dart:async";
import "dart:io";

import "package:args/command_runner.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/ascii_table.dart";
import "package:discloud/utils/messages.dart";

const _keysIgnore = {"avatar"};

class UserInfoCommand extends Command<void> {
  @override
  final name = "info";

  @override
  final description = "Get your information";

  @override
  Future<void> run() async {
    final spinner = context.printer.spin(text: "Fetching user info...");

    final response = await context.api.get("/user");
    spinner.success(resolveResponseMessage(response));

    if (response["user"] case final Map data) {
      stdout.writeln(mapToVerticalAsciiTable(data, _keysIgnore));
    }
  }
}
