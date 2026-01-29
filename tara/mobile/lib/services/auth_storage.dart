import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthSession {
  const AuthSession({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;
}

class AuthStorage {
  const AuthStorage(this._storage);

  static const _accessKey = 'tara_access_token';
  static const _refreshKey = 'tara_refresh_token';

  final FlutterSecureStorage _storage;

  Future<AuthSession?> load() async {
    final access = await _storage.read(key: _accessKey);
    final refresh = await _storage.read(key: _refreshKey);
    if (access == null || refresh == null) {
      return null;
    }
    return AuthSession(accessToken: access, refreshToken: refresh);
  }

  Future<void> save(AuthSession session) async {
    await _storage.write(key: _accessKey, value: session.accessToken);
    await _storage.write(key: _refreshKey, value: session.refreshToken);
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}

final authStorageProvider = Provider<AuthStorage>(
  (ref) => const AuthStorage(FlutterSecureStorage()),
);
