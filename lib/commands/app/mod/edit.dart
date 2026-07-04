import "dart:async";

import "package:args/command_runner.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/services/discloud/constants.dart";
import "package:discloud/utils/messages.dart";

final class AppModEditCommand extends Command<void> {
  AppModEditCommand() {
    argParser
      ..addOption("app")
      ..addOption("mod")
      ..addMultiOption("perms", allowed: appModPerms);
  }

  @override
  final name = "edit";

  @override
  final description = "Edit MOD perms of your app";

  @override
  Future<void> run() async {
    final appId = requiredOptionOrRest("app", 0);
    final modId = requiredOptionOrRest("mod", 1);
    final perms = multiOptionOrRest("perms", 2);
    _validatePerms(perms);

    final spinner = context.printer.spin(text: "Editing app MOD...");

    final response = await context.api.put(
      "/app/$appId/team",
      body: {"modID": modId, "perms": perms},
    );

    spinner.success(resolveResponseMessage(response));
  }

  void _validatePerms(List<String> perms) {
    final invalid = perms.where((perm) => !appModPerms.contains(perm)).toList();
    if (invalid.isEmpty) return;

    usageException("Invalid MOD permission: ${invalid.join(", ")}");
  }
}
