import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:vehicle_meter_demo/domain/engine_input.dart';
import 'package:vehicle_meter_demo/features/dashboard/data/engine_input_datasource.dart';

/// Input hub class for engine input mocking throttle by keyboard input or UI interaction.
class EngineInputEventBus implements EngineInputDataSource {
  final _controller = StreamController<EngineInput>.broadcast();

  /// Expose stream to catch keyboard input dynamically.
  @override
  Stream<EngineInput> get inputs => _controller.stream;

  void emit(EngineInput input) {
    _addSafely(_controller, input);
  }

  void _addSafely<T>(StreamController<T> controller, T value) {
    if (!controller.isClosed) {
      controller.add(value);
    } else {
      debugPrint("StreamController is closed. Failed to add value.");
    }
  }

  void dispose() {
    _controller.close();
  }
}
