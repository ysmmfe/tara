import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;

import '../state/profile_state.dart';

class ApiClient {
  ApiClient(this.baseUrl, {http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client _http;

  Future<Map<String, dynamic>> calculateProfile(ProfileFormState profile) async {
    final uri = Uri.parse('$baseUrl/api/v1/profile');
    final response = await _http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(profile.toRequestJson()),
    );
    if (response.statusCode != 200) {
      throw HttpException('Erro ao calcular perfil', response);
    }
    final decoded = utf8.decode(response.bodyBytes);
    return jsonDecode(decoded) as Map<String, dynamic>;
  }

  Future<AnalyzeResult> analyzeMenu({
    required ProfileFormState profile,
    required String menuText,
    required String mealType,
  }) async {
    final startUri = Uri.parse('$baseUrl/api/v1/analyze');
    final payload = {
      'profile': profile.toRequestJson(),
      'menu_text': menuText,
      'meal_type': mealType,
    };
    final startResponse = await _http.post(
      startUri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (startResponse.statusCode != 200) {
      throw HttpException('Erro ao iniciar análise', startResponse);
    }
    final startDecoded = utf8.decode(startResponse.bodyBytes);
    final startData = jsonDecode(startDecoded) as Map<String, dynamic>;
    final jobId = startData['job_id']?.toString();
    if (jobId == null || jobId.isEmpty) {
      throw Exception('Resposta inválida do servidor');
    }

    final deadline = DateTime.now().add(const Duration(minutes: 2));
    while (DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(seconds: 2));
      final statusUri = Uri.parse('$baseUrl/api/v1/analyze/$jobId');
      final statusResponse = await _http.get(statusUri);
      if (statusResponse.statusCode != 200) {
        throw HttpException('Erro ao consultar análise', statusResponse);
      }
      final statusDecoded = utf8.decode(statusResponse.bodyBytes);
      final statusData = jsonDecode(statusDecoded) as Map<String, dynamic>;
      final status = statusData['status']?.toString();
      if (status == 'done') {
        final result = statusData['result'];
        if (result is Map<String, dynamic>) {
          return AnalyzeResult.fromJson(result);
        }
        throw Exception('Resultado inválido da análise');
      }
      if (status == 'error') {
        final error = statusData['error']?.toString() ?? 'Erro desconhecido';
        throw Exception(error);
      }
    }
    throw TimeoutException('Tempo limite ao aguardar análise');
  }
}

class HttpException implements Exception {
  HttpException(this.message, this.response);

  final String message;
  final http.Response response;

  @override
  String toString() => '$message (${response.statusCode})';
}

class AnalyzeResult {
  AnalyzeResult({required this.profile, required this.recommendation});

  final Map<String, dynamic> profile;
  final dynamic recommendation;

  String get recommendationPretty {
    return const JsonEncoder.withIndent('  ').convert(recommendation);
  }

  factory AnalyzeResult.fromJson(Map<String, dynamic> json) {
    return AnalyzeResult(
      profile: (json['profile'] as Map<String, dynamic>?) ?? {},
      recommendation: json['recommendation'],
    );
  }
}
