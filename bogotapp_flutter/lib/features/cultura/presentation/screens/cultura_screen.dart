import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/review_entity.dart';
import '../providers/reviews_provider.dart';

class CulturaScreen extends ConsumerWidget {
  const CulturaScreen({super.key});

  static const _filters = [
    (label: 'Todos', value: null),
    (label: 'Películas', value: 'movie'),
    (label: 'Series', value: 'series'),
    (label: 'Música', value: 'music'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(reviewTypeFilterProvider);
    final reviewsAsync = ref.watch(reviewsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crítica Cultural'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: _filters.map((f) {
                final active = selected == f.value;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(f.label),
                    selected: active,
                    onSelected: (_) => ref
                        .read(reviewTypeFilterProvider.notifier)
                        .state = f.value,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      body: reviewsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const _EmptyReviews(),
        data: (reviews) {
          if (reviews.isEmpty) return const _EmptyReviews();
          return ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (ctx, i) => _ReviewCard(review: reviews[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/cultura/nueva'),
        icon: const Icon(Icons.rate_review),
        label: const Text('Nueva reseña'),
      ),
    );
  }
}

class _EmptyReviews extends StatelessWidget {
  const _EmptyReviews();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.movie_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No hay reseñas aún. ¡Sé el primero!',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewEntity review;
  const _ReviewCard({required this.review});

  static const _typeIcons = {
    'movie': Icons.movie_outlined,
    'series': Icons.tv_outlined,
    'music': Icons.music_note_outlined,
  };

  static const _typeLabels = {
    'movie': 'Película',
    'series': 'Serie',
    'music': 'Música',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _typeIcons[review.type] ?? Icons.star_outlined,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  _typeLabels[review.type] ?? review.type,
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: theme.colorScheme.primary),
                ),
                const Spacer(),
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < review.score ? Icons.star : Icons.star_outline,
                      size: 16,
                      color: Colors.amber,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(review.title,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(
              review.body,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
