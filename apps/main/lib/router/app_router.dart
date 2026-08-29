import 'package:go_router/go_router.dart';
import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/home/presentation/home_screen.dart';
import '../features/appraisal/presentation/appraisal_routes.dart';
import '../features/appraisal/presentation/appraisal_paths.dart';
import '../features/appraisal/presentation/screens/appraisal_activity_screen.dart';
import '../features/settings/presentation/settings_route.dart';
import '../features/profile/presentation/profile_route.dart';
import '../features/toyota_service/presentation/toyota_service_routes.dart';
import '../features/toyota_service/presentation/toyota_service_paths.dart';
import '../features/otoxpert/presentation/otoxpert_routes.dart';
import '../features/otoxpert/presentation/otoxpert_paths.dart';
import '../features/credit/presentation/credit_routes.dart';
import '../features/body_paint/presentation/body_paint_routes.dart';
import '../features/body_paint/presentation/body_paint_paths.dart';
import '../features/admin_directory/presentation/admin_directory_paths.dart';
import '../features/admin_directory/presentation/admin_directory_routes.dart';
import '../features/admin_users/presentation/admin_user_paths.dart';
import '../features/admin_users/presentation/admin_user_routes.dart';
import '../features/maintenance_estimate/presentation/maintenance_estimate_routes.dart';
import '../features/vehicle_benefit/presentation/vehicle_benefit_routes.dart';
import 'customer_shell.dart';

String? trivaAppRedirect(BuildContext context, GoRouterState state) {
  final authDestination = authRedirect(context, state);
  if (authDestination != null) return authDestination;

  final location = state.matchedLocation;
  if (!location.startsWith('/admin')) return null;

  final authState = ProviderScope.containerOf(context).read(authProvider);
  if (authState is! AuthAuthenticated) return null;

  return _canAccessAdminLocation(authState.user, location) ? null : '/';
}

bool _canAccessAdminLocation(User user, String location) {
  if (location == adminPanelPath) return user.canAccessAdminPanel;
  if (location == adminUsersPath) return user.canManageUsers;
  if (location == adminUserDirectoryPath ||
      location.startsWith('$adminUserDirectoryPath/')) {
    return user.canViewAnyUsers;
  }
  if (location == adminAppraisalQueuePath ||
      location.startsWith('$adminAppraisalQueuePath/')) {
    return user.canViewAnyAppraisals;
  }
  if (location == adminCreditSimulationQueuePath ||
      location.startsWith('$adminCreditSimulationQueuePath/')) {
    return user.canViewAnyCreditSimulations;
  }
  if (location == adminBodyPaintQueuePath) {
    return user.canViewAnyBodyPaintEstimates;
  }
  if (location.startsWith('$adminBodyPaintQueuePath/')) {
    return user.canViewBodyPaintEstimate;
  }
  if (location == adminToyotaServiceQueuePath ||
      location == adminOtoxpertQueuePath) {
    return user.canViewAnyServiceBookings;
  }
  if (location.startsWith('$adminToyotaServiceQueuePath/') ||
      location.startsWith('$adminOtoxpertQueuePath/')) {
    return user.canViewServiceBooking;
  }
  return false;
}

final appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: trivaAppRedirect,
  observers: [AppNavigatorObserver()],
  routes: [
    ...authRoutes,
    ...appraisalRoutes,
    ...toyotaServiceRoutes,
    ...otoxpertRoutes,
    ...creditRoutes,
    ...bodyPaintRoutes,
    ...adminUserRoutes,
    ...adminDirectoryRoutes,
    ...vehicleBenefitRoutes,
    ...maintenanceEstimateRoutes,
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => CustomerShell(
        navigationShell: navigationShell,
      ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: appraisalActivityPath,
              builder: (context, state) => const AppraisalActivityScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/notifications',
              builder: (context, state) => const NotificationsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(routes: [profileRoute]),
      ],
    ),
    settingsRoute,
  ],
);
