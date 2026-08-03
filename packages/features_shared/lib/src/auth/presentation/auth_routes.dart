import 'package:go_router/go_router.dart';

import 'auth_paths.dart';
import 'complete_profile_screen.dart';
import 'login_screen.dart';
import 'splash_screen.dart';

export 'auth_paths.dart';

final List<GoRoute> authRoutes = [
  GoRoute(
    path: '/splash',
    builder: (context, state) => const SplashScreen(),
  ),
  GoRoute(
    path: authLoginPath,
    builder: (context, state) => LoginScreen(
      returnTo: state.uri.queryParameters['from'],
    ),
  ),
  GoRoute(
    path: completeProfilePath,
    builder: (context, state) => CompleteProfileScreen(
      returnTo: state.uri.queryParameters['from'],
    ),
  ),
];
