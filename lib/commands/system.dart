import "package:args/command_runner.dart";
import "package:discloud/commands/system/locale.dart";

final class SystemCommand extends Command<void> {
  SystemCommand() {
    addSubcommand(SystemLocaleCommand());
  }

  @override
  final name = "system";

  @override
  final description = "View system info";

  @override
  final hidden = true;
}
