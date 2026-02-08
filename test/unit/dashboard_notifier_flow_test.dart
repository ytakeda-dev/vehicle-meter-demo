import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_meter_demo/domain/engine_input.dart';
import 'package:vehicle_meter_demo/domain/engine_state.dart';
import 'package:vehicle_meter_demo/features/dashboard/provider/dashboard_notifier_provider.dart';
import 'package:vehicle_meter_demo/features/dashboard/provider/engine_input_datasource_provider.dart';
import 'package:vehicle_meter_demo/features/dashboard/ui/constants.dart';

import '../helpers/fakes.dart';

void main() {
  /// This test validates the engine state machine at the notifier level: ignition events trigger transitions,
  /// and warm-up/cool-down progress is advanced deterministically without relying on real timers.
  test('Engine flow: off -> starting -> running -> off', () async {
    final ds = FakeEngineInputDataSource();

    final container = ProviderContainer(
      overrides: [engineInputDataSourceProvider.overrideWithValue(ds)],
    );
    addTearDown(container.dispose);
    addTearDown(ds.close);

    // Boot the notifier
    final notifier = container.read(dashboardNotifierProvider.notifier);

    // Stop periodic timer loop for deterministic test (requires debug hook)
    notifier.debugStopEngineLoop();

    // Initial
    expect(
      container.read(dashboardNotifierProvider).engineState,
      EngineState.off,
    );

    // Ignition ON -> starting
    ds.emit(KeyboardEngineIgnitionRequested());
    // Flush async event delivery from the fake input source.
    await Future<void>.delayed(Duration.zero);
    expect(
      container.read(dashboardNotifierProvider).engineState,
      EngineState.starting,
    );

    // Warm-up ticks until kWarmUpRpm reached => running
    for (var i = 0; i < 200; i++) {
      notifier.debugTick(0.016); // ~60fps
      final s = container.read(dashboardNotifierProvider);
      if (s.engineState == EngineState.running) break;
    }
    expect(
      container.read(dashboardNotifierProvider).engineState,
      EngineState.running,
    );

    // Ignition OFF -> off
    ds.emit(KeyboardEngineIgnitionRequested());
    await Future<void>.delayed(Duration.zero);
    expect(
      container.read(dashboardNotifierProvider).engineState,
      EngineState.off,
    );

    // Cooling goes to 0
    for (var i = 0; i < 300; i++) {
      notifier.debugTick(0.016);
    }
    expect(
      container.read(dashboardNotifierProvider).displayRpm,
      closeTo(0.0, 0.2),
    );
    expect(
      container.read(dashboardNotifierProvider).displayRpm,
      inInclusiveRange(0.0, kMaxRpm),
    );
  });
}
