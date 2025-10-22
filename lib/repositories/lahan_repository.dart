import 'package:ta_project/models/api_response.dart';
import 'package:ta_project/models/lahan_models.dart';
import 'package:ta_project/services/lahan_service.dart';

class LahanRepository {
  final LahanService _lahanService = LahanService();

  // Get all lahan with caching capability
  Future<ApiResponse<List<Lahan>>> getAllLahan() async {
    try {
      print('📦 [LAHAN_REPO] Getting all lahan...');
      final response = await _lahanService.getAllLahan();

      if (response.isSuccess && response.data != null) {
        print(
            '📦 [LAHAN_REPO] Successfully got ${response.data!.length} lahan');
        // Here you can add caching logic if needed
        // await _cacheLahan(response.data!);
      }

      return response;
    } catch (e) {
      print('💥 [LAHAN_REPO] Get all lahan error: $e');
      return ApiResponse<List<Lahan>>(
        status: 'error',
        message: 'Terjadi kesalahan saat mengambil data lahan',
      );
    }
  }

  // Get lahan by ID
  Future<ApiResponse<Lahan>> getLahanById(int id) async {
    try {
      print('📦 [LAHAN_REPO] Getting lahan by ID: $id');

      // Validate ID
      if (id <= 0) {
        return ApiResponse<Lahan>(
          status: 'error',
          message: 'ID lahan tidak valid',
        );
      }

      return await _lahanService.getLahanById(id);
    } catch (e) {
      print('💥 [LAHAN_REPO] Get lahan by ID error: $e');
      return ApiResponse<Lahan>(
        status: 'error',
        message: 'Terjadi kesalahan saat mengambil detail lahan',
      );
    }
  }

  // Create new lahan with validation
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
      print('📦 [LAHAN_REPO] Creating lahan: $nama');

      // Validate input
      final validation = _validateLahanInput(
        nama: nama,
        lokasi: lokasi,
        luas: luas,
        titikTanam: titikTanam,
        waktuBeli: waktuBeli,
        statusKepemilikan: statusKepemilikan,
        statusKebun: statusKebun,
      );

      if (validation != null) {
        return ApiResponse<Lahan>(
          status: 'error',
          message: validation,
        );
      }

      return await _lahanService.createLahan(
        nama: nama.trim(),
        lokasi: lokasi.trim(),
        luas: luas,
        titikTanam: titikTanam,
        waktuBeli: waktuBeli,
        statusKepemilikan: statusKepemilikan,
        statusKebun: statusKebun,
      );
    } catch (e) {
      print('💥 [LAHAN_REPO] Create lahan error: $e');
      return ApiResponse<Lahan>(
        status: 'error',
        message: 'Terjadi kesalahan saat menambahkan lahan',
      );
    }
  }

  // Update lahan with validation
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
      print('📦 [LAHAN_REPO] Updating lahan ID: $id');

      // Validate ID
      if (id <= 0) {
        return ApiResponse<Lahan>(
          status: 'error',
          message: 'ID lahan tidak valid',
        );
      }

      // Validate input
      final validation = _validateLahanInput(
        nama: nama,
        lokasi: lokasi,
        luas: luas,
        titikTanam: titikTanam,
        waktuBeli: waktuBeli,
        statusKepemilikan: statusKepemilikan,
        statusKebun: statusKebun,
      );

      if (validation != null) {
        return ApiResponse<Lahan>(
          status: 'error',
          message: validation,
        );
      }

      return await _lahanService.updateLahan(
        id: id,
        nama: nama.trim(),
        lokasi: lokasi.trim(),
        luas: luas,
        titikTanam: titikTanam,
        waktuBeli: waktuBeli,
        statusKepemilikan: statusKepemilikan,
        statusKebun: statusKebun,
      );
    } catch (e) {
      print('💥 [LAHAN_REPO] Update lahan error: $e');
      return ApiResponse<Lahan>(
        status: 'error',
        message: 'Terjadi kesalahan saat mengupdate lahan',
      );
    }
  }

  // Delete lahan with confirmation
  Future<ApiResponse<void>> deleteLahan(int id) async {
    try {
      print('📦 [LAHAN_REPO] Deleting lahan ID: $id');

      // Validate ID
      if (id <= 0) {
        return ApiResponse<void>(
          status: 'error',
          message: 'ID lahan tidak valid',
        );
      }

      return await _lahanService.deleteLahan(id);
    } catch (e) {
      print('💥 [LAHAN_REPO] Delete lahan error: $e');
      return ApiResponse<void>(
        status: 'error',
        message: 'Terjadi kesalahan saat menghapus lahan',
      );
    }
  }

  // Private method for input validation
  String? _validateLahanInput({
    required String nama,
    required String lokasi,
    required String luas,
    required int titikTanam,
    required String waktuBeli,
    required String statusKepemilikan,
    required String statusKebun,
  }) {
    if (nama.trim().isEmpty) {
      return 'Nama lahan tidak boleh kosong';
    }

    if (nama.trim().length < 3) {
      return 'Nama lahan minimal 3 karakter';
    }

    if (lokasi.trim().isEmpty) {
      return 'Lokasi lahan tidak boleh kosong';
    }

    if (luas.isEmpty) {
      return 'Luas lahan tidak boleh kosong';
    }

    // Validate luas is numeric
    final luasDouble = double.tryParse(luas.replaceAll(',', '.'));
    if (luasDouble == null || luasDouble <= 0) {
      return 'Luas lahan harus berupa angka positif';
    }

    if (titikTanam <= 0) {
      return 'Titik tanam harus lebih dari 0';
    }

    if (waktuBeli.isEmpty) {
      return 'Waktu beli tidak boleh kosong';
    }

    if (statusKepemilikan.isEmpty) {
      return 'Status kepemilikan tidak boleh kosong';
    }

    if (statusKebun.isEmpty) {
      return 'Status kebun tidak boleh kosong';
    }

    return null; // All validations passed
  }
}
