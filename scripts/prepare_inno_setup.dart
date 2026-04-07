import "dart:io";

import "package:args/args.dart";
import "package:interpolation/interpolation.dart";
import "package:pub_semver/pub_semver.dart";

void main(Iterable<String> args) async {
  final parser = ArgParser()..addOption("version", abbr: "-v", mandatory: true);
  final parsed = parser.parse(args);
  final version = parsed.option("version")!;
  Version.parse(version);

  final issFile = File("inno_setup.iss");

  final interpolator = Interpolation(
    option: .new(prefix: "{{", suffix: "}}"),
  );

  String issContent = await issFile.readAsString();

  issContent = interpolator.eval(issContent, {"version": version});

  await issFile.writeAsString(issContent);
}

const pubspecVersionPattern = r"\r?\nversion:\s\d+\.\d+\.\d+\r?\n";
final pubspecVersionRegexp = RegExp(pubspecVersionPattern);
