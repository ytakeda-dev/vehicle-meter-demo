import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_meter_demo/features/dashboard/data/engine_input_datasource.dart';
import 'package:vehicle_meter_demo/features/dashboard/provider/engine_input_event_bus_provider.dart';

final engineInputDataSourceProvider = Provider<EngineInputDataSource>((ref) {
  return ref.read(engineInputEventBusProvider);
});
