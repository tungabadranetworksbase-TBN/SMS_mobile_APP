import '../../../../core/config/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../models/certificate_dto.dart';

class CertificatesApiService {
  final ApiClient _apiClient;

  CertificatesApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<ApiResponse<List<CertificateDto>>> getCertificates() async {
    return _apiClient.get<List<CertificateDto>>(
      ApiEndpoints.certificates,
      fromJson: (json) {
        final list = json as List;
        return list.map((e) => CertificateDto.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
  }
}
