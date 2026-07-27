import 'package:go_router/go_router.dart';

import 'credit_paths.dart';
import 'screens/credit_simulation_detail_screen.dart';
import 'screens/credit_simulation_screen.dart';

final creditRoutes = <RouteBase>[
  GoRoute(
    path: creditPath,
    builder: (_, state) => CreditSimulationScreen(
      sourceAppraisalId: state.uri.queryParameters['appraisal_id'],
      sourceProgramId: state.uri.queryParameters['program_id'],
      campaignSource: state.uri.queryParameters['campaign_source'],
    ),
  ),
  GoRoute(
    path: '/credit/simulations/:id',
    builder: (_, state) => CreditSimulationDetailScreen(
      simulationId: state.pathParameters['id']!,
    ),
  ),
];
