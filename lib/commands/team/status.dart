import "dart:async";

import "package:args/command_runner.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/ascii_table.dart";
import "package:discloud/utils/messages.dart";

const _keysToIgnore = {"netIO"};

final class TeamStatusCommand extends Command<void> {
  new() {
    argParser.addOption("app");
  }

  @override
  final name = "status";

  @override
  final description = "Get status of your app";

  @override
  Future<void> run() async {
    final appId = argResults!.requiredOptionOrRest("app");

    final spinner = context.printer.spin(text: "Fetching app status...");

    final response = await context.api.get("/team/$appId/status");

    spinner.success(resolveResponseMessage(response));

    if (response["apps"] case final data?) {
      context.printer.writeln(mapToVerticalAsciiTable(data, _keysToIgnore));
    }
  }
}
