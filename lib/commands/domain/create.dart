import "dart:async";
import "dart:io";

import "package:args/command_runner.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/ascii_table.dart";
import "package:discloud/utils/messages.dart";

final class CustomdomainCreateCommand extends Command<void> {
  CustomdomainCreateCommand() {
    argParser
      ..addOption("id", aliases: const ["domain"], mandatory: true)
      ..addOption("app", aliases: const ["subdomain"], mandatory: true);
  }

  @override
  final name = "create";

  @override
  final description = "Create a domain";

  @override
  Future<void> run() async {
    final String domain = argResults!.option("id")!;
    final String subdomain = argResults!.option("app")!;

    final spinner = context.printer.spin(text: "Creating domain...");

    final response = await context.api.post(
      "/customdomain/create",
      body: {"appID": subdomain, "domainName": domain},
    );

    spinner.success(resolveResponseMessage(response));

    stdout.writeln(mapToVerticalAsciiTable(response["domain"]));
  }
}
