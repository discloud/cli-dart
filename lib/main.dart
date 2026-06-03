import "dart:io";

import "package:args/args.dart";
import "package:discloud/cli/context.dart";
import "package:discloud/cli/disposable.dart";
import "package:discloud/cli/runner.dart";
import "package:discloud/extensions/arg_results.dart";
import "package:discloud/utils/messages.dart";
import "package:discloud/utils/signal_wrapper.dart";
import "package:discloud/version.dart";
import "package:tint/tint.dart";

void main(Iterable<String> arguments) async {
  final CliContext context = .new(arguments);

  final CliCommandRunner runner = .new();

  late final ArgResults argResults;
  try {
    argResults = runner.parse(arguments);
  } /* on FormatException */ catch (e, s) {
    context.printer
      ..error(resolveResponseMessage(e))
      ..debug(s)
      ..debug(_version);
    await context.dispose();
    exit(1);
  }

  _printCliHeader(argResults);

  ProcessSignal? firstReceivedSignal;

  final SignalWrapper signal = .new(
    .sigint,
    onSignal: (signal) {
      firstReceivedSignal ??= signal;
      context.printer.debug("Received signal $signal ${signal.signalNumber}");
    },
    onDispose: () async {
      if (runner.getCommand(argResults) case final Disposable disposable) {
        context.printer.debug("Disposing...");
        await disposable.dispose();
      }

      context.printer.debug(_version);
      await context.dispose();
    },
  );

  try {
    await signal(() => runner.runCommand(argResults));
  } catch (e, s) {
    context.printer
      ..error(resolveResponseMessage(e))
      ..debug(s)
      ..debug(_version);
    exit(1);
  }

  exit(firstReceivedSignal?.signalNumber ?? 0);
}

String get _version =>
    """\t
OS ${Platform.operatingSystemVersion}
Dart SDK v${Platform.version}
Discloud CLI v$packageVersion
""";

void _printCliHeader(ArgResults argResults) {
  final StringBuffer buffer = .new()
    ..writeAll(["discloud", ?argResults.commandName, "v$packageVersion"], " ");

  stderr.writeln(buffer.toString().bold());
}
