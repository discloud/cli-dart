import "package:args/command_runner.dart";
import "package:discloud/commands/snapshot/create.dart";
import "package:discloud/commands/snapshot/download.dart";
import "package:discloud/commands/snapshot/list.dart";

final class SnapshotCommand extends Command<void> {
  SnapshotCommand() {
    addSubcommand(SnapshotCreateCommand());
    addSubcommand(SnapshotDownloadCommand());
    addSubcommand(SnapshotListCommand());
  }

  @override
  final name = "snapshot";

  @override
  final description = "Manage your versioned backups";

  @override
  final aliases = const ["snapshots"];
}
