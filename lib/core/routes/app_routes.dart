import 'package:flutter/material.dart';
import '../../features/camera/presentation/pages/camera_page.dart';
import '../../features/kwh_calculator/presentation/pages/kwh_page.dart';
import '../../features/water_calculator/presentation/pages/water_page.dart';
import '../../features/gps/presentation/pages/gps_page.dart';
import '../../features/scanner/presentation/pages/scanner_page.dart';
import '../../features/notes/presentation/pages/notes_page.dart';

class AppRoutes {
  static final Map<String, Widget Function(BuildContext)> routes = {
    '/camera': (context) => const CameraPage(),
    '/kwh': (context) => const KwhPage(),
    '/water': (context) => const WaterPage(),
    '/gps': (context) => const GpsPage(),
    '/scanner': (context) => const ScannerPage(),
    '/notes': (context) => const NotesPage(),
  };
}
