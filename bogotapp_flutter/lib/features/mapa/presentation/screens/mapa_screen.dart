import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../providers/places_provider.dart';
import '../../domain/entities/place_entity.dart';

class MapaScreen extends ConsumerWidget {
  const MapaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placesAsync = ref.watch(placesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa Bogotá'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(placesProvider.notifier).refresh(),
          ),
        ],
      ),
      body: placesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _MapView(places: const []),
        data: (places) => _MapView(places: places),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/mapa/nuevo'),
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Agregar lugar'),
      ),
    );
  }
}

class _MapView extends StatelessWidget {
  final List<PlaceEntity> places;

  const _MapView({required this.places});

  static const _bogota = LatLng(4.711, -74.0721);

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: _bogota,
        initialZoom: 12,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.bogotapp',
        ),
        MarkerLayer(
          markers: places.map((place) {
            return Marker(
              point: LatLng(place.lat, place.lng),
              width: 48,
              height: 48,
              child: GestureDetector(
                onTap: () => context.push('/mapa/${place.id}'),
                child: Column(
                  children: [
                    const Icon(Icons.location_pin, color: Colors.red, size: 32),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 2,
                          )
                        ],
                      ),
                      child: Text(
                        place.name,
                        style: const TextStyle(fontSize: 9),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
