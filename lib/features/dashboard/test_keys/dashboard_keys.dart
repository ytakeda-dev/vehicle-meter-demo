import 'package:flutter/cupertino.dart';

/// Keys for testing.
abstract class DashboardKeys {
  static const meterModeToggle = Key('meter_mode_toggle');
  static const analogMeter = Key('analog');
  static const barMeter = Key('bar');
  static const rpmValue = Key('dashboard_rpm_value');
  static const ignitionButton = Key('dashboard_ignition_button');
  static const throttleButton = Key('dashboard_throttle_button');
}
