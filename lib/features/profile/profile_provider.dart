import 'package:flutter_riverpod/legacy.dart';
import 'package:test_flutter/core/utils/logger.dart';
import 'package:test_flutter/core/utils/storage_helper.dart';
import 'package:test_flutter/features/profile/profile_service.dart';

enum ProfileState { initial, loading, loaded, error }

class ProfileStateNotifier extends StateNotifier<Map<String, dynamic>> {
  ProfileStateNotifier()
    : super({'status': ProfileState.initial, 'profile': null, 'error': null});

  // Get user profile from API
  Future<void> getProfile() async {
    try {
      state = {...state, 'status': ProfileState.loading, 'error': null};

      final response = await ProfileService.getProfile();
      final profileData = response['data'];

      logger.fine('Response Data: ' + response.toString());

      if (profileData != null) {
        // Update local storage with fresh profile data
        await StorageHelper.saveUser({
          "id": profileData['id'].toString(),
          "name": profileData['name'].toString(),
          "email": profileData['email'].toString(),
          "role": profileData['role']?.toString() ?? '',
          "phone": profileData['phone']?.toString() ?? '',
          "address": profileData['address']?.toString() ?? '',
        });

        state = {
          'status': ProfileState.loaded,
          'profile': profileData,
          'error': null,
        };
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

      state = {
        'status': ProfileState.error,
        'profile': state['profile'],
        'error': errorMessage,
      };
    }
  }

  // Update user profile
  Future<void> updateProfile({
    required String name,
    required String email,
    String? phone,
    String? address,
  }) async {
    try {
      state = {...state, 'status': ProfileState.loading, 'error': null};

      final response = await ProfileService.updateProfile(
        name: name,
        email: email,
        phone: phone,
        address: address,
      );

      final profileData = response['data'];

      if (profileData != null) {
        // Update local storage with updated profile data
        await StorageHelper.saveUser({
          "id": profileData['id'].toString(),
          "name": profileData['name'].toString(),
          "email": profileData['email'].toString(),
          "role": profileData['role']?.toString() ?? '',
          "phone": profileData['phone']?.toString() ?? '',
          "address": profileData['address']?.toString() ?? '',
        });

        state = {
          'status': ProfileState.loaded,
          'profile': profileData,
          'error': null,
        };
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

      state = {
        'status': ProfileState.error,
        'profile': state['profile'],
        'error': errorMessage,
      };
    }
  }

  // Load profile from local storage
  Future<void> loadFromStorage() async {
    try {
      final user = await StorageHelper.getUser();
      if (user != null) {
        state = {'status': ProfileState.loaded, 'profile': user, 'error': null};
      }

      logger.fine('Response Data Load From Storage: ' + user.toString());
    } catch (e) {
      state = {
        'status': ProfileState.error,
        'profile': null,
        'error': 'Failed to load profile from storage',
      };
    }
  }

  void clearError() {
    state = {...state, 'error': null};
  }
}

// Provider that can be used throughout the app
final profileProvider =
    StateNotifierProvider<ProfileStateNotifier, Map<String, dynamic>>((ref) {
      return ProfileStateNotifier();
    });
