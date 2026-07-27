part of 'toyota_service_booking_screens.dart';

class AdminPanelScreen extends ConsumerWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authProvider);
    final allowed =
        auth is AuthAuthenticated && auth.user.canViewAnyServiceBookings;
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
    final entries =
        <({IconData icon, String title, Color color, bool enabled})>[
      (
        icon: Icons.price_check_rounded,
        title: l10n.serviceAppraisalTitle,
        color: AppColors.appraisalBlue,
        enabled: false,
      ),
      (
        icon: Icons.car_repair_rounded,
        title: l10n.serviceToyotaTitle,
        color: AppColors.serviceOrange,
        enabled: true,
      ),
      (
        icon: Icons.handyman_rounded,
        title: l10n.serviceOtoxpertTitle,
        color: AppColors.serviceViolet,
        enabled: false,
      ),
      (
        icon: Icons.calculate_rounded,
        title: l10n.serviceCreditTitle,
        color: AppColors.serviceGreen,
        enabled: false,
      ),
      (
        icon: Icons.format_paint_rounded,
        title: l10n.serviceBodyPaintTitle,
        color: AppColors.serviceRose,
        enabled: false,
      ),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminPanelTitle)),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.large),
        itemCount: entries.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.medium),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.small),
              child: Text(l10n.adminPanelSubtitle),
            );
          }
          final entry = entries[index - 1];
          return Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: entry.color.withValues(alpha: .12),
                child: Icon(entry.icon, color: entry.color),
              ),
              title: Text(entry.title),
              subtitle: Text(
                entry.enabled
                    ? l10n.adminBookingQueueDescription
                    : l10n.comingSoon,
              ),
              trailing: entry.enabled
                  ? const Icon(Icons.chevron_right_rounded)
                  : const Icon(Icons.lock_clock_outlined),
              onTap: entry.enabled
                  ? () => context.push(adminToyotaServiceQueuePath)
                  : null,
            ),
          );
        },
      ),
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
                                    : AppColors.serviceOrange,
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
