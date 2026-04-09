import "dart:async";
import "dart:io";

import "package:args/command_runner.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/ascii_table.dart";
import "package:discloud/utils/messages.dart";

const _keysToIgnore = {"netIO"};

class TeamStatusCommand extends Command<void> {
  TeamStatusCommand() {
    argParser.addOption("app", mandatory: true);
  }

  @override
  final name = "status";

  @override
  final description = "Get status of your app";

  @override
  Future<void> run() async {
    final appId = argResults!.option("app");

    final spinner = context.printer.spin(text: "Fetching app status...");

    final response = await context.api.get("/team/$appId/status");

    spinner.success(resolveResponseMessage(response));

    if (response["apps"] case final data?) {
      stdout.writeln(mapToVerticalAsciiTable(data, _keysToIgnore));
    }
  }
}
