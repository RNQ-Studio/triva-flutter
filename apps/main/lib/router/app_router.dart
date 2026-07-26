import 'package:go_router/go_router.dart';
import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';

import '../features/home/presentation/home_screen.dart';
import '../features/appraisal/presentation/appraisal_routes.dart';
import '../features/appraisal/presentation/appraisal_paths.dart';
import '../features/appraisal/presentation/screens/appraisal_activity_screen.dart';
import '../features/settings/presentation/settings_route.dart';
import '../features/profile/presentation/profile_route.dart';
import 'customer_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: authRedirect,
  observers: [AppNavigatorObserver()],
  routes: [
    ...authRoutes,
    ...appraisalRoutes,
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
