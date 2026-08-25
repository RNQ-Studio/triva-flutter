import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

abstract class ThsLocationSource {
  Future<LatLng> current();
}

class GeolocatorThsLocationSource implements ThsLocationSource {
  @override
  Future<LatLng> current() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw StateError('location-services-disabled');
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw StateError('location-permission-denied');
    }
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
    return LatLng(position.latitude, position.longitude);
  }
}

final thsLocationSourceProvider = Provider<ThsLocationSource>(
  (_) => GeolocatorThsLocationSource(),
);

class ThsLocationPicker extends ConsumerStatefulWidget {
  const ThsLocationPicker({
    required this.latitude,
    required this.longitude,
    required this.onChanged,
    super.key,
  });

  final double? latitude;
  final double? longitude;
  final ValueChanged<LatLng> onChanged;

  @override
  ConsumerState<ThsLocationPicker> createState() => _ThsLocationPickerState();
}

class _ThsLocationPickerState extends ConsumerState<ThsLocationPicker> {
  final _mapController = MapController();
  late LatLng _point;
  bool _locating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _point = LatLng(
      widget.latitude ?? -7.2575,
      widget.longitude ?? 112.7521,
    );
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: AppRadius.large,
            child: SizedBox(
              height: 260,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _point,
                  initialZoom: 15,
                  onTap: (_, point) => _set(point),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'id.rnq.triva',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _point,
                        width: 48,
                        height: 48,
                        child: const Icon(
                          Icons.location_on_rounded,
                          size: 44,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                  const RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution('OpenStreetMap contributors'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          OutlinedButton.icon(
            onPressed: _locating ? null : _locate,
            icon: _locating
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location_rounded),
            label: Text(AppLocalizations.of(context)!.useCurrentLocation),
          ),
          if (_error != null)
            Text(
              '${_errorMessage(context)} '
              '${AppLocalizations.of(context)!.locationMapFallback}',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
        ],
      );

  Future<void> _locate() async {
    setState(() {
      _locating = true;
      _error = null;
    });
    try {
      _set(await ref.read(thsLocationSourceProvider).current());
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _set(LatLng value) {
    setState(() => _point = value);
    _mapController.move(value, 15);
    widget.onChanged(value);
  }

  String _errorMessage(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_error?.contains('location-services-disabled') ?? false) {
      return l10n.locationServicesDisabled;
    }
    return l10n.locationPermissionDenied;
  }
}
