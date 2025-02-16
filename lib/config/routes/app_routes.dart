import 'package:flutter/material.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/camera/presentation/pages/camera_page.dart';
import '../../features/kwh_calculator/presentation/pages/kwh_page.dart';
import '../../features/gps/presentation/pages/gps_page.dart';
import '../../features/notes/presentation/pages/notes_page.dart';
import '../../features/scanner/presentation/pages/scanner_page.dart';
import '../../features/water_calculator/presentation/pages/water_page.dart';

class AppRoutes {
  static const String dashboard = '/';
  static const String camera = '/camera';
  static const String notes = '/notes';
  static const String kwh = '/kwh';
  static const String water = '/water';
  static const String gps = '/gps';
  static const String scanner = '/scanner';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardPage());
      case camera:
        return MaterialPageRoute(builder: (_) => const CameraPage());
      case notes:
        return MaterialPageRoute(builder: (_) => const NotesPage());
      case kwh:
        return MaterialPageRoute(builder: (_) => const KwhPage());
      case water:
        return MaterialPageRoute(builder: (_) => const WaterPage());
      case scanner:
        return MaterialPageRoute(builder: (_) => const ScannerPage());
      case gps:
        return MaterialPageRoute(builder: (_) => const GpsPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
