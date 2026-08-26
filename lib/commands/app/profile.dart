import "dart:async";

import "package:args/command_runner.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/messages.dart";

final class AppProfileCommand extends Command<void> {
  new() {
    argParser
      ..addOption("app")
      ..addOption("name", abbr: "n")
      ..addOption("avatar", abbr: "a");
  }

  @override
  final name = "profile";

  @override
  final description =
      "Updates the profile information (avatar and name) for a specific app";

  @override
  Future<void> run() async {
    final appId = argResults!.requiredOptionOrRest("app");
    final name = argResults!.option("name");
    final avatar = argResults!.option("avatar");

    final spinner = context.printer.spin(text: "Changing app profile...");

    final response = await context.api.put(
      "/app/$appId/profile",
      body: {"name": ?name, "avatarURL": ?avatar},
    );

    spinner.success(resolveResponseMessage(response));
  }
}
