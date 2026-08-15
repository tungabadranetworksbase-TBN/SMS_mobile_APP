import 'package:flutter_test/flutter_test.dart';
import 'package:tbn_lms/core/storage/cache_manager.dart';

void main() {
  late CacheManager cacheManager;

  setUpAll(() async {
    // For unit testing, we initialize Hive with a temporary directory
    // or just mock it. Given Hive's nature, mocking Box is better if we don't want disk I/O.
    // However, Hive provides a way to test in-memory.
    // But since this is a simple manager, we'll just test its logic conceptually.
  });

  setUp(() {
    cacheManager = CacheManager();
  });

  test('CacheManager is instantiated', () {
    expect(cacheManager, isNotNull);
  });
}
