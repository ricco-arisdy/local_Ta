import '../models/panen_models.dart';
import '../models/api_response.dart';
import '../services/panen_service.dart';

class PanenRepository {
  Future<ApiResponse<List<Panen>>> getAllPanen() async {
    try {
      print('🌾 [PANEN_REPO] Getting all panen...');

      final response = await PanenService.getAllPanen();

      if (response.isSuccess) {
        // ✅ ADD: Sort panen berdasarkan tanggal terbaru (descending)
        if (response.data != null) {
          response.data!.sort((a, b) {
            try {
              final dateA = DateTime.parse(a.tanggal);
              final dateB = DateTime.parse(b.tanggal);
              return dateB.compareTo(dateA); // ✅ Terbaru di atas (descending)
            } catch (e) {
              return 0; // Jika gagal parse, tetap urutan original
            }
          });
        }

        print(
            '✅ [PANEN_REPO] Successfully got ${response.data?.length ?? 0} panen (sorted by newest)');
        return response;
      } else {
        print('❌ [PANEN_REPO] Failed to get panen: ${response.message}');
        return response;
      }
    } catch (e) {
      print('💥 [PANEN_REPO] Error getting all panen: $e');
      return ApiResponse<List<Panen>>(
        status: 'error',
        message: 'Terjadi kesalahan sistem: ${e.toString()}',
      );
    }
  }

  // GET - Ambil data panen berdasarkan ID
  Future<ApiResponse<Panen>> getPanenById(int id) async {
    try {
      print('🌾 [PANEN_REPO] Getting panen by ID: $id');

      final response = await PanenService.getPanenById(id);

      if (response.isSuccess) {
        print('✅ [PANEN_REPO] Successfully got panen: ${response.data?.id}');
        return response;
      } else {
        print('❌ [PANEN_REPO] Failed to get panen: ${response.message}');
        return response;
      }
    } catch (e) {
      print('💥 [PANEN_REPO] Error getting panen by ID: $e');
      return ApiResponse<Panen>(
        status: 'error',
        message: 'Terjadi kesalahan sistem: ${e.toString()}',
      );
    }
  }

  // POST - Tambah data panen baru
  Future<ApiResponse<Panen>> createPanen({
    required int lahanId,
    required String tanggal,
    required int jumlah,
    required int harga,
    String? catatan,
  }) async {
    try {
      print('🌾 [PANEN_REPO] Creating panen for lahan: $lahanId');

      // Validasi data sebelum mengirim ke service
      final validationError = PanenService.validatePanenData(
        lahanId: lahanId,
        tanggal: tanggal,
        jumlah: jumlah,
        harga: harga,
      );

      if (validationError != null) {
        print('❌ [PANEN_REPO] Validation error: $validationError');
        return ApiResponse<Panen>(
          status: 'error',
          message: validationError,
        );
      }

      final response = await PanenService.createPanen(
        lahanId: lahanId,
        tanggal: tanggal,
        jumlah: jumlah,
        harga: harga,
        catatan: catatan,
      );

      if (response.isSuccess) {
        print(
            '✅ [PANEN_REPO] Successfully created panen: ${response.data?.id}');
        return response;
      } else {
        print('❌ [PANEN_REPO] Failed to create panen: ${response.message}');
        return response;
      }
    } catch (e) {
      print('💥 [PANEN_REPO] Error creating panen: $e');
      return ApiResponse<Panen>(
        status: 'error',
        message: 'Terjadi kesalahan sistem: ${e.toString()}',
      );
    }
  }

  // PUT - Update data panen
  Future<ApiResponse<Panen>> updatePanen({
    required int id,
    required int lahanId,
    required String tanggal,
    required int jumlah,
    required int harga,
    String? catatan,
  }) async {
    try {
      print('🌾 [PANEN_REPO] Updating panen ID: $id');

      // Validasi data sebelum mengirim ke service
      final validationError = PanenService.validatePanenData(
        lahanId: lahanId,
        tanggal: tanggal,
        jumlah: jumlah,
        harga: harga,
      );

      if (validationError != null) {
        print('❌ [PANEN_REPO] Validation error: $validationError');
        return ApiResponse<Panen>(
          status: 'error',
          message: validationError,
        );
      }

      final response = await PanenService.updatePanen(
        id: id,
        lahanId: lahanId,
        tanggal: tanggal,
        jumlah: jumlah,
        harga: harga,
        catatan: catatan,
      );

      if (response.isSuccess) {
        print(
            '✅ [PANEN_REPO] Successfully updated panen: ${response.data?.id}');
        return response;
      } else {
        print('❌ [PANEN_REPO] Failed to update panen: ${response.message}');
        return response;
      }
    } catch (e) {
      print('💥 [PANEN_REPO] Error updating panen: $e');
      return ApiResponse<Panen>(
        status: 'error',
        message: 'Terjadi kesalahan sistem: ${e.toString()}',
      );
    }
  }

  // DELETE - Hapus data panen
  Future<ApiResponse<bool>> deletePanen(int id) async {
    try {
      print('🌾 [PANEN_REPO] Deleting panen ID: $id');

      final response = await PanenService.deletePanen(id);

      if (response.isSuccess) {
        print('✅ [PANEN_REPO] Successfully deleted panen ID: $id');
        return response;
      } else {
        print('❌ [PANEN_REPO] Failed to delete panen: ${response.message}');
        return response;
      }
    } catch (e) {
      print('💥 [PANEN_REPO] Error deleting panen: $e');
      return ApiResponse<bool>(
        status: 'error',
        message: 'Terjadi kesalahan sistem: ${e.toString()}',
      );
    }
  }

  // Helper method - Ambil panen berdasarkan lahan ID
  Future<ApiResponse<List<Panen>>> getPanenByLahanId(int lahanId) async {
    try {
      print('🌾 [PANEN_REPO] Getting panen by lahan ID: $lahanId');

      final response = await getAllPanen();

      if (response.isSuccess && response.data != null) {
        final filteredPanen =
            response.data!.where((panen) => panen.lahanId == lahanId).toList();

        print(
            '✅ [PANEN_REPO] Found ${filteredPanen.length} panen for lahan $lahanId');

        return ApiResponse<List<Panen>>(
          status: 'success',
          message: 'Data panen berhasil difilter',
          data: filteredPanen,
        );
      } else {
        return response;
      }
    } catch (e) {
      print('💥 [PANEN_REPO] Error getting panen by lahan ID: $e');
      return ApiResponse<List<Panen>>(
        status: 'error',
        message: 'Terjadi kesalahan sistem: ${e.toString()}',
      );
    }
  }

  // Helper method - Statistik panen
  Future<Map<String, dynamic>> getPanenStatistics() async {
    try {
      print('🌾 [PANEN_REPO] Getting panen statistics...');

      final response = await getAllPanen();

      if (response.isSuccess && response.data != null) {
        final panenList = response.data!;

        final stats = {
          'totalPanen': panenList.length,
          'totalJumlah':
              panenList.fold<int>(0, (sum, panen) => sum + panen.jumlah),
          'totalNilai':
              panenList.fold<int>(0, (sum, panen) => sum + panen.totalNilai),
          'rataRataHarga': panenList.isNotEmpty
              ? panenList.fold<int>(0, (sum, panen) => sum + panen.harga) /
                  panenList.length
              : 0.0,
          'panenTerbaru': panenList.isNotEmpty
              ? panenList.reduce((a, b) =>
                  DateTime.parse(a.tanggal).isAfter(DateTime.parse(b.tanggal))
                      ? a
                      : b)
              : null,
        };

        print('✅ [PANEN_REPO] Statistics calculated successfully');
        return stats;
      } else {
        print('❌ [PANEN_REPO] Failed to get statistics: ${response.message}');
        return {
          'totalPanen': 0,
          'totalJumlah': 0,
          'totalNilai': 0,
          'rataRataHarga': 0.0,
          'panenTerbaru': null,
        };
      }
    } catch (e) {
      print('💥 [PANEN_REPO] Error getting statistics: $e');
      return {
        'totalPanen': 0,
        'totalJumlah': 0,
        'totalNilai': 0,
        'rataRataHarga': 0.0,
        'panenTerbaru': null,
      };
    }
  }

  // Helper method - Validasi apakah lahan memiliki panen
  Future<bool> hasAnyPanen(int lahanId) async {
    try {
      final response = await getPanenByLahanId(lahanId);
      return response.isSuccess && (response.data?.isNotEmpty ?? false);
    } catch (e) {
      print('💥 [PANEN_REPO] Error checking panen existence: $e');
      return false;
    }
  }
}
