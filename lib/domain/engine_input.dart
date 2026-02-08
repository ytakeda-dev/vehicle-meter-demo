/// Abstract layer for engine input.
/// Assuming GPIO in the future but use keyboard on this demo.
sealed class EngineInput {
  const EngineInput();
}

/// Future use: GPIO throttle.
class GPIOThrottlePressed extends EngineInput {}

class GPIOThrottleReleased extends EngineInput {}

class GPIOEngineIgnitionRequested extends EngineInput {}

/// Demo use: keyboard input as throttle.
class KeyboardThrottlePressed extends EngineInput {}

class KeyboardThrottleReleased extends EngineInput {}

class KeyboardEngineIgnitionRequested extends EngineInput {}
