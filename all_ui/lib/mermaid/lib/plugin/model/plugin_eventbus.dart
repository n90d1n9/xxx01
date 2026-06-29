import 'dart:async' show StreamController;

import 'plugin_event.dart';

class PluginEventBus {
  final StreamController<PluginEvent> _controller =
      StreamController.broadcast();

  Stream<PluginEvent> get stream => _controller.stream;

  void emit(PluginEvent event) {
    _controller.add(event);
  }

  void dispose() {
    _controller.close();
  }
}
