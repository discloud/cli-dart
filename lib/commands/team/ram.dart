import "dart:async";
import "dart:math";

import "package:args/command_runner.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/messages.dart";
import "package:discloud_config/discloud_config.dart";

class TeamRamCommand extends Command<void> {
  TeamRamCommand() {
    argParser
      ..addOption("app", mandatory: true)
      ..addOption(
        "amount",
        aliases: const ["ram"],
        mandatory: true,
        valueHelp: DiscloudRamMinByType.lowest.value.toString(),
      );
  }

  @override
  final name = "ram";

  @override
  final description = "Set amount of ram for your app";

  @override
  Future<void> run() async {
    final appId = argResults!.option("app");
    final ramMB = max(
      int.parse(argResults!.option("amount")!),
      DiscloudRamMinByType.lowest.value,
    );

    final spinner = context.printer.spin();

    final response = await context.api.put(
      "/team/$appId/ram",
      body: {"ramMB": ramMB},
    );

    spinner.success(resolveResponseMessage(response));
  }
}
