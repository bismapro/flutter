import 'package:test_flutter/data/models/user/user.dart';

class GoogleAuthResponse {
  final String? message;
  final GoogleAuthData? data;
  final bool? requiresOnboarding;
  GoogleAuthResponse({this.message, this.data, this.requiresOnboarding});
  factory GoogleAuthResponse.fromJson(Map<String, dynamic> json) =>
      GoogleAuthResponse(
        message: json["message"],
        data: json["data"] == null
            ? null
            : GoogleAuthData.fromJson(json["data"]),
        requiresOnboarding: json["requires_onboarding"],
      );
}

class GoogleAuthData {
  final User? user;
  final String? token;
  GoogleAuthData({this.user, this.token});
  factory GoogleAuthData.fromJson(Map<String, dynamic> json) => GoogleAuthData(
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    token: json["token"],
  );
}
