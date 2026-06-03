import "package:args/command_runner.dart";
import "package:discloud/commands/domain/create.dart";
import "package:discloud/commands/domain/delete.dart";
import "package:discloud/commands/domain/edit.dart";
import "package:discloud/commands/domain/info.dart";
import "package:discloud/commands/domain/verify.dart";

final class DomainCommand extends Command<void> {
  DomainCommand() {
    addSubcommand(CustomdomainCreateCommand());
    addSubcommand(CustomdomainDeleteCommand());
    addSubcommand(CustomdomainEditCommand());
    addSubcommand(CustomdomainInfoCommand());
    addSubcommand(CustomdomainVerifyCommand());
  }

  @override
  final name = "domain";

  @override
  final description = "Manage your domains";

  @override
  final aliases = const ["customdomain"];
}
