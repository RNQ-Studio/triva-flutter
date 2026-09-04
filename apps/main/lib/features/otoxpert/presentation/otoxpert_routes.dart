import 'package:go_router/go_router.dart';

import 'otoxpert_paths.dart';
import 'screens/otoxpert_admin_screens.dart';
import 'screens/otoxpert_booking_screen.dart';
import 'screens/otoxpert_intake_screen.dart';
import 'screens/otoxpert_menu_screen.dart';

final otoxpertRoutes = <RouteBase>[
  GoRoute(
    path: otoxpertPath,
    builder: (_, __) => const OtoxpertMenuScreen(),
  ),
  GoRoute(
    path: otoxpertBookingIntakePath,
    builder: (_, __) => const OtoxpertIntakeScreen(),
  ),
  GoRoute(
    path: '/otoxpert/bookings/:id',
    builder: (_, state) => OtoxpertBookingScreen(
      bookingId: state.pathParameters['id']!,
    ),
  ),
  GoRoute(
    path: adminOtoxpertQueuePath,
    builder: (_, __) => const AdminOtoxpertQueueScreen(),
  ),
  GoRoute(
    path: '/admin/otoxpert/bookings/:id',
    builder: (_, state) => AdminOtoxpertBookingScreen(
      bookingId: state.pathParameters['id']!,
    ),
  ),
];
