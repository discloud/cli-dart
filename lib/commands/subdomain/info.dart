import "dart:async";
import "dart:io";

import "package:args/command_runner.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/ascii_table.dart";
import "package:discloud/utils/messages.dart";

final class SubdomainInfoCommand extends Command<void> {
  SubdomainInfoCommand() {
    argParser.addOption("id", aliases: const ["subdomain"], defaultsTo: "all");
  }

  @override
  final name = "info";

  @override
  final description = "Get information of your subdomains";

  @override
  Future<void> run() async {
    final String id = argResults!.option("id")!;

    final spinner = context.printer.spin(text: "Fetching subdomain info...");

    final response = await context.api.get("/subdomain/$id");

    spinner.success(resolveResponseMessage(response));

    switch (response["subdomain"] ?? response["subdomains"]) {
      case final List list:
        stdout.writeln(listToAsciiTable(list));
        break;
      case final Map data:
        stdout.writeln(mapToVerticalAsciiTable(data));
        break;
    }
  }
}
