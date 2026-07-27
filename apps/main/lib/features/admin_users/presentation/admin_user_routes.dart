import 'package:go_router/go_router.dart';

import 'admin_user_paths.dart';
import 'admin_user_screen.dart';

final adminUserRoutes = <RouteBase>[
  GoRoute(
    path: adminUsersPath,
    builder: (_, __) => const AdminUserScreen(),
  ),
];
