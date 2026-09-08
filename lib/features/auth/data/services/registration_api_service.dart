import 'package:dio/dio.dart';

import '../../../../core/config/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/json_value.dart';
import '../models/registration_status_dto.dart';

class RegistrationApiService {
  final ApiClient _apiClient;

  RegistrationApiService({required ApiClient apiClient})
    : _apiClient = apiClient;

  Future<ApiResponse<RegistrationStatusDto>> fetchStatus() {
    return _apiClient.get<RegistrationStatusDto>(
      ApiEndpoints.registrationStatus,
      fromJson: (json) => RegistrationStatusDto.fromJson(jsonMap(json)),
    );
  }

  Future<ApiResponse<void>> submitReceiptImage(String filePath) {
    return _apiClient.upload<void>(
      ApiEndpoints.registrationReceipt,
      formData: FormData.fromMap({
        'receipt': MultipartFile.fromFileSync(filePath),
      }),
    );
  }

  Future<ApiResponse<RegistrationCheckoutDto>> startCheckout(String origin) {
    return _apiClient.post<RegistrationCheckoutDto>(
      ApiEndpoints.registrationCheckout,
      headers: {'Origin': origin},
      fromJson: (json) => RegistrationCheckoutDto.fromJson(jsonMap(json)),
    );
  }

  Future<ApiResponse<void>> reportAbandoned() {
    return _apiClient.post<void>(ApiEndpoints.registrationAbandoned);
  }
}
