import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomerShell extends ConsumerWidget {
  const CustomerShell({
    required this.navigationShell,
    this.canAccessAdmin,
    this.unreadNotificationCount,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final bool? canAccessAdmin;
  final int? unreadNotificationCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final auth = canAccessAdmin == null ? ref.watch(authProvider) : null;
    final canAdmin = canAccessAdmin ??
        (auth is AuthAuthenticated && auth.user.canAccessAdminPanel);
    final unread = unreadNotificationCount ??
        ref.watch(visibleUnreadNotificationCountProvider).value ??
        0;
    final destinations = <NavigationDestination>[
      NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home_rounded),
        label: l10n.home,
      ),
      NavigationDestination(
        icon: const Icon(Icons.receipt_long_outlined),
        selectedIcon: const Icon(Icons.receipt_long_rounded),
        label: l10n.activity,
      ),
      NavigationDestination(
        icon: Badge(
          isLabelVisible: unread > 0,
          label: Text(unread > 9 ? '9+' : '$unread'),
          child: const Icon(Icons.notifications_outlined),
        ),
        selectedIcon: Badge(
          isLabelVisible: unread > 0,
          label: Text(unread > 9 ? '9+' : '$unread'),
          child: const Icon(Icons.notifications_rounded),
        ),
        label: l10n.notifications,
      ),
      NavigationDestination(
        icon: const Icon(Icons.person_outline_rounded),
        selectedIcon: const Icon(Icons.person_rounded),
        label: l10n.profile,
      ),
      if (canAdmin)
        NavigationDestination(
          icon: const Icon(Icons.admin_panel_settings_outlined),
          selectedIcon: const Icon(Icons.admin_panel_settings_rounded),
          label: l10n.adminPanel,
        ),
    ];
    final branchAllowed = navigationShell.currentIndex < destinations.length;
    if (!branchAllowed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigationShell.goBranch(0, initialLocation: true);
      });
    }
    return Scaffold(
      body: branchAllowed ? navigationShell : const SizedBox.shrink(),
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        selectedIndex: branchAllowed ? navigationShell.currentIndex : 0,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: destinations,
      ),
    );
  }
}
