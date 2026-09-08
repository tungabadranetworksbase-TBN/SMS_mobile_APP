import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/service_locator.dart';
import '../data/models/batch_dto.dart';
import '../data/repositories/batches_repository.dart';

final batchesRepositoryProvider = Provider<BatchesRepository>((ref) {
  return locator<BatchesRepository>();
});

final myBatchesProvider = FutureProvider<List<BatchDto>>((ref) {
  return ref.read(batchesRepositoryProvider).getMyBatches();
});

final availableBatchesProvider = FutureProvider<List<BatchDto>>((ref) {
  return ref.read(batchesRepositoryProvider).getAvailableBatches();
});

/// Joins, then refreshes both lists — the batch moves from one to the other.
Future<void> joinBatch(WidgetRef ref, String id) async {
  await ref.read(batchesRepositoryProvider).joinBatch(id);
  ref.invalidate(myBatchesProvider);
  ref.invalidate(availableBatchesProvider);
}
