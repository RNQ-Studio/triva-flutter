part of 'toyota_service_booking_screens.dart';

class AdminPanelScreen extends ConsumerWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authProvider);
    final allowed = auth is AuthAuthenticated && auth.user.canAccessAdminPanel;
    if (!allowed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/');
      });
      return Scaffold(
        appBar: AppBar(title: Text(l10n.adminPanel)),
        body: BookingEmptyState(
          title: l10n.adminAccessDenied,
          description: l10n.adminAccessDeniedDescription,
        ),
      );
    }
    final entries = <_AdminPanelEntry>[
      if (auth.user.canManageUsers)
        (
          icon: Icons.manage_accounts_outlined,
          title: l10n.adminUserAccessTitle,
          subtitle: l10n.adminUserAccessDescription,
          path: adminUsersPath,
        ),
      if (auth.user.canViewAnyUsers)
        (
          icon: Icons.groups_outlined,
          title: l10n.adminUserDirectoryTitle,
          subtitle: l10n.adminPanelUserDirectoryDescription,
          path: adminUserDirectoryPath,
        ),
      if (auth.user.canViewAnyAppraisals)
        (
          icon: Icons.price_check_rounded,
          title: l10n.adminAppraisalQueueTitle,
          subtitle: l10n.adminPanelAppraisalDescription,
          path: adminAppraisalQueuePath,
        ),
      if (auth.user.canViewAnyServiceBookings) ...[
        (
          icon: Icons.car_repair_rounded,
          title: l10n.serviceToyotaTitle,
          subtitle: l10n.adminBookingQueueDescription,
          path: adminToyotaServiceQueuePath,
        ),
        (
          icon: Icons.handyman_rounded,
          title: l10n.serviceOtoxpertTitle,
          subtitle: l10n.adminBookingQueueDescription,
          path: adminOtoxpertQueuePath,
        ),
      ],
      if (auth.user.canViewAnyCreditSimulations)
        (
          icon: Icons.calculate_rounded,
          title: l10n.adminCreditQueueTitle,
          subtitle: l10n.adminPanelCreditDescription,
          path: adminCreditSimulationQueuePath,
        ),
      if (auth.user.canViewAnyBodyPaintEstimates)
        (
          icon: Icons.format_paint_rounded,
          title: l10n.serviceBodyPaintTitle,
          subtitle: l10n.adminBookingQueueDescription,
          path: adminBodyPaintQueuePath,
        ),
    ];
    final content = ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.large,
        AppSpacing.small,
        AppSpacing.large,
        AppSpacing.xLarge,
      ),
      children: [
        if (auth.user.canViewVisitAnalytics) ...[
          const AdminVisitDashboardSection(),
          const SizedBox(height: AppSpacing.xLarge),
          const AdminDemographicsSection(),
          const SizedBox(height: AppSpacing.xLarge),
          const AdminMenuUsageSection(),
          const SizedBox(height: AppSpacing.xLarge),
        ],
        Text(
          l10n.adminPanelSubtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: AppSpacing.medium),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              for (var index = 0; index < entries.length; index++) ...[
                _AdminPanelEntryTile(entry: entries[index]),
                if (index < entries.length - 1)
                  Divider(
                    height: 1,
                    indent: AppSpacing.large,
                    endIndent: AppSpacing.large,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminPanelTitle)),
      body: SafeArea(
        child: auth.user.canViewVisitAnalytics
            ? RefreshIndicator(
                onRefresh: () async {
                  final _ = await ref.refresh(
                    adminVisitStatisticsProvider.future,
                  );
                },
                child: content,
              )
            : content,
      ),
    );
  }
}

typedef _AdminPanelEntry = ({
  IconData icon,
  String title,
  String subtitle,
  String path,
});

class _AdminPanelEntryTile extends StatelessWidget {
  const _AdminPanelEntryTile({required this.entry});

  final _AdminPanelEntry entry;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.accent.withValues(alpha: .12),
        child: Icon(entry.icon, color: AppColors.accent),
      ),
      title: Text(entry.title),
      subtitle: Text(entry.subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => context.push(entry.path),
    );
  }
}

class AdminToyotaServiceQueueScreen extends ConsumerWidget {
  const AdminToyotaServiceQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    if (auth is! AuthAuthenticated || !auth.user.canViewAnyServiceBookings) {
      return const AdminPanelScreen();
    }
    final l10n = AppLocalizations.of(context)!;
    final query = ref.watch(adminToyotaServiceQueryProvider);
    final provider = adminToyotaServiceFilteredBookingsProvider(query);
    final items = ref.watch(provider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminBookingQueue)),
      body: Column(
        children: [
          _AdminQueueFilters(query: query),
          Expanded(
            child: items.when(
              data: (values) => RefreshIndicator(
                onRefresh: () async => ref.refresh(provider.future),
                child: values.isEmpty
                    ? ListView(
                        children: [
                          BookingEmptyState(
                            title: l10n.adminNoBookings,
                            description: l10n.adminNoBookingsDescription,
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.large),
                        itemCount: values.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.small),
                        itemBuilder: (_, index) {
                          final item = values[index];
                          return Card(
                            margin: EdgeInsets.zero,
                            child: ListTile(
                              leading: Icon(
                                item.slaOverdue
                                    ? Icons.warning_amber_rounded
                                    : Icons.car_repair_outlined,
                                color: item.slaOverdue
                                    ? Theme.of(context).colorScheme.error
                                    : AppColors.accent,
                              ),
                              title: Text(
                                item.vehicle == null
                                    ? item.referenceNo
                                    : '${item.vehicle!.make} ${item.vehicle!.model}',
                              ),
                              subtitle: Text(
                                  '${item.referenceNo} • ${item.statusLabel}'),
                              trailing: const Icon(Icons.chevron_right_rounded),
                              onTap: () => context
                                  .push(adminToyotaServiceBookingPath(item.id)),
                            ),
                          );
                        },
                      ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => BookingErrorState(
                offline: isNetworkFailure(error),
                onRetry: () => ref.invalidate(provider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminQueueFilters extends ConsumerWidget {
  const _AdminQueueFilters({required this.query});

  final AdminToyotaServiceQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(adminToyotaServiceQueryProvider.notifier);
    final options = ref.watch(adminToyotaServiceOptionsProvider).value;
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.large,
        AppSpacing.small,
        AppSpacing.large,
        0,
      ),
      child: Column(
        children: [
          SearchBar(
            hintText: l10n.adminBookingQueueDescription,
            leading: const Icon(Icons.search_rounded),
            onSubmitted: (value) => notifier.update(
              query.copyWith(
                search: value.trim(),
                clearSearch: value.trim().isEmpty,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                DropdownButton<String>(
                  value: query.sort,
                  items: [
                    DropdownMenuItem(
                      value: 'updated_desc',
                      child: Text(l10n.sortUpdatedDesc),
                    ),
                    DropdownMenuItem(
                      value: 'due_asc',
                      child: Text(l10n.sortDueAsc),
                    ),
                    DropdownMenuItem(
                      value: 'slot_asc',
                      child: Text(l10n.sortSlotAsc),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      notifier.update(query.copyWith(sort: value));
                    }
                  },
                ),
                const SizedBox(width: AppSpacing.medium),
                DropdownButton<String?>(
                  value: query.status,
                  hint: Text(l10n.status),
                  items: [
                    DropdownMenuItem(value: null, child: Text(l10n.status)),
                    for (final item in options?.statuses ?? const [])
                      DropdownMenuItem(
                        value: item.value,
                        child: Text(item.label),
                      ),
                  ],
                  onChanged: (value) => notifier.update(
                    query.copyWith(
                      status: value,
                      clearStatus: value == null,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.medium),
                DropdownButton<String?>(
                  value: query.fulfillmentType,
                  hint: Text(l10n.fulfillment),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(l10n.fulfillment),
                    ),
                    for (final item in options?.fulfillmentTypes ?? const [])
                      DropdownMenuItem(
                        value: item.value,
                        child: Text(item.label),
                      ),
                  ],
                  onChanged: (value) => notifier.update(
                    query.copyWith(
                      fulfillmentType: value,
                      clearFulfillment: value == null,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.medium),
                DropdownButton<String?>(
                  value: query.serviceLocationId,
                  hint: Text(l10n.location),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(l10n.location),
                    ),
                    for (final item in options?.locations ?? const [])
                      DropdownMenuItem(
                        value: item.id,
                        child: Text(item.name),
                      ),
                  ],
                  onChanged: (value) => notifier.update(
                    query.copyWith(
                      serviceLocationId: value,
                      clearServiceLocation: value == null,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.medium),
                DropdownButton<String?>(
                  value: query.serviceTypeId,
                  hint: Text(l10n.service),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(l10n.service),
                    ),
                    for (final item in options?.serviceTypes ?? const [])
                      DropdownMenuItem(
                        value: item.id,
                        child: Text(item.name),
                      ),
                  ],
                  onChanged: (value) => notifier.update(
                    query.copyWith(
                      serviceTypeId: value,
                      clearServiceType: value == null,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.medium),
                DropdownButton<String?>(
                  value: query.advisorId,
                  hint: Text(l10n.serviceAdvisor),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(l10n.serviceAdvisor),
                    ),
                    for (final item in options?.advisors ?? const [])
                      DropdownMenuItem(
                        value: item.id,
                        child: Text(item.name),
                      ),
                  ],
                  onChanged: (value) => notifier.update(
                    query.copyWith(
                      advisorId: value,
                      clearAdvisor: value == null,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.medium),
                ActionChip(
                  avatar: const Icon(Icons.calendar_month_outlined),
                  label: Text(query.date ?? l10n.scheduleInspection),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 365),
                      ),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      initialDate:
                          DateTime.tryParse(query.date ?? '') ?? DateTime.now(),
                    );
                    if (date == null) return;
                    notifier.update(
                      query.copyWith(
                        date: '${date.year.toString().padLeft(4, '0')}-'
                            '${date.month.toString().padLeft(2, '0')}-'
                            '${date.day.toString().padLeft(2, '0')}',
                      ),
                    );
                  },
                ),
                if (query.date != null)
                  IconButton(
                    onPressed: () =>
                        notifier.update(query.copyWith(clearDate: true)),
                    icon: const Icon(Icons.close_rounded),
                  ),
                const SizedBox(width: AppSpacing.medium),
                FilterChip(
                  selected: query.slaOverdue == true,
                  label: Text(l10n.slaOverdueLabel),
                  onSelected: (selected) => notifier.update(
                    query.copyWith(
                      slaOverdue: selected ? true : null,
                      clearSla: !selected,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
