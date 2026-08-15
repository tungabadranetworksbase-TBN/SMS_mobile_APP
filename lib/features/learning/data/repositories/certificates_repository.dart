import '../../../../core/demo/demo_mode.dart';
import '../models/certificate_dto.dart';
import '../services/certificates_api_service.dart';

class CertificatesRepository {
  final CertificatesApiService _apiService;

  CertificatesRepository({required CertificatesApiService apiService})
      : _apiService = apiService;

  Future<List<CertificateDto>> getCertificates() async {
    if (DemoMode().isActive) {
      return [];
    }
    try {
      final response = await _apiService.getCertificates();
      if (response.success && response.data != null) {
        return response.data!;
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}

