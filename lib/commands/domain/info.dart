import "dart:async";
import "dart:io";

import "package:args/command_runner.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/ascii_table.dart";
import "package:discloud/utils/messages.dart";

class CustomdomainInfoCommand extends Command<void> {
  CustomdomainInfoCommand() {
    argParser.addOption("id", aliases: const ["domain"], defaultsTo: "all");
  }

  @override
  final name = "info";

  @override
  final description = "Get information of your domains";

  @override
  Future<void> run() async {
    final String domain = argResults!.option("id")!;

    final spinner = context.printer.spin(text: "Fetching domain info...");

    final response = await context.api.get("/customdomain/$domain");

    spinner.success(resolveResponseMessage(response));

    switch (response["customdomain"] ?? response["customdomains"]) {
      case final List list:
        stdout.writeln(listToAsciiTable(list));
        break;
      case final Map data:
        stdout.writeln(mapToVerticalAsciiTable(data));
        break;
    }
  }
}
