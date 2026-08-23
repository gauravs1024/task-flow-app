import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';

class OfflineException implements Exception {
  final String message;
  OfflineException([this.message = 'No internet connection']);
  @override
  String toString() => message;
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException([this.message = 'Connection timed out']);
  @override
  String toString() => message;
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException([this.message = 'Resource not found']);
  @override
  String toString() => message;
}

class ValidationException implements Exception {
  final String message;
  ValidationException([this.message = 'Validation failed']);
  @override
  String toString() => message;
}

class MockDataSource {
  // Singleton instance
  static final MockDataSource _instance = MockDataSource._internal();
  factory MockDataSource() => _instance;
  MockDataSource._internal();

  // Raw parsed JSON cache
  Map<String, dynamic>? _rawData;

  // In-memory data collections
  List<Map<String, dynamic>> organizations = [];
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> orgMembers = [];
  List<Map<String, dynamic>> projects = [];
  List<Map<String, dynamic>> tasks = [];
  List<Map<String, dynamic>> comments = [];
  List<Map<String, dynamic>> notifications = [];
  Map<String, dynamic> authMock = {};

  // Simulation controls
  bool isOffline = false;
  bool injectTimeoutError = false;
  bool injectNotFoundError = false;
  bool injectValidationError = false;
  bool delayEnabled = true;

  final Random _random = Random();

  /// Load and parse the initial mock JSON data
  Future<void> initialize() async {
    if (_rawData != null) return;
    try {
      final jsonString = await rootBundle.loadString('assets/mock-data.json');
      _rawData = json.decode(jsonString) as Map<String, dynamic>;

      // Load collections
      organizations = List<Map<String, dynamic>>.from(_rawData!['organizations'] ?? []);
      users = List<Map<String, dynamic>>.from(_rawData!['users'] ?? []);
      orgMembers = List<Map<String, dynamic>>.from(_rawData!['org_members'] ?? []);
      projects = List<Map<String, dynamic>>.from(_rawData!['projects'] ?? []);
      tasks = List<Map<String, dynamic>>.from(_rawData!['tasks'] ?? []);
      comments = List<Map<String, dynamic>>.from(_rawData!['comments'] ?? []);
      notifications = List<Map<String, dynamic>>.from(_rawData!['notifications'] ?? []);
      authMock = Map<String, dynamic>.from(_rawData!['auth_mock'] ?? {});
    } catch (e) {
      // Fallback empty structures if load fails
      _rawData = {};
    }
  }

  /// Reset to initial parsed values
  void resetData() {
    if (_rawData == null) return;
    organizations = List<Map<String, dynamic>>.from(_rawData!['organizations'] ?? []);
    users = List<Map<String, dynamic>>.from(_rawData!['users'] ?? []);
    orgMembers = List<Map<String, dynamic>>.from(_rawData!['org_members'] ?? []);
    projects = List<Map<String, dynamic>>.from(_rawData!['projects'] ?? []);
    tasks = List<Map<String, dynamic>>.from(_rawData!['tasks'] ?? []);
    comments = List<Map<String, dynamic>>.from(_rawData!['comments'] ?? []);
    notifications = List<Map<String, dynamic>>.from(_rawData!['notifications'] ?? []);
  }

  /// Simulate latency and custom errors
  Future<void> simulateNetwork() async {
    // 1. Check offline state
    if (isOffline) {
      throw OfflineException();
    }

    // 2. Add simulated delay (300-800ms)
    if (delayEnabled) {
      final delay = _random.nextInt(500) + 300;
      await Future.delayed(Duration(milliseconds: delay));
    }

    // 3. Inject simulated error states
    if (injectTimeoutError) {
      throw TimeoutException('Simulated network timeout occurred');
    }
    if (injectNotFoundError) {
      throw NotFoundException('Simulated 404 - Resource not found');
    }
    if (injectValidationError) {
      throw ValidationException('Simulated validation error on parameters');
    }
  }
}
