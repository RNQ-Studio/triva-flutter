part of 'toyota_service_models.dart';

enum ToyotaServiceFulfillment {
  workshop('workshop'),
  ths('ths');

  const ToyotaServiceFulfillment(this.value);

  final String value;

  static ToyotaServiceFulfillment? fromValue(String? value) {
    for (final fulfillment in values) {
      if (fulfillment.value == value) return fulfillment;
    }
    return null;
  }
}

class ToyotaServiceVehicle {
  const ToyotaServiceVehicle({
    required this.id,
    required this.make,
    required this.model,
    required this.variant,
    required this.year,
    required this.mileage,
    required this.licensePlate,
    this.makeSlug,
  });

  final String id;
  final String make;
  final String? makeSlug;
  final String model;
  final String variant;
  final int year;
  final int mileage;
  final String licensePlate;

  bool get isToyota =>
      makeSlug?.toLowerCase() == 'toyota' || make.toLowerCase() == 'toyota';

  String get displayName {
    final variantSuffix = variant.trim().isEmpty ? '' : ' $variant';
    return '$make $model$variantSuffix';
  }

  factory ToyotaServiceVehicle.fromJson(Map<String, dynamic> json) {
    final makeData = json['vehicle_make'];
    return ToyotaServiceVehicle(
      id: json['id']?.toString() ?? '',
      make: json['make']?.toString() ??
          (makeData is Map<String, dynamic>
              ? makeData['name']?.toString() ?? ''
              : ''),
      makeSlug: json['make_slug']?.toString() ??
          (makeData is Map<String, dynamic>
              ? makeData['slug']?.toString()
              : null),
      model: json['model']?.toString() ?? '',
      variant: json['variant']?.toString() ?? '',
      year: (json['year'] as num?)?.toInt() ?? 0,
      mileage: (json['mileage'] as num?)?.toInt() ?? 0,
      licensePlate: json['license_plate']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'make': make,
        if (makeSlug != null) 'make_slug': makeSlug,
        'model': model,
        'variant': variant,
        'year': year,
        'mileage': mileage,
        'license_plate': licensePlate,
      };
}

class ToyotaServiceLocation {
  const ToyotaServiceLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    this.latitude,
    this.longitude,
    this.phone,
    this.directionsUrl,
    this.supportsWorkshop = true,
    this.supportsThs = false,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String address;
  final String city;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final String? directionsUrl;
  final bool supportsWorkshop;
  final bool supportsThs;
  final bool isActive;

  factory ToyotaServiceLocation.fromJson(Map<String, dynamic> json) =>
      ToyotaServiceLocation(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        address: json['address']?.toString() ??
            json['address_line']?.toString() ??
            '',
        city: json['city']?.toString() ?? '',
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        phone: json['phone']?.toString(),
        directionsUrl: json['directions_url']?.toString(),
        supportsWorkshop: json['supports_workshop'] as bool? ?? true,
        supportsThs: json['supports_ths'] as bool? ?? false,
        isActive: json['is_active'] as bool? ?? true,
      );
}

class ToyotaServiceType {
  const ToyotaServiceType({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.allowedFulfillments,
    this.workshopLeadDays = 2,
    this.thsLeadDays = 1,
    this.isActive = true,
  });

  final String id;
  final String code;
  final String name;
  final String description;
  final List<ToyotaServiceFulfillment> allowedFulfillments;
  final int workshopLeadDays;
  final int thsLeadDays;
  final bool isActive;

  bool supports(ToyotaServiceFulfillment fulfillment) =>
      allowedFulfillments.contains(fulfillment);

  /// Jenis servis Body & Paint -- satu-satunya yang masih meminta foto
  /// pendukung pada langkah detail.
  bool get isBodyPaint =>
      const {'body_paint', 'body-paint'}.contains(code.toLowerCase());

  int leadDaysFor(ToyotaServiceFulfillment fulfillment) =>
      fulfillment == ToyotaServiceFulfillment.ths
          ? thsLeadDays
          : workshopLeadDays;

  factory ToyotaServiceType.fromJson(Map<String, dynamic> json) {
    final rawFulfillments =
        json['allowed_fulfillment_types'] as List<dynamic>? ??
            json['fulfillment_types'] as List<dynamic>? ??
            const ['workshop', 'ths'];
    return ToyotaServiceType(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      allowedFulfillments: rawFulfillments
          .map((item) => ToyotaServiceFulfillment.fromValue(item.toString()))
          .whereType<ToyotaServiceFulfillment>()
          .toList(growable: false),
      workshopLeadDays: (json['workshop_lead_time_days'] as num?)?.toInt() ??
          (json['lead_time_days'] as num?)?.toInt() ??
          2,
      thsLeadDays: (json['ths_lead_time_days'] as num?)?.toInt() ??
          (json['lead_time_days'] as num?)?.toInt() ??
          1,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

class ToyotaServiceCoverage {
  const ToyotaServiceCoverage({
    required this.city,
    required this.isActive,
    this.bounds,
    this.verificationSource,
    this.serviceLocationId,
  });

  final String city;
  final bool isActive;
  final Map<String, dynamic>? bounds;
  final String? verificationSource;
  final String? serviceLocationId;
  bool get requiresOperationalVerification => bounds == null;

  bool contains(double latitude, double longitude) {
    final value = bounds;
    if (value == null) return false;
    final south = _coordinate(value, 'south') ??
        _coordinate(value, 'min_latitude') ??
        _coordinate(value, 'latitude_min') ??
        _nestedCoordinate(value, 'southwest', 'latitude');
    final north = _coordinate(value, 'north') ??
        _coordinate(value, 'max_latitude') ??
        _coordinate(value, 'latitude_max') ??
        _nestedCoordinate(value, 'northeast', 'latitude');
    final west = _coordinate(value, 'west') ??
        _coordinate(value, 'min_longitude') ??
        _coordinate(value, 'longitude_min') ??
        _nestedCoordinate(value, 'southwest', 'longitude');
    final east = _coordinate(value, 'east') ??
        _coordinate(value, 'max_longitude') ??
        _coordinate(value, 'longitude_max') ??
        _nestedCoordinate(value, 'northeast', 'longitude');
    if (south == null || north == null || west == null || east == null) {
      return false;
    }
    return latitude >= south &&
        latitude <= north &&
        longitude >= west &&
        longitude <= east;
  }

  static double? _coordinate(Map<String, dynamic> map, String key) =>
      (map[key] as num?)?.toDouble();

  static double? _nestedCoordinate(
    Map<String, dynamic> map,
    String group,
    String key,
  ) {
    final nested = map[group];
    return nested is Map<String, dynamic>
        ? (nested[key] as num?)?.toDouble()
        : null;
  }

  factory ToyotaServiceCoverage.fromJson(Map<String, dynamic> json) =>
      ToyotaServiceCoverage(
        city: json['city']?.toString() ?? '',
        isActive: json['is_active'] as bool? ?? true,
        bounds: json['bounds'] is Map<String, dynamic>
            ? json['bounds'] as Map<String, dynamic>
            : null,
        verificationSource: json['verification_source']?.toString(),
        serviceLocationId: json['service_location_id']?.toString(),
      );
}

class ToyotaServiceFulfillmentOption {
  const ToyotaServiceFulfillmentOption({
    required this.fulfillment,
    required this.label,
    required this.isAvailable,
    this.unavailableReason,
  });

  final ToyotaServiceFulfillment fulfillment;
  final String label;
  final bool isAvailable;
  final String? unavailableReason;

  factory ToyotaServiceFulfillmentOption.fromJson(
    Map<String, dynamic> json,
  ) =>
      ToyotaServiceFulfillmentOption(
        fulfillment: ToyotaServiceFulfillment.fromValue(
              json['value']?.toString(),
            ) ??
            ToyotaServiceFulfillment.workshop,
        label: json['label']?.toString() ?? '',
        isAvailable: json['is_available'] as bool? ?? false,
        unavailableReason: json['unavailable_reason']?.toString() ??
            json['reason']?.toString(),
      );
}

class ToyotaServiceOptions {
  const ToyotaServiceOptions({
    required this.timezone,
    required this.contactChannels,
    required this.locations,
    required this.serviceTypes,
    required this.thsCoverage,
    this.fulfillmentOptions = const [],
    this.photoMimeTypes = const [
      'image/jpeg',
      'image/png',
      'image/heic',
      'image/heif',
    ],
    this.photoMaxFiles = 5,
    this.photoMaxSizeMb = 10,
  });

  final String timezone;
  final List<String> contactChannels;
  final List<ToyotaServiceLocation> locations;
  final List<ToyotaServiceType> serviceTypes;
  final List<ToyotaServiceCoverage> thsCoverage;
  final List<ToyotaServiceFulfillmentOption> fulfillmentOptions;
  final List<String> photoMimeTypes;
  final int photoMaxFiles;
  final int photoMaxSizeMb;

  Set<String> get photoExtensions {
    final extensions = <String>{};
    for (final raw in photoMimeTypes) {
      final value = raw.toLowerCase().trim();
      if (value.contains('jpeg') || value == 'jpg' || value == 'jpeg') {
        extensions.addAll(const ['jpg', 'jpeg']);
      } else if (value.contains('png')) {
        extensions.add('png');
      } else if (value.contains('heic')) {
        extensions.add('heic');
      } else if (value.contains('heif')) {
        extensions.add('heif');
      }
    }
    return extensions;
  }

  ToyotaServiceFulfillmentOption? fulfillmentOption(
    ToyotaServiceFulfillment fulfillment,
  ) =>
      fulfillmentOptions
          .where((item) => item.fulfillment == fulfillment)
          .firstOrNull;

  bool isFulfillmentAvailable(ToyotaServiceFulfillment fulfillment) {
    final option = fulfillmentOption(fulfillment);
    final enabledByApi =
        fulfillmentOptions.isEmpty || option?.isAvailable == true;
    return enabledByApi &&
        serviceTypes.any((item) => item.supports(fulfillment));
  }

  bool isThsCityCovered(String city) {
    final normalized = city.trim().toLowerCase();
    return thsCoverage.any(
      (coverage) =>
          coverage.isActive && coverage.city.trim().toLowerCase() == normalized,
    );
  }

  bool supportsFulfillmentSelection(ToyotaServiceDraft draft) {
    final fulfillment = draft.fulfillmentType;
    final locationId = draft.serviceLocation?.id;
    if (fulfillment == null || locationId == null) return false;
    final location =
        locations.where((item) => item.id == locationId).firstOrNull;
    if (location == null) return false;
    if (!isFulfillmentAvailable(fulfillment)) return false;
    return fulfillment == ToyotaServiceFulfillment.workshop
        ? location.supportsWorkshop
        : location.supportsThs &&
            thsCoverage.any(
              (coverage) =>
                  coverage.isActive &&
                  coverage.bounds != null &&
                  coverage.serviceLocationId == location.id,
            );
  }

  bool supportsServiceSelection(ToyotaServiceDraft draft) {
    final fulfillment = draft.fulfillmentType;
    final serviceTypeId = draft.serviceType?.id;
    if (fulfillment == null || serviceTypeId == null) return false;
    return serviceTypes.any(
      (item) => item.id == serviceTypeId && item.supports(fulfillment),
    );
  }

  bool coversThsAddress(ToyotaServiceDraft draft) {
    if (draft.fulfillmentType != ToyotaServiceFulfillment.ths) return true;
    final latitude = draft.thsLatitude;
    final longitude = draft.thsLongitude;
    final locationId = draft.serviceLocation?.id;
    final city = draft.thsCity.trim().toLowerCase();
    if (latitude == null ||
        longitude == null ||
        locationId == null ||
        city.isEmpty) {
      return false;
    }
    return thsCoverage.any(
      (coverage) =>
          coverage.isActive &&
          coverage.bounds != null &&
          coverage.serviceLocationId == locationId &&
          coverage.city.trim().toLowerCase() == city &&
          coverage.contains(latitude, longitude),
    );
  }

  bool supportsOperationalDraft(ToyotaServiceDraft draft) =>
      supportsFulfillmentSelection(draft) &&
      supportsServiceSelection(draft) &&
      coversThsAddress(draft);

  factory ToyotaServiceOptions.fromJson(Map<String, dynamic> json) =>
      ToyotaServiceOptions(
        timezone: json['timezone']?.toString() ?? 'Asia/Jakarta',
        contactChannels: (json['contact_channels'] as List<dynamic>? ??
                const ['whatsapp', 'phone', 'email'])
            .map((item) => item is Map<String, dynamic>
                ? item['value']?.toString() ?? ''
                : item.toString())
            .where((item) => item.isNotEmpty)
            .toList(growable: false),
        locations: (json['locations'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(ToyotaServiceLocation.fromJson)
            .where((item) => item.isActive)
            .toList(growable: false),
        serviceTypes: (json['service_types'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(ToyotaServiceType.fromJson)
            .where((item) => item.isActive)
            .toList(growable: false),
        thsCoverage: (json['ths_coverage'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(ToyotaServiceCoverage.fromJson)
            .toList(growable: false),
        fulfillmentOptions:
            (json['fulfillment_types'] as List<dynamic>? ?? const [])
                .whereType<Map<String, dynamic>>()
                .map(ToyotaServiceFulfillmentOption.fromJson)
                .toList(growable: false),
        photoMimeTypes: ((json['photo_upload']
                        as Map<String, dynamic>?)?['mime_types']
                    as List<dynamic>? ??
                const ['image/jpeg', 'image/png', 'image/heic', 'image/heif'])
            .map((item) => item.toString())
            .toList(growable: false),
        photoMaxFiles: ((json['photo_upload']
                    as Map<String, dynamic>?)?['max_files'] as num?)
                ?.toInt() ??
            5,
        photoMaxSizeMb: ((json['photo_upload']
                    as Map<String, dynamic>?)?['max_size_mb'] as num?)
                ?.toInt() ??
            10,
      );
}

class ToyotaServiceSlot {
  const ToyotaServiceSlot({
    required this.date,
    required this.timeWindow,
  });

  final String date;
  final String timeWindow;

  factory ToyotaServiceSlot.fromJson(Map<String, dynamic> json) =>
      ToyotaServiceSlot(
        date: json['date']?.toString() ?? '',
        timeWindow: json['time_window']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'date': date,
        'time_window': timeWindow,
      };

  @override
  bool operator ==(Object other) =>
      other is ToyotaServiceSlot &&
      date == other.date &&
      timeWindow == other.timeWindow;

  @override
  int get hashCode => Object.hash(date, timeWindow);
}

class ToyotaServiceAvailability {
  const ToyotaServiceAvailability({
    required this.timezone,
    required this.isRealTime,
    required this.slots,
  });

  final String timezone;
  final bool isRealTime;
  final List<ToyotaServiceSlot> slots;

  factory ToyotaServiceAvailability.fromJson(Map<String, dynamic> json) {
    final slots = <ToyotaServiceSlot>[];
    for (final item in json['dates'] as List<dynamic>? ?? const []) {
      if (item is! Map<String, dynamic>) continue;
      final date = item['date']?.toString() ?? '';
      for (final window in item['time_windows'] as List<dynamic>? ?? const []) {
        final value = window is Map<String, dynamic>
            ? window['value']?.toString() ??
                window['time_window']?.toString() ??
                ''
            : window.toString();
        if (date.isNotEmpty && value.isNotEmpty) {
          slots.add(ToyotaServiceSlot(date: date, timeWindow: value));
        }
      }
    }
    return ToyotaServiceAvailability(
      timezone: json['timezone']?.toString() ?? 'Asia/Jakarta',
      isRealTime: json['is_real_time'] as bool? ?? false,
      slots: slots,
    );
  }
}
