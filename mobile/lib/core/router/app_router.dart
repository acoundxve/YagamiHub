import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/account/business_screen.dart';
import '../../features/account/profile_screen.dart';
import '../../features/admin/super_admin_screen.dart';
import '../../features/auth/auth_providers.dart';
import '../../features/auth/auth_user.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/invoices/invoice_form_screen.dart';
import '../../features/invoices/invoices_list_screen.dart';
import '../../features/products/product.dart';
import '../../features/products/product_form_screen.dart';
import '../../features/products/products_list_screen.dart';
import '../../features/reports/reports_screen.dart';
import '../../features/splash/splash_screen.dart';

const _ownerOnlyPrefixes = ['/dashboard', '/products', '/invoices', '/reports', '/business'];

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: _AuthStateListenable(ref),
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final status = authState.status;
      final location = state.matchedLocation;
      final isSplash = location == '/splash';
      final isAuthRoute = location == '/login' || location == '/register';

      if (status == AuthStatus.unknown) {
        return isSplash ? null : '/splash';
      }
      if (status == AuthStatus.unauthenticated) {
        return isAuthRoute ? null : '/login';
      }

      // authenticated
      final isSuperAdmin = authState.me?.role == UserRole.superAdmin;
      final homeRoute = isSuperAdmin ? '/admin' : '/dashboard';

      if (isSplash || isAuthRoute) return homeRoute;
      if (isSuperAdmin && _ownerOnlyPrefixes.any((p) => location.startsWith(p))) return homeRoute;
      if (!isSuperAdmin && location == '/admin') return homeRoute;
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
      GoRoute(path: '/admin', builder: (context, state) => const SuperAdminScreen()),
      GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      GoRoute(path: '/business', builder: (context, state) => const BusinessScreen()),
      GoRoute(path: '/products', builder: (context, state) => const ProductsListScreen()),
      GoRoute(path: '/products/new', builder: (context, state) => const ProductFormScreen()),
      GoRoute(
        path: '/products/:id/edit',
        builder: (context, state) => ProductFormScreen(existingProduct: state.extra as Product?),
      ),
      GoRoute(path: '/invoices', builder: (context, state) => const InvoicesListScreen()),
      GoRoute(path: '/invoices/new', builder: (context, state) => const InvoiceFormScreen()),
      GoRoute(path: '/reports', builder: (context, state) => const ReportsScreen()),
    ],
  );
});

class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(this._ref) {
    _ref.listen(authControllerProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;
}
