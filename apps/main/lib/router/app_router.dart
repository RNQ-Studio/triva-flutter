import 'package:go_router/go_router.dart';
import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';

import '../features/home/presentation/home_screen.dart';
import '../features/settings/presentation/settings_route.dart';
import '../features/profile/presentation/profile_route.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: authRedirect,
  observers: [AppNavigatorObserver()],
  routes: [
    ...authRoutes,
    settingsRoute,
    profileRoute,
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);
