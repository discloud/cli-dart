part of "glob_zipper.dart";

typedef _ExceptionData = ({Object error, StackTrace trace});

Future<void> _zipInIsolate({
  required Directory directory,
  required File zipfile,
  Iterable<String> globPatterns = const ["**"],
  Iterable<String> ignorePatterns = const .empty(),
  String? ignoreFilename,
  int? level,
  String? password,
  ZipCallback? onData,
  OnErrorCallback? onError,
}) async {
  final mainPort = ReceivePort();

  final mainPortBroadcast = mainPort.asBroadcastStream();

  await Isolate.spawn(_isolatedZip, mainPort.sendPort);

  final SendPort isolatedSendPort = await mainPortBroadcast.first;

  final GlobZipper zipper = .new(
    directory: directory,
    zipfile: zipfile,
    globPatterns: globPatterns,
    ignoreFilename: ignoreFilename,
    ignorePatterns: ignorePatterns,
    level: level,
    password: password,
  );

  isolatedSendPort
    ..send(zipper)
    ..send(onData is ZipCallback)
    ..send(onError is OnErrorCallback);

  await for (final message in mainPortBroadcast) {
    if (message == null) break;

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
    await zipper.zip(
      onData: hasOnData ? mainSendPort.send : null,
      onError: hasOnError ? onError : null,
    );
  } catch (e, s) {
    onError(e, s);
  } finally {
    mainSendPort.send(null);
  }

  isolatedPort.close();
  await Isolate.exit();
}
