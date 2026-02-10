import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_meter_demo/features/dashboard/input/keyboard_engine_input_emitter.dart';
import 'package:vehicle_meter_demo/features/dashboard/provider/dashboard_notifier_provider.dart';
import 'package:vehicle_meter_demo/features/dashboard/provider/engine_input_event_bus_provider.dart';
import 'package:vehicle_meter_demo/features/dashboard/provider/keyboard_engine_input_emitter_provider.dart';
import 'package:vehicle_meter_demo/features/dashboard/state/brand.dart';
import 'package:vehicle_meter_demo/features/dashboard/state/dashboard_state.dart';
import 'package:vehicle_meter_demo/features/dashboard/state/meter_mode.dart';
import 'package:vehicle_meter_demo/features/dashboard/test_keys/dashboard_keys.dart';
import 'package:vehicle_meter_demo/features/dashboard/ui/analog_rpm_meter.dart';
import 'package:vehicle_meter_demo/features/dashboard/ui/bar_rpm_meter.dart';
import 'package:vehicle_meter_demo/features/dashboard/ui/constants.dart';
import 'package:vehicle_meter_demo/features/dashboard/ui/dashboard_screen.dart';
import 'package:vehicle_meter_demo/domain/engine_state.dart';

class FakeDashboardNotifier extends DashboardNotifier {
  FakeDashboardNotifier(this._initial);

  final DashboardState _initial;

  @override
  DashboardState build() => _initial;

  @override
  void setMeterMode(MeterMode mode) {
    state = state.copyWith(meterMode: mode);
  }
}

void main() {
  /// This test validates the widget-switching contract (toggle → state update → UI change)
  /// using a minimal fake notifier, rather than exercising full application behavior.
  testWidgets('Meter mode switch toggles meter widget', (tester) async {
    // Widget tests run with a default test surface (often 800x600),
    // which may cause layout overflows for UIs designed for larger screens.
    // Set an explicit surface size so the test environment matches the intended layout.
    await tester.binding.setSurfaceSize(const Size(kScreenWidth, kScreenHeight));
    addTearDown(() async => tester.binding.setSurfaceSize(null));

    final initial = DashboardState(
      engineState: EngineState.off,
      meterMode: MeterMode.analog,
      displayRpm: 2500,
      brand: Brand.toyota,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          keyboardEngineInputEmitterProvider.overrideWith((ref) {
            final bus = ref.read(engineInputEventBusProvider);
            return KeyboardEngineInputEmitter(bus); // no attach
          }),
          dashboardNotifierProvider.overrideWith(
            () => FakeDashboardNotifier(initial),
          ),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Confirm toggle exists (anchor for scoped finds).
    final toggle = find.byKey(DashboardKeys.meterModeToggle);
    expect(toggle, findsOneWidget);

    // Initial: Analog
    expect(find.byType(AnalogRpmMeter), findsOneWidget);
    expect(find.byType(BarRpmMeter), findsNothing);

    // Tap the BAR tab (scoped to the toggle to avoid accidental matches elsewhere).
    // We scope by the toggle root because the third-party toggle widget
    // does not expose keys for individual tabs.
    await tester.tap(
      find.descendant(
        of: toggle,
        matching: find.text(MeterMode.bar.name.toUpperCase()),
      ),
    );

    // AnimatedSwitcher duration is 220ms, applying 250ms should be enough.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    // Switched to bar
    expect(find.byKey(DashboardKeys.analogMeter), findsNothing);
    expect(find.byKey(DashboardKeys.barMeter), findsOneWidget);

    // Back to analog
    await tester.tap(
      find.descendant(
        of: toggle,
        matching: find.text(MeterMode.analog.name.toUpperCase()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byKey(DashboardKeys.analogMeter), findsOneWidget);
    expect(find.byKey(DashboardKeys.barMeter), findsNothing);
  });
}
