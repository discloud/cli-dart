part of "glob_zipper.dart";

Future<File> _zipInIsolate({
  required Directory directory,
  Iterable<String> globPatterns = const ["**"],
  Iterable<String> ignorePatterns = const .empty(),
  String? ignoreFilename,
  int? level,
  String? password,
  Directory? tempDirectory,
  String? zipname,
  ZipCallback? callback,
}) async {
  final mainPort = ReceivePort();

  final mainPortBroadcast = mainPort.asBroadcastStream();

  await Isolate.spawn(_isolatedZip, mainPort.sendPort);

  final SendPort isolatedSendPort = await mainPortBroadcast.first;

  final GlobZipper zipper = .new(
    directory: directory,
    globPatterns: globPatterns,
    ignoreFilename: ignoreFilename,
    ignorePatterns: ignorePatterns,
    level: level,
    password: password,
    tempDirectory: tempDirectory,
    zipname: zipname,
  );

  isolatedSendPort
    ..send(zipper)
    ..send(callback is ZipCallback);

  File? maybeFile;
  await for (final message in mainPortBroadcast) {
    if (message case final File file) {
      maybeFile = file;
      break;
    }

    switch (message) {
      case final ZipProgress progress:
        callback!(progress);
        break;
    }
  }

  mainPort.close();

  if (maybeFile == null) throw ZipException();

  return maybeFile;
}

Future<void> _isolatedZip(SendPort mainSendPort) async {
  final isolatedPort = ReceivePort();

  final isolatePortBroadcast = isolatedPort.asBroadcastStream();

  mainSendPort.send(isolatedPort.sendPort);

  final GlobZipper zipper = await isolatePortBroadcast.first;

  final bool hasCallback = await isolatePortBroadcast.first;

  final file = await zipper.zip(hasCallback ? mainSendPort.send : null);

  mainSendPort.send(file);

  isolatedPort.close();
  await Isolate.exit();
}
