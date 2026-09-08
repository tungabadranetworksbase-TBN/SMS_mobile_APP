import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_exception.dart';
import '../data/models/assessment_dto.dart';
import '../data/repositories/assessments_repository.dart';

final assessmentsRepositoryProvider = Provider<AssessmentsRepository>((ref) {
  return locator<AssessmentsRepository>();
});

final assessmentProvider = FutureProvider.family<AssessmentDto, String>((
  ref,
  id,
) {
  return ref.read(assessmentsRepositoryProvider).getAssessment(id);
});

class AssessmentController extends StateNotifier<AsyncValue<void>> {
  final AssessmentsRepository _repository;

  AssessmentController({required AssessmentsRepository repository})
    : _repository = repository,
      super(const AsyncValue.data(null));

  Future<bool> submitAssessment(
    String id,
    Map<String, List<int>> answers,
  ) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.submitAssessment(id, answers);
      state = const AsyncValue.data(null);
      return result != null;
    } on ApiException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    } catch (e) {
      state = AsyncValue.error(
        const ApiException.unknown(),
        StackTrace.current,
      );
      return false;
    }
  }
}

final assessmentControllerProvider =
    StateNotifierProvider<AssessmentController, AsyncValue<void>>((ref) {
      return AssessmentController(
        repository: ref.watch(assessmentsRepositoryProvider),
      );
    });
