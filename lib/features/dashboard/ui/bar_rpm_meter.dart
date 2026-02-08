import 'package:flutter/material.dart';

/// Vertical bar-style RPM meter.
/// The filled height is calculated from the normalized RPM value.
class BarRpmMeter extends StatelessWidget {
  const BarRpmMeter({
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

  @override
  Widget build(BuildContext context) {
    final t = (rpm / maxRpm).clamp(0.0, 1.0);
    final redT = (redlineRpm / maxRpm).clamp(0.0, 1.0);

    return Center(
      child: SizedBox(
        width: 260,
        height: 320,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              rpm.toStringAsFixed(0),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 44,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              engineStateLabel,
              style: const TextStyle(color: Colors.white38),
            ),
            const SizedBox(height: 18),

            // bar frame
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final h = constraints.maxHeight;
                  final fillH = h * t;
                  final redH = h * (1 - redT);

                  return Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white12),
                        ),
                      ),

                      // filled section
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        curve: Curves.easeOut,
                        width: 80,
                        height: fillH,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.cyanAccent.withOpacity(0.85),
                              Colors.cyanAccent.withOpacity(0.25),
                            ],
                          ),
                        ),
                      ),

                      // redline overlay area (top zone)
                      Positioned(
                        top: 0,
                        child: SizedBox(
                          width: 80,
                          height: redH,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.redAccent.withOpacity(0.10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
