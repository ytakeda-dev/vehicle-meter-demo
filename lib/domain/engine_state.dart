/// A state which represents the current engine state.
enum EngineState {
  /// Engine off.
  off,

  /// Igniting engine.
  starting,

  /// Engine has started and running.
  running,
}

/// Returns descriptive state.
extension EngineStateX on EngineState {
  /// Explain why we need these 2 even though both referencing the same original state.
  bool get isRunning => this == EngineState.running;
  bool get canRev => this == EngineState.running;
}
