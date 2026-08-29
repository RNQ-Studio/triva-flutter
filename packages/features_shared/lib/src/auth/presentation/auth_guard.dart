import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'auth_paths.dart';
import 'auth_provider.dart';
import 'auth_state.dart';

const _authEntryPaths = <String>{
  '/splash',
  authLoginPath,
  completeProfilePath,
};

/// Returns an internal post-auth destination, or null when [candidate] is
/// unsafe or would send the router back into the authentication flow.
///
/// Keeping this validation in one place prevents values from the `from` query
/// parameter from becoming an open redirect when login or profile setup
/// completes.
String? safeAuthReturnLocation(String? candidate) {
  if (candidate == null ||
      candidate.isEmpty ||
      candidate != candidate.trim() ||
      candidate.contains('\\') ||
      RegExp(r'[\u0000-\u001F\u007F]').hasMatch(candidate)) {
    return null;
  }

  final uri = Uri.tryParse(candidate);
  if (uri == null ||
      uri.hasScheme ||
      uri.hasAuthority ||
      !candidate.startsWith('/') ||
      candidate.startsWith('//') ||
      !uri.path.startsWith('/') ||
      _authEntryPaths.contains(uri.path)) {
    return null;
  }

  return uri.toString();
}

String _authLocationWithReturnTo(String path, String? candidate) {
  final destination = safeAuthReturnLocation(candidate);
  if (destination == null || destination == '/') return path;

  return Uri(
    path: path,
    queryParameters: {'from': destination},
  ).toString();
}

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
    final destination = isOnProfileSetup
        ? state.uri.queryParameters['from']
        : state.uri.toString();
    return _authLocationWithReturnTo(authLoginPath, destination);
  }

  final user = authState.user;
  // Gender dan tanggal lahir wajib sejak rilis ini, jadi profil dianggap
  // belum lengkap selama salah satunya kosong.
  final profileReady = user.hasCompleteProfile;
  if (!profileReady && !isOnProfileSetup) {
    final destination = isOnLoginPage
        ? state.uri.queryParameters['from']
        : state.uri.toString();
    return _authLocationWithReturnTo(completeProfilePath, destination);
  }
  if (profileReady && (isOnLoginPage || isOnProfileSetup)) {
    return safeAuthReturnLocation(state.uri.queryParameters['from']) ?? '/';
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
