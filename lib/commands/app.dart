import "package:args/command_runner.dart";
import "package:discloud/commands/app/apt.dart";
import "package:discloud/commands/app/backup.dart";
import "package:discloud/commands/app/commit.dart";
import "package:discloud/commands/app/console.dart";
import "package:discloud/commands/app/delete.dart";
import "package:discloud/commands/app/info.dart";
import "package:discloud/commands/app/logs.dart";
import "package:discloud/commands/app/mod.dart";
import "package:discloud/commands/app/profile.dart";
import "package:discloud/commands/app/ram.dart";
import "package:discloud/commands/app/restart.dart";
import "package:discloud/commands/app/start.dart";
import "package:discloud/commands/app/status.dart";
import "package:discloud/commands/app/stop.dart";
import "package:discloud/commands/app/upload.dart";

class AppCommand extends Command<void> {
  AppCommand() {
    addSubcommand(AppAptCommand());
    addSubcommand(AppBackupCommand());
    addSubcommand(AppCommitCommand());
    addSubcommand(AppConsoleCommand());
    addSubcommand(AppDeleteCommand());
    addSubcommand(AppInfoCommand());
    addSubcommand(AppLogsCommand());
    addSubcommand(AppModCommand());
    addSubcommand(AppProfileCommand());
    addSubcommand(AppRamCommand());
    addSubcommand(AppRestartCommand());
    addSubcommand(AppStartCommand());
    addSubcommand(AppStatusCommand());
    addSubcommand(AppStopCommand());
    addSubcommand(AppUploadCommand());
  }

  @override
  final name = "app";

  @override
  final description = "Manage your apps";
}
