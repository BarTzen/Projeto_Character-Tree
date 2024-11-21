import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class CacheService {
  final SharedPreferences _prefs;
  static const String userKey = 'cached_user'; // Corrigido para lowerCamelCase

  CacheService(this._prefs);

  Future<void> cacheUserData(UserModel user) async {
    await _prefs.setString(userKey, user.toJson());
  }

  UserModel? getCachedUser() {
    final userData = _prefs.getString(userKey);
    if (userData != null) {
      return UserModel.fromJson(userData);
    }
    return null;
  }

  Future<void> clearCache() async {
    await _prefs.clear();
  }
}
