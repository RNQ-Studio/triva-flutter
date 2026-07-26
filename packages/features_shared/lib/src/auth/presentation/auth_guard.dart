import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'auth_provider.dart';
import 'auth_routes.dart';
import 'auth_state.dart';

/// Compatible with GoRouter's [redirect] callback: `redirect: authRedirect`.
///
/// Returns null during [AuthInitial] and [AuthLoading] to prevent a flash
/// redirect to /login while the session check is still in progress.
String? authRedirect(BuildContext context, GoRouterState state) {
  final authState = ProviderScope.containerOf(context).read(authProvider);
  final location = state.matchedLocation;

  // While auth check is in progress, don't redirect.
  if (authState is AuthInitial || authState is AuthLoading) return null;

  // Let the splash render while it owns the initial session-check sequence.
  if (location == '/splash') return null;

  final isAuthenticated = authState is AuthAuthenticated;
  final isOnLoginPage = location == '/login';
  final isOnProfileSetup = location == completeProfilePath;

  if (!isAuthenticated) {
    if (isOnLoginPage) return null;
    final from = Uri.encodeComponent(state.uri.toString());
    return '$authLoginPath?from=$from';
  }

  final user = authState.user;
  if (!user.profileCompleted && !isOnProfileSetup) {
    return completeProfilePath;
  }
  if (user.profileCompleted && (isOnLoginPage || isOnProfileSetup)) {
    final destination = state.uri.queryParameters['from'];
    return destination == null || destination.startsWith('/login')
        ? '/'
        : destination;
  }
  return null;
}

class AuthGuard extends ConsumerWidget {
  const AuthGuard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState is AuthAuthenticated) return child;

    return const SizedBox.shrink();
  }
}
