import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'package:flutter/foundation.dart';

class CacheService {
  final SharedPreferences _prefs;
  static const String userKey = 'cached_user';
  static const String characterKey = 'cached_characters';
  static const Duration cacheExpiration = Duration(hours: 24);

  CacheService(this._prefs);

  Future<void> cacheUserData(UserModel user) async {
    try {
      user.validate();
      await _prefs.setString(userKey, user.toJson());
    } catch (e) {
      throw Exception('Erro ao cachear dados do usuário: $e');
    }
  }

  UserModel? getCachedUser() {
    try {
      final userData = _prefs.getString(userKey);
      if (userData != null) {
        final user = UserModel.fromJson(userData);
        user.validate();
        return user;
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao recuperar usuário do cache: $e');
      return null;
    }
  }

  Future<void> clearCache() async {
    await _prefs.clear();
  }

  bool isCacheValid(String key) {
    final timestamp = _prefs.getInt('${key}_timestamp');
    if (timestamp == null) return false;

    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateTime.now().difference(cacheTime) < cacheExpiration;
  }
}
