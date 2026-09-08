import 'dart:async';

import 'capabilities.dart';

/// In-memory capabilities. Cleared on logout. Never written to disk.
class CapabilitiesStore {
  Capabilities? _current;
  StreamController<void> _controller = StreamController<void>.broadcast();

  Capabilities? get current => _current;
  Stream<void> get changes => _controller.stream;

  void set(Capabilities value) {
    _current = value;
    _controller.add(null);
  }

  void clear() {
    _current = null;
    _controller.add(null);
  }

  void resetForTest() {
    _current = null;
    _controller = StreamController<void>.broadcast();
  }
}
