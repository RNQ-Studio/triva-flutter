import 'package:flutter_test/flutter_test.dart';
import 'package:triva_app/features/contact/domain/branch_contacts.dart';
import 'package:triva_app/features/contact/presentation/whatsapp_handoff.dart';

void main() {
  test('branch numbers default to the ones recorded in the meeting notes', () {
    const contacts = BranchContacts.fallback;

    expect(contacts.toyotaService, '6285713112000');
    expect(contacts.otoxpert, '6281511060290');
    expect(contacts.bodyPaint, '6285713112000');
  });

  test('server numbers are normalised whatever shape the branch types', () {
    final contacts = BranchContacts.fromConfig({
      'whatsapp_toyota_service': '0857-1311-2000',
      'whatsapp_otoxpert': '+62 815 1106 0290',
      'whatsapp_body_paint': '85713112000',
    });

    expect(contacts.toyotaService, '6285713112000');
    expect(contacts.otoxpert, '6281511060290');
    expect(contacts.bodyPaint, '6285713112000');
  });

  test('a blank or missing number falls back instead of breaking the link', () {
    final contacts = BranchContacts.fromConfig({
      'whatsapp_toyota_service': '',
      'whatsapp_otoxpert': null,
    });

    expect(contacts.toyotaService, BranchContacts.fallback.toyotaService);
    expect(contacts.otoxpert, BranchContacts.fallback.otoxpert);
    expect(contacts.bodyPaint, BranchContacts.fallback.bodyPaint);
  });

  test('each service points at its own destination number', () {
    const contacts = BranchContacts.fallback;

    expect(BranchChannel.otoxpert.numberFrom(contacts), '6281511060290');
    expect(BranchChannel.toyotaService.numberFrom(contacts), '6285713112000');
    expect(BranchChannel.bodyPaint.numberFrom(contacts), '6285713112000');
  });

  test('the summary drops empty fields so operators read only real data', () {
    final message = branchWhatsAppMessage(
      title: 'Halo Auto2000',
      details: {
        'Nomor referensi': 'BP-001',
        'Kendaraan': '  ',
        'Nomor polisi': null,
        'Keluhan': ' Bumper penyok ',
      },
    );

    expect(
      message,
      'Halo Auto2000\n\nNomor referensi: BP-001\nKeluhan: Bumper penyok',
    );
  });
}
