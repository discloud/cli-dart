import "dart:async";

import "package:args/command_runner.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/messages.dart";

class AppProfileCommand extends Command<void> {
  AppProfileCommand() {
    argParser
      ..addOption("app", mandatory: true)
      ..addOption("name", mandatory: true)
      ..addOption("avatar", mandatory: true);
  }

  @override
  final name = "profile";

  @override
  final description =
      "Updates the profile information (avatar and name) for a specific app";

  @override
  Future<void> run() async {
    final appId = argResults!.option("app")!;
    final name = argResults!.option("name")!;
    final avatar = argResults!.option("avatar")!;

    final spinner = context.printer.spin();

    final response = await context.api.put(
      "/app/$appId/profile",
      body: {"name": name, "avatarURL": avatar},
    );

    spinner.success(resolveResponseMessage(response));
  }
}
