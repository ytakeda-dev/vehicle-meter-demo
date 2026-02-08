import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_meter_demo/features/dashboard/input/keyboard_engine_input_emitter.dart';
import 'package:vehicle_meter_demo/features/dashboard/test_keys/dashboard_keys.dart';

import 'package:vehicle_meter_demo/features/dashboard/ui/dashboard_screen.dart';
import 'package:vehicle_meter_demo/features/dashboard/provider/engine_input_event_bus_provider.dart';
import 'package:vehicle_meter_demo/features/dashboard/provider/keyboard_engine_input_emitter_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// End-to-end test verifying the main engine interaction flow:
  /// IGNITION starts the engine, THROTTLE increases RPM while held, and releasing decreases RPM.
  testWidgets('E2E: IGNITION then THROTTLE increases RPM and releasing decreases', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Avoid registering real hardware keyboard handler in integration environment.
          keyboardEngineInputEmitterProvider.overrideWith((ref) {
            final bus = ref.read(engineInputEventBusProvider);
            return KeyboardEngineInputEmitter(bus); // no attach
          }),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );

    await tester.pumpAndSettle();

    // Tap IGNITION
    await tester.tap(find.byKey(DashboardKeys.ignitionButton));
    await tester.pump();

    // Allow time for the engine state to transition (e.g. off → starting → running)
    // before asserting RPM changes.
    await tester.pump(const Duration(seconds: 1));

    double readRpm() {
      // Read RPM via a stable key-based contract rather than relying on text search,
      // to keep the test resilient to layout or label changes.
      final numText = tester.widget<Text>(find.byKey(DashboardKeys.rpmValue));
      return double.tryParse((numText.data ?? '').trim()) ?? 0.0;
    }

    final rpm1 = readRpm();

    // Press and hold THROTTLE to simulate continuous acceleration.
    // We use a raw gesture to control press/release timing explicitly.
    final throttleFinder = find.byKey(DashboardKeys.throttleButton);
    final center = tester.getCenter(throttleFinder);
    final gesture = await tester.startGesture(center);
    await tester.pump(const Duration(milliseconds: 600));
    final rpm2 = readRpm();
    expect(rpm2, greaterThan(rpm1));

    // After releasing the throttle, RPM should decrease over time.
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 800));
    final rpm3 = readRpm();
    expect(rpm3, lessThan(rpm2));
  });
}
