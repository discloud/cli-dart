import "dart:async";
import "dart:io";

import "package:discloud/cli/disposable.dart";
import "package:discloud/cli/printer/console_printer.dart";
import "package:discloud/cli/printer/iprinter.dart";
import "package:discloud/cli/spin/cli_spin.dart";
import "package:discloud/extensions/duration.dart";
import "package:discloud/extensions/list.dart";
import "package:discloud/services/discloud/api_client.dart";
import "package:local_store/local_store.dart";
import "package:path/path.dart";
import "package:tint/tint.dart";

part "paths.dart";

class CliContext implements Disposable {
  static late final CliContext I;

  CliContext(this.arguments)
    : subscriptions = .empty(),
      _stopwatch = .new()..start(),
      debug = arguments.contains("--debug"),
      api = .new() {
    I = this;
    printer = ConsolePrinter(isDebug: debug);
    store = .json(cliConfigFilePath);
  }

  final List<Disposable> subscriptions;

  @override
  Future<void> dispose() async {
    await subscriptions.dispose();
    api.dispose();
    printer.dispose();

    _stopwatch.stop();

    final elapsed = _stopwatch.elapsed.pretty();

    stderr.writeln("Done in $elapsed".dim());
  }

  final Stopwatch _stopwatch;

  final Iterable<String> arguments;
  final bool debug;
  final DiscloudApiClient api;

  late final IPrinter<CLISpin> printer;
  late final LocalStore store;

  Directory get workspaceFolder => _workspaceFolder;

  String get rootFilePath => _rootFilePath;

  String get rootPath => _rootPath;

  String get userHomePath => _userHomePath;

  String get cliConfigDir => _cliConfigDir;

  String get cliConfigFilePath => _cliConfigFilePath;
}
