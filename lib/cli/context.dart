import "dart:async";
import "dart:io";

import "package:discloud/constants.dart";
import "package:discloud/extensions/list.dart";
import "package:discloud/services/discloud/api_client.dart";
import "package:discloud/structures/disposable.dart";
import "package:duration/duration.dart";
import "package:local_store/local_store.dart";
import "package:tint/tint.dart";

abstract class CliContext implements Disposable {
  static final CliContext I = _CliContext();

  void config(Iterable<String> arguments) {
    _start = .now();
    _arguments = arguments;
    _debug = arguments.contains("--debug");
  }

  final Stopwatch _stopwatch = .new()..start();

  DateTime? _start;
  DateTime get start => _start ??= .now();

  Iterable<String> _arguments = const .empty();
  Iterable<String> get arguments => _arguments;

  bool _debug = false;
  void debug(Object? object) {
    if (_debug) stderr.writeln(object);
  }

  final DiscloudApiClient api = .new();

  final LocalStore store = .json(cliConfigFilePath);

  final Directory workspaceFolder = .current;

  final List<Disposable> subscriptions = [];

  @override
  Future<void> dispose() async {
    _stopwatch.stop();
    api.dispose();
    await subscriptions.dispose();

    final elapsed = _stopwatch.elapsed.pretty(
      abbreviated: true,
      tersity: .millisecond,
    ).replaceAll(",", "");

    stderr.writeln("Elapsed: $elapsed".dim());
  }
}

class _CliContext extends CliContext {}
