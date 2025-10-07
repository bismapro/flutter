import 'package:flutter_riverpod/legacy.dart';
import 'package:test_flutter/core/utils/logger.dart';
import 'package:test_flutter/core/utils/storage_helper.dart';
import 'package:test_flutter/features/profile/profile_service.dart';

enum ProfileState { initial, loading, loaded, error, success }

class ProfileStateNotifier extends StateNotifier<Map<String, dynamic>> {
  ProfileStateNotifier()
    : super({'status': ProfileState.initial, 'profile': null, 'error': null});

  // Update user profile
  Future<void> updateProfile(String name, String email, String? phone) async {
    try {
      state = {...state, 'status': ProfileState.loading, 'error': null};

      final response = await ProfileService.updateProfile(name, email, phone);

      final profileData = response['data'];

      logger.fine('Update Profile Response: $response');

      if (profileData != null) {
        // Update local storage with updated profile data
        await StorageHelper.saveUser({
          "id": profileData['id'].toString(),
          "name": profileData['name'].toString(),
          "email": profileData['email'].toString(),
          "role": profileData['role']?.toString() ?? '',
          "phone": profileData['phone']?.toString() ?? '',
        });

        state = {
          'status': ProfileState.success,
          'profile': profileData,
          'error': null,
        };

        logger.fine('Profile updated successfully');
      } else {
        throw Exception('Invalid response from server');
      }
    } catch (e) {
      String errorMessage;
      if (e is Exception) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      } else {
        errorMessage = e.toString();
      }

      logger.warning('Edit profile error: $errorMessage');

      state = {
        'status': ProfileState.error,
        'profile': state['profile'],
        'error': errorMessage,
      };
    }
  }

  // Update user password
  Future<void> editPassword(
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      state = {...state, 'status': ProfileState.loading, 'error': null};

      final response = await ProfileService.updatePassword(
        currentPassword,
        newPassword,
        confirmPassword,
      );

      logger.fine('Update Password Response: $response');

      // Password change usually doesn't return user data, just success message
      state = {
        'status': ProfileState.success,
        'profile': state['profile'], // Keep current profile data
        'error': null,
      };

      logger.fine('Password updated successfully');
    } catch (e) {
      String errorMessage;
      if (e is Exception) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      } else {
        errorMessage = e.toString();
      }

      logger.warning('Edit password error: $errorMessage');

      state = {
        'status': ProfileState.error,
        'profile': state['profile'],
        'error': errorMessage,
      };
    }
  }

  Future<void> loadUser() async {
    try {
      state = {...state, 'status': ProfileState.loading, 'error': null};

      final user = await StorageHelper.getUser();

      if (user != null) {
        state = {'status': ProfileState.loaded, 'profile': user, 'error': null};
        logger.fine('User profile loaded from storage');
      } else {
        throw Exception('No user data found in storage');
      }
    } catch (e) {
      String errorMessage;
      if (e is Exception) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      } else {
        errorMessage = e.toString();
      }

      logger.warning('Load user error: $errorMessage');

      state = {
        'status': ProfileState.error,
        'profile': null,
        'error': errorMessage,
      };
    }
  }

  void clearError() {
    state = {...state, 'error': null};
  }

  void clearSuccess() {
    if (state['status'] == ProfileState.success) {
      state = {...state, 'status': ProfileState.initial};
    }
  }
}

// Provider that can be used throughout the app
final profileProvider =
    StateNotifierProvider<ProfileStateNotifier, Map<String, dynamic>>((ref) {
      return ProfileStateNotifier();
    });
