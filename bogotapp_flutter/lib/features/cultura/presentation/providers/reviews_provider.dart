import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/reviews_repository_impl.dart';
import '../../domain/entities/review_entity.dart';

final reviewsRepositoryProvider = Provider((ref) {
  return ReviewsRepositoryImpl(ref.watch(dioClientProvider));
});

final reviewTypeFilterProvider = StateProvider<String?>((ref) => null);

class ReviewsNotifier extends AsyncNotifier<List<ReviewEntity>> {
  @override
  Future<List<ReviewEntity>> build() async {
    final type = ref.watch(reviewTypeFilterProvider);
    return ref.watch(reviewsRepositoryProvider).getAll(type: type);
  }

  Future<void> refresh() async {
    final type = ref.read(reviewTypeFilterProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(reviewsRepositoryProvider).getAll(type: type));
  }

  Future<void> create({
    required String type,
    required String title,
    required int score,
    required String body,
  }) async {
    await ref
        .read(reviewsRepositoryProvider)
        .create(type: type, title: title, score: score, body: body);
    await refresh();
  }

  Future<void> delete(String id) async {
    await ref.read(reviewsRepositoryProvider).delete(id);
    await refresh();
  }
}

final reviewsProvider =
    AsyncNotifierProvider<ReviewsNotifier, List<ReviewEntity>>(
        ReviewsNotifier.new);
