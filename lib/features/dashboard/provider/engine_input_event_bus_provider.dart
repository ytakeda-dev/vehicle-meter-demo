import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_meter_demo/features/dashboard/data/engine_input_event_bus.dart';

final engineInputEventBusProvider = Provider<EngineInputEventBus>((ref) {
  final bus = EngineInputEventBus();
  ref.onDispose(bus.dispose);
  return bus;
});
