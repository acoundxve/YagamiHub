import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/auth_providers.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/splash/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: _AuthStateListenable(ref),
    redirect: (context, state) {
      final status = ref.read(authControllerProvider).status;
      final isSplash = state.matchedLocation == '/splash';
      final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (status == AuthStatus.unknown) {
        return isSplash ? null : '/splash';
      }
      if (status == AuthStatus.unauthenticated) {
        return isAuthRoute ? null : '/login';
      }
      // authenticated
      if (isSplash || isAuthRoute) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
    ],
  );
});

class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(this._ref) {
    _ref.listen(authControllerProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;
}
