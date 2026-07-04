import "dart:async";
import "dart:io";

import "package:args/args.dart";
import "package:args/command_runner.dart";
import "package:discloud/extensions/string.dart";
import "package:discloud/services/discloud/constants.dart";
import "package:discloud_config/discloud_config.dart";

final _configLineBreakPattern = RegExp(r"[\r\n]");

final class InitCommand extends Command<void> {
  InitCommand() {
    argParser
      ..addFlag(
        "autorestart",
        aliases: const ["ar"],
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
      ..addFlag(
        "overwrite",
        abbr: "o",
        help: "Overwrite config file",
        negatable: false,
      )
      ..addFlag(
        "yes",
        abbr: "y",
        help: "Skip config prompts",
        negatable: false,
      )
      ..addFlag("vlan", help: "Enables private networking", negatable: false)
      ..addMultiOption("apt", abbr: "a", help: appApts.join(","))
      ..addOption("avatar", help: "Image URL (.gif, .jpeg, .jpg, .png)")
      ..addOption(
        "engine-version",
        aliases: const ["ev", "version"],
        help: "current|latest|legacy|suja|x.x.x",
      )
      ..addOption(
        "hostname",
        help: "Custom hostname alias for other apps to reach this one",
      )
      ..addOption("id", help: "User-defined subdomains")
      ..addOption("main", abbr: "m", help: "Relative file path")
      ..addOption("name", abbr: "n", help: "1 - 30 characters")
      ..addOption("ram", abbr: "r", help: "Amount in MB; min 100")
      ..addOption("start", abbr: "s", help: "App start")
      ..addOption("type", abbr: "t", allowed: const ["bot", "site"]);
  }

  @override
  final name = "init";

  @override
  final description = "Init ${DiscloudConfig.filename} file";

  @override
  Future<void> run() async {
    final File file = .new(DiscloudConfig.filename);

    final _InitArgs args = .new(argResults);

    if (!args.force && await file.exists()) {
      throw Exception("${DiscloudConfig.filename} already exists!");
    }

    final StringBuffer buffer = .new()
      ..writeAll([
        "# https://docs.discloud.com/en/discloud.config",
        if (args.apt case final v when v.isNotEmpty)
          _configLine("APT", v.join(",")),
        if (args.autorestart case final v when v)
          _configLine("AUTORESTART", v),
        if (args.avatar case final v?) _configLine("AVATAR", v),
        if (args.hostname case final v?) _configLine("HOSTNAME", v),
        if (args.id case final v?) _configLine("ID", v),
        _configLine("MAIN", args.main.orEmpty),
        if (args.name case final v?) _configLine("NAME", v),
        if (args.ram case final v?) _configLine("RAM", v),
        if (args.start case final v?) _configLine("START", v),
        if (args.type case final v?) _configLine("TYPE", v),
        if (args.version case final v?) _configLine("VERSION", v),
        if (args.vlan case final v when v) _configLine("VLAN", v),
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

  bool get force => _flag("force") || _flag("overwrite");

  List<String> get apt => _multiOption("apt");
  bool get autorestart => _flag("autorestart");
  String? get avatar => _option("avatar");
  String? get hostname => _option("hostname");
  String? get id => _option("id");
  String? get main => _option("main");
  String? get name => _option("name");
  String? get ram => _option("ram");
  String? get start => _option("start");
  String? get type => _option("type");
  String? get version => _option("engine-version");
  bool get vlan => _flag("vlan");
}

String _configLine(String key, Object value) {
  return "$key=${value.toString().replaceAll(_configLineBreakPattern, "")}";
}
