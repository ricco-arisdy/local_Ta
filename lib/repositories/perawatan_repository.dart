import '../models/perawatan_models.dart';
import '../models/api_response.dart';
import '../services/perawatan_service.dart';

class PerawatanRepository {
  // GET - Ambil semua data perawatan
  Future<ApiResponse<List<Perawatan>>> getAllPerawatan() async {
    try {
      print('🌿 [PERAWATAN_REPO] Getting all perawatan...');

      final response = await PerawatanService.getAllPerawatan();

      if (response.isSuccess) {
        // ✅ Sort perawatan berdasarkan tanggal terbaru (descending)
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
            '✅ [PERAWATAN_REPO] Successfully got ${response.data?.length ?? 0} perawatan (sorted by newest)');
        return response;
      } else {
        print(
            '❌ [PERAWATAN_REPO] Failed to get perawatan: ${response.message}');
        return response;
      }
    } catch (e) {
      print('💥 [PERAWATAN_REPO] Error getting all perawatan: $e');
      return ApiResponse<List<Perawatan>>(
        status: 'error',
        message: 'Terjadi kesalahan sistem: ${e.toString()}',
      );
    }
  }

  // GET - Ambil data perawatan berdasarkan ID
  Future<ApiResponse<Perawatan>> getPerawatanById(int id) async {
    try {
      print('🌿 [PERAWATAN_REPO] Getting perawatan by ID: $id');

      final response = await PerawatanService.getPerawatanById(id);

      if (response.isSuccess) {
        print(
            '✅ [PERAWATAN_REPO] Successfully got perawatan: ${response.data?.id}');
        return response;
      } else {
        print(
            '❌ [PERAWATAN_REPO] Failed to get perawatan: ${response.message}');
        return response;
      }
    } catch (e) {
      print('💥 [PERAWATAN_REPO] Error getting perawatan by ID: $e');
      return ApiResponse<Perawatan>(
        status: 'error',
        message: 'Terjadi kesalahan sistem: ${e.toString()}',
      );
    }
  }

  // POST - Tambah data perawatan baru
  Future<ApiResponse<Perawatan>> createPerawatan({
    required int kebunId,
    required String kegiatan,
    required String tanggal,
    required int jumlah,
    String? satuan,
    required int biaya,
    String? catatan,
  }) async {
    try {
      print('🌿 [PERAWATAN_REPO] Creating perawatan for kebun: $kebunId');

      // Validasi data sebelum mengirim ke service
      final validationError = PerawatanService.validatePerawatanData(
        kebunId: kebunId,
        kegiatan: kegiatan,
        tanggal: tanggal,
        jumlah: jumlah,
        satuan: satuan,
        biaya: biaya,
      );

      if (validationError != null) {
        print('❌ [PERAWATAN_REPO] Validation error: $validationError');
        return ApiResponse<Perawatan>(
          status: 'error',
          message: validationError,
        );
      }

      final response = await PerawatanService.createPerawatan(
        kebunId: kebunId,
        kegiatan: kegiatan,
        tanggal: tanggal,
        jumlah: jumlah,
        satuan: satuan,
        biaya: biaya,
        catatan: catatan,
      );

      if (response.isSuccess) {
        print(
            '✅ [PERAWATAN_REPO] Successfully created perawatan: ${response.data?.id}');
        return response;
      } else {
        print(
            '❌ [PERAWATAN_REPO] Failed to create perawatan: ${response.message}');
        return response;
      }
    } catch (e) {
      print('💥 [PERAWATAN_REPO] Error creating perawatan: $e');
      return ApiResponse<Perawatan>(
        status: 'error',
        message: 'Terjadi kesalahan sistem: ${e.toString()}',
      );
    }
  }

  // PUT - Update data perawatan
  Future<ApiResponse<Perawatan>> updatePerawatan({
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
      print('🌿 [PERAWATAN_REPO] Updating perawatan ID: $id');

      // Validasi data sebelum mengirim ke service
      final validationError = PerawatanService.validatePerawatanData(
        kebunId: kebunId,
        kegiatan: kegiatan,
        tanggal: tanggal,
        jumlah: jumlah,
        satuan: satuan,
        biaya: biaya,
      );

      if (validationError != null) {
        print('❌ [PERAWATAN_REPO] Validation error: $validationError');
        return ApiResponse<Perawatan>(
          status: 'error',
          message: validationError,
        );
      }

      final response = await PerawatanService.updatePerawatan(
        id: id,
        kebunId: kebunId,
        kegiatan: kegiatan,
        tanggal: tanggal,
        jumlah: jumlah,
        satuan: satuan,
        biaya: biaya,
        catatan: catatan,
      );

      if (response.isSuccess) {
        print(
            '✅ [PERAWATAN_REPO] Successfully updated perawatan: ${response.data?.id}');
        return response;
      } else {
        print(
            '❌ [PERAWATAN_REPO] Failed to update perawatan: ${response.message}');
        return response;
      }
    } catch (e) {
      print('💥 [PERAWATAN_REPO] Error updating perawatan: $e');
      return ApiResponse<Perawatan>(
        status: 'error',
        message: 'Terjadi kesalahan sistem: ${e.toString()}',
      );
    }
  }

  // DELETE - Hapus data perawatan
  Future<ApiResponse<bool>> deletePerawatan(int id) async {
    try {
      print('🌿 [PERAWATAN_REPO] Deleting perawatan ID: $id');

      final response = await PerawatanService.deletePerawatan(id);

      if (response.isSuccess) {
        print('✅ [PERAWATAN_REPO] Successfully deleted perawatan ID: $id');
        return response;
      } else {
        print(
            '❌ [PERAWATAN_REPO] Failed to delete perawatan: ${response.message}');
        return response;
      }
    } catch (e) {
      print('💥 [PERAWATAN_REPO] Error deleting perawatan: $e');
      return ApiResponse<bool>(
        status: 'error',
        message: 'Terjadi kesalahan sistem: ${e.toString()}',
      );
    }
  }

  // Helper method - Ambil perawatan berdasarkan kebun ID
  Future<ApiResponse<List<Perawatan>>> getPerawatanByKebunId(
      int kebunId) async {
    try {
      print('🌿 [PERAWATAN_REPO] Getting perawatan by kebun ID: $kebunId');

      final response = await getAllPerawatan();

      if (response.isSuccess && response.data != null) {
        final filteredPerawatan = response.data!
            .where((perawatan) => perawatan.kebunId == kebunId)
            .toList();

        print(
            '✅ [PERAWATAN_REPO] Found ${filteredPerawatan.length} perawatan for kebun $kebunId');

        return ApiResponse<List<Perawatan>>(
          status: 'success',
          message: 'Data perawatan berhasil difilter',
          data: filteredPerawatan,
        );
      } else {
        return response;
      }
    } catch (e) {
      print('💥 [PERAWATAN_REPO] Error getting perawatan by kebun ID: $e');
      return ApiResponse<List<Perawatan>>(
        status: 'error',
        message: 'Terjadi kesalahan sistem: ${e.toString()}',
      );
    }
  }

  // Helper method - Ambil perawatan berdasarkan jenis kegiatan
  Future<ApiResponse<List<Perawatan>>> getPerawatanByKegiatan(
      String kegiatan) async {
    try {
      print('🌿 [PERAWATAN_REPO] Getting perawatan by kegiatan: $kegiatan');

      final response = await getAllPerawatan();

      if (response.isSuccess && response.data != null) {
        final filteredPerawatan = response.data!
            .where((perawatan) => perawatan.kegiatan
                .toLowerCase()
                .contains(kegiatan.toLowerCase()))
            .toList();

        print(
            '✅ [PERAWATAN_REPO] Found ${filteredPerawatan.length} perawatan for kegiatan $kegiatan');

        return ApiResponse<List<Perawatan>>(
          status: 'success',
          message: 'Data perawatan berhasil difilter',
          data: filteredPerawatan,
        );
      } else {
        return response;
      }
    } catch (e) {
      print('💥 [PERAWATAN_REPO] Error getting perawatan by kegiatan: $e');
      return ApiResponse<List<Perawatan>>(
        status: 'error',
        message: 'Terjadi kesalahan sistem: ${e.toString()}',
      );
    }
  }

  // Helper method - Statistik perawatan
  Future<Map<String, dynamic>> getPerawatanStatistics() async {
    try {
      print('🌿 [PERAWATAN_REPO] Getting perawatan statistics...');

      final response = await getAllPerawatan();

      if (response.isSuccess && response.data != null) {
        final perawatanList = response.data!;

        final stats = {
          'totalPerawatan': perawatanList.length,
          'totalBiaya': perawatanList.fold<int>(
              0, (sum, perawatan) => sum + perawatan.biaya),
          'rataRataBiaya': perawatanList.isNotEmpty
              ? perawatanList.fold<int>(
                      0, (sum, perawatan) => sum + perawatan.biaya) /
                  perawatanList.length
              : 0.0,
          'perawatanTerbaru': perawatanList.isNotEmpty
              ? perawatanList.reduce((a, b) =>
                  DateTime.parse(a.tanggal).isAfter(DateTime.parse(b.tanggal))
                      ? a
                      : b)
              : null,
          'kegiatanTerbanyak': _getMostFrequentActivity(perawatanList),
        };

        print('✅ [PERAWATAN_REPO] Statistics calculated successfully');
        return stats;
      } else {
        print(
            '❌ [PERAWATAN_REPO] Failed to get statistics: ${response.message}');
        return {
          'totalPerawatan': 0,
          'totalBiaya': 0,
          'rataRataBiaya': 0.0,
          'perawatanTerbaru': null,
          'kegiatanTerbanyak': null,
        };
      }
    } catch (e) {
      print('💥 [PERAWATAN_REPO] Error getting statistics: $e');
      return {
        'totalPerawatan': 0,
        'totalBiaya': 0,
        'rataRataBiaya': 0.0,
        'perawatanTerbaru': null,
        'kegiatanTerbanyak': null,
      };
    }
  }

  // Helper method - Validasi apakah kebun memiliki perawatan
  Future<bool> hasAnyPerawatan(int kebunId) async {
    try {
      final response = await getPerawatanByKebunId(kebunId);
      return response.isSuccess && (response.data?.isNotEmpty ?? false);
    } catch (e) {
      print('💥 [PERAWATAN_REPO] Error checking perawatan existence: $e');
      return false;
    }
  }

  // Helper method - Get kegiatan yang paling sering dilakukan
  String? _getMostFrequentActivity(List<Perawatan> perawatanList) {
    if (perawatanList.isEmpty) return null;

    final activityCount = <String, int>{};

    for (var perawatan in perawatanList) {
      activityCount[perawatan.kegiatan] =
          (activityCount[perawatan.kegiatan] ?? 0) + 1;
    }

    var maxCount = 0;
    String? mostFrequent;

    activityCount.forEach((activity, count) {
      if (count > maxCount) {
        maxCount = count;
        mostFrequent = activity;
      }
    });

    return mostFrequent;
  }

  // Helper method - Get perawatan berdasarkan rentang tanggal
  Future<ApiResponse<List<Perawatan>>> getPerawatanByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      print(
          '🌿 [PERAWATAN_REPO] Getting perawatan from ${startDate.toString()} to ${endDate.toString()}');

      final response = await getAllPerawatan();

      if (response.isSuccess && response.data != null) {
        final filteredPerawatan = response.data!.where((perawatan) {
          try {
            final tanggal = DateTime.parse(perawatan.tanggal);
            return tanggal
                    .isAfter(startDate.subtract(const Duration(days: 1))) &&
                tanggal.isBefore(endDate.add(const Duration(days: 1)));
          } catch (e) {
            return false;
          }
        }).toList();

        print(
            '✅ [PERAWATAN_REPO] Found ${filteredPerawatan.length} perawatan in date range');

        return ApiResponse<List<Perawatan>>(
          status: 'success',
          message: 'Data perawatan berhasil difilter',
          data: filteredPerawatan,
        );
      } else {
        return response;
      }
    } catch (e) {
      print('💥 [PERAWATAN_REPO] Error getting perawatan by date range: $e');
      return ApiResponse<List<Perawatan>>(
        status: 'error',
        message: 'Terjadi kesalahan sistem: ${e.toString()}',
      );
    }
  }
}
