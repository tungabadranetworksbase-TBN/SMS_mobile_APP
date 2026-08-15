import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_exception.dart';
import '../data/models/profile_dto.dart';
import '../data/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return locator<ProfileRepository>();
});

final profileProvider = FutureProvider<ProfileDto>((ref) {
  return ref.read(profileRepositoryProvider).getProfile();
});

class ProfileController extends StateNotifier<AsyncValue<void>> {
  final ProfileRepository _repository;
  final Ref _ref;

  ProfileController({required ProfileRepository repository, required Ref ref})
      : _repository = repository,
        _ref = ref,
        super(const AsyncValue.data(null));

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateProfile(data);
      _ref.invalidate(profileProvider); // Refresh the profile data
      state = const AsyncValue.data(null);
      return true;
    } on ApiException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    } catch (e) {
      state = AsyncValue.error(const ApiException.unknown(), StackTrace.current);
      return false;
    }
  }

  Future<bool> uploadAvatar(String filePath) async {
    state = const AsyncValue.loading();
    try {
      await _repository.uploadAvatar(filePath);
      _ref.invalidate(profileProvider);
      state = const AsyncValue.data(null);
      return true;
    } on ApiException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    } catch (e) {
      state = AsyncValue.error(const ApiException.unknown(), StackTrace.current);
      return false;
    }
  }
}

final profileControllerProvider = StateNotifierProvider<ProfileController, AsyncValue<void>>((ref) {
  return ProfileController(repository: ref.watch(profileRepositoryProvider), ref: ref);
});
