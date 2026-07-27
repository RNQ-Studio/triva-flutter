part of 'toyota_service_booking_screens.dart';

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.urgent});

  final String label;
  final bool urgent;

  @override
  Widget build(BuildContext context) => Chip(
        avatar: urgent ? const Icon(Icons.timer_off_outlined, size: 16) : null,
        label: Text(label),
        backgroundColor: urgent
            ? Theme.of(context).colorScheme.errorContainer
            : Theme.of(context).colorScheme.secondaryContainer,
      );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.medium),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: AppIconSize.medium),
            const SizedBox(width: AppSpacing.medium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: AppSpacing.xSmall),
                  Text(value),
                ],
              ),
            ),
          ],
        ),
      );
}

class _SlotRequest {
  const _SlotRequest({
    required this.primary,
    required this.alternative,
    required this.reason,
  });

  final ToyotaServiceSlot primary;
  final ToyotaServiceSlot alternative;
  final String reason;
}

class _SlotRequestDialog extends StatefulWidget {
  const _SlotRequestDialog({
    required this.title,
    required this.availableSlots,
    this.initialPrimary,
    this.initialAlternative,
  });

  final String title;
  final List<ToyotaServiceSlot> availableSlots;
  final ToyotaServiceSlot? initialPrimary;
  final ToyotaServiceSlot? initialAlternative;

  @override
  State<_SlotRequestDialog> createState() => _SlotRequestDialogState();
}

class _SlotRequestDialogState extends State<_SlotRequestDialog> {
  ToyotaServiceSlot? _primary;
  ToyotaServiceSlot? _alternative;
  final _reason = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    _primary = widget.availableSlots.contains(widget.initialPrimary)
        ? widget.initialPrimary
        : widget.availableSlots.firstOrNull;
    _alternative = widget.availableSlots.contains(widget.initialAlternative)
        ? widget.initialAlternative
        : widget.availableSlots.where((slot) => slot != _primary).firstOrNull;
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(widget.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<ToyotaServiceSlot>(
                initialValue: _primary,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.preferencePrimary,
                ),
                items: widget.availableSlots
                    .map(
                      (slot) => DropdownMenuItem(
                        value: slot,
                        child: Text(formatBookingSlot(context, slot)),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) => setState(() => _primary = value),
              ),
              const SizedBox(height: AppSpacing.medium),
              DropdownButtonFormField<ToyotaServiceSlot>(
                initialValue: _alternative,
                decoration: InputDecoration(
                  labelText:
                      AppLocalizations.of(context)!.preferenceAlternative,
                ),
                items: widget.availableSlots
                    .map(
                      (slot) => DropdownMenuItem(
                        value: slot,
                        child: Text(formatBookingSlot(context, slot)),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) => setState(() => _alternative = value),
              ),
              const SizedBox(height: AppSpacing.medium),
              TextField(
                controller: _reason,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.adminActionReason,
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.small),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (_primary == null ||
                  _alternative == null ||
                  _primary == _alternative ||
                  _reason.text.trim().length < 5) {
                setState(
                  () => _error =
                      AppLocalizations.of(context)!.bookingIncompleteError,
                );
                return;
              }
              Navigator.pop(
                context,
                _SlotRequest(
                  primary: _primary!,
                  alternative: _alternative!,
                  reason: _reason.text.trim(),
                ),
              );
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      );
}

Future<String?> _reasonDialog(
  BuildContext context, {
  required String title,
  bool optional = false,
}) async {
  final controller = TextEditingController();
  final result = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.adminActionReason,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        FilledButton(
          onPressed: () {
            final reason = controller.text.trim();
            if (!optional && reason.length < 5) return;
            Navigator.pop(dialogContext, reason);
          },
          child: Text(AppLocalizations.of(context)!.save),
        ),
      ],
    ),
  );
  controller.dispose();
  return result;
}
