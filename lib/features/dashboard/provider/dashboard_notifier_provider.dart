import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_meter_demo/domain/engine_input.dart';
import 'package:vehicle_meter_demo/domain/engine_state.dart';
import 'package:vehicle_meter_demo/features/dashboard/state/meter_mode.dart';
import 'package:vehicle_meter_demo/features/dashboard/data/engine_input_datasource.dart';
import 'package:vehicle_meter_demo/features/dashboard/provider/engine_input_datasource_provider.dart';
import 'package:vehicle_meter_demo/features/dashboard/state/brand.dart';
import 'package:vehicle_meter_demo/features/dashboard/state/dashboard_state.dart';

import '../ui/constants.dart';

final dashboardNotifierProvider =
    NotifierProvider<DashboardNotifier, DashboardState>(DashboardNotifier.new);

/// Converts and notifies EngineInput to Dashboard
/// Process flow:
/// Timer (60fps)
///    ↓
/// _tick(dt)
///    ↓
/// engineState switch
///    ↓
/// updateXXX(dt)
///    ↓
/// state = copyWith(...)
///    ↓
/// UI rebuild
class DashboardNotifier extends Notifier<DashboardState> {
  late final EngineInputDataSource _dataSource;
  StreamSubscription<EngineInput>? _sub;
  Timer? _engineLoop;
  DateTime? _lastTick;
  bool _isThrottlePressed = false;

  @override
  DashboardState build() {
    _dataSource = ref.read(engineInputDataSourceProvider);
    _sub = _dataSource.inputs.listen(_onEngineInput);

    // Start engine input monitoring loop.
    _startEngineLoop();

    ref.onDispose(() {
      _sub?.cancel();
      _engineLoop?.cancel();
    });

    return DashboardState.initial();
  }

  void _onEngineInput(EngineInput input) {
    switch (input) {
      case KeyboardEngineIgnitionRequested():
        _toggleEngine();
      case KeyboardThrottlePressed():
        _increaseRpm();
      case KeyboardThrottleReleased():
        _decreaseRpm();
      case GPIOEngineIgnitionRequested():
        // Future use
        break;
      case GPIOThrottlePressed():
        // Future use
        break;
      case GPIOThrottleReleased():
        // Future use
        break;
    }
  }

  /// Controls continuous state change for smooth UI update (pseudo-animation).
  void _startEngineLoop() {
    // Save the initial invocation time.
    _lastTick = DateTime.now();

    // Construct a Timer to apply meter state update periodically.
    _engineLoop = Timer.periodic(
      // About 60fps (1000ms/60fps=16.66...). Can be adjusted depends on hardware spec.
      const Duration(milliseconds: 16),
      (_) {
        final now = DateTime.now();
        // Calculate the difference from the previous value to determine the quantity to apply this time
        final dt = now.difference(_lastTick!).inMilliseconds / 1000.0;
        // Save the current as the new last.
        _lastTick = now;

        // Pass the calculated time difference as a base unit to calculate the RPM update unit per time.
        _tick(dt);
      },
    );
  }

  /// Applies state change at a point of time.
  void _tick(double dt) {
    switch (state.engineState) {
      case .off:
        _updateCooling(dt);
        break;
      case .starting:
        _updateWarmUp(dt);
        break;
      case .running:
        _updateRunning(dt);
        break;
    }
  }

  /// Applies meter decrement per time on ignition off.
  void _updateCooling(double dt) {
    // Handle the last one gap.
    if (state.displayRpm <= 0.1) {
      state = state.copyWith(displayRpm: 0.0);
      // Can stop the loop here for future optimization.
      // E.g.) for batter efficiency, background handling or else.
      // Make sure to re-start the loop again on KeyboardEngineIgnitionRequested.
      // _engineLoop?.cancel();
      return;
    }
    final next = state.displayRpm + (0 - state.displayRpm) * dt * 5;
    // Updates RPM until the current RPM reaches 0RPM.
    state = state.copyWith(displayRpm: next.clamp(0, kMaxRpm));
  }

  /// Applies meter increment/decrement per time while running.
  void _updateRunning(double dt) {
    final target = _isThrottlePressed ? kRevLimitRpm : kIdleRpm;
    final next = state.displayRpm + (target - state.displayRpm) * dt * 5;

    state = state.copyWith(displayRpm: next.clamp(0, kRevLimitRpm));
  }

  /// Applies meter increment and hold per time on engine start up.
  void _updateWarmUp(double dt) {
    final nextRpm = (state.displayRpm + 5000 * dt).clamp(0, kWarmUpRpm);
    // Updates RPM until the current RPM reaches warmUpRpm.
    state = state.copyWith(displayRpm: nextRpm.toDouble());

    // Updates engine state to .running when warm up is done.
    if (nextRpm >= kWarmUpRpm) {
      // Let _updateRunning handle decrement to idleRpm.
      state = state.copyWith(engineState: .running);
    }
  }

  /// Starts the engine.
  void _ignitionOn() {
    state = switch (state.engineState) {
      EngineState.off => _warmUp(),
      EngineState.starting => state, // Ignore IG ON duplication.
      EngineState.running => state, // Ignore IG ON duplication.
    };
  }

  /// Rev up to ignitionOnRpm.
  DashboardState _warmUp() {
    return state.copyWith(engineState: .starting, displayRpm: 0.0);
  }

  /// Terminates the engine.
  void _ignitionOff() {
    state = switch (state.engineState) {
      EngineState.off => state, // Ignore IG OFF duplication.
      EngineState.starting => state.copyWith(engineState: .off),
      EngineState.running => state.copyWith(engineState: .off),
    };
  }

  /// Flip start/running/stop with one call.
  void _toggleEngine() {
    switch (state.engineState) {
      case EngineState.off:
        _ignitionOn();
        break;
      case EngineState.starting:
        _ignitionOff();
        break;
      case EngineState.running:
        _ignitionOff();
        break;
    }
  }

  /// Tracks throttle pressed.
  void _increaseRpm() {
    _isThrottlePressed = true;
  }

  /// Tracks throttle released.
  void _decreaseRpm() {
    _isThrottlePressed = false;
  }

  /// Changes meter UI to given mode.
  void setMeterMode(MeterMode mode) {
    state = state.copyWith(meterMode: mode);
  }

  /// Toggle meter UI by one call.
  void toggleMeterMode() {
    state = state.copyWith(
      meterMode: state.meterMode == .analog ? .bar : .analog,
    );
  }

  /// Applies given brand.
  void selectBrand(Brand brand) {
    state = state.copyWith(brand: brand);
    _applySoundAsset(brand);
  }

  void _applySoundAsset(Brand brand) {
    // Future use: Call sound asset manager or else.
  }
}
