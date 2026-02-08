import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:vehicle_meter_demo/domain/engine_input.dart';
import 'package:vehicle_meter_demo/features/dashboard/data/engine_input_datasource.dart';

/// A simple controllable datasource for unit tests.
class FakeEngineInputDataSource implements EngineInputDataSource {
  final StreamController<EngineInput> _controller =
      StreamController.broadcast();

  @override
  Stream<EngineInput> get inputs => _controller.stream;

  void emit(EngineInput input) => _controller.add(input);

  Future<void> close() => _controller.close();
}

/// Helper to create a ProviderContainer with a fake input datasource.
ProviderContainer createTestContainer({
  required EngineInputDataSource dataSource,
  List<Override> overrides = const [],
}) {
  return ProviderContainer(
    overrides: [
      ...overrides,
      // Most tests want to control EngineInput stream deterministically.
      // Override EngineInputDataSource to a fake.
      // NOTE: import in test files: engine_input_datasource_provider.dart
    ],
  );
}
