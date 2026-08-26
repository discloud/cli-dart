import "dart:async";
import "dart:math";

import "package:args/command_runner.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/messages.dart";
import "package:discloud_config/discloud_config.dart";

final class AppRamCommand extends Command<void> {
  new() {
    argParser
      ..addOption("app")
      ..addOption(
        "amount",
        aliases: const ["ram"],
        valueHelp: DiscloudRamMinByType.lowest.value.toString(),
      );
  }

  @override
  final name = "ram";

  @override
  final description = "Set amount of ram for your app";

  @override
  Future<void> run() async {
    final appId = argResults!.requiredOptionOrRest("app");
    final ramMB = max(
      argResults!.requiredIntOptionOrRest("amount", after: const ["app"]),
      DiscloudRamMinByType.lowest.value,
    );

    final spinner = context.printer.spin(text: "Defining amount of RAM...");

    final response = await context.api.put(
      "/app/$appId/ram",
      body: {"ramMB": ramMB},
    );

    spinner.success(resolveResponseMessage(response));
  }
}
