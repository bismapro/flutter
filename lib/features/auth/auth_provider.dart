import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:test_flutter/core/utils/logger.dart';
import 'package:test_flutter/core/utils/storage_helper.dart';
import 'package:test_flutter/data/services/google/google_auth_service.dart';
import 'package:test_flutter/features/auth/auth_service.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
  isRegistered,
}

class AuthStateNotifier extends StateNotifier<Map<String, dynamic>> {
  AuthStateNotifier()
    : super({'status': AuthState.initial, 'user': null, 'error': null});

  // --- Helpers --------------------------------------------------------------

  /// Normalize any token value coming from the backend to a String.
  String? _normalizeToken(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) return raw;
    // Many backends return ints or other primitive types
    return raw.toString();
  }

  // --- Public API -----------------------------------------------------------

  // Check if user is already logged in
  Future<void> checkAuthStatus() async {
    state = {...state, 'status': AuthState.loading};
    logger.fine('Checking auth status...');

    try {
      final data = await _getUserWithSingleRefresh();
      if (data != null) {
        // Successfully fetched from server
        state = {
          'status': AuthState.authenticated,
          'user': data,
          'error': null,
        };
        // Sync to storage to stay up to date
        await StorageHelper.saveUser(data);
        return;
      }

      // Reached here => couldn't get user from server (401 after refresh / null)
      await _fallbackToStorageOrUnauth();
    } on DioException catch (e) {
      logger.warning('Network/Dio error: ${e.type} ${e.response?.statusCode}');
      // Offline/timeouts or other errors → fallback
      await _fallbackToStorageOrUnauth();
    } catch (e) {
      logger.warning('Unknown error: $e');
      await _fallbackToStorageOrUnauth(error: 'Failed to check auth status');
    }
  }

  /// Try GET /current-user once; if 401 → refresh token once → retry.
  /// return: user map on success, or null on failure.
  Future<Map<String, dynamic>?> _getUserWithSingleRefresh() async {
    try {
      final resp = await AuthService.getCurrentUser();
      final data = resp['data'] as Map<String, dynamic>?;
      if (data != null) return data['user'];
      return null;
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 401) {
        logger.fine('Access token 401 → try refresh once');
        try {
          final r = await AuthService.refresh(); // ensure this endpoint exists
          final newAccess = _normalizeToken(r['token'] ?? r['access_token']);

          if (newAccess == null || newAccess.isEmpty) {
            logger.fine('Refresh failed: empty access token');
            return null;
          }

          // Save the new token
          await StorageHelper.saveToken(newAccess);

          // Retry get current user
          final retry = await AuthService.getCurrentUser();
          final data2 = retry['data'] as Map<String, dynamic>?;
          return data2?['user'];
        } catch (e2) {
          logger.warning('Refresh attempt failed: $e2');
          return null; // caller will fallback to storage
        }
      }
      rethrow; // errors other than 401: let caller fallback
    }
  }

  /// Fallback to storage (offline mode) or set unauthenticated when no data.
  Future<void> _fallbackToStorageOrUnauth({String? error}) async {
    logger.warning('Fallback to local storage...');

    final localUser = await StorageHelper.getUser();
    final localToken = await StorageHelper.getToken();

    if (localUser != null && localToken != null && localToken.isNotEmpty) {
      state = {
        'status': AuthState.authenticated,
        'user': localUser,
        'error': null,
      };
    } else {
      state = {
        'status': AuthState.unauthenticated,
        'user': null,
        'error': error,
      };
    }
  }

  // Login
  Future<void> login(String email, String password) async {
    try {
      state = {...state, 'status': AuthState.loading, 'error': null};

      // Call API
      final response = await AuthService.login(email, password);
      final data = response['data'];

      logger.fine('Login response: $data');

      if (data == null) {
        throw Exception('Invalid response from server');
      }

      // Save token (accept either "token" or "access_token"; normalize to String)
      final tokenStr = _normalizeToken(data['token'] ?? data['access_token']);
      if (tokenStr == null || tokenStr.isEmpty) {
        throw Exception('No token received from server');
      }
      await StorageHelper.saveToken(tokenStr);
      logger.fine('Access Token saved: $tokenStr');

      // Save user data
      if (data['user'] != null) {
        final user = data['user'];
        await StorageHelper.saveUser({
          "id": user['id']?.toString() ?? '',
          "name": user['name']?.toString() ?? '',
          "email": user['email']?.toString() ?? '',
          "role": user['role']?.toString() ?? '',
          "phone": user['phone']?.toString() ?? '',
        });

        logger.fine(
          'User data saved - ID: ${user['id']}, Name: ${user['name']}, '
          'Email: ${user['email']}, Role: ${user['role']}',
        );
      }

      // Update state to authenticated
      state = {
        'status': AuthState.authenticated,
        'user': data['user'],
        'error': null,
      };

      logger.fine('Authentication state set to authenticated');
    } catch (e) {
      logger.fine('Login error: ${e.toString()}');

      // Extract error message from Exception
      String errorMessage;
      if (e is Exception) {
        // remove 'Exception: ' prefix for cleaner UI
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      } else {
        errorMessage = e.toString();
      }

      // Update state with formatted error
      state = {'status': AuthState.error, 'user': null, 'error': errorMessage};
    }
  }

  // Login
  Future<void> loginWithGoogle() async {
    try {
      state = {...state, 'status': AuthState.loading, 'error': null};

      // Call Google Sign-In service
      final response = await GoogleAuthService.signInWithGoogle();
      final data = response['data'];

      logger.fine('Google login response: $data');

      if (data == null) {
        throw Exception('Invalid response from server');
      }

      // Save token
      final tokenStr = _normalizeToken(data['token'] ?? data['access_token']);
      if (tokenStr == null || tokenStr.isEmpty) {
        throw Exception('No token received from server');
      }
      await StorageHelper.saveToken(tokenStr);
      logger.fine('Access Token saved: $tokenStr');

      // Save user data
      if (data['user'] != null) {
        final user = data['user'];
        await StorageHelper.saveUser({
          "id": user['id']?.toString() ?? '',
          "name": user['name']?.toString() ?? '',
          "email": user['email']?.toString() ?? '',
          "role": user['role']?.toString() ?? '',
          "phone": user['phone']?.toString() ?? '',
        });

        logger.fine(
          'User data saved - ID: ${user['id']}, Name: ${user['name']}, '
          'Email: ${user['email']}, Role: ${user['role']}',
        );
      }

      // Check if onboarding is required
      final requiresOnboarding = response['requires_onboarding'] ?? false;
      final message = response['message'] ?? 'Login successful';

      // Update state to authenticated
      state = {
        'status': AuthState.authenticated,
        'user': data['user'],
        'error': null,
        'message': message,
        'requires_onboarding': requiresOnboarding,
      };

      logger.fine('Authentication state set to authenticated');
    } catch (e) {
      logger.fine('Google login error: ${e.toString()}');

      String errorMessage;
      if (e is Exception) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      } else {
        errorMessage = e.toString();
      }

      state = {'status': AuthState.error, 'user': null, 'error': errorMessage};
    }
  }

  // Register
  Future<void> register(
    String name,
    String email,
    String password,
    String confirmationPassword,
  ) async {
    try {
      state = {...state, 'status': AuthState.loading, 'error': null};

      // Call API
      await AuthService.register(name, email, password, confirmationPassword);

      // Update state to registered (let UI navigate to login)
      state = {'status': AuthState.isRegistered, 'user': null, 'error': null};
    } catch (e) {
      String errorMessage;
      if (e is Exception) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      } else {
        errorMessage = e.toString();
      }

      state = {'status': AuthState.error, 'user': null, 'error': errorMessage};
    }
  }

  // Logout user
  Future<void> logout() async {
    state = {...state, 'status': AuthState.loading};

    try {
      // Call API
      final response = await AuthService.logout();

      if (response == true) {
        logger.fine('Logout successful on server');

        // Clear local data once
        await StorageHelper.clearUserData();

        // Update state to unauthenticated
        state = {
          'status': AuthState.unauthenticated,
          'user': null,
          'error': null,
        };
      } else {
        throw Exception('Logout failed');
      }
    } catch (e) {
      state = {
        'status': AuthState.error,
        'user': state['user'],
        'error': 'Failed to logout',
      };
    }
  }

  void clearError() {
    // Clear error state
    state = {...state, 'error': null};
  }
}

// Provider that can be used throughout the app
final authProvider =
    StateNotifierProvider<AuthStateNotifier, Map<String, dynamic>>((ref) {
      return AuthStateNotifier();
    });
