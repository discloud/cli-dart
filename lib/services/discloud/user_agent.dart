import "dart:io";

import "package:discloud/version.dart";

class UserAgent {
  static const _product = "DiscloudCLI";

  const UserAgent();

  String get _version => packageVersion;

  String get _osName => Platform.operatingSystem;

  @override
  String toString() {
    return "$_product/$_version ($_osName)";
  }
}
