import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong2.dart';
import '../../../shared/providers/location_provider.dart';

class GameMapWidget extends ConsumerWidget {
  final double targetLat;
  final double targetLng;

  const GameMapWidget({
    super.key,
    required this.targetLat,
    required this.targetLng,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPos = ref.watch(locationStreamProvider).value;
    final target = LatLng(targetLat, targetLng);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: FlutterMap(
        options: MapOptions(
          initialCenter: target,
          initialZoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
            subdomains: const ['a', 'b', 'c', 'd'],
          ),
          MarkerLayer(
            markers: [
              // Target Marker
              Marker(
                point: target,
                width: 60,
                height: 60,
                child: const Icon(Icons.location_on, color: Color(0xFFFF0040), size: 40),
              ),
              // User Marker
              if (userPos != null)
                Marker(
                  point: LatLng(userPos.latitude, userPos.longitude),
                  width: 40,
                  height: 40,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.3),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue, width: 2),
                    ),
                    child: const Center(
                      child: Icon(Icons.person_pin_circle, color: Colors.blue, size: 24),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
