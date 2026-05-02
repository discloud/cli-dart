import "dart:async";

import "package:args/command_runner.dart";
import "package:discloud/cli/disposable.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/messages.dart";

class CustomdomainEditCommand extends Command<void> with Disposable {
  CustomdomainEditCommand() {
    argParser
      ..addOption("id", aliases: const ["domain"], mandatory: true)
      ..addOption("app", aliases: const ["subdomain"], mandatory: true);
  }

  @override
  final name = "edit";

  @override
  final description = "Edit a domain";

  @override
  Future<void> run() async {
    final String domain = argResults!.option("id")!;
    final String subdomain = argResults!.option("app")!;

    final spinner = context.printer.spin(text: "Editting a domain...");

    final response = await context.api.put(
      "/customdomain/$domain/edit",
      body: {"newAppID": subdomain},
    );

    spinner.success(resolveResponseMessage(response));
  }

  @override
  Future<void> dispose() async {}
}
