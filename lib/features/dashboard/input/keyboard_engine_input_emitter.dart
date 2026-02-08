import 'package:flutter/services.dart';
import 'package:vehicle_meter_demo/domain/engine_input.dart';
import 'package:vehicle_meter_demo/features/dashboard/data/engine_input_event_bus.dart';

/// Emits input into datasource.
class KeyboardEngineInputEmitter {
  KeyboardEngineInputEmitter(this.bus);

  final EngineInputEventBus bus;

  void attach() {
    HardwareKeyboard.instance.addHandler(_onKeyEvent);
  }

  void detach() {
    HardwareKeyboard.instance.removeHandler(_onKeyEvent);
  }

  /// Invoked on every keyboard input.
  /// Only targets space key as throttle on this demo.
  bool _onKeyEvent(KeyEvent event) {
    final keyPressed = event.logicalKey;

    EngineInput? input;

    switch (keyPressed) {
      case .enter:
        input = event is KeyDownEvent
            ? KeyboardEngineIgnitionRequested()
            : null;
        break;
      case .space:
        input = (event is KeyDownEvent || event is KeyRepeatEvent)
            ? KeyboardThrottlePressed()
            : KeyboardThrottleReleased();
        break;
      default:
        break;
    }

    if (input != null) {
      bus.emit(input);
    }

    // Return true to prevent beep on key input.
    return true;
  }

  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKeyEvent);
  }
}
