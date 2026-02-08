/// Maximum RPM value for the meter scale.
const double kMaxRpm = 10000.0;

/// Redline threshold where the meter switches to warning color.
const double kRevLimitRpm = 8000.0;

/// Redline UI threshold for display use.
const double kRedlineStartRpm = 8000.0;

/// A warming up rpm on start up.
const double kWarmUpRpm = 1500.0;

/// An idle state.
const double kIdleRpm = 800.0;

/// Starting angle of the analog meter needle (bottom-left).
const double kNeedleStartDeg = -135;

/// Total sweep angle of the analog meter.
const double kNeedleSweepDeg = 270;

/// Whole analog meter size.
const double kMeterSize = 320;

/// An element with half the width of the device screen, centered horizontally.
/// Occupies center 1/2 of given width, leaves 1/4 margin horizontally
const double kCarouselWidthRatio = 0.5;

/// Number of visible items in the carousel. 0.22 ≒ 5 items.
const double kCarouselViewportFraction = 0.22;

/// Width that hides both horizontal edges of the carousel.
const double kEdgeMaskWidth = 90;
