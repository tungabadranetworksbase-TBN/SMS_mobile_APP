import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_exception.dart';
import '../data/models/certificate_dto.dart';
import '../data/repositories/certificates_repository.dart';

final certificatesRepositoryProvider = Provider<CertificatesRepository>((ref) {
  return locator<CertificatesRepository>();
});

final certificatesProvider = StateNotifierProvider<CertificatesController, AsyncValue<List<CertificateDto>>>((ref) {
  return CertificatesController(repository: ref.watch(certificatesRepositoryProvider));
});

class CertificatesController extends StateNotifier<AsyncValue<List<CertificateDto>>> {
  final CertificatesRepository _repository;

  CertificatesController({required CertificatesRepository repository})
      : _repository = repository,
        super(const AsyncValue.loading()) {
    fetchCertificates();
  }

  Future<void> fetchCertificates() async {
    state = const AsyncValue.loading();
    try {
      final certificates = await _repository.getCertificates();
      state = AsyncValue.data(certificates);
    } on ApiException catch (e, st) {
      state = AsyncValue.error(e, st);
    } catch (e, st) {
      state = AsyncValue.error(ApiException(message: e.toString()), st);
    }
  }

  Future<void> refresh() async {
    await fetchCertificates();
  }
}
