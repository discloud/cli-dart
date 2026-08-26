import "dart:async";

import "package:args/command_runner.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/messages.dart";

final class CustomdomainDeleteCommand extends Command<void> {
  new() {
    argParser.addOption("id", aliases: const ["domain"]);
  }

  @override
  final name = "delete";

  @override
  final description = "Delete a domain";

  @override
  Future<void> run() async {
    final domain = argResults!.requiredOptionOrRest("id");

    final spinner = context.printer.spin(text: "Deleting $domain...");

    final response = await context.api.delete("/customdomain/$domain");

    spinner.success(resolveResponseMessage(response));
  }
}
