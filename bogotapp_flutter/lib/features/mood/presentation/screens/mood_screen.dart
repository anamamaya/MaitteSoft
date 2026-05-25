import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/mood_provider.dart';
import '../../data/repositories/mood_repository_impl.dart';

class MoodScreen extends ConsumerStatefulWidget {
  const MoodScreen({super.key});

  @override
  ConsumerState<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends ConsumerState<MoodScreen> {
  final _ctrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _ask() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(moodProvider.notifier).getRecommendation(_ctrl.text.trim());
  }

  void _navigateToResult(MoodRecommendation rec) {
    if (rec.type == 'lugar' && rec.lat != null && rec.lng != null) {
      context.go('/mapa');
    } else {
      context.go('/cultura');
    }
  }

  @override
  Widget build(BuildContext context) {
    final moodAsync = ref.watch(moodProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Mood Picker')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              '¿Cómo te sientes hoy?',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Cuéntame tu estado de ánimo y te recomendaré algo perfecto para ti.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _ctrl,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Describe tu mood...',
                      hintText:
                          'Ej: Me siento creativo y con ganas de explorar algo diferente',
                    ),
                    validator: (v) =>
                        v == null || v.length < 3 ? 'Cuéntame más' : null,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: moodAsync.isLoading ? null : _ask,
                    icon: moodAsync.isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: const Text('Recomiéndame algo'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            moodAsync.when(
              loading: () => const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Claude está pensando en ti...'),
                  ],
                ),
              ),
              error: (e, _) => _ErrorCard(message: e.toString()),
              data: (rec) {
                if (rec == null) return const SizedBox.shrink();
                return _RecommendationCard(
                  recommendation: rec,
                  onNavigate: () => _navigateToResult(rec),
                  onReset: () {
                    _ctrl.clear();
                    ref.read(moodProvider.notifier).reset();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final MoodRecommendation recommendation;
  final VoidCallback onNavigate;
  final VoidCallback onReset;

  const _RecommendationCard({
    required this.recommendation,
    required this.onNavigate,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlace = recommendation.type == 'lugar';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPlace ? Icons.location_on : Icons.movie_outlined,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                isPlace ? 'Lugar recomendado' : 'Contenido recomendado',
                style: theme.textTheme.labelLarge
                    ?.copyWith(color: theme.colorScheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            recommendation.name,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            recommendation.reason,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onNavigate,
                  child: Text(isPlace ? 'Ver en el mapa' : 'Ver reseñas'),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: onReset,
                child: const Text('Intentar de nuevo'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}
