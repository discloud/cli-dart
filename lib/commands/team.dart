import "package:args/command_runner.dart";
import "package:discloud/commands/team/backup.dart";
import "package:discloud/commands/team/commit.dart";
import "package:discloud/commands/team/info.dart";
import "package:discloud/commands/team/logs.dart";
import "package:discloud/commands/team/restart.dart";
import "package:discloud/commands/team/start.dart";
import "package:discloud/commands/team/status.dart";
import "package:discloud/commands/team/stop.dart";

class TeamCommand extends Command<void> {
  TeamCommand() {
    addSubcommand(TeamBackupCommand());
    addSubcommand(TeamCommitCommand());
    addSubcommand(TeamInfoCommand());
    addSubcommand(TeamLogsCommand());
    addSubcommand(TeamRestartCommand());
    addSubcommand(TeamStartCommand());
    addSubcommand(TeamStatusCommand());
    addSubcommand(TeamStopCommand());
  }

  @override
  final name = "team";

  @override
  final description = "Manage team apps";
}
