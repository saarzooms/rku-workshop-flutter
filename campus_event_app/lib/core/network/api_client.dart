import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../errors/api_exception.dart';

class ApiClient {
  ApiClient({
    http.Client? httpClient,
    FlutterSecureStorage? secureStorage,
  })  : _httpClient = httpClient ?? http.Client(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const String _tokenKey = 'campus_auth_token';

  final http.Client _httpClient;
  final FlutterSecureStorage _secureStorage;

  Future<void> saveToken(String token) =>
      _secureStorage.write(key: _tokenKey, value: token);

  Future<String?> getToken() => _secureStorage.read(key: _tokenKey);

  Future<void> clearToken() => _secureStorage.delete(key: _tokenKey);

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    return _send('GET', path, queryParameters: queryParameters);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    return _send('POST', path, body: body);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    return _send('PUT', path, body: body);
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    return _send('PATCH', path, body: body);
  }

  Future<Map<String, dynamic>> delete(String path) async {
    return _send('DELETE', path);
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, String>? queryParameters,
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path').replace(
      queryParameters: queryParameters == null || queryParameters.isEmpty
          ? null
          : queryParameters,
    );

    final token = await getToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    try {
      late final http.Response response;
      final encodedBody = body != null ? jsonEncode(body) : null;

      switch (method) {
        case 'GET':
          response = await _httpClient
              .get(uri, headers: headers)
              .timeout(const Duration(seconds: 15));
          break;
        case 'POST':
          response = await _httpClient
              .post(uri, headers: headers, body: encodedBody)
              .timeout(const Duration(seconds: 15));
          break;
        case 'PUT':
          response = await _httpClient
              .put(uri, headers: headers, body: encodedBody)
              .timeout(const Duration(seconds: 15));
          break;
        case 'PATCH':
          response = await _httpClient
              .patch(uri, headers: headers, body: encodedBody)
              .timeout(const Duration(seconds: 15));
          break;
        case 'DELETE':
          response = await _httpClient
              .delete(uri, headers: headers)
              .timeout(const Duration(seconds: 15));
          break;
        default:
          throw ApiException(message: 'Unsupported HTTP method: $method');
      }

      final decoded = _decodeJson(response.body);
      final success = decoded['success'] == true;

      if (response.statusCode >= 200 && response.statusCode < 300 && success) {
        return decoded;
      }

      final rawErrors = decoded['errors'];
      final fieldErrors = <String, String>{};
      if (rawErrors is Map) {
        rawErrors.forEach((key, value) {
          fieldErrors[key.toString()] = value.toString();
        });
      }

      throw ApiException(
        message: (decoded['message'] as String?) ?? 'Request failed',
        statusCode: response.statusCode,
        fieldErrors: fieldErrors,
      );
    } on SocketException {
      throw const ApiException(
        message: 'Unable to reach server. Check your network and API URL.',
      );
    } on FormatException {
      throw const ApiException(
        message: 'Invalid response received from server.',
      );
    }
  }

  Map<String, dynamic> _decodeJson(String body) {
    if (body.trim().isEmpty) {
      return {'success': true, 'message': 'OK', 'data': null};
    }
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw const FormatException('Expected JSON object');
  }
}
