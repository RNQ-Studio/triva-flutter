import 'package:flutter_test/flutter_test.dart';
import 'package:triva_app/features/toyota_service/domain/toyota_service_models.dart';

void main() {
  test('booking parses the public status update link for the WhatsApp text',
      () {
    final booking = ToyotaServiceBooking.fromJson({
      'id': 'b-1',
      'reference_no': 'BTS-1',
      'status': 'awaiting_confirmation',
      'status_label': 'Menunggu',
      'fulfillment_type': 'workshop',
      'current_mileage': 1,
      'complaint': 'Servis',
      'contact_channel': 'whatsapp',
      'status_update_url': 'https://triva.test/booking-servis/abc',
    });

    expect(
      booking.statusUpdateUrl,
      'https://triva.test/booking-servis/abc',
    );
    expect(
      ToyotaServiceBooking.fromJson({
        'id': 'b-2',
        'status': 'awaiting_confirmation',
        'fulfillment_type': 'workshop',
      }).statusUpdateUrl,
      isNull,
    );
  });

  group('Toyota service API models', () {
    test('parses canonical options fields and operational THS coverage', () {
      final options = ToyotaServiceOptions.fromJson({
        'timezone': 'Asia/Jakarta',
        'contact_channels': ['whatsapp', 'phone'],
        'fulfillment_types': [
          {
            'value': 'workshop',
            'label': 'Bengkel',
            'is_available': true,
          },
          {
            'value': 'ths',
            'label': 'THS',
            'is_available': false,
            'unavailable_reason': 'Belum operasional',
          },
        ],
        'photo_upload': {
          'max_files': 5,
          'max_size_mb': 10,
          'mime_types': [
            'image/jpeg',
            'image/png',
            'image/heic',
            'image/heif',
          ],
        },
        'locations': [
          {
            'id': 'loc-1',
            'name': 'Toyota Kertajaya',
            'address': 'Jl. Kertajaya',
            'city': 'Surabaya',
            'phone': '031123',
            'directions_url': 'https://maps.example/location',
            'latitude': -7.27,
            'longitude': 112.76,
            'supports_workshop': true,
            'supports_ths': false,
          },
        ],
        'service_types': [
          {
            'id': 'service-1',
            'code': 'periodic-service',
            'name': 'Servis Berkala',
            'fulfillment_types': ['workshop', 'ths'],
            'workshop_lead_time_days': 2,
            'ths_lead_time_days': 1,
          },
        ],
        'ths_coverage': [
          {
            'city': 'Surabaya',
            'is_active': true,
            'service_location_id': 'loc-1',
            'bounds': {
              'latitude_min': -7.4,
              'latitude_max': -7.1,
              'longitude_min': 112.6,
              'longitude_max': 112.9,
            },
            'verification_source': 'operational',
          },
        ],
      });

      expect(options.locations.single.phone, '031123');
      expect(options.locations.single.directionsUrl, contains('maps'));
      expect(options.locations.single.supportsWorkshop, isTrue);
      expect(options.locations.single.supportsThs, isFalse);
      expect(options.serviceTypes.single.code, 'periodic-service');
      expect(options.serviceTypes.single.workshopLeadDays, 2);
      expect(options.serviceTypes.single.thsLeadDays, 1);
      expect(
        options.thsCoverage.single.requiresOperationalVerification,
        isFalse,
      );
      expect(options.thsCoverage.single.serviceLocationId, 'loc-1');
      expect(options.thsCoverage.single.contains(-7.27, 112.76), isTrue);
      expect(options.thsCoverage.single.contains(-8, 112.76), isFalse);
      expect(options.photoMaxFiles, 5);
      expect(options.photoExtensions, containsAll(['jpg', 'jpeg', 'heic']));
      expect(options.photoExtensions, isNot(contains('webp')));
      expect(
        options
            .fulfillmentOption(ToyotaServiceFulfillment.ths)
            ?.unavailableReason,
        'Belum operasional',
      );
      expect(
        options.isFulfillmentAvailable(ToyotaServiceFulfillment.ths),
        isFalse,
      );
    });

    test('parses detail slots, nested THS, advisor and actions', () {
      final booking = ToyotaServiceBooking.fromJson({
        'id': 'booking-1',
        'reference_no': 'TS-001',
        'status': 'alternative_proposed',
        'status_label': 'Alternatif diajukan',
        'fulfillment_type': 'ths',
        'current_mileage': 12000,
        'complaint': 'Perawatan berkala',
        'contact_channel': 'whatsapp',
        'requested_slots': {
          'primary': {
            'date': '2026-08-01',
            'time_window': '09:00-11:00',
            'timezone': 'Asia/Jakarta',
          },
          'alternative': {
            'date': '2026-08-02',
            'time_window': '13:00-15:00',
          },
        },
        'proposed_slot': {
          'date': '2026-08-03',
          'time_window': '10:00-12:00',
          'pic_name': 'Sari Proposal',
          'arrival_instructions': 'Masuk melalui gate timur',
          'external_booking_number': 'PARTNER-PROP-1',
        },
        'ths_location': {
          'address': 'Jalan Mawar 10',
          'city': 'Surabaya',
          'latitude': -7.2,
          'longitude': 112.7,
          'notes': 'Pagar hitam',
        },
        'assigned_advisor': {'name': 'Budi', 'phone': '0812'},
        'service_advisor': {'name': 'Sari', 'phone': '0813'},
        'allowed_customer_actions': [
          'accept_alternative',
          'reject_alternative'
        ],
        'available_admin_actions': [
          {'action': 'confirm', 'label': 'Konfirmasi'}
        ],
        'benefit_checks': [
          {
            'benefit_type': 't_care',
            'benefit_status': 'pending_verification',
          }
        ],
        'photos': [
          {
            'id': 'asset-1',
            'asset': {
              'temporary_url': 'https://assets.example/photo',
              'original_filename': 'damage.jpg',
            },
          }
        ],
        'sla': {'is_overdue': true},
        'timeline': [],
        'reason_code': 'capacity',
        'reason': 'Slot penuh',
      });

      expect(
          booking.primarySlot,
          const ToyotaServiceSlot(
              date: '2026-08-01', timeWindow: '09:00-11:00'));
      expect(booking.thsAddress, 'Jalan Mawar 10');
      expect(booking.assignedAdvisorName, 'Budi');
      expect(booking.serviceAdvisorName, 'Sari');
      expect(booking.serviceAdvisorPhone, '0813');
      expect(booking.picName, 'Sari');
      expect(booking.proposedPicName, 'Sari Proposal');
      expect(
        booking.proposedArrivalInstructions,
        'Masuk melalui gate timur',
      );
      expect(booking.proposedExternalBookingNumber, 'PARTNER-PROP-1');
      expect(booking.availableAdminActions.single.action, 'confirm');
      expect(booking.slaOverdue, isTrue);
      expect(booking.reason, 'Slot penuh');
      expect(booking.benefitChecks.single.status, 'pending_verification');
      expect(booking.photos.single.url, contains('assets.example'));
    });

    test('slot value equality prevents duplicate preferences', () {
      const first =
          ToyotaServiceSlot(date: '2026-08-01', timeWindow: '09:00-11:00');
      const same =
          ToyotaServiceSlot(date: '2026-08-01', timeWindow: '09:00-11:00');
      const different =
          ToyotaServiceSlot(date: '2026-08-01', timeWindow: '13:00-15:00');

      expect(first, same);
      expect(first, isNot(different));
      expect(
        const ToyotaServiceDraft(
          primarySlot: first,
          alternativeSlot: same,
        ).hasSchedule,
        isFalse,
      );
    });

    test('alternative preference may be chronologically earlier than primary',
        () {
      const primary =
          ToyotaServiceSlot(date: '2026-08-05', timeWindow: '13:00-15:00');
      const earlierAlternative =
          ToyotaServiceSlot(date: '2026-08-03', timeWindow: '09:00-11:00');

      expect(
        const ToyotaServiceDraft(
          primarySlot: primary,
          alternativeSlot: earlierAlternative,
        ).hasSchedule,
        isTrue,
      );
    });

    test('up to five uploaded photo assets survive draft persistence', () {
      final draft = const ToyotaServiceDraft().copyWith(
        photos: List.generate(
          5,
          (index) => ToyotaServiceDraftPhoto(
            assetId: 'asset-$index',
            name: 'damage-$index.jpg',
          ),
        ),
      );

      expect(draft.photos, hasLength(5));
      expect(ToyotaServiceDraft.fromJson(draft.toJson()).photos, draft.photos);
    });

    test('payload mutation can rotate an existing idempotency key', () {
      final failedAttempt = const ToyotaServiceDraft().copyWith(
        idempotencyKey: 'fixed-retry-key',
      );

      expect(failedAttempt.idempotencyKey, 'fixed-retry-key');
      expect(
        failedAttempt.copyWith(clearIdempotencyKey: true).idempotencyKey,
        isNull,
      );
    });

    test('parses assignable admin advisors', () {
      final options = ToyotaServiceAdminOptions.fromJson({
        'advisors': [
          {
            'id': 17,
            'name': 'Budi',
            'email': 'budi@example.com',
            'phone': '0812',
          }
        ],
      });

      expect(options.advisors.single.id, '17');
      expect(options.advisors.single.name, 'Budi');
    });

    test('operational draft rejects stale location and out-of-bounds THS pin',
        () {
      final options = ToyotaServiceOptions.fromJson({
        'locations': [
          {
            'id': 'loc-1',
            'name': 'Toyota Surabaya',
            'address': 'Jl. Toyota',
            'city': 'Surabaya',
            'supports_workshop': true,
            'supports_ths': true,
          },
        ],
        'service_types': [
          {
            'id': 'service-1',
            'code': 'periodic',
            'name': 'Servis Berkala',
            'allowed_fulfillment_types': ['workshop', 'ths'],
          },
        ],
        'ths_coverage': [
          {
            'city': 'Surabaya',
            'is_active': true,
            'service_location_id': 'loc-1',
            'bounds': {
              'latitude_min': -7.4,
              'latitude_max': -7.1,
              'longitude_min': 112.6,
              'longitude_max': 112.9,
            },
          },
        ],
      });
      final valid = ToyotaServiceDraft(
        serviceLocation: options.locations.single,
        serviceType: options.serviceTypes.single,
        fulfillmentType: ToyotaServiceFulfillment.ths,
        thsAddress: 'Jalan Toyota nomor 10',
        thsCity: 'Surabaya',
        thsLatitude: -7.27,
        thsLongitude: 112.76,
      );

      expect(options.supportsOperationalDraft(valid), isTrue);
      expect(
        options.supportsOperationalDraft(
          valid.copyWith(thsLatitude: -8),
        ),
        isFalse,
      );
      expect(
        options.supportsOperationalDraft(
          valid.copyWith(
            serviceLocation: const ToyotaServiceLocation(
              id: 'removed-location',
              name: 'Removed',
              address: '-',
              city: 'Surabaya',
              supportsThs: true,
            ),
          ),
        ),
        isFalse,
      );
    });

    test('authoritative unavailable fulfillment wins over live THS coverage',
        () {
      final options = ToyotaServiceOptions.fromJson({
        'fulfillment_types': [
          {
            'value': 'ths',
            'label': 'THS',
            'is_available': false,
            'unavailable_reason': 'No effective THS service type',
          },
        ],
        'locations': [
          {
            'id': 'loc-1',
            'name': 'Toyota',
            'address': 'Jl. Toyota',
            'city': 'Surabaya',
            'supports_ths': true,
          },
        ],
        'service_types': [
          {
            'id': 'service-1',
            'code': 'workshop-only',
            'name': 'Workshop only',
            'allowed_fulfillment_types': ['workshop'],
          },
        ],
        'ths_coverage': [
          {
            'city': 'Surabaya',
            'is_active': true,
            'service_location_id': 'loc-1',
            'bounds': {
              'latitude_min': -7.4,
              'latitude_max': -7.1,
              'longitude_min': 112.6,
              'longitude_max': 112.9,
            },
          },
        ],
      });

      expect(
        options.isFulfillmentAvailable(ToyotaServiceFulfillment.ths),
        isFalse,
      );
    });

    test('admin confirm actions only use their authoritative requested slots',
        () {
      final booking = ToyotaServiceBooking.fromJson({
        'id': 'booking-1',
        'fulfillment_type': 'workshop',
        'requested_slots': {
          'primary': {
            'date': '2026-08-02',
            'time_window': '09:00-11:00',
          },
          'alternative': {
            'date': '2026-08-03',
            'time_window': '13:00-15:00',
          },
        },
        'reschedule_request': {
          'primary': {
            'date': '2026-08-04',
            'time_window': '09:00-11:00',
          },
          'alternative': {
            'date': '2026-08-05',
            'time_window': '13:00-15:00',
          },
        },
      });

      expect(
        validAdminConfirmationSlots(
          booking,
          'confirm',
          now: DateTime(2026, 8),
        ),
        [booking.primarySlot, booking.alternativeSlot],
      );
      expect(
        validAdminConfirmationSlots(
          booking,
          'confirm_reschedule',
          now: DateTime(2026, 8),
        ),
        [
          booking.reschedulePrimarySlot,
          booking.rescheduleAlternativeSlot,
        ],
      );
      expect(
        validAdminConfirmationSlots(
          booking,
          'propose_alternative',
          now: DateTime(2026, 8),
        ),
        isEmpty,
      );
    });

    test('proposal expiry is capped before proposed and active confirmed slots',
        () {
      const proposed =
          ToyotaServiceSlot(date: '2026-08-03', timeWindow: '09:00-11:00');
      const confirmed =
          ToyotaServiceSlot(date: '2026-08-02', timeWindow: '10:00-12:00');
      final now = DateTime(2026, 8, 1, 9);

      final expiry = defaultProposalExpiry(
        proposed,
        existingConfirmedSlot: confirmed,
        now: now,
      );

      expect(expiry, DateTime(2026, 8, 2, 9));
      expect(
        isValidProposalExpiry(
          expiry!,
          proposed,
          existingConfirmedSlot: confirmed,
          now: now,
        ),
        isTrue,
      );
      expect(
        isValidProposalExpiry(
          DateTime(2026, 8, 2, 10),
          proposed,
          existingConfirmedSlot: confirmed,
          now: now,
        ),
        isFalse,
      );
    });

    test('parses admin timeline actor, reason and internal note', () {
      final item = ToyotaServiceTimelineItem.fromJson({
        'status': 'confirmed',
        'title': 'Booking confirmed',
        'event': 'booking.confirmed',
        'reason_code': 'customer_preference',
        'actor_type': 'admin',
        'actor': {'id': 'admin-1', 'name': 'Ramadhan'},
        'note': 'Internal audit note',
        'metadata': {'source': 'mobile_admin'},
      });

      expect(item.actorName, 'Ramadhan');
      expect(item.actorType, 'admin');
      expect(item.reasonCode, 'customer_preference');
      expect(item.internalNote, 'Internal audit note');
      expect(item.metadata['source'], 'mobile_admin');
    });
  });
}
