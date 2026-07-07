import "dart:async";
import "dart:io";

import "package:args/command_runner.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/ascii_table.dart";
import "package:discloud/utils/messages.dart";

final class CustomdomainCreateCommand extends Command<void> {
  CustomdomainCreateCommand() {
    argParser
      ..addOption("id", aliases: const ["domain"])
      ..addOption("app", aliases: const ["subdomain"]);
  }

  @override
  final name = "create";

  @override
  final description = "Create a domain";

  @override
  Future<void> run() async {
    final domain = argResults!.requiredOptionOrRest("id");
    final subdomain = argResults!.requiredOptionOrRest("app", const ["id"]);

    final spinner = context.printer.spin(text: "Creating $domain...");

    final response = await context.api.post(
      "/customdomain/create",
      body: {"appID": subdomain, "domainName": domain},
    );

    spinner.success(resolveResponseMessage(response));

    stdout.writeln(mapToVerticalAsciiTable(response["domain"]));
  }
}
