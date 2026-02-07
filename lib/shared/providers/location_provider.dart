import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong2.dart';

class UserLocation {
  final double latitude;
  final double longitude;
  final double? accuracy;

  UserLocation({required this.latitude, required this.longitude, this.accuracy});
}

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
