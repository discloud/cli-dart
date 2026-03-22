part of "glob_zipper.dart";

class ZipProgress {
  const ZipProgress({
    required this.file,
    required this.stat,
    required this.current,
    required this.processed,
  });

  final File file;
  final FileStat stat;
  final int current;
  final int processed;
}
