part of "glob_zipper.dart";

class ZipProgress {
  const ZipProgress({
    required this.file,
    required this.stat,
    required this.current,
    required this.processed,
    required this.compressed,
  });

  final File file;
  final FileStat stat;
  final int current;
  final int processed;
  final int compressed;
}
