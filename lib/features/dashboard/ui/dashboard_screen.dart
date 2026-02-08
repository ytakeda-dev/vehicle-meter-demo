import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:vehicle_meter_demo/domain/engine_input.dart';
import 'package:vehicle_meter_demo/domain/engine_state.dart';
import 'package:vehicle_meter_demo/features/dashboard/state/meter_mode.dart';
import 'package:vehicle_meter_demo/features/dashboard/provider/dashboard_notifier_provider.dart';
import 'package:vehicle_meter_demo/features/dashboard/provider/engine_input_event_bus_provider.dart';
import 'package:vehicle_meter_demo/features/dashboard/provider/keyboard_engine_input_emitter_provider.dart';
import 'package:vehicle_meter_demo/features/dashboard/state/brand.dart';
import 'package:vehicle_meter_demo/features/dashboard/ui/analog_rpm_meter.dart';
import 'package:vehicle_meter_demo/features/dashboard/ui/bar_rpm_meter.dart';
import 'package:vehicle_meter_demo/features/dashboard/ui/constants.dart';

/// Main dashboard screen.
/// This screen observes DashboardState and renders UI accordingly.
/// All business logic and timing are handled by DashboardNotifier.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Make sure to keep an emitter alive.
    ref.watch(keyboardEngineInputEmitterProvider);

    final state = ref.watch(dashboardNotifierProvider);
    final engineState = state.engineState;
    final notifier = ref.read(dashboardNotifierProvider.notifier);
    final bus = ref.read(engineInputEventBusProvider);

    final carouselController = CarouselSliderController();
    final selectedIndex = Brand.values.indexOf(state.brand);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final carouselWidth = w * kCarouselWidthRatio;

            return Center(
              child: SizedBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- Meter mode toggle ---
                    FlutterToggleTab(
                      width: 60,
                      borderRadius: 18,
                      selectedTextStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      unSelectedTextStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      dataTabs: MeterMode.values
                          .map((m) => DataTab(title: m.name.toUpperCase()))
                          .toList(),
                      selectedIndex: state.meterMode.index,
                      selectedLabelIndex: (index) {
                        notifier.setMeterMode(MeterMode.values[index]);
                      },
                    ),
                    const SizedBox(height: 18),

                    // --- Meter area ---
                    SizedBox(
                      height: 360,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        child: state.meterMode == MeterMode.analog
                            ? AnalogRpmMeter(
                                key: const ValueKey('analog'),
                                rpm: state.displayRpm,
                                maxRpm: kMaxRpm,
                                redlineRpm: kRedlineStartRpm,
                                engineStateLabel: state.engineState.name
                                    .toUpperCase(),
                              )
                            : BarRpmMeter(
                                key: const ValueKey('bar'),
                                rpm: state.displayRpm,
                                maxRpm: kMaxRpm,
                                redlineRpm: kRedlineStartRpm,
                                engineStateLabel: state.engineState.name
                                    .toUpperCase(),
                              ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          state.displayRpm.toStringAsFixed(0),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ' RPM',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // --- Brand carousel ---
                    SizedBox(
                      width: carouselWidth,
                      height: 70,
                      child: Stack(
                        children: [
                          CarouselSlider.builder(
                            carouselController: carouselController,
                            itemCount: Brand.values.length,
                            itemBuilder: (context, index, realIndex) {
                              final brand = Brand.values[index];
                              return _BrandCarouselItem(
                                brand: brand,
                                isSelected: brand == state.brand,
                              );
                            },
                            options: CarouselOptions(
                              initialPage: selectedIndex,
                              height: 70,
                              viewportFraction: kCarouselViewportFraction,
                              enlargeCenterPage: true,
                              enlargeFactor: 0.28,
                              enableInfiniteScroll: true,
                              onPageChanged: (index, _) {
                                notifier.selectBrand(Brand.values[index]);
                              },
                            ),
                          ),

                          // Blur/fade effect in the both edges.
                          _EdgeBlurMask(side: _BlurSide.left),
                          _EdgeBlurMask(side: _BlurSide.right),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // --- Controls ---
                    SizedBox(
                      width: w * 0.5,
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _ignitionColor(engineState),
                                foregroundColor: Colors.white,
                                elevation: engineState == .off ? 2 : 8,
                              ),
                              onPressed: () {
                                bus.emit(KeyboardEngineIgnitionRequested());
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Text(
                                  'IGNITION',
                                  style: TextStyle(fontWeight: .bold),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTapDown: (_) =>
                                  bus.emit(KeyboardThrottlePressed()),
                              onTapUp: (_) =>
                                  bus.emit(KeyboardThrottleReleased()),
                              onTapCancel: () =>
                                  bus.emit(KeyboardThrottleReleased()),
                              child: ElevatedButton(
                                onPressed:
                                    () {}, // GestureDetector does everything.
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  child: Text('THROTTLE (HOLD)'),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Color _ignitionColor(EngineState s) {
    return switch (s) {
      EngineState.off => Colors.grey.shade700,
      EngineState.starting => Colors.orange,
      EngineState.running => Colors.green,
    };
  }
}

class _BrandCarouselItem extends StatelessWidget {
  const _BrandCarouselItem({required this.brand, required this.isSelected});

  final Brand brand;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      brand.displayName,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: brand.accentColor,
        fontSize: isSelected ? 20 : 16,
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
      ),
    );

    // Blur non-selected item a bit.
    return Center(
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        scale: isSelected ? 1.08 : 0.95,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: isSelected ? 1.0 : 0.55,
          child: isSelected
              ? text
              : ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 0.8, sigmaY: 0.8),
                  child: text,
                ),
        ),
      ),
    );
  }
}

enum _BlurSide { left, right }

class _EdgeBlurMask extends StatelessWidget {
  const _EdgeBlurMask({required this.side});

  final _BlurSide side;

  @override
  Widget build(BuildContext context) {
    final align = side == _BlurSide.left
        ? Alignment.centerLeft
        : Alignment.centerRight;
    final begin = side == _BlurSide.left
        ? Alignment.centerLeft
        : Alignment.centerRight;
    final end = side == _BlurSide.left
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Align(
      alignment: align,
      child: IgnorePointer(
        child: ClipRect(
          child: SizedBox(
            width: kEdgeMaskWidth,
            height: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // blur
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: const SizedBox(),
                ),
                // fade to transparent
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: begin,
                      end: end,
                      colors: [
                        Colors.black.withOpacity(0.95),
                        Colors.black.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
