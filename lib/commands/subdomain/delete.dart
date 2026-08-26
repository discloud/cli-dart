import "dart:async";

import "package:args/command_runner.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/messages.dart";

final class SubdomainDeleteCommand extends Command<void> {
  new() {
    argParser.addOption("id", aliases: const ["subdomain"]);
  }

  @override
  final name = "delete";

  @override
  final description = "Delete a subdomain";

  @override
  Future<void> run() async {
    final id = argResults!.requiredOptionOrRest("id");

    final spinner = context.printer.spin(text: "Deleting $id...");

    final response = await context.api.delete("/subdomain/$id");

    spinner.success(resolveResponseMessage(response));
  }
}
