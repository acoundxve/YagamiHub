import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/api/token_storage.dart';
import 'auth_repository.dart';
import 'auth_user.dart';
import 'tenant.dart';

final tokenStorageProvider = Provider((ref) => TokenStorage());

final apiClientProvider = Provider((ref) => ApiClient(ref.watch(tokenStorageProvider)));

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(ref.watch(apiClientProvider), ref.watch(tokenStorageProvider)),
);

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  const AuthState({required this.status, this.me, this.tenant});

  final AuthStatus status;
  final AuthUser? me;
  final Tenant? tenant;

  AuthState copyWith({AuthStatus? status, AuthUser? me, Tenant? tenant}) => AuthState(
        status: status ?? this.status,
        me: me ?? this.me,
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
    await _loadSession();
  }

  Future<void> _loadSession() async {
    try {
      final me = await _repository.fetchMe();
      Tenant? tenant;
      if (me.role == UserRole.owner || me.role == UserRole.employee) {
        tenant = await _repository.fetchMyTenant();
      }
      state = state.copyWith(status: AuthStatus.authenticated, me: me, tenant: tenant);
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
      await _loadSession();
      return null;
    } catch (error) {
      return error.toString();
    }
  }

  Future<String?> login({required String email, required String password}) async {
    try {
      await _repository.login(email: email, password: password);
      await _loadSession();
      return null;
    } catch (error) {
      return error.toString();
    }
  }

  Future<void> updateBusiness({
    required String businessName,
    String? businessType,
    bool? isPublished,
  }) async {
    final tenant = await _repository.updateBusiness(
      businessName: businessName,
      businessType: businessType,
      isPublished: isPublished,
    );
    state = state.copyWith(tenant: tenant);
  }

  Future<void> updateProfile({String? email, String? phone}) async {
    final me = await _repository.updateProfile(email: email, phone: phone);
    state = state.copyWith(me: me);
  }

  Future<void> changePassword({required String currentPassword, required String newPassword}) {
    return _repository.changePassword(currentPassword: currentPassword, newPassword: newPassword);
  }

  Future<void> logout() async {
    await _repository.logout();
    state = state.copyWith(status: AuthStatus.unauthenticated);
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(ref.watch(authRepositoryProvider)),
);
