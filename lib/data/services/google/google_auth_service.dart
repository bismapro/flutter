import 'dart:async';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:test_flutter/core/utils/api_client.dart';
import 'package:test_flutter/core/utils/logger.dart';

class GoogleAuthService {
  static bool _isInitialized = false;

  // REQUIRED: Initialize Google Sign-In
  static Future<void> initialize() async {
    if (!_isInitialized) {
      await GoogleSignIn.instance.initialize();
      _isInitialized = true;
    }
  }

  static Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Ensure initialization
      await initialize();

      // Use Completer for event-driven API
      final Completer<GoogleSignInAccount?> completer =
          Completer<GoogleSignInAccount?>();

      // Listen to authentication events
      late StreamSubscription<GoogleSignInAuthenticationEvent> subscription;
      subscription = GoogleSignIn.instance.authenticationEvents.listen((event) {
        if (event is GoogleSignInAuthenticationEventSignIn) {
          subscription.cancel();
          completer.complete(event.user);
        }
      });

      try {
        // Trigger authentication
        await GoogleSignIn.instance.authenticate();

        // Wait for result with timeout
        final GoogleSignInAccount? googleUser = await completer.future.timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            subscription.cancel();
            return null;
          },
        );

        if (googleUser == null) {
          throw Exception('Sign-in cancelled by user');
        }

        logger.fine('Google user authenticated: ${googleUser.email}');

        // Define required scopes
        const List<String> scopes = [
          'https://www.googleapis.com/auth/userinfo.email',
          'https://www.googleapis.com/auth/userinfo.profile',
        ];

        // Check if authorization already exists
        GoogleSignInClientAuthorization? authorization;
        try {
          authorization = await googleUser.authorizationClient
              .authorizationForScopes(scopes);
          logger.fine('Existing authorization found');
        } catch (e) {
          logger.warning('No existing authorization: $e');
        }

        // Request authorization if not exists
        if (authorization == null) {
          logger.fine('Requesting new authorization...');
          try {
            await googleUser.authorizationClient.authorizeScopes(scopes);
            // Wait a bit for authorization to complete
            await Future.delayed(const Duration(milliseconds: 500));

            // Try to get authorization again
            authorization = await googleUser.authorizationClient
                .authorizationForScopes(scopes);
          } catch (e) {
            logger.severe('Failed to authorize scopes: $e');
            throw Exception('Failed to authorize required scopes');
          }
        }

        if (authorization == null) {
          throw Exception('Authorization is null after requesting scopes');
        }

        // Get auth headers with access token
        Map<String, String>? headers;
        try {
          headers = await googleUser.authorizationClient.authorizationHeaders(
            scopes,
          );
          logger.fine('Authorization headers obtained');
        } catch (e) {
          logger.severe('Failed to get authorization headers: $e');
          throw Exception(
            'Failed to get authorization headers: ${e.toString()}',
          );
        }

        if (headers == null) {
          throw Exception('Authorization headers are null');
        }

        logger.fine('Headers: ${headers.keys.join(", ")}');

        // Try different header keys that might contain the token
        String? accessToken;

        if (headers.containsKey('authorization')) {
          accessToken = headers['authorization'];
        } else if (headers.containsKey('Authorization')) {
          accessToken = headers['Authorization'];
        } else {
          logger.severe('Available headers: $headers');
          throw Exception('No authorization header found in response');
        }

        // Extract token from Bearer format
        if (accessToken != null && accessToken.startsWith('Bearer ')) {
          accessToken = accessToken.substring(7);
        }

        if (accessToken == null || accessToken.isEmpty) {
          throw Exception('Access token is empty or null');
        }

        logger.fine(
          'Access token obtained: $accessToken...',
        );

        // Send to your Laravel API
        try {
          final response = await ApiClient.dio.post(
            '/login-google',
            data: {'token': accessToken},
          );

          if (response.statusCode == 200) {
            logger.fine('Laravel API response successful');
            logger.fine('Response data: ${response.data}');
            return response.data;
          } else {
            logger.severe('Laravel API error: ${response.statusCode}');
            logger.severe('Response data: ${response.data}');
            throw Exception(
              response.data['message'] ?? 'Authentication failed',
            );
          }
        } on DioException catch (e) {
          logger.severe('DioException: ${e.type}');
          logger.severe('Status code: ${e.response?.statusCode}');
          logger.severe('Response data: ${e.response?.data}');

          // Extract error message from Laravel response
          String errorMessage = 'Authentication failed';

          if (e.response?.data != null) {
            final data = e.response!.data;
            if (data is Map) {
              errorMessage =
                  data['message'] ?? data['error'] ?? 'Server error occurred';

              // Log detailed error for debugging
              if (data['errors'] != null) {
                logger.severe('Validation errors: ${data['errors']}');
              }
              if (data['trace'] != null && data['trace'] is String) {
                // Log first line of trace for debugging
                final trace = data['trace'] as String;
                final firstLine = trace.split('\n').first;
                logger.severe('Error trace: $firstLine');
              }
            } else if (data is String) {
              errorMessage = data;
            }
          }

          throw Exception(errorMessage);
        }
      } catch (e) {
        subscription.cancel();
        logger.severe('Error during Google sign-in: $e');
        rethrow;
      }
    } on GoogleSignInException catch (e) {
      logger.severe('GoogleSignInException: ${e.code} - ${e.description}');
      String errorMessage = switch (e.code) {
        GoogleSignInExceptionCode.canceled => 'Sign-in cancelled',
        // GoogleSignInExceptionCode.networkError => 'Network error occurred',
        GoogleSignInExceptionCode.unknownError => 'Unknown error occurred',
        _ => 'Google Sign-In error: ${e.description}',
      };
      throw Exception(errorMessage);
    } catch (e) {
      logger.severe('Unexpected error: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Authentication error: ${e.toString()}');
    }
  }

  static Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.disconnect();
      logger.fine('Google sign-out successful');
    } catch (e) {
      logger.warning('Error during sign-out: $e');
    }
  }
}
