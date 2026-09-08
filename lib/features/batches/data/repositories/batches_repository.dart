import '../../../../core/demo/demo_mode.dart';
import '../../../../core/network/api_exception.dart';
import '../models/batch_dto.dart';
import '../services/batches_api_service.dart';

class BatchesRepository {
  final BatchesApiService _apiService;

  BatchesRepository({required BatchesApiService apiService})
    : _apiService = apiService;

  Future<List<BatchDto>> getMyBatches() async {
    if (DemoMode().isActive) return const [];
    final response = await _apiService.fetchMyBatches();
    if (response.success && response.data != null) return response.data!;
    throw ApiException(message: response.message ?? 'Failed to load batches');
  }

  Future<List<BatchDto>> getAvailableBatches() async {
    if (DemoMode().isActive) return const [];
    final response = await _apiService.fetchAvailableBatches();
    if (response.success && response.data != null) return response.data!;
    throw ApiException(
      message: response.message ?? 'Failed to load available batches',
    );
  }

  Future<void> joinBatch(String id) async {
    if (DemoMode().isActive) {
      throw const ApiException(message: 'Joining is disabled in demo mode.');
    }
    final response = await _apiService.joinBatch(id);
    if (!response.success) {
      throw ApiException(message: response.message ?? 'Could not join batch');
    }
  }
}
