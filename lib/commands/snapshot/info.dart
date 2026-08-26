import "dart:async";

import "package:args/command_runner.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/ascii_table.dart";
import "package:discloud/utils/messages.dart";

final class SnapshotInfoCommand extends Command<void> {
  new() {
    argParser
      ..addOption("app")
      ..addOption(
        "page",
        abbr: "p",
        help: "Page number (must be >= 1)",
        valueHelp: "1",
      )
      ..addOption(
        "limit",
        abbr: "l",
        help: "Items per page (1–200)",
        valueHelp: "50",
      )
      ..addFlag(
        "summary",
        abbr: "s",
        help: "shows a summary view of each backup",
        negatable: false,
      );
  }

  @override
  final name = "info";

  @override
  final description = "List your versioned snapshots";

  @override
  final aliases = const ["ls"];

  @override
  Future<void> run() {
    return switch (argResults!.optionOrRest("app")) {
      final String appId => _runSingle(appId),
      _ => _runMulti(),
    };
  }

  Future<void> _runSingle(String appId) async {
    final spinner = context.printer.spin(text: "Fetching snapshots...");

    final response = await context.api.get("/snapshot/$appId");

    spinner.success(resolveResponseMessage(response));

    if (response["versions"] case final List list) {
      context.printer.writeln(listToAsciiTable(_flattenSnapshotVersion(list)));
    }
  }

  Future<void> _runMulti() async {
    final spinner = context.printer.spin(text: "Fetching snapshots...");

    final response = await context.api.get(
      "/snapshot",
      query: {
        "page": ?argResults!.option("page"),
        "limit": ?argResults!.option("limit"),
        "summary": argResults!.flag("summary").toString(),
      },
    );

    spinner.success(resolveResponseMessage(response));

    if (response["apps"] case final List list) {
      context.printer.writeln(listToAsciiTable(_flattenSnapshotApp(list)));
      if (response["pagination"] case final Map pagination) {
        context.printer.writeln(_showSnapshotPagination(pagination));
      }
    }
  }

  List<Map<String, dynamic>> _flattenSnapshotApp(List list) {
    return [
      for (final map in list)
        if (map case final Map map)
          {
            "App ID": map["appID"],
            "Versions": ?map["versionsCount"],
            "Total size": ?map["totalSize"],
            if (map["latestBackup"] case final Map lastBackup)
              "Last backup": StringBuffer()
                ..writeAll([lastBackup["version"], lastBackup["size"]], " "),
          },
    ];
  }

  List<Map<String, dynamic>> _flattenSnapshotVersion(List list) {
    return [
      for (final map in list)
        if (map case final Map map)
          {
            "Version": map["version"],
            "Size": map["size"],
            "Last modified": map["lastModified"],
          },
    ];
  }

  String? _showSnapshotPagination(Map pagination) {
    final StringBuffer buffer = .new()
      ..writeAll([
        if (pagination["currentPage"] case final int page) ...[
          "Page $page",
          if (pagination["totalPages"] case final int total) " of $total",
        ] else if (pagination["totalPages"] case final int total)
          "Pages: $total",
      ]);
    return buffer.toString();
  }
}
