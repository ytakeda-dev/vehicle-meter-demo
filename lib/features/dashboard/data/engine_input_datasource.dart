import 'package:vehicle_meter_demo/domain/engine_input.dart';

abstract class EngineInputDataSource {
  Stream<EngineInput> get inputs;
}
