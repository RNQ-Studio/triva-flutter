import 'package:go_router/go_router.dart';

import 'admin_content_paths.dart';
import 'admin_info_popup_screens.dart';
import 'admin_partner_logo_screens.dart';
import 'admin_service_package_screens.dart';

// Rute `new` didaftarkan sebelum `:id` supaya tidak terbaca sebagai id.
final adminContentRoutes = <RouteBase>[
  GoRoute(
    path: adminInfoPopupsPath,
    builder: (_, __) => const AdminInfoPopupListScreen(),
    routes: [
      GoRoute(
        path: 'new',
        builder: (_, __) => const AdminInfoPopupFormScreen(),
      ),
      GoRoute(
        path: ':id',
        builder: (_, state) =>
            AdminInfoPopupFormScreen(id: state.pathParameters['id']),
      ),
    ],
  ),
  GoRoute(
    path: adminPartnerLogosPath,
    builder: (_, __) => const AdminPartnerLogoListScreen(),
    routes: [
      GoRoute(
        path: 'new',
        builder: (_, __) => const AdminPartnerLogoFormScreen(),
      ),
      GoRoute(
        path: ':id',
        builder: (_, state) =>
            AdminPartnerLogoFormScreen(id: state.pathParameters['id']),
      ),
    ],
  ),
  GoRoute(
    path: adminServicePackagesPath,
    builder: (_, __) => const AdminServicePackageListScreen(),
    routes: [
      GoRoute(
        path: 'new',
        builder: (_, __) => const AdminServicePackageFormScreen(),
      ),
      GoRoute(
        path: ':id',
        builder: (_, state) =>
            AdminServicePackageFormScreen(id: state.pathParameters['id']),
      ),
    ],
  ),
];
