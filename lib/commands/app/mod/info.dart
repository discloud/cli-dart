import "dart:async";
import "package:args/command_runner.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/ascii_table.dart";
import "package:discloud/utils/messages.dart";

final class AppModInfoCommand extends Command<void> {
  AppModInfoCommand() {
    argParser.addOption("app");
  }

  @override
  final name = "info";

  @override
  final description = "Get MOD info of your app";

  @override
  Future<void> run() async {
    final appId = requiredOptionOrRest("app", 0);

    final spinner = context.printer.spin(text: "Fetching app MODs...");

    final response = await context.api.get("/app/$appId/team");

    if (response["team"] case final List list when list.isNotEmpty) {
      spinner.success(resolveResponseMessage(response));
      context.printer.writeln(listToAsciiTable(list));
    } else {
      spinner.success(resolveResponseMessage(response));
    }
  }
}
