part of "context.dart";

final Directory _workspaceFolder = .current;

final _rootFilePath = Platform.resolvedExecutable;

final _rootPath = dirname(_rootFilePath);

final String _userHomePath = .fromEnvironment(
  const ["HOME", "USERPROFILE"].firstWhere(
    bool.hasEnvironment,
    orElse: () {
      throw Exception("User home path not found");
    },
  ),
);

final _cliConfigDir = joinAll([_userHomePath, ".discloud"]);

final _cliConfigFilePath = joinAll([_cliConfigDir, ".cli"]);
