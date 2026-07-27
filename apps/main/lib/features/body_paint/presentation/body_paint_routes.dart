import 'package:go_router/go_router.dart';

import 'body_paint_paths.dart';
import 'screens/body_paint_admin_screens.dart';
import 'screens/body_paint_customer_screens.dart';
import 'screens/body_paint_intake_screen.dart';

final bodyPaintRoutes = <RouteBase>[
  GoRoute(
    path: bodyPaintPath,
    builder: (_, __) => const BodyPaintIntakeScreen(),
  ),
  GoRoute(
    path: '/body-paint/estimates/:id',
    builder: (_, state) => BodyPaintEstimateScreen(
      estimateId: state.pathParameters['id']!,
    ),
  ),
  GoRoute(
    path: '/body-paint/estimates/:id/booking',
    builder: (_, state) => BodyPaintBookingScreen(
      estimateId: state.pathParameters['id']!,
    ),
  ),
  GoRoute(
    path: adminBodyPaintQueuePath,
    builder: (_, __) => const AdminBodyPaintQueueScreen(),
  ),
  GoRoute(
    path: '/admin/body-paint/estimates/:id',
    builder: (_, state) => AdminBodyPaintEstimateScreen(
      estimateId: state.pathParameters['id']!,
    ),
  ),
  GoRoute(
    path: '/admin/body-paint/estimates/:id/publish',
    builder: (_, state) => AdminBodyPaintPublishScreen(
      estimateId: state.pathParameters['id']!,
    ),
  ),
];
