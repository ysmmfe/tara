import 'dart:convert';

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
    final uri = Uri.parse('$baseUrl/api/v1/analyze');
    final payload = {
      'profile': profile.toRequestJson(),
      'menu_text': menuText,
      'meal_type': mealType,
    };
    final response = await _http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (response.statusCode != 200) {
      throw HttpException('Erro ao analisar cardápio', response);
    }
    final decoded = utf8.decode(response.bodyBytes);
    final data = jsonDecode(decoded) as Map<String, dynamic>;
    return AnalyzeResult.fromJson(data);
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
