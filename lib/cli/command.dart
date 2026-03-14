import "package:args/command_runner.dart";
import "package:discloud/services/discloud/api_client.dart";

abstract class CliCommand<T> extends Command<T> {
  DiscloudApiClient? _client;
  DiscloudApiClient get client => _client ??= .new();
}
