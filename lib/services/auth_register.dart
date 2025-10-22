import 'dart:convert';
import 'package:ta_project/models/api_response.dart';
import 'package:ta_project/models/user_models.dart';
import 'package:ta_project/models/app_constants.dart';
import 'package:ta_project/services/http_service.dart';

class AuthRegisterService {
  Future<ApiResponse<User>> register({
    required String nama,
    required String email,
    required String password,
    required String ulangiPassword,
  }) async {
    try {
      print('🚀 [AUTH] Attempting register for email: $email');

      // Use HttpService instead of direct HTTP call
      final response = await HttpService.post(
        ApiEndpoints.register,
        {
          'nama': nama,
          'email': email,
          'password': password,
          'ulangi_password': ulangiPassword,
        },
        withAuth: false,
      );

      if (response.body.isEmpty) {
        return ApiResponse<User>(
          status: 'error',
          message: 'Server tidak memberikan response',
        );
      }

      if (response.body.trim().startsWith('<')) {
        return ApiResponse<User>(
          status: 'error',
          message: 'Server error: Response bukan JSON',
        );
      }

      final Map<String, dynamic> jsonData = json.decode(response.body);
      print('✅ [AUTH] JSON Decoded: $jsonData');

      if (jsonData['status'] == 'success') {
        final user = User.fromJson(jsonData['data']);
        print('🎉 [AUTH] Register SUCCESS! User: ${user.nama}');

        return ApiResponse<User>(
          status: 'success',
          message: jsonData['message'] ?? 'Registrasi berhasil',
          data: user,
        );
      } else {
        print('❌ [AUTH] Register FAILED: ${jsonData['message']}');
        return ApiResponse<User>(
          status: jsonData['status'] ?? 'error',
          message: jsonData['message'] ?? 'Registrasi gagal',
        );
      }
    } catch (e, stackTrace) {
      print('💥 [AUTH] Register error: $e');
      print('📚 [AUTH] Stack trace: $stackTrace');
      return ApiResponse<User>(
        status: 'error',
        message: 'Koneksi gagal: ${e.toString()}',
      );
    }
  }
}
