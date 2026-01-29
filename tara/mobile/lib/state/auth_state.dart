import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../services/api_client.dart';
import '../services/api_client_provider.dart';
import '../services/auth_storage.dart';

const _googleWebClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');

class AuthController extends StateNotifier<AsyncValue<AuthSession?>> {
  AuthController(this._storage, this._api)
      : super(const AsyncValue.loading()) {
    _load();
  }

  final AuthStorage _storage;
  final ApiClient _api;

  Future<void> _load() async {
    final session = await _storage.load();
    state = AsyncValue.data(session);
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      if (_googleWebClientId.isEmpty) {
        throw Exception('GOOGLE_WEB_CLIENT_ID não configurado.');
      }
      final googleSignIn = GoogleSignIn(
        scopes: const ['email', 'profile'],
        serverClientId: _googleWebClientId,
      );
      final account = await googleSignIn.signIn();
      if (account == null) {
        state = const AsyncValue.data(null);
        return;
      }
      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw Exception('ID token não disponível.');
      }
      final session = await _api.loginWithGoogle(idToken);
      await _storage.save(session);
      state = AsyncValue.data(session);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> signOut() async {
    await _storage.clear();
    state = const AsyncValue.data(null);
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<AuthSession?>>(
  (ref) => AuthController(
    ref.read(authStorageProvider),
    ref.read(apiClientProvider),
  ),
);
