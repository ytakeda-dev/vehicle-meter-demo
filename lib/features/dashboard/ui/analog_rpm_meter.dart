import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vehicle_meter_demo/features/dashboard/ui/constants.dart';

/// Analog RPM meter.
/// This widget is stateless and purely visual.
/// It maps RPM values to a needle rotation angle.
class AnalogRpmMeter extends StatelessWidget {
  const AnalogRpmMeter({
    super.key,
    required this.rpm,
    required this.maxRpm,
    required this.redlineRpm,
    required this.engineStateLabel,
  });

  final double rpm;
  final double maxRpm;
  final double redlineRpm;
  final String engineStateLabel;

  // 270° range sweep from -135° to +135°
  double _rpmToAngle(double rpm) {
    final t = (rpm / maxRpm).clamp(0.0, 1.0);
    final start = kNeedleStartDeg * math.pi / 180.0;
    final sweep = kNeedleSweepDeg * math.pi / 180.0;
    return start + sweep * t;
  }

  @override
  Widget build(BuildContext context) {
    final angle = _rpmToAngle(rpm);

    return Center(
      child: SizedBox(
        width: kMeterSize,
        height: kMeterSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(kMeterSize, kMeterSize),
              painter: _AnalogDialPainter(
                maxRpm: maxRpm,
                redlineRpm: redlineRpm,
              ),
            ),

            /// Needle
            /// Convert RPM to a normalized value (0.0 - 1.0)
            /// and map it to the meter's sweep angle.
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: angle),
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              builder: (_, a, _) {
                return Transform.rotate(
                  angle: a,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 6,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                );
              },
            ),

            // Needle hub
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24),
              ),
            ),

            // Center labels
            Positioned(
              bottom: 30,
              child: Column(
                children: [
                  Text(
                    rpm.toStringAsFixed(0),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'RPM',
                    style: TextStyle(color: Colors.white54, letterSpacing: 2),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    engineStateLabel,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalogDialPainter extends CustomPainter {
  _AnalogDialPainter({required this.maxRpm, required this.redlineRpm});

  final double maxRpm;
  final double redlineRpm;

  // Converts a Canvas‑aligned radian (3‑o’clock) to a top‑aligned degree (12‑o’clock).
  double toCanvasRadFromTopDeg(double deg) {
    return (deg - 90.0) * math.pi / 180.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    // background circle
    final bg = Paint()..color = const Color(0xFF111111);
    canvas.drawCircle(c, r, bg);

    // arc parameters
    final start = toCanvasRadFromTopDeg(kNeedleStartDeg);
    final sweep = kNeedleSweepDeg * math.pi / 180.0;
    final rect = Rect.fromCircle(center: c, radius: r - 14);

    // base arc
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..color = Colors.white12;
    canvas.drawArc(rect, start, sweep, false, basePaint);

    // redline arc (8000 ~ 10000)
    final redStartT = (redlineRpm / maxRpm).clamp(0.0, 1.0);
    final redPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..color = Colors.redAccent.withValues(alpha: 0.9);
    canvas.drawArc(
      rect,
      start + sweep * redStartT,
      sweep * (1 - redStartT),
      false,
      redPaint,
    );

    // ticks (equivalent to 0 ~ 10 scales)
    final tickPaint = Paint()
      ..color = Colors.white38
      ..strokeWidth = 2;

    for (int i = 0; i <= 10; i++) {
      final t = i / 10.0;
      final a = start + sweep * t;
      final p1 = c + Offset(math.cos(a), math.sin(a)) * (r - 18);
      final p2 = c + Offset(math.cos(a), math.sin(a)) * (r - 32);

      tickPaint.color = (t >= redStartT) ? Colors.redAccent : Colors.white38;
      canvas.drawLine(p1, p2, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AnalogDialPainter oldDelegate) {
    return oldDelegate.maxRpm != maxRpm || oldDelegate.redlineRpm != redlineRpm;
  }
}
