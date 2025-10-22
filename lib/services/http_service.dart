import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ta_project/services/SharedPreferences_service.dart';
import '../models/app_constants.dart';

class HttpService {
  // Handle 401 responses globally
  static void _handleUnauthorized() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Get auth token from SharedPreferences
  static Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);

    return token;
  }

  // Get headers with auth token
  static Future<Map<String, String>> _getHeaders({bool withAuth = true}) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (withAuth) {
      final token = await _getAuthToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      } else {}
    }

    return headers;
  }

  // GET request with auth
  static Future<http.Response> get(String endpoint,
      {bool withAuth = true}) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
      final headers = await _getHeaders(withAuth: withAuth);

      print('🚀 [HTTP] GET: $url');
      print('📥 [HTTP] Headers: $headers');

      final response = await http
          .get(url, headers: headers)
          .timeout(AppConstants.timeoutDuration);

      print('📥 [HTTP] Response Status: ${response.statusCode}');
      print('📥 [HTTP] Response Body: ${response.body}');

      // ✅ Handle 401 globally
      if (response.statusCode == 401) {
        _handleUnauthorized();
      }

      return response;
    } catch (e, stackTrace) {
      print('💥 [HTTP] GET Error: $e');
      print('📚 [HTTP] Stack trace: $stackTrace');
      rethrow;
    }
  }

  // POST request with auth
  static Future<http.Response> post(String endpoint, Map<String, dynamic> body,
      {bool withAuth = true}) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
      final headers = await _getHeaders(withAuth: withAuth);

      print('🚀 [HTTP] POST: $url');
      print('📤 [HTTP] Headers: $headers');
      print('📤 [HTTP] Body: ${json.encode(body)}');

      final response = await http
          .post(
        url,
        headers: headers,
        body: json.encode(body),
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('💥 [HTTP] Request timeout untuk URL: $url');
          throw Exception('Connection timeout - periksa URL server');
        },
      );

      print('📥 [HTTP] Response Status: ${response.statusCode}');
      print('📥 [HTTP] Response Body: ${response.body}');

      // ✅ Handle 401 globally
      if (response.statusCode == 401) {
        _handleUnauthorized();
      }

      return response;
    } catch (e, stackTrace) {
      print('💥 [HTTP] POST Error: $e');
      print('📚 [HTTP] Stack trace: $stackTrace');
      rethrow;
    }
  }

  // PUT request with auth
  static Future<http.Response> put(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final token = await SharedPreferencesService.getToken();

      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      // ✅ FIX: Untuk update, pastikan ID ada di path bukan query
      String url = '${AppConstants.baseUrl}$endpoint';

      print('🔄 [HTTP] PUT Request to: $url');
      print('🔄 [HTTP] PUT Body: ${json.encode(data)}');

      final response = await http
          .put(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(data),
          )
          .timeout(AppConstants.timeoutDuration);

      print('✅ [HTTP] PUT Response: ${response.statusCode}');
      print('✅ [HTTP] PUT Body: ${response.body}');

      return response;
    } catch (e) {
      print('💥 [HTTP] PUT Error: $e');
      rethrow;
    }
  }

  // DELETE request with auth
  static Future<http.Response> delete(String endpoint,
      {bool withAuth = true}) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
      final headers = await _getHeaders(withAuth: withAuth);

      print('🚀 [HTTP] DELETE: $url');
      print('📤 [HTTP] Headers: $headers');

      final response = await http
          .delete(
            url,
            headers: headers,
          )
          .timeout(AppConstants.timeoutDuration);

      print('📥 [HTTP] Response Status: ${response.statusCode}');
      print('📥 [HTTP] Response Body: ${response.body}');

      // ✅ Handle 401 globally
      if (response.statusCode == 401) {
        _handleUnauthorized();
      }

      return response;
    } catch (e, stackTrace) {
      print('💥 [HTTP] DELETE Error: $e');
      print('📚 [HTTP] Stack trace: $stackTrace');
      rethrow;
    }
  }
}
