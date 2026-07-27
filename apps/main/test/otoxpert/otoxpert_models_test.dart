import 'package:flutter_test/flutter_test.dart';
import 'package:triva_app/features/otoxpert/domain/otoxpert_models.dart';
import 'package:triva_app/features/toyota_service/domain/toyota_service_models.dart';

void main() {
  test('parses request-to-confirm booking, price, actions, and timeline', () {
    final booking = OtoxpertBooking.fromJson({
      'id': 'booking-1',
      'reference_no': 'OX-001',
      'status': 'alternative_proposed',
      'status_label': 'Jadwal alternatif diajukan',
      'current_mileage': 42000,
      'complaint': 'Mesin terdengar kasar.',
      'symptom_codes': ['noise'],
      'is_confirmed': false,
      'submitted_at': '2026-07-27T01:00:00Z',
      'requested_slots': {
        'primary': {'date': '2026-08-01', 'time_window': '08:00-10:00'},
        'alternative': {
          'date': '2026-08-02',
          'time_window': '10:00-12:00',
        },
      },
      'proposed_slot': {
        'date': '2026-08-03',
        'time_window': '13:00-15:00',
        'reason': 'Kapasitas penuh.',
        'expires_at': '2026-07-28T01:00:00Z',
      },
      'price': {
        'type': 'range',
        'minimum_amount': 500000,
        'maximum_amount': 750000,
        'currency': 'IDR',
        'disclaimer': 'Harga final setelah pemeriksaan.',
      },
      'allowed_customer_actions': [
        'accept_alternative',
        'reject_alternative',
      ],
      'available_admin_actions': [
        {'action': 'confirm', 'label': 'Konfirmasi'},
      ],
      'timeline': [
        {
          'status': 'alternative_proposed',
          'event': 'alternative_proposed',
          'title': 'Jadwal alternatif diajukan',
          'created_at': '2026-07-27T02:00:00Z',
        },
      ],
      'sla': {'is_overdue': true},
      'customer': {'name': 'Customer A', 'phone': '0812'},
    });

    expect(booking.primarySlot?.date, '2026-08-01');
    expect(booking.proposedSlot?.timeWindow, '13:00-15:00');
    expect(booking.proposalReason, 'Kapasitas penuh.');
    expect(booking.price?.maximumAmount, 750000);
    expect(booking.canAcceptAlternative, isTrue);
    expect(booking.availableAdminActions.single.value, 'confirm');
    expect(booking.timeline.single.event, 'alternative_proposed');
    expect(booking.slaOverdue, isTrue);
    expect(booking.customerName, 'Customer A');
  });

  test('draft requires two distinct preferences and partner consent', () {
    const vehicle = ToyotaServiceVehicle(
      id: 'vehicle-1',
      make: 'Honda',
      model: 'Brio',
      variant: 'RS',
      year: 2024,
      mileage: 12000,
      licensePlate: 'L 1234 AB',
    );
    const workshop = OtoxpertWorkshop(
      id: 'workshop-1',
      name: 'OtoXpert Rungkut',
      address: 'Surabaya',
      city: 'Surabaya',
      timezone: 'Asia/Jakarta',
      supportsPickupDelivery: false,
      confirmationSlaMinutes: 30,
    );
    const service = OtoxpertService(
      id: 'service-1',
      code: 'oil',
      name: 'Ganti oli',
      description: '',
      leadTimeDays: 1,
    );
    const slot = ToyotaServiceSlot(
      date: '2026-08-01',
      timeWindow: '08:00-10:00',
    );
    const base = OtoxpertDraft(
      vehicle: vehicle,
      workshop: workshop,
      service: service,
      currentMileage: 12000,
      complaint: 'Perlu ganti oli mesin.',
      symptomCodes: ['noise'],
      primarySlot: slot,
      alternativeSlot: slot,
      partnerConsent: true,
    );

    expect(base.canSubmit, isFalse);
    expect(
      base
          .copyWith(
            alternativeSlot: const ToyotaServiceSlot(
              date: '2026-08-02',
              timeWindow: '10:00-12:00',
            ),
          )
          .canSubmit,
      isTrue,
    );
    expect(
      base.copyWith(partnerConsent: false).canSubmit,
      isFalse,
    );
  });
}
