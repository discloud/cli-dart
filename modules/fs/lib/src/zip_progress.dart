import "dart:io";

class ZipProgress {
  const ZipProgress({
    required this.file,
    required this.stat,
    required this.current,
    required this.total,
    required this.processed,
  });

  final File file;
  final FileStat stat;
  final int current;
  final int total;
  final int processed;
}
