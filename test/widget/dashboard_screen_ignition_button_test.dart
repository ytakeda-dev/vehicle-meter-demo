import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_meter_demo/domain/engine_state.dart';
import 'package:vehicle_meter_demo/features/dashboard/input/keyboard_engine_input_emitter.dart';
import 'package:vehicle_meter_demo/features/dashboard/provider/dashboard_notifier_provider.dart';
import 'package:vehicle_meter_demo/features/dashboard/provider/engine_input_event_bus_provider.dart';
import 'package:vehicle_meter_demo/features/dashboard/provider/keyboard_engine_input_emitter_provider.dart';
import 'package:vehicle_meter_demo/features/dashboard/state/brand.dart';
import 'package:vehicle_meter_demo/features/dashboard/state/dashboard_state.dart';
import 'package:vehicle_meter_demo/features/dashboard/state/meter_mode.dart';
import 'package:vehicle_meter_demo/features/dashboard/test_keys/dashboard_keys.dart';
import 'package:vehicle_meter_demo/features/dashboard/ui/constants.dart';
import 'package:vehicle_meter_demo/features/dashboard/ui/dashboard_screen.dart';

class FakeDashboardNotifier extends DashboardNotifier {
  FakeDashboardNotifier(this._initial);

  final DashboardState _initial;

  @override
  DashboardState build() => _initial;
}

void main() {
  Future<void> pumpWithState(
    WidgetTester tester,
    EngineState engineState,
  ) async {
    final initial = DashboardState(
      engineState: engineState,
      meterMode: MeterMode.analog,
      displayRpm: 1234,
      brand: Brand.toyota,
    );

    await tester.pumpWidget(
      ProviderScope(
        // ProviderScope's Element (and its ProviderContainer) may be reused across pumps.
        // Without a unique key, overrides might not be rebuilt, leaving the old state.
        key: UniqueKey(),
        overrides: [
          // Prevent real keyboard hook registration in widget tests.
          keyboardEngineInputEmitterProvider.overrideWith((ref) {
            final bus = ref.read(engineInputEventBusProvider);
            // Create emitter but don't attach.
            return KeyboardEngineInputEmitter(bus);
          }),
          dashboardNotifierProvider.overrideWith(
            () => FakeDashboardNotifier(initial),
          ),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Color ignitionButtonBackgroundColor(WidgetTester tester) {
    // Use a stable test contract: the IGNITION button is identified by key.
    // This avoids coupling tests to label text or internal widget structure.
    final button = tester.widget<ElevatedButton>(
      find.byKey(DashboardKeys.ignitionButton),
    );

    // Assert via ElevatedButton's public API (ButtonStyle) rather than digging for
    // an internal Material widget. This keeps the test resilient to implementation
    // changes inside Flutter or the button widget.
    final bg = button.style?.backgroundColor?.resolve(<WidgetState>{});

    if (bg == null) {
      fail(
        'IGNITION button backgroundColor is null (style/backgroundColor not set)',
      );
    }
    return bg;
  }

  /// This test checks the visual mapping (EngineState → IGNITION button color) by pumping the screen
  /// with controlled provider state, avoiding real keyboard/input side effects.
  testWidgets('IGNITION button color follows EngineState', (tester) async {
    // Widget tests run with a default test surface (often 800x600),
    // which may cause layout overflows for UIs designed for larger screens.
    // Set an explicit surface size so the test environment matches the intended layout.
    await tester.binding.setSurfaceSize(const Size(kScreenWidth, kScreenHeight));
    addTearDown(() async => tester.binding.setSurfaceSize(null));

    // Off
    await pumpWithState(tester, EngineState.off);
    expect(
      ignitionButtonBackgroundColor(tester).toARGB32(),
      equals(Colors.grey.shade700.toARGB32()),
    );

    // Starting => orange(500)
    await pumpWithState(tester, EngineState.starting);
    // Compare ARGB32 so that we can ignore Color/MaterialColor type difference.
    expect(
      ignitionButtonBackgroundColor(tester).toARGB32(),
      equals(Colors.orange.toARGB32()),
    );

    // Running => green(500)
    await pumpWithState(tester, EngineState.running);
    // We intentionally use a fixed shade (500) as a spec for this demo.
    // In real-world UI tests, this can be loosened to a hue-based comparison
    // to make tests more resilient against theming or Material changes.
    // Example:
    // final hsv = HSVColor.fromColor(ignitionButtonBackgroundColor(tester));
    // expect(hsv.hue, closeTo(120, 8)); // green-ish
    expect(
      ignitionButtonBackgroundColor(tester).toARGB32(),
      equals(Colors.green.shade500.toARGB32()),
    );
  });
}
