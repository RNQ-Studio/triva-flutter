import 'package:go_router/go_router.dart';

import 'vehicle_benefit_check_screen.dart';
import 'vehicle_benefit_paths.dart';

final vehicleBenefitRoutes = <RouteBase>[
  GoRoute(
    path: vehicleBenefitCheckPath,
    builder: (_, __) => const VehicleBenefitCheckScreen(),
  ),
];
