import 'dart:convert';
import 'package:ta_project/models/api_response.dart';
import 'package:ta_project/models/lahan_models.dart';
import 'package:ta_project/models/app_constants.dart';
import 'package:ta_project/services/http_service.dart';

class LahanService {
  // GET - Fetch all lahan
  // Update getAllLahan method
  Future<ApiResponse<List<Lahan>>> getAllLahan() async {
    try {
      print('🌱 [LAHAN] Getting all lahan...');

      final response = await HttpService.get(ApiEndpoints.lahan);
      print('📊 [LAHAN] Raw Response: ${response.body}');
      print('📊 [LAHAN] Status Code: ${response.statusCode}');

      // ✅ Handle 401 specifically
      if (response.statusCode == 401) {
        print('🚨 [LAHAN] 401 Unauthorized - Session expired');
        return ApiResponse<List<Lahan>>(
          status: 'error',
          message: 'Sesi Anda telah berakhir. Silakan login kembali.',
        );
      }

      if (response.statusCode != 200) {
        print('⚠️ [LAHAN] HTTP Status: ${response.statusCode}');
        return ApiResponse<List<Lahan>>(
          status: 'error',
          message: 'Server error: ${response.statusCode}',
        );
      }

      final Map<String, dynamic> jsonData = json.decode(response.body);
      print('📊 [LAHAN] JSON Data: $jsonData');

      if (jsonData['status'] == 'success') {
        List<dynamic> lahanJsonList = [];

        if (jsonData['data'] != null && jsonData['data']['lahan'] != null) {
          lahanJsonList = jsonData['data']['lahan'];
        }

        final List<Lahan> lahanList = lahanJsonList
            .map((json) => Lahan.fromJson(json as Map<String, dynamic>))
            .toList();

        print('✅ [LAHAN] Successfully got ${lahanList.length} lahan');
        return ApiResponse<List<Lahan>>(
          status: 'success',
          message: lahanList.isEmpty
              ? 'Belum ada data lahan'
              : 'Data lahan berhasil diambil',
          data: lahanList,
        );
      } else {
        print('❌ [LAHAN] API Error: ${jsonData['message']}');
        return ApiResponse<List<Lahan>>(
          status: 'error',
          message: jsonData['message'] ?? 'Gagal mengambil data lahan',
        );
      }
    } catch (e, stackTrace) {
      print('💥 [LAHAN] Get all lahan error: $e');
      print('📚 [LAHAN] Stack trace: $stackTrace');

      return ApiResponse<List<Lahan>>(
        status: 'error',
        message: 'Terjadi kesalahan sistem: ${e.toString()}',
      );
    }
  }

  // POST - Create new lahan
  Future<ApiResponse<Lahan>> createLahan({
    required String nama,
    required String lokasi,
    required String luas,
    required int titikTanam,
    required String waktuBeli,
    required String statusKepemilikan,
    required String statusKebun,
  }) async {
    try {
      print('🌱 [LAHAN] Creating lahan: $nama');

      final data = {
        'nama': nama,
        'lokasi': lokasi,
        'luas': luas,
        'titik_tanam': titikTanam, // ✅ Make sure it's integer
        'waktu_beli': waktuBeli,
        'status_kepemilikan': statusKepemilikan,
        'status_kebun': statusKebun,
      };

      print('📤 [LAHAN] Sending data: ${json.encode(data)}'); // Add this debug
      print('📅 [LAHAN] Date format being sent: $waktuBeli');

      final response = await HttpService.post(ApiEndpoints.lahan, data);

      print(
          '📥 [LAHAN] Response status: ${response.statusCode}'); // Add this debug
      print('📥 [LAHAN] Response body: ${response.body}'); // Add this debug

      // ✅ Handle 500 error specifically
      if (response.statusCode == 500) {
        print('🚨 [LAHAN] Server error 500');
        return ApiResponse<Lahan>(
          status: 'error',
          message: 'Server mengalami kesalahan internal. Silakan coba lagi.',
        );
      }

      final Map<String, dynamic> jsonData = json.decode(response.body);

      if (jsonData['status'] == 'success' && response.statusCode == 201) {
        final lahan = Lahan.fromJson(jsonData['data']);
        print('✅ [LAHAN] Successfully created lahan: ${lahan.nama}');

        return ApiResponse<Lahan>(
          status: 'success',
          message: jsonData['message'],
          data: lahan,
        );
      } else {
        print('❌ [LAHAN] Create failed: ${jsonData['message']}');
        return ApiResponse<Lahan>(
          status: 'error',
          message: jsonData['message'] ?? 'Gagal menambahkan lahan',
        );
      }
    } catch (e) {
      print('💥 [LAHAN] Create lahan error: $e');
      return ApiResponse<Lahan>(
        status: 'error',
        message: 'Terjadi kesalahan sistem: ${e.toString()}',
      );
    }
  }

  // PUT - Update lahan
  Future<ApiResponse<Lahan>> updateLahan({
    required int id,
    required String nama,
    required String lokasi,
    required String luas,
    required int titikTanam,
    required String waktuBeli,
    required String statusKepemilikan,
    required String statusKebun,
  }) async {
    try {
      print('🌱 [LAHAN] Updating lahan ID: $id');

      final data = {
        'nama': nama,
        'lokasi': lokasi,
        'luas': luas,
        'titik_tanam': titikTanam,
        'waktu_beli': waktuBeli,
        'status_kepemilikan': statusKepemilikan,
        'status_kebun': statusKebun,
      };

      final response = await HttpService.put('${ApiEndpoints.lahan}/$id', data);
      final Map<String, dynamic> jsonData = json.decode(response.body);

      if (jsonData['status'] == 'success') {
        final lahan = Lahan.fromJson(jsonData['data']);
        print('✅ [LAHAN] Successfully updated lahan: ${lahan.nama}');

        return ApiResponse<Lahan>(
          status: 'success',
          message: jsonData['message'],
          data: lahan,
        );
      } else {
        print('❌ [LAHAN] Update failed: ${jsonData['message']}');
        return ApiResponse<Lahan>(
          status: 'error',
          message: jsonData['message'] ?? 'Gagal mengupdate lahan',
        );
      }
    } catch (e) {
      print('💥 [LAHAN] Update lahan error: $e');
      return ApiResponse<Lahan>(
        status: 'error',
        message: 'Terjadi kesalahan sistem: ${e.toString()}',
      );
    }
  }

  // GET - Get lahan by ID
  Future<ApiResponse<Lahan>> getLahanById(int id) async {
    try {
      print('🌱 [LAHAN] Getting lahan by ID: $id');

      final response = await HttpService.get('${ApiEndpoints.lahan}/$id');
      final Map<String, dynamic> jsonData = json.decode(response.body);

      if (jsonData['status'] == 'success' && response.statusCode == 200) {
        final lahan = Lahan.fromJson(jsonData['data']);
        print('✅ [LAHAN] Successfully got lahan: ${lahan.nama}');

        return ApiResponse<Lahan>(
          status: 'success',
          message: jsonData['message'],
          data: lahan,
        );
      } else {
        print('❌ [LAHAN] Get by ID failed: ${jsonData['message']}');
        return ApiResponse<Lahan>(
          status: 'error',
          message: jsonData['message'] ?? 'Lahan tidak ditemukan',
        );
      }
    } catch (e) {
      print('💥 [LAHAN] Get lahan by ID error: $e');
      return ApiResponse<Lahan>(
        status: 'error',
        message: 'Terjadi kesalahan sistem: ${e.toString()}',
      );
    }
  }

  // DELETE - Delete lahan
  Future<ApiResponse<void>> deleteLahan(int id) async {
    try {
      print('🌱 [LAHAN] Deleting lahan ID: $id');

      final response = await HttpService.delete('${ApiEndpoints.lahan}/$id');
      final Map<String, dynamic> jsonData = json.decode(response.body);

      if (jsonData['status'] == 'success') {
        print('✅ [LAHAN] Successfully deleted lahan ID: $id');

        return ApiResponse<void>(
          status: 'success',
          message: jsonData['message'],
        );
      } else {
        print('❌ [LAHAN] Delete failed: ${jsonData['message']}');
        return ApiResponse<void>(
          status: 'error',
          message: jsonData['message'] ?? 'Gagal menghapus lahan',
        );
      }
    } catch (e) {
      print('💥 [LAHAN] Delete lahan error: $e');
      return ApiResponse<void>(
        status: 'error',
        message: 'Terjadi kesalahan sistem: ${e.toString()}',
      );
    }
  }
}
