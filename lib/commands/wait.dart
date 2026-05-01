import "dart:async";

import "package:args/command_runner.dart";
import "package:discloud/cli/disposable.dart";
import "package:discloud/extensions/num.dart";

class WaitCommand extends Command<void> with Disposable {
  WaitCommand();

  @override
  final name = "wait";

  @override
  final description = "Wait N seconds";

  @override
  final hidden = true;

  @override
  final takesArguments = true;

  @override
  Future<void> run() async {
    if (argResults?.arguments.firstOrNull case final seconds?) {
      if (int.tryParse(seconds) case final seconds? when seconds.isPositive) {
        await Future.delayed(.new(seconds: seconds));
      }
    }
  }

  @override
  FutureOr<void> dispose() {
    // ignore: no_runtimetype_tostring
    print("$hashCode $runtimeType disposed");
  }
}
