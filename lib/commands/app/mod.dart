import "package:args/command_runner.dart";
import "package:discloud/commands/app/mod/add.dart";
import "package:discloud/commands/app/mod/delete.dart";
import "package:discloud/commands/app/mod/edit.dart";
import "package:discloud/commands/app/mod/info.dart";

class AppModCommand extends Command<void> {
  AppModCommand() {
    addSubcommand(AppModAddCommand());
    addSubcommand(AppModDeleteCommand());
    addSubcommand(AppModEditCommand());
    addSubcommand(AppModInfoCommand());
  }

  @override
  final name = "mod";

  @override
  final description = "Manage your app team";
}
