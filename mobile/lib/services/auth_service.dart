import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_service.dart';

class AuthService {
  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  static const String _tokenKey = 'auth_token';

  static Future<String?> getToken() async {
    return await _storage.read(
      key: _tokenKey,
    );
  }

  static Future<void> saveToken(
    String token,
  ) async {
    await _storage.write(
      key: _tokenKey,
      value: token,
    );
  }

  static Future<void> clearToken() async {
    await _storage.delete(
      key: _tokenKey,
    );
  }

  

  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response = await ApiService.post(
      '/auth/register',
      body: {
        'full_name': fullName,
        'email': email,
        'password': password,
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {

      if (data['data']?['token'] != null) {
        await saveToken(
          data['data']['token'],
        );
      }

      return data;
    }

    throw Exception(
      data['message'] ??
          'Registration failed',
    );
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiService.post(
      '/auth/login',
      body: {
        'email': email,
        'password': password,
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {

      if (data['data']?['token'] != null) {
        await saveToken(
          data['data']['token'],
        );
      }

      return data;
    }

    throw Exception(
      data['message'] ??
          'Login failed',
    );
  }

  static Future<Map<String, dynamic>> getMe() async {
    final token = await getToken();

    if (token == null) {
      throw Exception(
        'No authentication token found',
      );
    }

    final response = await ApiService.get(
      '/auth/me',
      token: token,
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return data;
    }

    if (response.statusCode == 401) {
      await clearToken();
    }

    throw Exception(
      data['message'] ??
          'Authentication expired',
    );
  }

  static Future<void> logout() async {
    final token = await getToken();

    if (token != null) {
      try {
        await ApiService.post(
          '/auth/logout',
          token: token,
        );
      } catch (_) {
        // Even if server logout fails,
        // remove local token.
      }
    }

    await clearToken();
  }
}