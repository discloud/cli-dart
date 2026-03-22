import "package:args/command_runner.dart";
import "package:discloud/commands/user/info.dart";
import "package:discloud/commands/user/locale.dart";

class UserCommand extends Command<void> {
  UserCommand() {
    addSubcommand(UserInfoCommand());
    addSubcommand(UserLocaleCommand());
  }

  @override
  final name = "user";

  @override
  final description = "Manage your profile";
}
