import "dart:async";

import "package:args/command_runner.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/ascii_table.dart";
import "package:discloud/utils/messages.dart";

final class SnapshotCreateCommand extends Command<void> {
  new() {
    argParser.addOption("app");
  }

  @override
  final name = "create";

  @override
  final description = "Create a versioned snapshot of your app";

  @override
  Future<void> run() async {
    final String appId = argResults!.requiredOptionOrRest("app");

    final spinner = context.printer.spin(text: "Creating snapshot...");

    final response = await context.api.post("/snapshot/$appId");

    spinner.success(resolveResponseMessage(response));

    if (response["snapshot"] case final Map snapshot) {
      context.printer.writeln(mapToVerticalAsciiTable(_flatten(snapshot)));
    }
  }

  Map _flatten(Map snapshot) {
    return {"Version": snapshot["version"], "Size": snapshot["version"]};
  }
}
