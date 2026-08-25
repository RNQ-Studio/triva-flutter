import 'package:go_router/go_router.dart';

import 'maintenance_estimate_paths.dart';
import 'maintenance_estimate_screen.dart';

final maintenanceEstimateRoutes = <RouteBase>[
  GoRoute(
    path: maintenanceEstimatePath,
    builder: (_, __) => const MaintenanceEstimateScreen(),
  ),
];
