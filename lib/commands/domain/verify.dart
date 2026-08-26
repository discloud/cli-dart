import "dart:async";

import "package:args/command_runner.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/ascii_table.dart";
import "package:discloud/utils/messages.dart";

final class CustomdomainVerifyCommand extends Command<void> {
  new() {
    argParser.addOption("id", aliases: const ["domain"]);
  }

  @override
  final name = "verify";

  @override
  final description = "Verify a domain";

  @override
  Future<void> run() async {
    final domain = argResults!.requiredOptionOrRest("id");

    final spinner = context.printer.spin(text: "Verifying $domain...");

    final response = await context.api.get("/customdomain/$domain/verify");

    spinner.success(resolveResponseMessage(response));

    context.printer.writeln(mapToVerticalAsciiTable(response["domain"]));
  }
}
