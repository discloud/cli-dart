abstract interface class ISpin {
  abstract String text;

  void fail([String? text]);

  void info([String? text]);

  void start([String? text]);

  void stop();

  void stopAndPersist({String? symbol, String? text});

  void success([String? text]);

  void warn([String? text]);
}
