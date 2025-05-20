import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String cacheKey = 'youtube_cache';

  Future<void> saveCache(List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(items);
    await prefs.setString(cacheKey, jsonString);
  }

  Future<List<Map<String, dynamic>>?> getCache() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(cacheKey);
    if (jsonString == null) return null;
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.cast<Map<String, dynamic>>();
  }
}
