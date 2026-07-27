import 'package:go_router/go_router.dart';

import 'screens/toyota_service_add_vehicle_screen.dart';
import 'screens/toyota_service_booking_screens.dart';
import 'screens/toyota_service_intake_screens.dart';
import 'toyota_service_paths.dart';

export 'screens/toyota_service_booking_screens.dart' show AdminPanelScreen;

final toyotaServiceRoutes = <RouteBase>[
  GoRoute(
    path: adminPanelPath,
    builder: (_, __) => const AdminPanelScreen(),
  ),
  GoRoute(
    path: toyotaServiceVehiclePath,
    builder: (_, __) => const ToyotaServiceVehicleScreen(),
  ),
  GoRoute(
    path: toyotaServiceNonToyotaPath,
    builder: (_, __) => const ToyotaServiceNonToyotaScreen(),
  ),
  GoRoute(
    path: toyotaServiceAddVehiclePath,
    builder: (_, __) => const ToyotaServiceAddVehicleScreen(),
  ),
  GoRoute(
    path: toyotaServiceFulfillmentPath,
    builder: (_, __) => const ToyotaServiceFulfillmentScreen(),
  ),
  GoRoute(
    path: toyotaServiceTypePath,
    builder: (_, __) => const ToyotaServiceTypeScreen(),
  ),
  GoRoute(
    path: toyotaServiceDetailsPath,
    builder: (_, __) => const ToyotaServiceDetailsScreen(),
  ),
  GoRoute(
    path: toyotaServiceSchedulePath,
    builder: (_, __) => const ToyotaServiceScheduleScreen(),
  ),
  GoRoute(
    path: toyotaServiceAddressPath,
    builder: (_, __) => const ToyotaServiceAddressScreen(),
  ),
  GoRoute(
    path: toyotaServiceReviewPath,
    builder: (_, __) => const ToyotaServiceReviewScreen(),
  ),
  GoRoute(
    path: '/toyota-service/submitted/:id',
    builder: (_, state) =>
        ToyotaServiceSubmittedScreen(bookingId: state.pathParameters['id']!),
  ),
  GoRoute(
    path: '/toyota-service/bookings/:id',
    builder: (_, state) => ToyotaServiceBookingDetailScreen(
        bookingId: state.pathParameters['id']!),
  ),
  GoRoute(
    path: adminToyotaServiceQueuePath,
    builder: (_, __) => const AdminToyotaServiceQueueScreen(),
  ),
  GoRoute(
    path: '/admin/toyota-service/bookings/:id',
    builder: (_, state) => AdminToyotaServiceBookingScreen(
      bookingId: state.pathParameters['id']!,
    ),
  ),
];
