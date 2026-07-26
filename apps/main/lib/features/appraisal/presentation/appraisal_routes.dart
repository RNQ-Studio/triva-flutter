import 'package:go_router/go_router.dart';

import 'appraisal_paths.dart';
import 'screens/appraisal_complete_screen.dart';
import 'screens/appraisal_detail_screen.dart';
import 'screens/appraisal_result_screen.dart';
import 'screens/appraisal_review_screen.dart';
import 'screens/appraisal_submitted_screen.dart';
import 'screens/vehicle_condition_screen.dart';
import 'screens/vehicle_details_screen.dart';
import 'screens/vehicle_identity_screen.dart';
import 'screens/vehicle_photos_screen.dart';

final appraisalRoutes = <GoRoute>[
  GoRoute(
    path: appraisalIdentityPath,
    builder: (_, __) => const VehicleIdentityScreen(),
  ),
  GoRoute(
    path: appraisalDetailsPath,
    builder: (_, __) => const VehicleDetailsScreen(),
  ),
  GoRoute(
    path: appraisalConditionPath,
    builder: (_, __) => const VehicleConditionScreen(),
  ),
  GoRoute(
    path: appraisalPhotosPath,
    builder: (_, __) => const VehiclePhotosScreen(),
  ),
  GoRoute(
    path: appraisalReviewPath,
    builder: (_, __) => const AppraisalReviewScreen(),
  ),
  GoRoute(
    path: '/appraisals/submitted/:id',
    builder: (_, state) => AppraisalSubmittedScreen(
      appraisalId: state.pathParameters['id']!,
    ),
  ),
  GoRoute(
    path: '/appraisals/:id/result',
    builder: (_, state) => AppraisalResultScreen(
      appraisalId: state.pathParameters['id']!,
    ),
  ),
  GoRoute(
    path: '/appraisals/:id/complete',
    builder: (_, state) => AppraisalCompleteScreen(
      appraisalId: state.pathParameters['id']!,
      outcome: state.uri.queryParameters['outcome'] ?? 'accepted',
    ),
  ),
  GoRoute(
    path: '/appraisals/:id',
    builder: (_, state) => AppraisalDetailScreen(
      appraisalId: state.pathParameters['id']!,
    ),
  ),
];
