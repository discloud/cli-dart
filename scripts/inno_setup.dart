import "dart:io";

import "package:args/args.dart";
import "package:interpolation/interpolation.dart";
import "package:yaml/yaml.dart";

void main(Iterable<String> args) async {
  final interpolator = Interpolation(
    option: .new(prefix: "{{", suffix: "}}"),
  );

  final parser = ArgParser()..addOption("version");
  final parsed = parser.parse(args);

  final issFile = File("inno_setup.iss");
  final pubspecFile = File("pubspec.yaml");

  String issContent = await issFile.readAsString();
  final pubspec = loadYaml(await pubspecFile.readAsString());

  final version = parsed.option("version") ?? pubspec["version"];

  issContent = interpolator.eval(issContent, {"version": version});

  await issFile.writeAsString(issContent);
}
