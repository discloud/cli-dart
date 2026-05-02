import "package:args/command_runner.dart";
import "package:discloud/commands/customdomain/create.dart";
import "package:discloud/commands/customdomain/delete.dart";
import "package:discloud/commands/customdomain/edit.dart";
import "package:discloud/commands/customdomain/info.dart";
import "package:discloud/commands/customdomain/verify.dart";

class CustomdomainCommand extends Command<void> {
  CustomdomainCommand() {
    addSubcommand(CustomdomainCreateCommand());
    addSubcommand(CustomdomainDeleteCommand());
    addSubcommand(CustomdomainEditCommand());
    addSubcommand(CustomdomainInfoCommand());
    addSubcommand(CustomdomainVerifyCommand());
  }

  @override
  final name = "customdomain";

  @override
  final description = "Manage your customdomains";

  @override
  final aliases = const ["domain"];
}
