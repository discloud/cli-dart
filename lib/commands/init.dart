import "dart:async";
import "dart:io";

import "package:args/command_runner.dart";
import "package:discloud/extensions/string.dart";
import "package:discloud/services/discloud/constants.dart";
import "package:discloud_config/discloud_config.dart";

class InitCommand extends Command<void> {
  InitCommand() {
    argParser
      ..addFlag(
        "autorestart",
        help:
            "Determines whether the app should automatically restart if it crashes.",
        negatable: false,
      )
      ..addFlag("force", abbr: "f", help: "Overwrite config file", negatable: false)
      ..addFlag("vlan", help: "Enables private networking", negatable: false)
      ..addMultiOption("apt", help: appApts.join(","))
      ..addOption("avatar", help: "Image URL (.gif, .jpeg, .jpg, .png)")
      ..addOption(
        "hostname",
        help: "Custom hostname alias for other apps to reach this one",
      )
      ..addOption("id", help: "User-defined subdomains")
      ..addOption("main", help: "Relative file path")
      ..addOption("name", help: "1 - 30 characters")
      ..addOption("ram", help: "Amount in MB; min 100")
      ..addOption("type", allowed: const ["bot", "site"])
      ..addOption("version", help: "current|latest|legacy|suja|x.x.x");
  }

  @override
  final name = "init";

  @override
  final description = "Init ${DiscloudConfig.filename} file";

  @override
  Future<void> run() async {
    final file = File(DiscloudConfig.filename);

    if (!argResults!.flag("force") && await file.exists()) {
      throw Exception("${DiscloudConfig.filename} already exists!");
    }

    final args = argResults;

    final hostname = args?.option("hostname");

    final buffer = StringBuffer()
      ..writeAll([
        "# https://docs.discloud.com/en/discloud.config",
        if (args?.multiOption("apt") case final v?) "APT=${v.join(",")}",
        if (args?.flag("autorestart") case final v? when v) "AUTORESTART=$v",
        if (args?.option("avatar") case final v?) "AVATAR=$v",
        if (hostname case final v?) "HOSTNAME=$v",
        if (args?.option("id") case final v?) "ID=$v",
        "MAIN=${args?.option("main").orEmpty}",
        if (args?.option("name") case final v?) "NAME=$v",
        if (args?.option("ram") case final v?) "RAM=$v",
        if (args?.option("type") case final v?) "TYPE=$v",
        if (args?.option("version") case final v?) "VERSION=$v",
        if (args?.flag("vlan") case final v?
            when v || hostname is String && hostname.isNotEmpty)
          "VLAN=$v",
      ], "\n");

    final sink = file.openWrite()..write(buffer);

    await sink.close();
  }
}
