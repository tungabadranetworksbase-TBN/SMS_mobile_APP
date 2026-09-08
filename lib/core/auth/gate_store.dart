import 'dart:async';

/// In-memory flags that are not part of /users/me (registration fee).
class GateStore {
  bool _regFeeRequired = false;
  StreamController<void> _controller = StreamController<void>.broadcast();

  bool get regFeeRequired => _regFeeRequired;
  Stream<void> get changes => _controller.stream;

  void setRegFeeRequired(bool value) {
    if (_regFeeRequired == value) return;
    _regFeeRequired = value;
    _controller.add(null);
  }

  void clear() {
    _regFeeRequired = false;
    _controller.add(null);
  }

  void resetForTest() {
    _regFeeRequired = false;
    _controller = StreamController<void>.broadcast();
  }
}
