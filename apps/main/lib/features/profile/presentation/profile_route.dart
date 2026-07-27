import 'package:go_router/go_router.dart';
import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../toyota_service/presentation/toyota_service_paths.dart';

final profileRoute = GoRoute(
  path: AppRoutes.profile,
  builder: (context, state) => const ProfileRouteScreen(),
  routes: [
    GoRoute(
      path: 'edit',
      builder: (context, state) => const EditProfileScreen(),
    ),
  ],
);

class ProfileRouteScreen extends ConsumerWidget {
  const ProfileRouteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final isAdmin = auth is AuthAuthenticated && auth.user.isAdmin;

    return ProfileScreen(
      onOpenAdminPanel: isAdmin ? () => context.push(adminPanelPath) : null,
    );
  }
}
