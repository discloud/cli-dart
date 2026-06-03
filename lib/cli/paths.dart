part of "context.dart";

final Directory _workspaceFolder = .current;

final String _rootFilePath = Platform.resolvedExecutable;

final String _rootPath = dirname(_rootFilePath);

final String _userHomePath =
    Platform.environment[const ["HOME", "USERPROFILE"].firstWhere(
      Platform.environment.containsKey,
      orElse: () {
        throw Exception("User home path not found");
      },
    )]!;

final String _cliConfigDir = joinAll([_userHomePath, ".discloud"]);

final String _cliConfigFilePath = joinAll([_cliConfigDir, ".cli"]);
