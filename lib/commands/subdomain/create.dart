import "dart:async";

import "package:args/command_runner.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/ascii_table.dart";
import "package:discloud/utils/messages.dart";

final class SubdomainCreateCommand extends Command<void> {
  SubdomainCreateCommand() {
    argParser.addOption("id", aliases: const ["subdomain"]);
  }

  @override
  final name = "create";

  @override
  final description = "Create a subdomain";

  @override
  Future<void> run() async {
    final id = argResults!.requiredOptionOrRest("id");

    final spinner = context.printer.spin(text: "Creating $id...");

    final response = await context.api.post("/subdomain/$id");

    spinner.success(resolveResponseMessage(response));

    context.printer.writeln(mapToVerticalAsciiTable(response["subdomain"]));
  }
}
