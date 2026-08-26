import "dart:async";

import "package:args/command_runner.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/ascii_table.dart";
import "package:discloud/utils/messages.dart";

final class SubdomainInfoCommand extends Command<void> {
  new() {
    argParser.addOption("id", aliases: const ["subdomain"], valueHelp: "all");
  }

  @override
  final name = "info";

  @override
  final description = "Get information of your subdomains";

  @override
  Future<void> run() async {
    final id = argResults!.optionOrRest("id") ?? "all";

    final spinner = context.printer.spin(text: "Fetching $id...");

    final response = await context.api.get("/subdomain/$id");

    spinner.success(resolveResponseMessage(response));

    switch (response["subdomain"] ?? response["subdomains"]) {
      case final List list:
        context.printer.writeln(listToAsciiTable(list));
        break;
      case final Map data:
        context.printer.writeln(mapToVerticalAsciiTable(data));
        break;
    }
  }
}
