import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../state/profile_state.dart';
import 'auth_storage.dart';

class ApiClient {
  ApiClient(
    this.baseUrl, {
    required AuthStorage authStorage,
    http.Client? httpClient,
  })  : _authStorage = authStorage,
        _http = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client _http;
  final AuthStorage _authStorage;

  Future<AuthSession> loginWithGoogle(String idToken) async {
    final uri = Uri.parse('$baseUrl/api/v1/auth/google');
    final response = await _http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_token': idToken}),
    );
    if (response.statusCode != 200) {
      throw HttpException('Erro ao autenticar', response);
    }
    final decoded = utf8.decode(response.bodyBytes);
    final data = jsonDecode(decoded) as Map<String, dynamic>;
    final accessToken = data['access_token']?.toString() ?? '';
    final refreshToken = data['refresh_token']?.toString() ?? '';
    if (accessToken.isEmpty || refreshToken.isEmpty) {
      throw Exception('Resposta inválida do servidor');
    }
    return AuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  Future<AuthSession> refreshTokens(String refreshToken) async {
    final uri = Uri.parse('$baseUrl/api/v1/auth/refresh');
    final response = await _http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': refreshToken}),
    );
    if (response.statusCode != 200) {
      throw HttpException('Erro ao atualizar token', response);
    }
    final decoded = utf8.decode(response.bodyBytes);
    final data = jsonDecode(decoded) as Map<String, dynamic>;
    final accessToken = data['access_token']?.toString() ?? '';
    final newRefreshToken = data['refresh_token']?.toString() ?? '';
    if (accessToken.isEmpty || newRefreshToken.isEmpty) {
      throw Exception('Resposta inválida do servidor');
    }
    return AuthSession(
      accessToken: accessToken,
      refreshToken: newRefreshToken,
    );
  }

  Future<Map<String, dynamic>> calculateProfile(ProfileFormState profile) async {
    final response = await _authorizedPost(
      '/api/v1/profile',
      body: jsonEncode(profile.toProfileRequestJson()),
    );
    if (response.statusCode != 200) {
      throw HttpException('Erro ao calcular perfil', response);
    }
    final decoded = utf8.decode(response.bodyBytes);
    return jsonDecode(decoded) as Map<String, dynamic>;
  }

  Future<ProfileFormState?> fetchProfile() async {
    final response = await _authorizedGet('/api/v1/me/profile');
    if (response.statusCode == 404) {
      return null;
    }
    if (response.statusCode != 200) {
      throw HttpException('Erro ao carregar perfil', response);
    }
    final decoded = utf8.decode(response.bodyBytes);
    final data = jsonDecode(decoded) as Map<String, dynamic>;
    return ProfileFormState.fromServer(data);
  }

  Future<ProfileFormState> saveProfile(ProfileFormState profile) async {
    final payload = {
      'profile': profile.toProfileRequestJson(),
      'training_preferences': profile.toPreferencesRequestJson(),
    };
    final response = await _authorizedPut(
      '/api/v1/me/profile',
      body: jsonEncode(payload),
    );
    if (response.statusCode != 200) {
      throw HttpException('Erro ao salvar perfil', response);
    }
    final decoded = utf8.decode(response.bodyBytes);
    final data = jsonDecode(decoded) as Map<String, dynamic>;
    return ProfileFormState.fromServer(data);
  }

  Future<AnalyzeResult> analyzeMenu({
    required String menuText,
    required String mealType,
  }) async {
    final payload = {
      'menu_text': menuText,
      'meal_type': mealType,
    };
    final startResponse = await _authorizedPost(
      '/api/v1/analyze',
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

    final deadline = DateTime.now().add(const Duration(seconds: 180));
    while (DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(seconds: 2));
      final statusResponse = await _authorizedGet('/api/v1/analyze/$jobId');
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

  Future<Map<String, String>> _authorizedHeaders() async {
    final session = await _authStorage.load();
    final accessToken = session?.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Usuário não autenticado');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
  }

  Future<http.Response> _authorizedGet(String path) async {
    return _authorizedRequest((headers) {
      final uri = Uri.parse('$baseUrl$path');
      return _http.get(uri, headers: headers);
    });
  }

  Future<http.Response> _authorizedPost(String path, {required String body}) async {
    return _authorizedRequest((headers) {
      final uri = Uri.parse('$baseUrl$path');
      return _http.post(uri, headers: headers, body: body);
    });
  }

  Future<http.Response> _authorizedPut(String path, {required String body}) async {
    return _authorizedRequest((headers) {
      final uri = Uri.parse('$baseUrl$path');
      return _http.put(uri, headers: headers, body: body);
    });
  }

  Future<http.Response> _authorizedRequest(
    Future<http.Response> Function(Map<String, String>) requestFn,
  ) async {
    var headers = await _authorizedHeaders();
    var response = await requestFn(headers);
    if (response.statusCode != 401) {
      return response;
    }
    final session = await _authStorage.load();
    final refreshToken = session?.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      return response;
    }
    final refreshed = await refreshTokens(refreshToken);
    await _authStorage.save(refreshed);
    headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${refreshed.accessToken}',
    };
    return requestFn(headers);
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
