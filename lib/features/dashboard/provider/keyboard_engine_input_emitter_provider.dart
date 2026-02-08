import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_meter_demo/features/dashboard/input/keyboard_engine_input_emitter.dart';
import 'package:vehicle_meter_demo/features/dashboard/provider/engine_input_event_bus_provider.dart';

final keyboardEngineInputEmitterProvider = Provider<KeyboardEngineInputEmitter>(
  (ref) {
    final bus = ref.read(engineInputEventBusProvider);
    final emitter = KeyboardEngineInputEmitter(bus);

    emitter.attach();
    ref.onDispose(emitter.detach);

    return emitter;
  },
);
