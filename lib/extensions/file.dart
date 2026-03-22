import "dart:io";

extension FileExtension on File {
  Future<void> safeDelete({bool recursive = false}) async {
    try {
      await delete(recursive: recursive);
    } catch (_) {}
  }
}
