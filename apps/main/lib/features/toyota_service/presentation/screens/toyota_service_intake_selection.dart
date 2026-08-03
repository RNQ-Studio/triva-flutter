part of 'toyota_service_intake_screens.dart';

class ToyotaServiceFulfillmentScreen extends ConsumerWidget {
  const ToyotaServiceFulfillmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final flow = ref.watch(toyotaServiceFlowProvider);
    final draft = flow.value?.draft ?? const ToyotaServiceDraft();
    final options = ref.watch(toyotaServiceOptionsProvider);
    final freshOptions = options.value;
    final freshLocation = freshOptions?.locations
        .where((item) => item.id == draft.serviceLocation?.id)
        .firstOrNull;
    final fulfillmentIsEffective = freshLocation != null &&
        (freshOptions?.supportsFulfillmentSelection(draft) ?? false);
    return ToyotaServiceFlowScaffold(
      step: 1,
      fallbackLocation: toyotaServiceVehiclePath,
      title: l10n.serviceWhereTitle,
      description: l10n.serviceWhereDescription,
      primaryLabel: l10n.chooseServiceType,
      onPrimary: draft.hasFulfillment && fulfillmentIsEffective
          ? () => context.push(toyotaServiceTypePath)
          : null,
      body: BookingAsyncView<ToyotaServiceOptions>(
        value: options,
        isEmpty: (value) => value.locations.isEmpty,
        emptyTitle: l10n.loadFailed,
        emptyDescription: l10n.errorGeneral,
        onRetry: () => ref.invalidate(toyotaServiceOptionsProvider),
        data: (value) {
          final workshopAvailable = value.isFulfillmentAvailable(
            ToyotaServiceFulfillment.workshop,
          );
          final thsAvailable = value.isFulfillmentAvailable(
            ToyotaServiceFulfillment.ths,
          );
          final workshopLocations = value.locations
              .where((item) => workshopAvailable && item.supportsWorkshop)
              .toList(growable: false);
          final thsLocations = value.locations
              .where(
                (item) =>
                    thsAvailable &&
                    item.supportsThs &&
                    value.thsCoverage.any(
                      (coverage) =>
                          coverage.isActive &&
                          coverage.bounds != null &&
                          coverage.serviceLocationId == item.id,
                    ),
              )
              .toList(growable: false);
          final availableLocations =
              draft.fulfillmentType == ToyotaServiceFulfillment.ths
                  ? thsLocations
                  : workshopLocations;
          final selectedLocation = availableLocations
                  .where((item) => item.id == draft.serviceLocation?.id)
                  .firstOrNull ??
              availableLocations.firstOrNull;
          final workshopLocation = workshopLocations
                  .where((item) => item.id == draft.serviceLocation?.id)
                  .firstOrNull ??
              workshopLocations.firstOrNull;
          final thsLocation = thsLocations
                  .where((item) => item.id == draft.serviceLocation?.id)
                  .firstOrNull ??
              thsLocations.firstOrNull;
          if (workshopLocation == null && thsLocation == null) {
            return BookingEmptyState(
              title: l10n.serviceFulfillmentUnavailableTitle,
              description: l10n.serviceFulfillmentUnavailableDescription,
            );
          }
          return ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              BookingSection(
                selected:
                    draft.fulfillmentType == ToyotaServiceFulfillment.workshop,
                onTap: workshopLocation == null
                    ? null
                    : () => ref
                        .read(toyotaServiceFlowProvider.notifier)
                        .selectFulfillment(
                          fulfillment: ToyotaServiceFulfillment.workshop,
                          location: workshopLocation,
                        ),
                child: _FulfillmentChoice(
                  icon: Icons.home_work_outlined,
                  title: l10n.workshopService,
                  description: l10n.workshopServiceDescription,
                  location: workshopLocation == null
                      ? null
                      : '${workshopLocation.name}\n'
                          '${workshopLocation.address}',
                ),
              ),
              const SizedBox(height: AppSpacing.medium),
              BookingSection(
                selected: draft.fulfillmentType == ToyotaServiceFulfillment.ths,
                onTap: thsLocation == null
                    ? null
                    : () => ref
                        .read(toyotaServiceFlowProvider.notifier)
                        .selectFulfillment(
                          fulfillment: ToyotaServiceFulfillment.ths,
                          location: thsLocation,
                        ),
                child: _FulfillmentChoice(
                  icon: Icons.home_repair_service_outlined,
                  title: l10n.thsService,
                  description: l10n.thsServiceDescription,
                ),
              ),
              if (thsLocations.isEmpty) ...[
                const SizedBox(height: AppSpacing.small),
                BookingNotice(
                  message: value
                          .fulfillmentOption(ToyotaServiceFulfillment.ths)
                          ?.unavailableReason ??
                      l10n.thsTemporarilyUnavailable,
                  kind: BookingNoticeKind.information,
                ),
              ],
              if (availableLocations.length > 1) ...[
                const SizedBox(height: AppSpacing.medium),
                DropdownButtonFormField<ToyotaServiceLocation>(
                  initialValue: selectedLocation,
                  decoration: InputDecoration(labelText: l10n.location),
                  items: availableLocations
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item.name),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (item) {
                    if (item == null || draft.fulfillmentType == null) return;
                    ref
                        .read(toyotaServiceFlowProvider.notifier)
                        .selectFulfillment(
                          fulfillment: draft.fulfillmentType!,
                          location: item,
                        );
                  },
                ),
              ],
              const SizedBox(height: AppSpacing.large),
              BookingNotice(message: l10n.scheduleNeedsConfirmation),
            ],
          );
        },
      ),
    );
  }
}

class _FulfillmentChoice extends StatelessWidget {
  const _FulfillmentChoice({
    required this.icon,
    required this.title,
    required this.description,
    this.location,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? location;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(child: Icon(icon)),
        const SizedBox(width: AppSpacing.medium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xSmall),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              if (location != null) ...[
                const SizedBox(height: AppSpacing.small),
                Text(
                  location!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class ToyotaServiceTypeScreen extends ConsumerWidget {
  const ToyotaServiceTypeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final flow = ref.watch(toyotaServiceFlowProvider);
    final draft = flow.value?.draft ?? const ToyotaServiceDraft();
    final options = ref.watch(toyotaServiceOptionsProvider);
    final serviceIsEffective = options.value?.serviceTypes.any(
          (item) =>
              item.id == draft.serviceType?.id &&
              draft.fulfillmentType != null &&
              item.supports(draft.fulfillmentType!),
        ) ??
        false;
    return ToyotaServiceFlowScaffold(
      step: 1,
      fallbackLocation: toyotaServiceFulfillmentPath,
      title: l10n.serviceTypeTitle,
      description: l10n.serviceTypeDescription,
      primaryLabel: l10n.continueServiceDetails,
      onPrimary: draft.hasService && serviceIsEffective
          ? () => context.push(toyotaServiceDetailsPath)
          : null,
      body: BookingAsyncView<ToyotaServiceOptions>(
        value: options,
        isEmpty: (value) => value.serviceTypes
            .where((item) =>
                draft.fulfillmentType != null &&
                item.supports(draft.fulfillmentType!))
            .isEmpty,
        emptyTitle: l10n.serviceTypesEmpty,
        emptyDescription: l10n.serviceTypesEmptyDescription,
        onRetry: () => ref.invalidate(toyotaServiceOptionsProvider),
        data: (value) {
          final services = value.serviceTypes
              .where((item) =>
                  draft.fulfillmentType != null &&
                  item.supports(draft.fulfillmentType!))
              .toList(growable: false);
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: services.length + 1,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.medium),
            itemBuilder: (context, index) {
              if (index == services.length) {
                return BookingNotice(
                  message: l10n.serviceAdvisorConfirmation,
                );
              }
              final item = services[index];
              return BookingSection(
                selected: draft.serviceType?.id == item.id,
                onTap: () => ref
                    .read(toyotaServiceFlowProvider.notifier)
                    .selectService(item),
                child: Row(
                  children: [
                    CircleAvatar(child: Icon(_serviceIcon(item.code))),
                    const SizedBox(width: AppSpacing.medium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (item.description.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.xSmall),
                            Text(
                              item.description,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(
                      draft.serviceType?.id == item.id
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _serviceIcon(String code) {
    return switch (code) {
      'periodic' ||
      'periodic_service' ||
      'periodic-service' =>
        Icons.event_available_outlined,
      'general_repair' || 'general-repair' => Icons.build_outlined,
      'body_paint' || 'body-paint' => Icons.format_paint_outlined,
      _ => Icons.support_agent_outlined,
    };
  }
}
