import "package:args/command_runner.dart";
import "package:discloud/commands/snapshot/create.dart";
import "package:discloud/commands/snapshot/download.dart";
import "package:discloud/commands/snapshot/info.dart";

final class SnapshotCommand extends Command<void> {
  new() {
    addSubcommand(SnapshotCreateCommand());
    addSubcommand(SnapshotDownloadCommand());
    addSubcommand(SnapshotInfoCommand());
  }

  @override
  final name = "snapshot";

  @override
  final description = "Manage your versioned backups";

  @override
  final aliases = const ["snapshots"];
}
