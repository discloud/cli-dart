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

class CliContext implements Disposable {
  static late final CliContext I;

  CliContext(this.arguments)
    : _start = .now(),
      debug = arguments.contains("--debug") {
    I = this;
    printer = ConsolePrinter(isDebug: debug);
  }

  @override
  Future<void> dispose() async {
    await subscriptions.dispose();
    api.dispose();
    printer.dispose();

    _stopwatch.stop();

    final elapsed = _stopwatch.elapsed.pretty();

    stderr.writeln("Done in $elapsed".dim());
  }

  final List<Disposable> subscriptions = [];

  final Stopwatch _stopwatch = .new()..start();

  DateTime? _start;
  DateTime get start => _start ??= .now();

  final Iterable<String> arguments;

  final bool debug;

  late final IPrinter<CLISpin> printer;

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
}
