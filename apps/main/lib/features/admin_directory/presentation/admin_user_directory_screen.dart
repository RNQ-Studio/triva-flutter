import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/admin_directory_models.dart';
import 'admin_directory_controller.dart';
import 'admin_directory_paths.dart';
import 'admin_directory_widgets.dart';

/// Daftar seluruh pengguna terdaftar beserta data lengkapnya.
class AdminUserDirectoryScreen extends ConsumerWidget {
  const AdminUserDirectoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(adminUserDirectoryProvider);

    return AdminListScaffold<AdminUserRecord>(
      title: l10n.adminUserDirectoryTitle,
      searchHint: l10n.adminUserDirectorySearchHint,
      state: state,
      controller: ref.read(adminUserDirectoryProvider.notifier),
      statusOptions: [
        (value: 'male', label: l10n.genderMale),
        (value: 'female', label: l10n.genderFemale),
        (value: 'undisclosed', label: l10n.genderUndisclosed),
        (value: 'unknown', label: l10n.adminValueNotSet),
      ],
      allStatusLabel: l10n.adminFilterAll,
      emptyTitle: l10n.adminUserDirectoryEmptyTitle,
      emptyDescription: l10n.adminUserDirectoryEmptyDescription,
      itemBuilder: (context, user) => _AdminUserTile(user: user),
    );
  }
}

class _AdminUserTile extends StatelessWidget {
  const _AdminUserTile({required this.user});

  final AdminUserRecord user;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final subtitle = <String>[
      if (user.phone != null && user.phone!.isNotEmpty) user.phone!,
      if (user.city != null && user.city!.isNotEmpty) user.city!,
      if (user.genderLabel != null) user.genderLabel!,
      if (user.age != null) l10n.adminAgeYears(user.age!),
    ].join(' · ');

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: () => context.push(adminUserDetailPath(user.id)),
        leading: CircleAvatar(
          backgroundColor: colors.primaryContainer,
          child: Text(
            user.name.isEmpty ? '?' : user.name.characters.first.toUpperCase(),
            style: TextStyle(color: colors.onPrimaryContainer),
          ),
        ),
        title: Text(user.name.isEmpty ? user.email : user.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            if (subtitle.isNotEmpty)
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
              ),
          ],
        ),
        isThreeLine: subtitle.isNotEmpty,
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

/// Data lengkap satu pengguna: kontak, demografi, aktivitas, dan perangkat.
class AdminUserDetailScreen extends ConsumerWidget {
  const AdminUserDetailScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final detail = ref.watch(adminUserDetailProvider(userId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminUserDetailTitle)),
      body: SafeArea(
        child: detail.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => AdminDirectoryMessage(
            icon: isAdminDirectoryOffline(error)
                ? Icons.wifi_off_rounded
                : Icons.error_outline_rounded,
            title: isAdminDirectoryOffline(error)
                ? l10n.bookingOfflineError
                : l10n.loadFailed,
            description: isAdminDirectoryOffline(error)
                ? l10n.submissionNetworkError
                : l10n.errorGeneral,
            action: OutlinedButton.icon(
              onPressed: () => ref.invalidate(adminUserDetailProvider(userId)),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.retry),
            ),
          ),
          data: (user) => ListView(
            padding: const EdgeInsets.all(AppSpacing.large),
            children: [
              AdminDetailCard(
                title: l10n.adminSectionAccount,
                children: [
                  AdminDetailRow(label: l10n.name, value: _or(user.name)),
                  AdminDetailRow(label: l10n.email, value: _or(user.email)),
                  AdminDetailRow(
                    label: l10n.phoneNumber,
                    value: _or(user.phone),
                  ),
                  AdminDetailRow(
                    label: l10n.cityOrRegency,
                    value: _or(user.city),
                  ),
                  AdminDetailRow(
                    label: l10n.adminFieldAccountStatus,
                    value: user.isActive
                        ? l10n.adminUserActive
                        : l10n.adminUserInactive,
                  ),
                  AdminDetailRow(
                    label: l10n.adminFieldRoles,
                    value: user.roles.isEmpty
                        ? l10n.adminRoleCustomer
                        : user.roles.join(', '),
                  ),
                  AdminDetailRow(
                    label: l10n.adminFieldRegisteredAt,
                    value: formatAdminDate(context, user.createdAt),
                  ),
                  AdminDetailRow(
                    label: l10n.adminFieldLastActive,
                    value: formatAdminDate(context, user.lastActiveAt),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.medium),
              AdminDetailCard(
                title: l10n.adminSectionDemographics,
                children: [
                  AdminDetailRow(
                    label: l10n.gender,
                    value: user.genderLabel ?? l10n.adminValueNotSet,
                  ),
                  AdminDetailRow(
                    label: l10n.birthDate,
                    value: user.birthDate == null
                        ? l10n.adminValueNotSet
                        : formatAdminDateOnly(context, user.birthDate),
                  ),
                  AdminDetailRow(
                    label: l10n.adminFieldAge,
                    value: user.age == null
                        ? l10n.adminValueNotSet
                        : l10n.adminAgeYears(user.age!),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.medium),
              AdminDetailCard(
                title: l10n.adminSectionConsent,
                children: [
                  AdminDetailRow(
                    label: l10n.adminFieldServiceConsent,
                    value: formatAdminDate(context, user.serviceConsentAt),
                  ),
                  AdminDetailRow(
                    label: l10n.adminFieldMarketingConsent,
                    value: user.marketingConsent
                        ? l10n.adminValueYes
                        : l10n.adminValueNo,
                  ),
                  AdminDetailRow(
                    label: l10n.adminFieldEmailVerified,
                    value: formatAdminDate(context, user.emailVerifiedAt),
                  ),
                  AdminDetailRow(
                    label: l10n.adminFieldPhoneVerified,
                    value: formatAdminDate(context, user.phoneVerifiedAt),
                  ),
                ],
              ),
              if (user.activity != null) ...[
                const SizedBox(height: AppSpacing.medium),
                AdminDetailCard(
                  title: l10n.adminSectionActivity,
                  children: [
                    AdminDetailRow(
                      label: l10n.serviceAppraisalTitle,
                      value: '${user.activity!.appraisals}',
                    ),
                    AdminDetailRow(
                      label: l10n.serviceToyotaTitle,
                      value: '${user.activity!.toyotaServiceBookings}',
                    ),
                    AdminDetailRow(
                      label: l10n.serviceOtoxpertTitle,
                      value: '${user.activity!.otoxpertBookings}',
                    ),
                    AdminDetailRow(
                      label: l10n.serviceCreditTitle,
                      value: '${user.activity!.creditSimulations}',
                    ),
                    AdminDetailRow(
                      label: l10n.serviceBodyPaintTitle,
                      value: '${user.activity!.bodyPaintEstimates}',
                    ),
                    AdminDetailRow(
                      label: l10n.myVehicle,
                      value: '${user.activity!.vehicles}',
                    ),
                  ],
                ),
              ],
              if (user.devices.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.medium),
                AdminDetailCard(
                  title: l10n.adminSectionDevices,
                  children: [
                    for (final device in user.devices)
                      AdminDetailRow(
                        label: device.deviceName ?? device.platform,
                        value: [
                          device.platform,
                          if (device.osVersion != null) device.osVersion!,
                          if (device.appVersion != null)
                            'v${device.appVersion}'
                                '${device.appBuild == null ? '' : '+${device.appBuild}'}',
                          formatAdminDate(context, device.lastActiveAt),
                        ].join(' · '),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

String _or(String? value) => value == null || value.isEmpty ? '—' : value;
