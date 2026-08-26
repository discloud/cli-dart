import "package:args/command_runner.dart";
import "package:discloud/commands/app/apt/install.dart";
import "package:discloud/commands/app/apt/uninstall.dart";

final class AppAptCommand extends Command<void> {
  new() {
    addSubcommand(AppAptInstallCommand());
    addSubcommand(AppAptUninstallCommand());
  }

  @override
  final name = "apt";

  @override
  final description = "Manage your apps APT";
}
