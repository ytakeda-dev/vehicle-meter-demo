import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_meter_demo/domain/engine_input.dart';
import 'package:vehicle_meter_demo/features/dashboard/provider/dashboard_notifier_provider.dart';
import 'package:vehicle_meter_demo/features/dashboard/provider/engine_input_datasource_provider.dart';
import 'package:vehicle_meter_demo/features/dashboard/ui/constants.dart';

import '../helpers/fakes.dart';

void main() {
  /// This test is a deterministic “stress” check: with a fake input source and manual ticking,
  /// RPM must never go below 0 or exceed the configured limits throughout state changes.
  test('RPM invariant: never below 0 and never above limits', () async {
    final ds = FakeEngineInputDataSource();

    final container = ProviderContainer(
      overrides: [engineInputDataSourceProvider.overrideWithValue(ds)],
    );

    final state = container.read(dashboardNotifierProvider);
    final rpm = state.displayRpm;

    addTearDown(container.dispose);
    addTearDown(ds.close);

    final notifier = container.read(dashboardNotifierProvider.notifier);
    notifier.debugStopEngineLoop();

    // Ignite and run warm up
    ds.emit(KeyboardEngineIgnitionRequested());
    // Flush async event delivery from the fake input source.
    await Future<void>.delayed(Duration.zero);
    // Advance time deterministically (~60fps) via debugTick().
    for (var i = 0; i < 250; i++) {
      notifier.debugTick(0.016);
    }

    // Hammer throttle for a while
    ds.emit(KeyboardThrottlePressed());
    await Future<void>.delayed(Duration.zero);
    for (var i = 0; i < 600; i++) {
      notifier.debugTick(0.016);
      expect(rpm, inInclusiveRange(0.0, kRevLimitRpm + 0.1));
    }

    // Turn off and cool down
    ds.emit(KeyboardEngineIgnitionRequested());
    await Future<void>.delayed(Duration.zero);
    for (var i = 0; i < 800; i++) {
      notifier.debugTick(0.016);
      expect(rpm, inInclusiveRange(0.0, kMaxRpm));
    }
  });
}
