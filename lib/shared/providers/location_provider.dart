import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong2.dart';

final locationStreamProvider = StreamProvider<Position>((ref) {
  return Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    ),
  );
});

final distanceProvider = Provider.family<double?, LatLng>((ref, target) {
  final userPos = ref.watch(locationStreamProvider).value;
  if (userPos == null) return null;

  return Geolocator.distanceBetween(
    userPos.latitude,
    userPos.longitude,
    target.latitude,
    target.longitude,
  );
});