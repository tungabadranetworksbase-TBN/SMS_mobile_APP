import '../../../../core/config/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../models/batch_dto.dart';

class BatchesApiService {
  final ApiClient _apiClient;

  BatchesApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<ApiResponse<List<BatchDto>>> fetchMyBatches() {
    return _apiClient.get<List<BatchDto>>(
      ApiEndpoints.myBatches,
      fromJson: BatchDto.listFrom,
    );
  }

  Future<ApiResponse<List<BatchDto>>> fetchAvailableBatches() {
    return _apiClient.get<List<BatchDto>>(
      ApiEndpoints.availableBatches,
      fromJson: BatchDto.listFrom,
    );
  }

  Future<ApiResponse<void>> joinBatch(String id) {
    return _apiClient.post<void>(
      ApiEndpoints.withParams(ApiEndpoints.joinBatch, {'id': id}),
    );
  }
}
