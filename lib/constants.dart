import "dart:io";

import "package:path/path.dart";

const configFilename = "discloud.config";

final userHomePath =
    Platform.environment["HOME"] ??
    Platform.environment["USERPROFILE"] ??
    (throw Exception("User home path not found"));

final cliConfigDir = joinAll([userHomePath, ".discloud"]);

final cliConfigFilePath = joinAll([cliConfigDir, ".cli"]);
