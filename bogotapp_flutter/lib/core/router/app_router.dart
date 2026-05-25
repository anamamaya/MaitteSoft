import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/mapa/presentation/screens/mapa_screen.dart';
import '../../features/mapa/presentation/screens/add_place_screen.dart';
import '../../features/mapa/presentation/screens/place_detail_screen.dart';
import '../../features/cultura/presentation/screens/cultura_screen.dart';
import '../../features/cultura/presentation/screens/add_review_screen.dart';
import '../../features/mood/presentation/screens/mood_screen.dart';
import '../widgets/main_shell.dart';

class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(Ref ref) {
    ref.listen(authProvider, (previous, next) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = _AuthNotifier(ref);

  final router = GoRouter(
    initialLocation: '/mapa',
    refreshListenable: authNotifier,
    redirect: (context, state) => null,
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/mapa',
            builder: (context, state) => const MapaScreen(),
            routes: [
              GoRoute(
                path: 'nuevo',
                builder: (context, state) => const AddPlaceScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) =>
                    PlaceDetailScreen(placeId: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: '/cultura',
            builder: (context, state) => const CulturaScreen(),
            routes: [
              GoRoute(
                path: 'nueva',
                builder: (context, state) => const AddReviewScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/mood',
            builder: (context, state) => const MoodScreen(),
          ),
        ],
      ),
    ],
  );

  ref.onDispose(() {
    authNotifier.dispose();
    router.dispose();
  });

  return router;
});
