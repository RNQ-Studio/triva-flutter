part of 'toyota_service_intake_screens.dart';

class ToyotaServiceVehicleScreen extends ConsumerWidget {
  const ToyotaServiceVehicleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final flow = ref.watch(toyotaServiceFlowProvider);
    final vehicles = ref.watch(toyotaServiceVehiclesProvider);
    final selected = flow.value?.draft.vehicle;

    return ToyotaServiceFlowScaffold(
      step: 0,
      fallbackLocation: '/',
      title: l10n.bookingSelectVehicleTitle,
      description: l10n.bookingSelectVehicleDescription,
      primaryLabel: l10n.useThisVehicle,
      onPrimary: selected == null
          ? null
          : () {
              context.push(
                selected.isToyota
                    ? toyotaServiceFulfillmentPath
                    : toyotaServiceNonToyotaPath,
              );
            },
      body: SizedBox(
        height: 420,
        child: BookingAsyncView<List<ToyotaServiceVehicle>>(
          value: vehicles,
          isEmpty: (items) => items.isEmpty,
          emptyTitle: l10n.bookingNoVehicles,
          emptyDescription: l10n.bookingNoVehiclesDescription,
          emptyAction: OutlinedButton.icon(
            onPressed: () => context.push(toyotaServiceAddVehiclePath),
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.addVehicle),
          ),
          onRetry: () => ref.invalidate(toyotaServiceVehiclesProvider),
          data: (items) => ListView.separated(
            itemCount: items.length + 1,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.medium),
            itemBuilder: (context, index) {
              if (index == items.length) {
                return OutlinedButton.icon(
                  onPressed: () => context.push(toyotaServiceAddVehiclePath),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.addVehicle),
                );
              }
              final vehicle = items[index];
              return BookingSection(
                selected: selected?.id == vehicle.id,
                onTap: () => ref
                    .read(toyotaServiceFlowProvider.notifier)
                    .selectVehicle(vehicle),
                child: Row(
                  children: [
                    CircleAvatar(
                      child: Icon(
                        vehicle.isToyota
                            ? Icons.directions_car_filled_rounded
                            : Icons.directions_car_outlined,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.medium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehicle.displayName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.xSmall),
                          Text(
                            '${vehicle.year} · ${vehicle.licensePlate}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.xSmall),
                          Text(
                            '${NumberFormat.decimalPattern(
                              Localizations.localeOf(context).toLanguageTag(),
                            ).format(vehicle.mileage)} km',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      selected?.id == vehicle.id
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class ToyotaServiceNonToyotaScreen extends ConsumerWidget {
  const ToyotaServiceNonToyotaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final vehicle = ref.watch(toyotaServiceFlowProvider).value?.draft.vehicle;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.bookingToyotaTitle)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BookingProgress(step: 0),
                  if (vehicle != null) ...[
                    BookingSection(
                      child: Row(
                        children: [
                          const CircleAvatar(
                            child: Icon(Icons.directions_car_outlined),
                          ),
                          const SizedBox(width: AppSpacing.medium),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vehicle.displayName,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: AppSpacing.xSmall),
                                Text(
                                  '${vehicle.year} · ${vehicle.licensePlate}',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.large),
                  ],
                  Icon(
                    Icons.info_outline_rounded,
                    color: Theme.of(context).colorScheme.secondary,
                    size: AppIconSize.large,
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  Text(
                    l10n.nonToyotaTitle,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Text(
                    l10n.nonToyotaDescription,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xLarge),
                  FilledButton.icon(
                    onPressed: () => context.go(otoxpertBookingIntakePath),
                    icon: const Icon(Icons.handyman_outlined),
                    label: Text(l10n.continueOtoxpert),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  OutlinedButton(
                    onPressed: () => context.go(toyotaServiceVehiclePath),
                    child: Text(l10n.chooseAnotherVehicle),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
