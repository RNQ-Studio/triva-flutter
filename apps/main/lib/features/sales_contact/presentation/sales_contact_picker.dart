import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../contact/presentation/whatsapp_handoff.dart';
import '../domain/sales_contact_models.dart';
import 'sales_contact_controller.dart';

/// Pilihan tujuan WhatsApp: sales tertentu (foto & nama) atau "belum ada
/// sales" yang otomatis mengarah ke supervisor (revisi 4 September 2026).
///
/// Mengembalikan kontak yang dipilih, atau null bila lembar ditutup.
Future<SalesContact?> showSalesContactPicker(
  BuildContext context, {
  required SalesDirectory directory,
}) {
  return showModalBottomSheet<SalesContact>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _SalesContactSheet(directory: directory),
  );
}

/// Membuka WhatsApp ke satu kontak dengan pesan yang sudah terisi.
Future<bool> openSalesWhatsApp(SalesContact contact, String message) async {
  final uri = Uri.https('wa.me', '/${contact.whatsappNumber}', {
    'text': message,
  });
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } on Object {
    return false;
  }
}

/// Memuat direktori sales, menampilkan pilihan, lalu membuka WhatsApp.
/// Bila cabang belum mendaftarkan sales/SPV sama sekali, pesan diteruskan ke
/// WhatsApp admin booking servis supaya pelanggan tetap terlayani.
Future<bool> pickSalesAndOpenWhatsApp(
  BuildContext context,
  WidgetRef ref, {
  required String message,
}) async {
  final directory = await _loadDirectory(ref);
  if (!context.mounted) return false;
  if (directory.isEmpty) {
    return openBranchWhatsApp(
      ref,
      channel: BranchChannel.toyotaService,
      message: message,
    );
  }
  final chosen = await showSalesContactPicker(context, directory: directory);
  if (chosen == null) return true;
  return openSalesWhatsApp(chosen, message);
}

/// Membuka WhatsApp supervisor langsung (jadwal inspeksi, terima harga, dan
/// tindak lanjut appraisal lainnya).
Future<bool> openSupervisorWhatsApp(
  WidgetRef ref, {
  required String message,
}) async {
  final directory = await _loadDirectory(ref);
  final supervisor = directory.defaultSupervisor;
  if (supervisor == null) {
    return openBranchWhatsApp(
      ref,
      channel: BranchChannel.toyotaService,
      message: message,
    );
  }
  return openSalesWhatsApp(supervisor, message);
}

Future<SalesDirectory> _loadDirectory(WidgetRef ref) async {
  try {
    return await ref.read(salesDirectoryProvider.future);
  } on Object {
    return const SalesDirectory([]);
  }
}

class _SalesContactSheet extends StatelessWidget {
  const _SalesContactSheet({required this.directory});

  final SalesDirectory directory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final supervisor = directory.defaultSupervisor;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
              child: Text(
                l10n.salesPickerTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: AppSpacing.xSmall),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
              child: Text(
                l10n.salesPickerSubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.small,
                ),
                children: [
                  for (final contact in directory.sales)
                    ListTile(
                      key: ValueKey('sales-contact-${contact.id}'),
                      leading: _Avatar(contact: contact),
                      title: Text(contact.name),
                      subtitle: Text(
                        contact.roleLabel.isEmpty
                            ? l10n.salesRoleSales
                            : contact.roleLabel,
                      ),
                      trailing: const Icon(Icons.chat_outlined),
                      onTap: () => Navigator.of(context).pop(contact),
                    ),
                  if (supervisor != null)
                    ListTile(
                      key: const ValueKey('sales-contact-none'),
                      leading: CircleAvatar(
                        backgroundColor: colors.secondaryContainer,
                        child: Icon(
                          Icons.support_agent_outlined,
                          color: colors.onSecondaryContainer,
                        ),
                      ),
                      title: Text(l10n.salesPickerNoSales),
                      subtitle: Text(
                        l10n.salesPickerNoSalesSubtitle(supervisor.name),
                      ),
                      trailing: const Icon(Icons.chat_outlined),
                      onTap: () => Navigator.of(context).pop(supervisor),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.medium),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.contact});

  final SalesContact contact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final initials = contact.name.trim().isEmpty
        ? '?'
        : contact.name.trim().substring(0, 1).toUpperCase();
    return CircleAvatar(
      backgroundColor: colors.primaryContainer,
      foregroundImage:
          contact.hasPhoto ? NetworkImage(contact.photoUrl!) : null,
      onForegroundImageError: contact.hasPhoto ? (_, __) {} : null,
      child: Text(
        initials,
        style: TextStyle(color: colors.onPrimaryContainer),
      ),
    );
  }
}
