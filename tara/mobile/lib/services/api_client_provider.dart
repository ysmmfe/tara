import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';
import 'auth_storage.dart';

final apiBaseUrlProvider = Provider<String>((ref) {
  const url = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://tara-ukju.onrender.com',
  );
  return url;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final baseUrl = ref.watch(apiBaseUrlProvider);
  final authStorage = ref.watch(authStorageProvider);
  return ApiClient(baseUrl, authStorage: authStorage);
});
