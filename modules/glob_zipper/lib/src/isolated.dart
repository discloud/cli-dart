part of "glob_zipper.dart";

typedef _ExceptionData = ({Object error, StackTrace trace});

Future<File> _zipInIsolate({
  required Directory directory,
  Iterable<String> globPatterns = const ["**"],
  Iterable<String> ignorePatterns = const .empty(),
  String? ignoreFilename,
  int? level,
  String? password,
  Directory? tempDirectory,
  String? zipname,
  ZipCallback? onData,
  OnErrorCallback? onError,
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
    ..send(onData is ZipCallback)
    ..send(onError is OnErrorCallback);

  File? maybeFile;
  await for (final message in mainPortBroadcast) {
    if (message case final File file) {
      maybeFile = file;
      break;
    }

    switch (message) {
      case final ZipProgress progress:
        onData!(progress);
        break;
      case final _ExceptionData error:
        if (onError case final onError?) {
          onError(error.error, error.trace);
          break;
        }

        // rethows PathAccessException or other
        // ignore: only_throw_errors
        throw error.error;
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

  final bool hasOnData = await isolatePortBroadcast.first;

  final bool hasOnError = await isolatePortBroadcast.first;

  void onError(Object error, StackTrace trace) {
    final _ExceptionData errorData = (error: error, trace: trace);
    mainSendPort.send(errorData);
  }

  try {
    final file = await zipper.zip(
      onData: hasOnData ? mainSendPort.send : null,
      onError: hasOnError ? onError : null,
    );

    mainSendPort.send(file);
  } catch (e, s) {
    onError(e, s);
  }

  isolatedPort.close();
  await Isolate.exit();
}
