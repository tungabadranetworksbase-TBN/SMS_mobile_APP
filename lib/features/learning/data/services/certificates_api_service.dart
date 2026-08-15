import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/unsupported_endpoint.dart';
import '../models/certificate_dto.dart';

class CertificatesApiService {
  /// Deliberately unstored: there is no certificates route to call yet. The
  /// parameter stays so the DI registration and constructor shape match every
  /// other API service, and so restoring the real call is a one-line change.
  CertificatesApiService({required ApiClient apiClient});

  /// The backend has no certificates module. The screen renders from demo
  /// fixtures until one exists.
  Future<ApiResponse<List<CertificateDto>>> getCertificates() async {
    throw unsupportedEndpoint('Certificates');
  }
}
