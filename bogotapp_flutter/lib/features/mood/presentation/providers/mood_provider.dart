import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/mood_repository_impl.dart';

final moodRepositoryProvider = Provider((ref) {
  return MoodRepositoryImpl(ref.watch(dioClientProvider));
});

final moodProvider =
    AsyncNotifierProvider.autoDispose<MoodNotifier, MoodRecommendation?>(
        MoodNotifier.new);

class MoodNotifier extends AutoDisposeAsyncNotifier<MoodRecommendation?> {
  @override
  Future<MoodRecommendation?> build() async => null;

  Future<void> getRecommendation(String mood) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(moodRepositoryProvider).getRecommendation(mood));
  }

  void reset() {
    state = const AsyncData(null);
  }
}
