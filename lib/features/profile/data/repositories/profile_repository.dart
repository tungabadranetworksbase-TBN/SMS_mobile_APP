import '../../../../core/demo/demo_data.dart';
import '../../../../core/demo/demo_mode.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/managers/session_manager.dart';
import '../models/profile_dto.dart';
import '../services/profile_api_service.dart';

class ProfileRepository {
  final ProfileApiService _apiService;
  final SessionManager _sessionManager;

  ProfileRepository({
    required ProfileApiService apiService,
    required SessionManager sessionManager,
  }) : _apiService = apiService,
       _sessionManager = sessionManager;

  Future<ProfileDto> getProfile() async {
    if (DemoMode().isActive) {
      return DemoData.getProfile(DemoMode().selectedRole);
    }
    try {
      final response = await _apiService.getProfile();
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw ApiException(message: response.message ?? 'Failed to load profile');
    } catch (e) {
      rethrow;
    }
  }

  Future<ProfileDto> updateProfile(Map<String, dynamic> data) async {
    if (DemoMode().isActive) {
      final currentRole = DemoMode().selectedRole;
      final updated = ProfileDto(
        id: 'stud-001',
        name: data['name'] ?? 'John Doe',
        email: data['email'] ?? 'john.doe@gmail.com',
        phone: data['phone'] ?? '+91 91234 56789',
        address: data['address'] ?? 'Indiranagar, Bangalore, Karnataka',
        role: currentRole,
        joinedAt: DateTime.now().subtract(const Duration(days: 45)),
      );
      await _sessionManager.saveSession(
        token: 'demo-token',
        userId: updated.id,
        userName: updated.name,
        userEmail: updated.email,
        userAvatar: updated.avatarUrl,
      );
      return updated;
    }
    try {
      final response = await _apiService.updateProfile(data);
      if (!response.success) {
        throw ApiException(
          message: response.message ?? 'Failed to update profile',
        );
      }
      final profile = await getProfile();
      final token = await _sessionManager.token;
      final refreshToken = await _sessionManager.refreshToken;
      await _sessionManager.saveSession(
        token: token ?? '',
        refreshToken: refreshToken,
        userId: profile.id,
        userName: profile.name,
        userEmail: profile.email,
        userAvatar: profile.avatarUrl,
      );
      return profile;
    } catch (e) {
      rethrow;
    }
  }

  Future<ProfileDto> uploadAvatar(String filePath) async {
    if (DemoMode().isActive) {
      return DemoData.getProfile(DemoMode().selectedRole);
    }
    try {
      final response = await _apiService.uploadAvatar(filePath);
      if (response.success && response.data != null) {
        final profile = response.data!;
        final token = await _sessionManager.token;
        final refreshToken = await _sessionManager.refreshToken;

        await _sessionManager.saveSession(
          token: token ?? '',
          refreshToken: refreshToken,
          userId: profile.id,
          userName: profile.name,
          userEmail: profile.email,
          userAvatar: profile.avatarUrl,
        );
        return profile;
      }
      throw ApiException(
        message: response.message ?? 'Failed to upload avatar',
      );
    } catch (e) {
      rethrow;
    }
  }
}
