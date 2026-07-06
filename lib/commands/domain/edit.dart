import "dart:async";

import "package:args/command_runner.dart";
import "package:discloud/cli/disposable.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/messages.dart";

final class CustomdomainEditCommand extends Command<void> with Disposable {
  CustomdomainEditCommand() {
    argParser
      ..addOption("id", aliases: const ["domain"])
      ..addOption("app", aliases: const ["subdomain"], defaultsTo: "all");
  }

  @override
  final name = "edit";

  @override
  final description = "Edit a domain";

  @override
  Future<void> run() async {
    final domain = requiredOptionOrRest("id", 0);
    final subdomain =
        optionOrRest("app", argResults!.restIndexAfter(["id"])) ?? "all";

    final spinner = context.printer.spin(text: "Editting $domain...");

    final response = await context.api.put(
      "/customdomain/$domain/edit",
      body: {"newAppID": subdomain},
    );

    spinner.success(resolveResponseMessage(response));
  }

  @override
  Future<void> dispose() async {}
}
