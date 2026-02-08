import 'package:vehicle_meter_demo/domain/engine_state.dart';
import 'package:vehicle_meter_demo/features/dashboard/state/meter_mode.dart';
import 'package:vehicle_meter_demo/features/dashboard/state/brand.dart';
import 'package:vehicle_meter_demo/features/dashboard/state/rpm.dart';

class DashboardState {
  final EngineState engineState;
  final MeterMode meterMode;
  final Rpm displayRpm;
  final Brand brand;

  const DashboardState({
    required this.engineState,
    required this.meterMode,
    required this.displayRpm,
    required this.brand,
  });

  factory DashboardState.initial() {
    return const DashboardState(
      engineState: EngineState.off,
      meterMode: MeterMode.analog,
      displayRpm: 0.0,
      brand: Brand.toyota,
    );
  }

  DashboardState copyWith({
    EngineState? engineState,
    MeterMode? meterMode,
    Rpm? displayRpm,
    Brand? brand,
  }) {
    return DashboardState(
      engineState: engineState ?? this.engineState,
      meterMode: meterMode ?? this.meterMode,
      displayRpm: displayRpm ?? this.displayRpm,
      brand: brand ?? this.brand,
    );
  }
}
