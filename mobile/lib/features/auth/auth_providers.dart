import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/api/token_storage.dart';
import 'auth_repository.dart';
import 'tenant.dart';

final tokenStorageProvider = Provider((ref) => TokenStorage());

final apiClientProvider = Provider((ref) => ApiClient(ref.watch(tokenStorageProvider)));

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(ref.watch(apiClientProvider), ref.watch(tokenStorageProvider)),
);

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  const AuthState({required this.status, this.tenant});

  final AuthStatus status;
  final Tenant? tenant;

  AuthState copyWith({AuthStatus? status, Tenant? tenant}) => AuthState(
        status: status ?? this.status,
        tenant: tenant ?? this.tenant,
      );

  static const initial = AuthState(status: AuthStatus.unknown);
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repository) : super(AuthState.initial) {
    _restoreSession();
  }

  final AuthRepository _repository;

  Future<void> _restoreSession() async {
    final hasToken = await _repository.hasStoredToken();
    if (!hasToken) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }
    await _loadTenant();
  }

  Future<void> _loadTenant() async {
    try {
      final tenant = await _repository.fetchMyTenant();
      state = state.copyWith(status: AuthStatus.authenticated, tenant: tenant);
    } catch (_) {
      await _repository.logout();
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<String?> register({
    required String businessName,
    required String email,
    required String password,
  }) async {
    try {
      await _repository.register(businessName: businessName, email: email, password: password);
      await _loadTenant();
      return null;
    } catch (error) {
      return error.toString();
    }
  }

  Future<String?> login({required String email, required String password}) async {
    try {
      await _repository.login(email: email, password: password);
      await _loadTenant();
      return null;
    } catch (error) {
      return error.toString();
    }
  }

  Future<void> updateBusinessName(String businessName) async {
    final tenant = await _repository.updateBusinessName(businessName);
    state = state.copyWith(tenant: tenant);
  }

  Future<void> logout() async {
    await _repository.logout();
    state = state.copyWith(status: AuthStatus.unauthenticated);
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(ref.watch(authRepositoryProvider)),
);
