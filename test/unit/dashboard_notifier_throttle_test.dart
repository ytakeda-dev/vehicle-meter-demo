import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_meter_demo/domain/engine_input.dart';
import 'package:vehicle_meter_demo/domain/engine_state.dart';
import 'package:vehicle_meter_demo/features/dashboard/provider/dashboard_notifier_provider.dart';
import 'package:vehicle_meter_demo/features/dashboard/provider/engine_input_datasource_provider.dart';
import 'package:vehicle_meter_demo/features/dashboard/ui/constants.dart';

import '../helpers/fakes.dart';

void main() {
  /// This test verifies the domain-level RPM behavior driven by engine input events:
  /// throttle press increases RPM up to the rev limit, and release decreases RPM, using a fake data source and manual ticks.
  test(
    'Throttle press/release changes RPM direction and respects rev limit',
    () async {
      final ds = FakeEngineInputDataSource();

      final container = ProviderContainer(
        overrides: [engineInputDataSourceProvider.overrideWithValue(ds)],
      );
      addTearDown(container.dispose);
      addTearDown(ds.close);

      final notifier = container.read(dashboardNotifierProvider.notifier);
      notifier.debugStopEngineLoop();

      // Move to running state first
      ds.emit(KeyboardEngineIgnitionRequested());
      // Flush async event delivery from the fake data source.
      await Future<void>.delayed(Duration.zero);
      // Advance time deterministically (simulate ~60fps) via debugTick().
      for (var i = 0; i < 200; i++) {
        notifier.debugTick(0.016);
        if (container.read(dashboardNotifierProvider).engineState ==
            EngineState.running) {
          break;
        }
      }
      expect(
        container.read(dashboardNotifierProvider).engineState,
        EngineState.running,
      );

      // Press throttle => RPM should increase toward kRevLimitRpm
      ds.emit(KeyboardThrottlePressed());
      await Future<void>.delayed(Duration.zero);

      final before = container.read(dashboardNotifierProvider).displayRpm;
      for (var i = 0; i < 120; i++) {
        notifier.debugTick(0.016);
      }
      final afterUp = container.read(dashboardNotifierProvider).displayRpm;
      expect(afterUp, greaterThan(before));
      expect(afterUp, lessThanOrEqualTo(kRevLimitRpm + 0.1));

      // Release throttle => RPM should decrease toward idle
      ds.emit(KeyboardThrottleReleased());
      await Future<void>.delayed(Duration.zero);

      final beforeDown = container.read(dashboardNotifierProvider).displayRpm;
      for (var i = 0; i < 180; i++) {
        notifier.debugTick(0.016);
      }
      final afterDown = container.read(dashboardNotifierProvider).displayRpm;
      expect(afterDown, lessThan(beforeDown));
      expect(afterDown, greaterThanOrEqualTo(0.0));
    },
  );
}
