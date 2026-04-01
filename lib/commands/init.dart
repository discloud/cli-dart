import "dart:async";
import "dart:io";

import "package:args/args.dart";
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
      ..addFlag(
        "force",
        abbr: "f",
        help: "Overwrite config file",
        negatable: false,
      )
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

    final args = _InitArgs(argResults);

    if (!args.force && await file.exists()) {
      throw Exception("${DiscloudConfig.filename} already exists!");
    }

    final buffer = StringBuffer()
      ..writeAll([
        "# https://docs.discloud.com/en/discloud.config",
        if (args.apt case final v when v.isNotEmpty) "APT=${v.join(",")}",
        if (args.autorestart case final v when v) "AUTORESTART=$v",
        if (args.avatar case final v?) "AVATAR=$v",
        if (args.hostname case final v?) "HOSTNAME=$v",
        if (args.id case final v?) "ID=$v",
        "MAIN=${args.main.orEmpty}",
        if (args.name case final v?) "NAME=$v",
        if (args.ram case final v?) "RAM=$v",
        if (args.type case final v?) "TYPE=$v",
        if (args.version case final v?) "VERSION=$v",
        if (args.vlan case final v when v) "VLAN=$v",
      ], "\n");

    final sink = file.openWrite()..write(buffer);

    await sink.close();
  }
}

class _InitArgs {
  const _InitArgs(this._argResults);

  final ArgResults? _argResults;

  bool _flag(String name) => _argResults?.flag(name) ?? false;
  List<String> _multiOption(String n) => _argResults?.multiOption(n) ?? [];
  String? _option(String name) => _argResults?.option(name);

  bool get force => _flag("force");

  List<String> get apt => _multiOption("apt");
  bool get autorestart => _flag("autorestart");
  String? get avatar => _option("avatar");
  String? get hostname => _option("hostname");
  String? get id => _option("id");
  String? get main => _option("main");
  String? get name => _option("name");
  String? get ram => _option("ram");
  String? get type => _option("type");
  String? get version => _option("version");
  bool get vlan => _flag("vlan");
}
