import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_meter_demo/features/dashboard/ui/constants.dart';
import 'package:window_manager/window_manager.dart';

import 'features/dashboard/ui/dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(kScreenWidth, kScreenHeight),
    minimumSize: Size(kScreenWidth, kScreenHeight),
    maximumSize: Size(kScreenWidth, kScreenHeight),
    center: true,
    backgroundColor: Colors.transparent,
    titleBarStyle: TitleBarStyle.normal,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vehicle Meter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const DashboardScreen(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(size: const Size(kScreenWidth, kScreenHeight), devicePixelRatio: 1.0),
          child: child!,
        );
      },
    );
  }
}
