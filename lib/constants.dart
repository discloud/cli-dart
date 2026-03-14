import "dart:io";

const configFilename = "discloud.config";

final userHomePath =
    Platform.environment["HOME"] ??
    Platform.environment["USERPROFILE"] ??
    (throw Exception("User home path not found"));
