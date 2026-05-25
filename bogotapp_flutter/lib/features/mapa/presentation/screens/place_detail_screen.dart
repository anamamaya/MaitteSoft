import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/places_provider.dart';

class PlaceDetailScreen extends ConsumerWidget {
  final String placeId;
  const PlaceDetailScreen({super.key, required this.placeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placesAsync = ref.watch(placesProvider);

    return placesAsync.when(
      loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator())),
      error: (e, _) =>
          Scaffold(body: Center(child: Text('Error: $e'))),
      data: (places) {
        final place = places.where((p) => p.id == placeId).firstOrNull;
        if (place == null) {
          return const Scaffold(
              body: Center(child: Text('Lugar no encontrado')));
        }

        return Scaffold(
          appBar: AppBar(title: Text(place.name)),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (place.photoUrl != null)
                  CachedNetworkImage(
                    imageUrl: 'http://localhost:3000${place.photoUrl}',
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 220,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 220,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, size: 48),
                    ),
                  )
                else
                  Container(
                    height: 220,
                    color: Colors.grey[200],
                    child: const Center(
                        child: Icon(Icons.place, size: 64, color: Colors.grey)),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Chip(
                        label: Text(place.category),
                        avatar: const Icon(Icons.category, size: 16),
                      ),
                      const SizedBox(height: 12),
                      Text(place.description,
                          style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16,
                              color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                              '${place.lat.toStringAsFixed(4)}, ${place.lng.toStringAsFixed(4)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () =>
                            ref.read(placesProvider.notifier).toggleLike(place.id),
                        icon: const Icon(Icons.favorite_border),
                        label: Text('${place.likesCount} likes'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
