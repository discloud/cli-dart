import "dart:async";
import "dart:io";

import "package:cli_spin/cli_spin.dart";
import "package:discloud/cli/disposable.dart";
import "package:discloud/cli/printer/console_printer.dart";
import "package:discloud/cli/printer/iprinter.dart";
import "package:discloud/extensions/duration.dart";
import "package:discloud/extensions/list.dart";
import "package:discloud/services/discloud/api_client.dart";
import "package:local_store/local_store.dart";
import "package:path/path.dart";
import "package:tint/tint.dart";

abstract class CliContext implements Disposable {
  static final CliContext I = _CliContext();

  @override
  Future<void> dispose() async {
    api.dispose();
    await subscriptions.dispose();
    _stopwatch.stop();

    final elapsed = _stopwatch.elapsed.pretty();

    _printer
      ..writeln("Done in $elapsed".dim())
      ..dispose();
  }

  final List<Disposable> subscriptions = [];

  final Stopwatch _stopwatch = .new()..start();

  DateTime? _start;
  DateTime get start => _start ??= .now();

  Iterable<String> _arguments = const .empty();
  Iterable<String> get arguments => _arguments;

  bool _debug = false;
  bool get isDebug => _debug;

  final IPrinter<CliSpin> _printer = ConsolePrinter();
  IPrinter<CliSpin> get printer => _printer;

  final DiscloudApiClient api = .new();

  late final LocalStore store = .json(cliConfigFilePath);

  final Directory workspaceFolder = .current;

  final rootFilePath = Platform.resolvedExecutable;

  late final rootPath = dirname(rootFilePath);

  late final userHomePath =
      Platform.environment["HOME"] ??
      Platform.environment["USERPROFILE"] ??
      (throw Exception("User home path not found"));

  late final cliConfigDir = joinAll([userHomePath, ".discloud"]);

  late final cliConfigFilePath = joinAll([cliConfigDir, ".cli"]);

  void config(Iterable<String> arguments) {
    _start = .now();
    _arguments = arguments;
    _debug = arguments.contains("--debug");
  }

  void debug(Object? object) {
    _printer.debug(object);
  }
}

class _CliContext extends CliContext {}
