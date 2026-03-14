import "package:cli_spin/cli_spin.dart";
import "package:discloud/cli/command.dart";
import "package:discloud/prompts/api_token.dart";
import "package:discloud/services/discloud/exception.dart";
import "package:discloud/services/discloud/utils.dart";
import "package:discloud/utils/messages.dart";

class LoginCommand extends CliCommand<void> {
  @override
  final name = "login";

  @override
  final description = "Login on Discloud API";

  @override
  Future<void> run() async {
    final token = await promptApiToken(message: "Your Discloud token:");

    if (!isDiscloudJwt(token)) throw Exception("Invalid token");

    final spinner = CliSpin().start();

    try {
      final response = await client.get("/user", headers: {"api-token": token});

      spinner.success(resolveResponseMessage(response));
    } on DiscloudApiException catch (e) {
      spinner.fail(resolveResponseMessage(e));
    } catch (e) {
      spinner.fail(resolveResponseMessage(e));
    } finally {
      client.dispose();
    }
  }
}
