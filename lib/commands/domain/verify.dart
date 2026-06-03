import "dart:async";
import "dart:io";

import "package:args/command_runner.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/ascii_table.dart";
import "package:discloud/utils/messages.dart";

final class CustomdomainVerifyCommand extends Command<void> {
  CustomdomainVerifyCommand() {
    argParser.addOption("id", aliases: const ["domain"], mandatory: true);
  }

  @override
  final name = "verify";

  @override
  final description = "Verify a domain";

  @override
  Future<void> run() async {
    final String domain = argResults!.option("id")!;

    final spinner = context.printer.spin(text: "Verifying a domain...");

    final response = await context.api.get("/customdomain/$domain/verify");

    spinner.success(resolveResponseMessage(response));

    stdout.writeln(mapToVerticalAsciiTable(response["domain"]));
  }
}
