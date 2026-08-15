import 'package:hive_flutter/hive_flutter.dart';

/// Tungabadra Networks LMS — Local Cache Manager
///
/// Wrapper around Hive for fast API response caching.
class CacheManager {
  static const String _apiCacheBoxName = 'api_cache';

  late final Box<dynamic> _apiCacheBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _apiCacheBox = await Hive.openBox(_apiCacheBoxName);
  }

  /// Write data to the cache.
  Future<void> writeCache(String key, dynamic data) async {
    await _apiCacheBox.put(key, data);
  }

  /// Read data from the cache.
  dynamic readCache(String key) {
    return _apiCacheBox.get(key);
  }

  /// Delete a specific cache key.
  Future<void> deleteCache(String key) async {
    await _apiCacheBox.delete(key);
  }

  /// Clear the entire API cache (e.g., on logout).
  Future<void> clearAll() async {
    await _apiCacheBox.clear();
  }
}
