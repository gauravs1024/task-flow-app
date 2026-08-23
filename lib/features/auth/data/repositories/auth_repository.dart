import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/data/mock_data_source.dart';
import '../models/auth_token_model.dart';
import '../models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> login(String email, String password);
  Future<void> register(String name, String email, String password);
  Future<AuthTokenModel?> getStoredTokens();
  Future<UserModel?> getStoredUser();
  Future<AuthTokenModel> refreshToken(String refreshToken);
  Future<void> logout();
  Future<UserModel?> checkSession();
  Future<void> forceTokenExpiry();
  Future<List<Map<String, dynamic>>> getTestCredentials();
}

class AuthRepositoryImpl implements AuthRepository {
  final MockDataSource _dataSource = MockDataSource();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _keyTokens = 'auth_tokens';
  static const String _keyUser = 'auth_user';

  @override
  Future<UserModel> login(String email, String password) async {
    // 1. Simulate network delay/error
    await _dataSource.simulateNetwork();

    // 2. Validate input format
    if (email.trim().isEmpty || !email.contains('@')) {
      throw ValidationException('Invalid email address format');
    }
    if (password.length < 6) {
      throw ValidationException('Password must be at least 6 characters long');
    }

    // 3. Find test credentials matching email and password
    final credentialsList = List<Map<String, dynamic>>.from(
      _dataSource.authMock['test_credentials'] ?? [],
    );

    final matchingCred = credentialsList.firstWhere(
      (cred) =>
          cred['email'].toString().toLowerCase() == email.trim().toLowerCase() &&
          cred['password'].toString() == password,
      orElse: () => throw ValidationException('Invalid email or password'),
    );

    // 4. Retrieve user details corresponding to this email
    final userJson = _dataSource.users.firstWhere(
      (u) => u['email'].toString().toLowerCase() == email.trim().toLowerCase(),
      orElse: () => {
        'id': 'user_temp_${DateTime.now().millisecondsSinceEpoch}',
        'name': email.split('@').first,
        'email': email,
        'avatar_url': 'https://i.pravatar.cc/150?img=99',
      },
    );

    // 5. Build user model with organization and role mapping
    final user = UserModel.fromJson(
      userJson,
      orgId: matchingCred['org_id']?.toString(),
      role: matchingCred['role']?.toString(),
    );

    // 6. Generate and save mock token response
    final tokenJson = Map<String, dynamic>.from(
      _dataSource.authMock['mock_login_response'] ?? {},
    );
    final tokens = AuthTokenModel.fromJson(tokenJson);

    await _saveSession(tokens, user);

    return user;
  }

  @override
  Future<void> register(String name, String email, String password) async {
    await _dataSource.simulateNetwork();

    if (name.trim().isEmpty) {
      throw ValidationException('Name cannot be empty');
    }
    if (email.trim().isEmpty || !email.contains('@')) {
      throw ValidationException('Invalid email address');
    }
    if (password.length < 6) {
      throw ValidationException('Password must be at least 6 characters long');
    }

    // Check if user already exists
    final exists = _dataSource.users.any(
      (u) => u['email'].toString().toLowerCase() == email.trim().toLowerCase(),
    );
    if (exists) {
      throw ValidationException('Email is already registered');
    }

    // Generate mock new user ID
    final newUserId = 'user_${100 + _dataSource.users.length + 1}';

    // Insert user into mock users data source in memory
    final newUser = {
      'id': newUserId,
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'avatar_url': 'https://i.pravatar.cc/150?img=${_dataSource.users.length + 1}',
    };
    _dataSource.users.add(newUser);

    // Assign standard 'member' role and default org 'org_a1b2c3' (Nimbus Digital)
    final newCreds = {
      'email': email.trim().toLowerCase(),
      'password': password,
      'org_id': 'org_a1b2c3',
      'role': 'member',
    };
    final credentialsList = List<Map<String, dynamic>>.from(
      _dataSource.authMock['test_credentials'] ?? [],
    );
    credentialsList.add(newCreds);
    _dataSource.authMock['test_credentials'] = credentialsList;

    // Add to org members collection
    _dataSource.orgMembers.add({
      'org_id': 'org_a1b2c3',
      'user_id': newUserId,
      'role': 'member',
    });
  }

  @override
  Future<AuthTokenModel?> getStoredTokens() async {
    try {
      final tokenStr = await _secureStorage.read(key: _keyTokens);
      if (tokenStr == null) return null;
      return AuthTokenModel.fromStoredJson(json.decode(tokenStr));
    } catch (_) {
      return null;
    }
  }

  @override
  Future<UserModel?> getStoredUser() async {
    try {
      final userStr = await _secureStorage.read(key: _keyUser);
      if (userStr == null) return null;
      return UserModel.fromJson(json.decode(userStr));
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AuthTokenModel> refreshToken(String refreshToken) async {
    // 1. Simulate network
    await _dataSource.simulateNetwork();

    // 2. Validate token
    final storedTokens = await getStoredTokens();
    if (storedTokens == null || storedTokens.refreshToken != refreshToken) {
      throw Exception('Invalid or expired refresh token');
    }

    // 3. Issue new tokens
    final tokenJson = Map<String, dynamic>.from(
      _dataSource.authMock['mock_login_response'] ?? {},
    );
    // Generate a new access token code to verify update visually
    tokenJson['access_token'] = 'mock.access.token.refreshed_${DateTime.now().millisecondsSinceEpoch}';
    final newTokens = AuthTokenModel.fromJson(tokenJson);

    final user = await getStoredUser();
    if (user != null) {
      await _saveSession(newTokens, user);
    }

    return newTokens;
  }

  @override
  Future<void> logout() async {
    await _secureStorage.delete(key: _keyTokens);
    await _secureStorage.delete(key: _keyUser);
  }

  @override
  Future<UserModel?> checkSession() async {
    final tokens = await getStoredTokens();
    final user = await getStoredUser();

    if (tokens == null || user == null) {
      await logout();
      return null;
    }

    // Check refresh flow if access token expired but refresh token remains valid
    if (tokens.isAccessTokenExpired) {
      if (tokens.isRefreshTokenExpired) {
        await logout();
        return null;
      }
      try {
        await refreshToken(tokens.refreshToken);
        return await getStoredUser();
      } catch (_) {
        await logout();
        return null;
      }
    }

    return user;
  }

  @override
  Future<void> forceTokenExpiry() async {
    final tokens = await getStoredTokens();
    if (tokens != null) {
      final expiredTokens = AuthTokenModel(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        accessTokenExpiry: DateTime.now().subtract(const Duration(seconds: 1)),
        refreshTokenExpiry: tokens.refreshTokenExpiry,
      );
      await _secureStorage.write(key: _keyTokens, value: json.encode(expiredTokens.toJson()));
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTestCredentials() async {
    return List<Map<String, dynamic>>.from(_dataSource.authMock['test_credentials'] ?? []);
  }

  Future<void> _saveSession(AuthTokenModel tokens, UserModel user) async {
    await _secureStorage.write(key: _keyTokens, value: json.encode(tokens.toJson()));
    await _secureStorage.write(key: _keyUser, value: json.encode(user.toJson()));
  }
}
