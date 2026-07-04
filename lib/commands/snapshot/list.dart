import "dart:async";
import "dart:io";

import "package:args/command_runner.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/ascii_table.dart";
import "package:discloud/utils/messages.dart";

final class SnapshotListCommand extends Command<void> {
  SnapshotListCommand() {
    argParser
      ..addOption("app", defaultsTo: "all", valueHelp: "all")
      ..addOption("page", defaultsTo: "1")
      ..addOption("limit", defaultsTo: "50")
      ..addFlag("summary", negatable: false);
  }

  @override
  final name = "list";

  @override
  final description = "List your versioned snapshots";

  @override
  final aliases = const ["ls"];

  @override
  Future<void> run() async {
    final String appId = argResults!.option("app")!;

    final spinner = context.printer.spin(text: "Fetching snapshots...");

    if (appId == "all") {
      final response = await context.api.get(
        "/snapshot",
        query: {
          "page": argResults!.option("page")!,
          "limit": argResults!.option("limit")!,
          "summary": "${argResults!.flag("summary")}",
        },
      );

      spinner.success(resolveResponseMessage(response));

      switch (response["apps"]) {
        case final List list:
          stdout.writeln(listToAsciiTable(_flattenApps(list)));
          break;
      }

      return;
    }

    final response = await context.api.get("/snapshot/$appId");

    spinner.success(resolveResponseMessage(response));

    switch (response["versions"]) {
      case final List list:
        stdout.writeln(listToAsciiTable(list));
        break;
    }
  }

  List<Map<String, dynamic>> _flattenApps(List list) {
    return [
      for (final app in list)
        {
          "appID": app["appID"],
          "versionsCount": app["versionsCount"],
          "totalSize": app["totalSize"],
          "latestVersion": app["latestBackup"]?["version"],
          "lastModified": app["latestBackup"]?["lastModified"],
        },
    ];
  }
}
