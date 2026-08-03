import 'package:core/core.dart';
import 'package:flutter/material.dart';

Future<String?> showCreditFollowUpDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  var consent = false;
  var channel = 'whatsapp';
  final submitted = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog.adaptive(
        title: Text(l10n.creditFollowUpConsentTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                initialValue: channel,
                decoration: InputDecoration(
                  labelText: l10n.creditContactChannel,
                ),
                items: [
                  DropdownMenuItem(
                    value: 'whatsapp',
                    child: Text(l10n.creditContactWhatsapp),
                  ),
                  DropdownMenuItem(
                    value: 'phone',
                    child: Text(l10n.creditContactPhone),
                  ),
                  DropdownMenuItem(
                    value: 'email',
                    child: Text(l10n.creditContactEmail),
                  ),
                ],
                onChanged: (value) => setDialogState(
                  () => channel = value ?? channel,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: consent,
                onChanged: (value) => setDialogState(
                  () => consent = value ?? false,
                ),
                title: Text(l10n.creditFollowUpConsentDescription),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed:
                consent ? () => Navigator.pop(dialogContext, true) : null,
            child: Text(l10n.creditRequestSales),
          ),
        ],
      ),
    ),
  );
  return submitted == true ? channel : null;
}
