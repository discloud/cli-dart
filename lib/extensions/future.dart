extension FutureExtension<T> on Future<T> {
  Future<T?> catchNull() async {
    try {
      return await this;
    } catch (_) {
      return null;
    }
  }
}
