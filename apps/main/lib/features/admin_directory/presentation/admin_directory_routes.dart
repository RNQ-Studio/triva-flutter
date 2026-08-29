import 'package:go_router/go_router.dart';

import 'admin_appraisal_screens.dart';
import 'admin_credit_simulation_screens.dart';
import 'admin_directory_paths.dart';
import 'admin_user_directory_screen.dart';

final adminDirectoryRoutes = <RouteBase>[
  GoRoute(
    path: adminUserDirectoryPath,
    builder: (_, __) => const AdminUserDirectoryScreen(),
  ),
  GoRoute(
    path: '$adminUserDirectoryPath/:id',
    builder: (_, state) =>
        AdminUserDetailScreen(userId: state.pathParameters['id']!),
  ),
  GoRoute(
    path: adminAppraisalQueuePath,
    builder: (_, __) => const AdminAppraisalQueueScreen(),
  ),
  GoRoute(
    path: '$adminAppraisalQueuePath/:id',
    builder: (_, state) =>
        AdminAppraisalDetailScreen(appraisalId: state.pathParameters['id']!),
  ),
  GoRoute(
    path: adminCreditSimulationQueuePath,
    builder: (_, __) => const AdminCreditSimulationQueueScreen(),
  ),
  GoRoute(
    path: '$adminCreditSimulationQueuePath/:id',
    builder: (_, state) => AdminCreditSimulationDetailScreen(
      simulationId: state.pathParameters['id']!,
    ),
  ),
];
