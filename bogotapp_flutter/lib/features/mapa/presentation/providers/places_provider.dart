import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../data/models/place_model.dart';
import '../../data/repositories/places_repository_impl.dart';
import '../../domain/entities/place_entity.dart';

final placesRepositoryProvider = Provider((ref) {
  return PlacesRepositoryImpl(ref.watch(dioClientProvider));
});

class PlacesNotifier extends AsyncNotifier<List<PlaceEntity>> {
  WebSocketChannel? _channel;

  @override
  Future<List<PlaceEntity>> build() async {
    _connectWebSocket();
    ref.onDispose(() => _channel?.sink.close());
    return ref.watch(placesRepositoryProvider).getAll();
  }

  void _connectWebSocket() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse('ws://192.168.1.43:3000/ws'));
      _channel!.stream.listen((raw) {
        final message = jsonDecode(raw as String) as Map<String, dynamic>;
        if (message['event'] == 'place:created') {
          final place = PlaceModel.fromJson(
                  message['payload'] as Map<String, dynamic>)
              .toEntity();
          state.whenData((places) {
            state = AsyncData([place, ...places]);
          });
        }
      });
    } catch (_) {}
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(placesRepositoryProvider).getAll());
  }

  Future<void> createPlace({
    required String name,
    required String description,
    required String category,
    required double lat,
    required double lng,
    String? photoPath,
  }) async {
    await ref.read(placesRepositoryProvider).create(
          name: name,
          description: description,
          category: category,
          lat: lat,
          lng: lng,
          photoPath: photoPath,
        );
    await refresh();
  }

  Future<void> toggleLike(String placeId) async {
    await ref.read(placesRepositoryProvider).toggleLike(placeId);
    await refresh();
  }
}

final placesProvider =
    AsyncNotifierProvider<PlacesNotifier, List<PlaceEntity>>(PlacesNotifier.new);
