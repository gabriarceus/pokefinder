/// A domain-owned cancellation handle, decoupled from any HTTP library.
///
/// The repository layer bridges this to the concrete transport-level
/// cancellation mechanism (e.g. Dio's `CancelToken`).
class CancellationToken {
  bool _isCancelled = false;
  String? _reason;
  final _listeners = <void Function()>[];

  /// Whether [cancel] has been called.
  bool get isCancelled => _isCancelled;

  /// The reason passed to [cancel], if any.
  String? get reason => _reason;

  /// Signals cancellation.
  void cancel([String? reason]) {
    if (_isCancelled) return;
    _isCancelled = true;
    _reason = reason;
    for (final listener in _listeners) {
      listener();
    }
    _listeners.clear();
  }

  /// Registers a [callback] invoked when this token is cancelled.
  ///
  /// If the token is already cancelled, the callback is invoked immediately.
  void onCancel(void Function() callback) {
    if (_isCancelled) {
      callback();
      return;
    }
    _listeners.add(callback);
  }
}
