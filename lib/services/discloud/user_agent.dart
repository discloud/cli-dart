import "dart:io";

import "package:discloud/version.dart";

final class const UserAgent() {
  static const _product = "DiscloudCLI";

  String get _version => packageVersion;

  String get _osName => Platform.operatingSystem;

  @override
  String toString() => "$_product/$_version ($_osName)";
}
