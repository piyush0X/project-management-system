import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

import '../utils/app_navigator.dart';

class ApiService {
  static Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return await http.post(
      Uri.parse('${ApiConfig.baseUrl}$endpoint'),
      headers: headers,
      body: body == null ? null : jsonEncode(body),
    );
  }

  // ignore: unused_element
  static Future<void> _handleUnauthorized(
  http.Response response,
) async {
  if (response.statusCode == 401) {
    await AppNavigator.goToLogin();
  }
}

  static Future<http.Response> get(
    String endpoint, {
    String? token,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return await http.get(
      Uri.parse('${ApiConfig.baseUrl}$endpoint'),
      headers: headers,
    );
  }

  static Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return await http.put(
      Uri.parse('${ApiConfig.baseUrl}$endpoint'),
      headers: headers,
      body: body == null ? null : jsonEncode(body),
    );
  }

  static Future<http.Response> delete(
    String endpoint, {
    String? token,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return await http.delete(
      Uri.parse('${ApiConfig.baseUrl}$endpoint'),
      headers: headers,
    );
  }
}