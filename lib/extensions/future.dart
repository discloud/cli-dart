typedef ErrorCallback = void Function(Object error, [StackTrace? trace]);

extension FutureExtension<T> on Future<T> {
  Future<T?> catchNull([ErrorCallback? onError]) async {
    try {
      return await this;
    } catch (e, s) {
      onError?.call(e, s);
      return null;
    }
  }
}
