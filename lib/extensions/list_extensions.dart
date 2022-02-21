extension Async<T> on List<T> {
  Future<void> asyncSort([int Function(T, T)? compare]) async {
    return Future(() => sort(compare));
  }
}
