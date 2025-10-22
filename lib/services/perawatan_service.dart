import 'dart:convert';
import 'package:ta_project/models/app_constants.dart';

import '../models/perawatan_models.dart';
import '../models/api_response.dart';
import 'http_service.dart';
import 'SharedPreferences_service.dart';

class PerawatanService {
  // GET - Ambil semua data perawatan
  static Future<ApiResponse<List<Perawatan>>> getAllPerawatan() async {
    try {
      final token = await SharedPreferencesService.getToken();
      if (token == null) {
        return ApiResponse<List<Perawatan>>(
          status: 'error',
          message: 'Token tidak ditemukan',
        );
      }

      // ✅ Sesuaikan dengan HttpService yang ada
      final response = await HttpService.get('perawatan.php');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == 'success') {
          final List<dynamic> perawatanList =
              jsonData['data']['perawatan'] ?? [];
          final List<Perawatan> perawatans =
              perawatanList.map((item) => Perawatan.fromJson(item)).toList();

          return ApiResponse<List<Perawatan>>(
            status: 'success',
            message: 'Data berhasil diambil',
            data: perawatans,
          );
        } else {
          return ApiResponse<List<Perawatan>>(
            status: 'error',
            message: jsonData['message'] ?? 'Gagal mengambil data perawatan',
          );
        }
      } else {
        return ApiResponse<List<Perawatan>>(
          status: 'error',
          message: 'Gagal terhubung ke server',
        );
      }
    } catch (e) {
      return ApiResponse<List<Perawatan>>(
        status: 'error',
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  // GET - Ambil data perawatan berdasarkan ID
  static Future<ApiResponse<Perawatan>> getPerawatanById(int id) async {
    try {
      final token = await SharedPreferencesService.getToken();
      if (token == null) {
        return ApiResponse<Perawatan>(
          status: 'error',
          message: 'Token tidak ditemukan',
        );
      }

      // ✅ Sesuaikan dengan HttpService yang ada
      final response = await HttpService.get('perawatan.php?id=$id');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == 'success') {
          final perawatan = Perawatan.fromJson(jsonData['data']);
          return ApiResponse<Perawatan>(
            status: 'success',
            message: 'Data berhasil diambil',
            data: perawatan,
          );
        } else {
          return ApiResponse<Perawatan>(
            status: 'error',
            message: jsonData['message'] ?? 'Data perawatan tidak ditemukan',
          );
        }
      } else {
        return ApiResponse<Perawatan>(
          status: 'error',
          message: 'Gagal terhubung ke server',
        );
      }
    } catch (e) {
      return ApiResponse<Perawatan>(
        status: 'error',
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  // POST - Tambah data perawatan baru
  static Future<ApiResponse<Perawatan>> createPerawatan({
    required int kebunId,
    required String kegiatan,
    required String tanggal,
    required int jumlah,
    String? satuan,
    required int biaya,
    String? catatan,
  }) async {
    try {
      final token = await SharedPreferencesService.getToken();
      if (token == null) {
        return ApiResponse<Perawatan>(
          status: 'error',
          message: 'Token tidak ditemukan',
        );
      }

      final Map<String, dynamic> requestData = {
        'kebun_id': kebunId,
        'kegiatan': kegiatan,
        'tanggal': tanggal,
        'jumlah': jumlah,
        if (satuan != null && satuan.isNotEmpty) 'satuan': satuan,
        'biaya': biaya,
        if (catatan != null && catatan.isNotEmpty) 'catatan': catatan,
      };

      // ✅ Sesuaikan dengan HttpService yang ada
      final response = await HttpService.post('perawatan.php', requestData);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == 'success') {
          final perawatan = Perawatan.fromJson(jsonData['data']);
          return ApiResponse<Perawatan>(
            status: 'success',
            message: 'Data perawatan berhasil ditambahkan',
            data: perawatan,
          );
        } else {
          return ApiResponse<Perawatan>(
            status: 'error',
            message: jsonData['message'] ?? 'Gagal menambah data perawatan',
          );
        }
      } else {
        final jsonData = json.decode(response.body);
        return ApiResponse<Perawatan>(
          status: 'error',
          message: jsonData['message'] ?? 'Gagal menambah data perawatan',
        );
      }
    } catch (e) {
      return ApiResponse<Perawatan>(
        status: 'error',
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  // PUT - Update data perawatan
  static Future<ApiResponse<Perawatan>> updatePerawatan({
    required int id,
    required int kebunId,
    required String kegiatan,
    required String tanggal,
    required int jumlah,
    String? satuan,
    required int biaya,
    String? catatan,
  }) async {
    try {
      final token = await SharedPreferencesService.getToken();
      if (token == null) {
        return ApiResponse<Perawatan>(
          status: 'error',
          message: 'Token tidak ditemukan',
        );
      }

      final Map<String, dynamic> requestData = {
        'kebun_id': kebunId,
        'kegiatan': kegiatan,
        'tanggal': tanggal,
        'jumlah': jumlah,
        if (satuan != null && satuan.isNotEmpty) 'satuan': satuan,
        'biaya': biaya,
        if (catatan != null && catatan.isNotEmpty) 'catatan': catatan,
      };

      // ✅ FIX: Kirim ID sebagai bagian dari path, bukan query parameter
      final response = await HttpService.put('perawatan.php/$id', requestData);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == 'success') {
          final perawatan = Perawatan.fromJson(jsonData['data']);
          return ApiResponse<Perawatan>(
            status: 'success',
            message: 'Data perawatan berhasil diupdate',
            data: perawatan,
          );
        } else {
          return ApiResponse<Perawatan>(
            status: 'error',
            message: jsonData['message'] ?? 'Gagal mengupdate data perawatan',
          );
        }
      } else {
        final jsonData = json.decode(response.body);
        return ApiResponse<Perawatan>(
          status: 'error',
          message: jsonData['message'] ?? 'Gagal mengupdate data perawatan',
        );
      }
    } catch (e) {
      return ApiResponse<Perawatan>(
        status: 'error',
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  // DELETE - Hapus data perawatan
  static Future<ApiResponse<bool>> deletePerawatan(int id) async {
    try {
      final token = await SharedPreferencesService.getToken();
      if (token == null) {
        return ApiResponse<bool>(
          status: 'error',
          message: 'Token tidak ditemukan',
        );
      }

      // ✅ FIX: Delete juga menggunakan path ID
      final response = await HttpService.delete('perawatan.php/$id');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == 'success') {
          return ApiResponse<bool>(
            status: 'success',
            message: 'Data perawatan berhasil dihapus',
            data: true,
          );
        } else {
          return ApiResponse<bool>(
            status: 'error',
            message: jsonData['message'] ?? 'Gagal menghapus data perawatan',
          );
        }
      } else {
        final jsonData = json.decode(response.body);
        return ApiResponse<bool>(
          status: 'error',
          message: jsonData['message'] ?? 'Gagal menghapus data perawatan',
        );
      }
    } catch (e) {
      return ApiResponse<bool>(
        status: 'error',
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  //  method untuk validasi data perawatan
  static String? validatePerawatanData({
    required int kebunId,
    required String kegiatan,
    required String tanggal,
    required int jumlah,
    String? satuan,
    required int biaya,
  }) {
    if (kebunId <= 0) {
      return 'Pilih kebun terlebih dahulu';
    }

    if (kegiatan.isEmpty) {
      return 'Jenis kegiatan harus diisi';
    }

    if (satuan != null && satuan.isNotEmpty) {
      if (!PerawatanConstants.satuanOptions.contains(satuan)) {
        return 'Satuan harus berupa ${PerawatanConstants.satuanOptions.join(" atau ")}';
      }
    }

    final dateError = validateDateFormat(tanggal);
    if (dateError != null) {
      return dateError;
    }

    if (jumlah <= 0) {
      return 'Jumlah harus lebih dari 0';
    }

    if (biaya < 0) {
      return 'Biaya tidak boleh negatif';
    }

    return null; // Valid
  }

  // Helper method untuk validasi format tanggal
  static String? validateDateFormat(String dateString) {
    if (dateString.isEmpty) {
      return 'Tanggal harus diisi';
    }

    // Check DD-MM-YYYY format
    final datePattern = RegExp(r'^\d{2}-\d{2}-\d{4}$');
    if (!datePattern.hasMatch(dateString)) {
      return 'Format tanggal harus DD-MM-YYYY';
    }

    try {
      final parts = dateString.split('-');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      // Validate components
      if (month < 1 || month > 12) {
        return 'Bulan tidak valid (1-12)';
      }

      if (day < 1 || day > 31) {
        return 'Tanggal tidak valid (1-31)';
      }

      // Validate complete date
      final date = DateTime(year, month, day);
      if (date.day != day || date.month != month || date.year != year) {
        return 'Tanggal tidak valid';
      }

      return null; // Valid
    } catch (e) {
      return 'Format tanggal tidak valid';
    }
  }
}
