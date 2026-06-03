import "dart:async";

import "package:args/command_runner.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/messages.dart";

final class SubdomainDeleteCommand extends Command<void> {
  SubdomainDeleteCommand() {
    argParser.addOption("id", aliases: const ["subdomain"], mandatory: true);
  }

  @override
  final name = "delete";

  @override
  final description = "Delete a subdomain";

  @override
  Future<void> run() async {
    final String id = argResults!.option("id")!;

    final spinner = context.printer.spin(text: "Deleting subdomain...");

    final response = await context.api.delete("/subdomain/$id");

    spinner.success(resolveResponseMessage(response));
  }
}
