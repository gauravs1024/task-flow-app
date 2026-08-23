import 'package:equatable/equatable.dart';

class AuthTokenModel extends Equatable {
  final String accessToken;
  final String refreshToken;
  final DateTime accessTokenExpiry;
  final DateTime refreshTokenExpiry;

  const AuthTokenModel({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiry,
    required this.refreshTokenExpiry,
  });

  factory AuthTokenModel.fromJson(Map<String, dynamic> json, {DateTime? baseTime}) {
    final base = baseTime ?? DateTime.now();
    final accessExpiresIn = json['access_token_expires_in_seconds'] as int? ?? 900;
    final refreshExpiresIn = json['refresh_token_expires_in_seconds'] as int? ?? 604800;

    return AuthTokenModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      accessTokenExpiry: base.add(Duration(seconds: accessExpiresIn)),
      refreshTokenExpiry: base.add(Duration(seconds: refreshExpiresIn)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'access_token_expiry': accessTokenExpiry.toIso8601String(),
      'refresh_token_expiry': refreshTokenExpiry.toIso8601String(),
    };
  }

  factory AuthTokenModel.fromStoredJson(Map<String, dynamic> json) {
    return AuthTokenModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      accessTokenExpiry: DateTime.parse(json['access_token_expiry'] as String),
      refreshTokenExpiry: DateTime.parse(json['refresh_token_expiry'] as String),
    );
  }

  bool get isAccessTokenExpired => DateTime.now().isAfter(accessTokenExpiry);
  bool get isRefreshTokenExpired => DateTime.now().isAfter(refreshTokenExpiry);

  @override
  List<Object?> get props => [accessToken, refreshToken, accessTokenExpiry, refreshTokenExpiry];
}
