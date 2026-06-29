class BreakpointDebugger {
  final Set<String> breakpoints = {};
  final Map<String, Map<String, dynamic>> nodeSnapshots = {};
  bool isPaused = false;
  String? currentNodeId;

  void addBreakpoint(String nodeId) {
    breakpoints.add(nodeId);
  }

  void removeBreakpoint(String nodeId) {
    breakpoints.remove(nodeId);
  }

  bool hasBreakpoint(String nodeId) {
    return breakpoints.contains(nodeId);
  }

  void captureSnapshot(String nodeId, Map<String, dynamic> data) {
    nodeSnapshots[nodeId] = Map.from(data);
  }

  Map<String, dynamic>? getSnapshot(String nodeId) {
    return nodeSnapshots[nodeId];
  }

  Future<void> pause() async {
    isPaused = true;
    // Wait for resume
    while (isPaused) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  void resume() {
    isPaused = false;
  }

  void stepOver() {
    resume();
  }
}
