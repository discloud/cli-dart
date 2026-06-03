import "package:args/command_runner.dart";
import "package:discloud/commands/subdomain/create.dart";
import "package:discloud/commands/subdomain/delete.dart";
import "package:discloud/commands/subdomain/info.dart";

final class SubdomainCommand extends Command<void> {
  SubdomainCommand() {
    addSubcommand(SubdomainCreateCommand());
    addSubcommand(SubdomainDeleteCommand());
    addSubcommand(SubdomainInfoCommand());
  }

  @override
  final name = "subdomain";

  @override
  final description = "Manage your subdomains";
}
