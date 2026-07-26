import 'package:go_router/go_router.dart';

import 'complete_profile_screen.dart';
import 'login_screen.dart';
import 'splash_screen.dart';

const authLoginPath = '/login';
const completeProfilePath = '/complete-profile';

final List<GoRoute> authRoutes = [
  GoRoute(
    path: '/splash',
    builder: (context, state) => const SplashScreen(),
  ),
  GoRoute(
    path: authLoginPath,
    builder: (context, state) => const LoginScreen(),
  ),
  GoRoute(
    path: completeProfilePath,
    builder: (context, state) => const CompleteProfileScreen(),
  ),
];
