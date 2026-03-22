import "package:args/command_runner.dart";
import "package:cli_spin/cli_spin.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/services/discloud/utils.dart";
import "package:discloud/utils/messages.dart";
import "package:interact/interact.dart";

class LoginCommand extends Command<void> {
  @override
  final name = "login";

  @override
  final description = "Login on Discloud API";

  @override
  Future<void> run() async {
    final input = Password(prompt: "Your Discloud token");
    final token = input.interact();

    if (!isDiscloudJwt(token)) throw Exception("Invalid token");

    final spinner = CliSpin().start();

    try {
      final response = await context.api.get(
        "/user",
        headers: {"api-token": token},
      );

      await context.store.set("token", token);

      spinner.success(resolveResponseMessage(response));
    } catch (e, s) {
      spinner.fail(resolveResponseMessage(e));

      context.debug(s);
    }
  }
}
