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
  final context = CliContext(arguments);

  final runner = CliCommandRunner();

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

  final signal = SignalWrapper(
    .sigint,
    onSignal: (signal) async {
      if (runner.getCommand(argResults) case final Disposable disposable) {
        context.printer.debug("Disposing...");
        await disposable.dispose();
      }

      context.printer.debug(_version);
      await context.dispose();
    },
  );

  try {
    await signal.run(() => runner.runCommand(argResults));
  } catch (e, s) {
    context.printer
      ..error(resolveResponseMessage(e))
      ..debug(s)
      ..debug(_version);
    exit(1);
  }

  exit(signal.signed ? 2 : 0);
}

String get _version =>
    """\t
OS ${Platform.operatingSystemVersion}
Dart SDK v${Platform.version}
Discloud CLI v$packageVersion
""";

void _printCliHeader(ArgResults argResults) {
  final buffer = StringBuffer()
    ..writeAll(["discloud", ?argResults.commandName, "v$packageVersion"], " ");

  stderr.writeln(buffer.toString().bold());
}
