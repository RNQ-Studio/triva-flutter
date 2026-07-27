import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/admin_user_models.dart';
import 'admin_user_controller.dart';

class AdminUserScreen extends ConsumerStatefulWidget {
  const AdminUserScreen({super.key});

  @override
  ConsumerState<AdminUserScreen> createState() => _AdminUserScreenState();
}

class _AdminUserScreenState extends ConsumerState<AdminUserScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authProvider);
    final allowed = auth is AuthAuthenticated && auth.user.canManageUsers;
    if (!allowed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/');
      });
      return Scaffold(
        appBar: AppBar(title: Text(l10n.adminUserAccessTitle)),
        body: _AdminUserMessage(
          icon: Icons.lock_outline_rounded,
          title: l10n.adminAccessDenied,
          description: l10n.adminAccessDeniedDescription,
        ),
      );
    }

    final users = ref.watch(adminUserAccessProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminUserAccessTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.large,
                AppSpacing.small,
                AppSpacing.large,
                AppSpacing.medium,
              ),
              child: SearchBar(
                controller: _searchController,
                hintText: l10n.adminUserSearchHint,
                leading: const Icon(Icons.search_rounded),
                trailing: [
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                        ref.read(adminUserAccessProvider.notifier).search('');
                      },
                      icon: const Icon(Icons.close_rounded),
                      tooltip: l10n.clear,
                    ),
                ],
                textInputAction: TextInputAction.search,
                onChanged: (_) => setState(() {}),
                onSubmitted: (value) =>
                    ref.read(adminUserAccessProvider.notifier).search(value),
              ),
            ),
            Expanded(
              child: users.when(
                loading: _AdminUserLoading.new,
                error: (error, _) => _AdminUserMessage(
                  icon: _isOffline(error)
                      ? Icons.wifi_off_rounded
                      : Icons.error_outline_rounded,
                  title: _isOffline(error)
                      ? l10n.bookingOfflineError
                      : l10n.loadFailed,
                  description: _isOffline(error)
                      ? l10n.submissionNetworkError
                      : l10n.errorGeneral,
                  action: OutlinedButton.icon(
                    onPressed: () => ref.invalidate(adminUserAccessProvider),
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(l10n.retry),
                  ),
                ),
                data: (state) => state.users.isEmpty
                    ? _AdminUserMessage(
                        icon: Icons.person_search_outlined,
                        title: l10n.adminUserEmptyTitle,
                        description: l10n.adminUserEmptyDescription,
                      )
                    : RefreshIndicator(
                        onRefresh: () async =>
                            ref.invalidate(adminUserAccessProvider),
                        child: ListView.separated(
                          key: const ValueKey('admin-user-list'),
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.large,
                            0,
                            AppSpacing.large,
                            AppSpacing.xLarge,
                          ),
                          itemCount:
                              state.users.length + (state.canLoadMore ? 1 : 0),
                          separatorBuilder: (_, __) => Divider(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                          itemBuilder: (context, index) {
                            if (index == state.users.length) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.medium,
                                ),
                                child: Center(
                                  child: OutlinedButton(
                                    onPressed: state.isLoadingMore
                                        ? null
                                        : ref
                                            .read(
                                              adminUserAccessProvider.notifier,
                                            )
                                            .loadMore,
                                    child: state.isLoadingMore
                                        ? const SizedBox.square(
                                            dimension: AppIconSize.medium,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(l10n.loadMore),
                                  ),
                                ),
                              );
                            }
                            final user = state.users[index];
                            return _AdminUserRow(
                              user: user,
                              busy: state.promotingUserId == user.id,
                              onGrant: () => _confirmGrant(user),
                            );
                          },
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmGrant(AdminUser user) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(l10n.adminUserGrantConfirmTitle(user.name)),
        content: Text(l10n.adminUserGrantConfirmDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.adminUserGrantAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final success =
        await ref.read(adminUserAccessProvider.notifier).grantAdmin(user.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            success
                ? l10n.adminUserGrantSuccess(user.name)
                : l10n.adminUserGrantFailed,
          ),
        ),
      );
  }
}

class _AdminUserRow extends StatelessWidget {
  const _AdminUserRow({
    required this.user,
    required this.busy,
    required this.onGrant,
  });

  final AdminUser user;
  final bool busy;
  final VoidCallback onGrant;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final enabled = user.isActive && !user.isAdmin && !busy;
    final status = user.isAdmin
        ? l10n.adminUserAlreadyAdmin
        : user.isActive
            ? l10n.adminUserGrantAction
            : l10n.adminUserInactive;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      enabled: enabled,
      onTap: enabled ? onGrant : null,
      leading: CircleAvatar(
        child: Text(
          user.name.trim().isEmpty ? '?' : user.name.trim()[0].toUpperCase(),
        ),
      ),
      title: Text(user.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(user.email),
          Text(
            status,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
      isThreeLine: true,
      trailing: busy
          ? const SizedBox.square(
              dimension: AppIconSize.medium,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              user.isAdmin
                  ? Icons.verified_user_rounded
                  : user.isActive
                      ? Icons.person_add_alt_1_rounded
                      : Icons.person_off_outlined,
            ),
    );
  }
}

class _AdminUserLoading extends StatelessWidget {
  const _AdminUserLoading();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.large),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.medium),
      itemBuilder: (_, __) => DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: AppRadius.medium,
        ),
        child: const SizedBox(height: AppListExtent.twoLine),
      ),
    );
  }
}

class _AdminUserMessage extends StatelessWidget {
  const _AdminUserMessage({
    required this.icon,
    required this.title,
    required this.description,
    this.action,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: AppIconSize.large, color: colors.primary),
            const SizedBox(height: AppSpacing.large),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
            ),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.large),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

bool _isOffline(Object error) {
  if (error is NetworkException) return true;
  if (error is! DioException) return false;
  return error.type == DioExceptionType.connectionError ||
      error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.sendTimeout;
}
