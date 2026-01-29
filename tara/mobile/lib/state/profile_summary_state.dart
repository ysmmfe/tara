import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/api_client_provider.dart';
import 'profile_state.dart';

final profileSummaryProvider =
    FutureProvider<Map<String, dynamic>?>((ref) async {
  final profile = ref.watch(profileControllerProvider);
  if (!profile.isComplete) {
    return null;
  }
  final apiClient = ref.watch(apiClientProvider);
  return apiClient.calculateProfile(profile);
});
