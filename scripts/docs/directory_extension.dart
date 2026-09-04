import "dart:io";
import "dart:typed_data";

import "package:path/path.dart";

extension DirectoryExtension on Directory {
  Future<void> recreate({
    Iterable<String> filenamesToPreserve = const [],
    bool recursive = true,
  }) async {
    final filesToPreserveContents = <File, Uint8List>{};

    for (final filename in filenamesToPreserve) {
      final filePath = joinAll([path, filename]);

      switch (await FileSystemEntity.type(filePath)) {
        case .directory:
          if (!recursive) break;

          final Directory dir = .new(filePath);

          await for (final file in dir.list(recursive: recursive)) {
            if (file is! File) continue;
            filesToPreserveContents[file] = await file.readAsBytes();
          }

          break;
        case .file:
          final File file = .new(filePath);

          filesToPreserveContents[file] = await file.readAsBytes();

          break;
        default:
          break;
      }
    }

    await delete(recursive: true);
    await create();

    for (final entry in filesToPreserveContents.entries) {
      if (!await entry.key.parent.exists()) {
        await entry.key.parent.create(recursive: true);
      }

      await entry.key.writeAsBytes(entry.value, flush: true);
    }
  }
}
