import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  static const String _settingsBox = 'settings';
  static const String _cacheBox = 'cache';
  static const String _userBox = 'user';

  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox(_settingsBox);
    await Hive.openBox(_cacheBox);
    await Hive.openBox(_userBox);
  }

  // Settings
  static Box get _settings => Hive.box(_settingsBox);
  
  static bool get isDarkMode => _settings.get('isDarkMode', defaultValue: false);
  static set isDarkMode(bool value) => _settings.put('isDarkMode', value);
  
  static String get language => _settings.get('language', defaultValue: 'en');
  static set language(String value) => _settings.put('language', value);
  
  static bool get notificationsEnabled => 
      _settings.get('notificationsEnabled', defaultValue: true);
  static set notificationsEnabled(bool value) => 
      _settings.put('notificationsEnabled', value);

  // User
  static Box get _user => Hive.box(_userBox);
  
  static String? get userId => _user.get('userId');
  static set userId(String? value) => _user.put('userId', value);
  
  static Map<String, dynamic>? get userData {
    final data = _user.get('userData');
    if (data != null) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }
  static set userData(Map<String, dynamic>? value) => 
      _user.put('userData', value);

  // Cache
  static Box get _cache => Hive.box(_cacheBox);
  
  static Future<void> cacheData(String key, dynamic value) async {
    await _cache.put(key, {
      'data': value,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static dynamic getCachedData(String key, {Duration? maxAge}) {
    final cached = _cache.get(key);
    if (cached == null) return null;
    
    if (maxAge != null) {
      final timestamp = DateTime.parse(cached['timestamp']);
      if (DateTime.now().difference(timestamp) > maxAge) {
        _cache.delete(key);
        return null;
      }
    }
    
    return cached['data'];
  }

  static Future<void> clearCache() async {
    await _cache.clear();
  }

  static Future<void> clearAll() async {
    await _settings.clear();
    await _cache.clear();
    await _user.clear();
  }
}

