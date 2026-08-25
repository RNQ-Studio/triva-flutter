import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/app_contact_repository.dart';
import '../domain/branch_contacts.dart';

final appContactRepositoryProvider = Provider<AppContactRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return AppContactRepository(
    dio: DioClient(
      storage,
      onLogout: () => ref.read(authProvider.notifier).expireSession(),
    ).dio,
  );
});

final branchContactsProvider = FutureProvider<BranchContacts>((ref) {
  return ref.watch(appContactRepositoryProvider).branchContacts();
});

/// Layanan yang punya nomor WhatsApp tujuan sendiri.
enum BranchChannel { toyotaService, otoxpert, bodyPaint }

extension BranchChannelNumber on BranchChannel {
  String numberFrom(BranchContacts contacts) => switch (this) {
        BranchChannel.toyotaService => contacts.toyotaService,
        BranchChannel.otoxpert => contacts.otoxpert,
        BranchChannel.bodyPaint => contacts.bodyPaint,
      };
}

/// Membuka WhatsApp cabang dengan ringkasan yang sudah terisi.
///
/// Notulensi 19 Agustus 2026: setelah pelanggan selesai mengisi form, datanya
/// dikirim ke WhatsApp cabang yang sesuai. Mengembalikan `true` bila WhatsApp
/// benar-benar terbuka, sehingga pemanggil bisa menjelaskan kegagalannya alih-
/// alih diam saja.
Future<bool> openBranchWhatsApp(
  WidgetRef ref, {
  required BranchChannel channel,
  required String message,
}) async {
  final contacts = await ref.read(branchContactsProvider.future);
  final uri = Uri.https(
    'wa.me',
    '/${channel.numberFrom(contacts)}',
    {'text': message},
  );

  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } on Object {
    // Perangkat tanpa WhatsApp, atau browser yang memblokir pop-up.
    return false;
  }
}

/// Menyusun ringkasan yang mudah dibaca operator: satu judul, lalu pasangan
/// label dan nilai yang tidak kosong.
String branchWhatsAppMessage({
  required String title,
  required Map<String, String?> details,
}) {
  final lines = <String>[title, ''];
  details.forEach((label, value) {
    if (value == null || value.trim().isEmpty) return;
    lines.add('$label: ${value.trim()}');
  });

  return lines.join('\n');
}
