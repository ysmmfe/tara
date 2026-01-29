import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/api_client.dart';
import '../services/api_client_provider.dart';

class AnalysisController extends StateNotifier<AsyncValue<AnalyzeResult?>> {
  AnalysisController(this._api) : super(const AsyncValue.data(null));

  final ApiClient _api;

  Future<void> analyze({
    required String menuText,
    required String mealType,
  }) async {
    if (menuText.trim().isEmpty) {
      state = AsyncValue.error('Informe o cardápio', StackTrace.current);
      return;
    }
    state = const AsyncValue.loading();
    try {
      final result = await _api.analyzeMenu(
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
