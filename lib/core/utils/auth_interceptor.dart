import 'package:dio/dio.dart';
import 'package:test_flutter/core/utils/storage_helper.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._dio);

  final Dio _dio;
  static const _retriedKey = 'retriedOnce';

  bool _isAuthPath(String path) =>
      path.contains('/auth/login') || path.contains('/auth/refresh');

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Jangan pasang token untuk request yang jelas-jelas auth/skipAuth
    final skipAuth =
        options.extra['skipAuth'] == true || _isAuthPath(options.path);
    if (!skipAuth) {
      final token = await StorageHelper.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final req = err.requestOptions;
    final is401 = err.response?.statusCode == 401;

    // Kalau bukan 401, atau ini endpoint auth, atau sudah pernah diretry -> teruskan error
    if (!is401 || _isAuthPath(req.path) || (req.extra[_retriedKey] == true)) {
      handler.next(err);
      return;
    }

    // Tandai supaya tidak retry lebih dari sekali
    req.extra[_retriedKey] = true;

    try {
      // 1) Coba refresh token
      final newAccessToken = await _refreshToken();
      if (newAccessToken == null || newAccessToken.isEmpty) {
        // refresh gagal -> anggap unauthenticated
        return handler.reject(_unauthenticated(req));
      }

      // 2) Simpan token baru
      await StorageHelper.saveToken(newAccessToken);

      // 3) Ulangi request asli dengan token baru
      final newHeaders = Map<String, dynamic>.from(req.headers)
        ..['Authorization'] = 'Bearer $newAccessToken';

      final response = await _dio.request<dynamic>(
        req.path,
        data: req.data,
        queryParameters: req.queryParameters,
        options: Options(
          method: req.method,
          headers: newHeaders,
          responseType: req.responseType,
          contentType: req.contentType,
          receiveTimeout: req.receiveTimeout,
          sendTimeout: req.sendTimeout,
          followRedirects: req.followRedirects,
          validateStatus: req.validateStatus,
          receiveDataWhenStatusError: req.receiveDataWhenStatusError,
        ),
        cancelToken: req.cancelToken,
        onSendProgress: req.onSendProgress,
        onReceiveProgress: req.onReceiveProgress,
      );

      return handler.resolve(response);
    } catch (_) {
      // kalau ada error saat refresh/retry -> unauthenticated
      return handler.reject(_unauthenticated(req));
    }
  }

  Future<String?> _refreshToken() async {
    // NOTE:
    // - Jika refresh perlu "refresh_token", ambil dari secure storage juga.
    // - Pastikan request refresh tidak ikut Authorization lama.
    try {
      final res = await _dio.post(
        '/auth/refresh',
        data: {}, // isi sesuai backend kamu
        options: Options(extra: {'skipAuth': true}),
      );
      // sesuaikan key access token sesuai respons backend
      return (res.data?['access_token'] as String?) ?? '';
    } catch (_) {
      return null;
    }
  }

  DioException _unauthenticated(RequestOptions req) {
    return DioException(
      requestOptions: req,
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: req,
        statusCode: 401,
        data: {'message': 'Unauthenticated'},
      ),
    );
  }
}
