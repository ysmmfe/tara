import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ProfileStorage {
  const ProfileStorage();

  static const _key = 'tara_profile_v1';

  Future<Map<String, dynamic>?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final data = jsonDecode(raw);
    if (data is! Map<String, dynamic>) {
      return null;
    }
    return data;
  }

  Future<void> save(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(data);
    await prefs.setString(_key, raw);
  }
}
