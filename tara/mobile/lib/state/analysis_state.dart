import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/api_client.dart';
import 'profile_state.dart';

final apiBaseUrlProvider = Provider<String>((ref) {
  return 'http://10.0.2.2:8000';
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final baseUrl = ref.watch(apiBaseUrlProvider);
  return ApiClient(baseUrl);
});

class AnalysisController extends StateNotifier<AsyncValue<AnalyzeResult?>> {
  AnalysisController(this._api) : super(const AsyncValue.data(null));

  final ApiClient _api;

  Future<void> analyze({
    required ProfileFormState profile,
    required String menuText,
    required String mealType,
  }) async {
    if (!profile.isComplete) {
      state = AsyncValue.error('Perfil incompleto', StackTrace.current);
      return;
    }
    if (menuText.trim().isEmpty) {
      state = AsyncValue.error('Informe o cardápio', StackTrace.current);
      return;
    }
    state = const AsyncValue.loading();
    try {
      final result = await _api.analyzeMenu(
        profile: profile,
        menuText: menuText,
        mealType: mealType,
      );
      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final analysisControllerProvider =
    StateNotifierProvider<AnalysisController, AsyncValue<AnalyzeResult?>>(
  (ref) => AnalysisController(ref.read(apiClientProvider)),
);
