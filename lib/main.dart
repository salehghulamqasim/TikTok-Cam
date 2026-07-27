import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:device_preview/device_preview.dart';

import 'cubit/camera_cubit.dart';
import 'cubit/filter_cubit.dart';
import 'pages/camera_screen.dart';
import 'theme/app_theme.dart';

// ─── Toggle DevicePreview ────────────────────────────────────────────────────
// Set to true  → runs inside DevicePreview (great for web/demo)
// Set to false → runs normally on a real device/emulator
const bool useDevicePreview = false;
// ────────────────────────────────────────────────────────────────────────────

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (useDevicePreview) {
    runApp(DevicePreview(enabled: true, builder: (_) => const TikTokCamApp()));
  } else {
    runApp(const TikTokCamApp());
  }
}

class TikTokCamApp extends StatelessWidget {
  const TikTokCamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CameraCubit>(create: (_) => CameraCubit()),
        BlocProvider<FilterCubit>(create: (_) => FilterCubit()),
      ],
      child: MaterialApp(
        title: 'TikTok Cam',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        // These three lines are required for DevicePreview to work correctly.
        // They are safely ignored when useDevicePreview is false.
        // ignore: deprecated_member_use
        useInheritedMediaQuery: useDevicePreview,
        locale: useDevicePreview ? DevicePreview.locale(context) : null,
        builder: useDevicePreview ? DevicePreview.appBuilder : null,
        home: const CameraScreen(),
      ),
    );
  }
}
