import 'dart:convert';
import 'package:ta_project/models/app_constants.dart';
import '../models/api_response.dart';
import '../models/laporan_models.dart';
import 'http_service.dart';

class LaporanService {
  static const String _endpoint = ApiEndpoints.laporanData;

  /// Get summary keseluruhan tanpa filter
  static Future<ApiResponse<SummaryKeseluruhan>> getSummaryKeseluruhan() async {
    try {
      print('📊 [LAPORAN_SERVICE] Fetching overall summary');

      // Call endpoint tanpa parameter lahan_id untuk mendapatkan summary keseluruhan
      final response = await HttpService.get(_endpoint);

      if (response.body.isEmpty) {
        return ApiResponse<SummaryKeseluruhan>(
          status: 'error',
          message: 'Server tidak memberikan response',
        );
      }

      // Check if response is HTML (error page)
      if (response.body.trim().startsWith('<')) {
        return ApiResponse<SummaryKeseluruhan>(
          status: 'error',
          message: 'Server error: Response bukan JSON',
        );
      }

      late Map<String, dynamic> jsonData;
      try {
        jsonData = json.decode(response.body) as Map<String, dynamic>;
      } catch (e) {
        print('💥 [LAPORAN_SERVICE] JSON Parse Error: $e');
        return ApiResponse<SummaryKeseluruhan>(
          status: 'error',
          message: 'Format response tidak valid: ${e.toString()}',
        );
      }

      print('✅ [LAPORAN_SERVICE] Summary JSON Response: ${jsonData['status']}');

      if (jsonData['status'] == 'success') {
        // Periksa apakah response adalah summary keseluruhan
        if (jsonData['data']['type'] == 'summary_keseluruhan') {
          final summaryData = SummaryKeseluruhan.fromJson(jsonData['data']);

          print('🎉 [LAPORAN_SERVICE] Summary keseluruhan loaded successfully');
          print('   - Total Lahan: ${summaryData.totalLahan}');
          print('   - Total Biaya: ${summaryData.totalBiayaPerawatan}');
          print('   - Total Pendapatan: ${summaryData.totalPendapatan}');
          print('   - Total Keuntungan: ${summaryData.totalKeuntungan}');

          return ApiResponse<SummaryKeseluruhan>(
            status: 'success',
            message: jsonData['message'] ?? 'Summary berhasil dimuat',
            data: summaryData,
          );
        } else {
          return ApiResponse<SummaryKeseluruhan>(
            status: 'error',
            message: 'Response bukan summary keseluruhan',
          );
        }
      } else {
        print('❌ [LAPORAN_SERVICE] Failed: ${jsonData['message']}');
        return ApiResponse<SummaryKeseluruhan>(
          status: jsonData['status'] ?? 'error',
          message: jsonData['message'] ?? 'Gagal memuat summary',
        );
      }
    } catch (e, stackTrace) {
      print('💥 [LAPORAN_SERVICE] Error: $e');
      print('📚 [LAPORAN_SERVICE] Stack trace: $stackTrace');
      return ApiResponse<SummaryKeseluruhan>(
        status: 'error',
        message: 'Koneksi gagal: ${e.toString()}',
      );
    }
  }

  /// Get laporan data by lahan ID with optional date range
  static Future<ApiResponse<LaporanData>> getLaporanData({
    required int lahanId,
    String? tanggalDari,
    String? tanggalSampai,
  }) async {
    try {
      print('📊 [LAPORAN_SERVICE] Fetching laporan for lahan: $lahanId');
      print('   - Date range: $tanggalDari to $tanggalSampai');

      // Build query parameters
      Map<String, String> queryParams = {
        'lahan_id': lahanId.toString(),
      };

      // Add date filters if provided
      if (tanggalDari != null) {
        queryParams['tanggal_dari'] = formatDateForApi(tanggalDari);
      }
      if (tanggalSampai != null) {
        queryParams['tanggal_sampai'] = formatDateForApi(tanggalSampai);
      }

      // Build URL with query parameters
      String url = _endpoint;
      if (queryParams.isNotEmpty) {
        final queryString = queryParams.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&');
        url += '?$queryString';
      }

      print('📊 [LAPORAN_SERVICE] Request URL: $url');

      final response = await HttpService.get(url);

      if (response.body.isEmpty) {
        return ApiResponse<LaporanData>(
          status: 'error',
          message: 'Server tidak memberikan response',
        );
      }

      // Check if response is HTML (error page)
      if (response.body.trim().startsWith('<')) {
        return ApiResponse<LaporanData>(
          status: 'error',
          message: 'Server error: Response bukan JSON',
        );
      }

      late Map<String, dynamic> jsonData;
      try {
        jsonData = json.decode(response.body) as Map<String, dynamic>;
      } catch (e) {
        print('💥 [LAPORAN_SERVICE] JSON Parse Error: $e');
        return ApiResponse<LaporanData>(
          status: 'error',
          message: 'Format response tidak valid: ${e.toString()}',
        );
      }

      print('✅ [LAPORAN_SERVICE] JSON Response: ${jsonData['status']}');

      if (jsonData['status'] == 'success') {
        // Periksa apakah response adalah laporan lahan
        if (jsonData['data']['type'] == 'laporan_lahan') {
          final laporanData = LaporanData.fromJson(jsonData['data']);

          print('🎉 [LAPORAN_SERVICE] Laporan data loaded successfully');
          print('   - Lahan: ${laporanData.lahan.nama}');
          print(
              '   - Perawatan: ${laporanData.perawatan.totalRecords} records');
          print('   - Panen: ${laporanData.panen.totalRecords} records');
          print(
              '   - Total Keuntungan: ${laporanData.summary.totalKeuntungan}');

          return ApiResponse<LaporanData>(
            status: 'success',
            message: jsonData['message'] ?? 'Data laporan berhasil dimuat',
            data: laporanData,
          );
        } else {
          return ApiResponse<LaporanData>(
            status: 'error',
            message: 'Response bukan laporan lahan yang valid',
          );
        }
      } else {
        print('❌ [LAPORAN_SERVICE] Failed: ${jsonData['message']}');
        return ApiResponse<LaporanData>(
          status: jsonData['status'] ?? 'error',
          message: jsonData['message'] ?? 'Gagal memuat data laporan',
        );
      }
    } catch (e, stackTrace) {
      print('💥 [LAPORAN_SERVICE] Error: $e');
      print('📚 [LAPORAN_SERVICE] Stack trace: $stackTrace');
      return ApiResponse<LaporanData>(
        status: 'error',
        message: 'Koneksi gagal: ${e.toString()}',
      );
    }
  }

  /// Get available lahan for laporan selection
  /// Get available lahan for laporan selection
  static Future<ApiResponse<List<Map<String, dynamic>>>>
      getAvailableLahan() async {
    try {
      print('📋 [LAPORAN_SERVICE] Fetching available lahan for laporan');

      // Gunakan endpoint lahan yang benar untuk list
      const lahanEndpoint = 'lahan.php'; // Tanpa parameter endpoint=create

      final response = await HttpService.get(lahanEndpoint);

      if (response.body.isEmpty) {
        return ApiResponse<List<Map<String, dynamic>>>(
          status: 'error',
          message: 'Server tidak memberikan response',
        );
      }

      late Map<String, dynamic> jsonData;
      try {
        jsonData = json.decode(response.body) as Map<String, dynamic>;
      } catch (e) {
        print('💥 [LAPORAN_SERVICE] JSON Parse Error: $e');
        return ApiResponse<List<Map<String, dynamic>>>(
          status: 'error',
          message: 'Format response tidak valid: ${e.toString()}',
        );
      }

      print('📋 [LAPORAN_SERVICE] Response structure: ${jsonData.keys}');
      print('📋 [LAPORAN_SERVICE] Data type: ${jsonData['data'].runtimeType}');

      if (jsonData['status'] == 'success') {
        // Handle different response structures
        List<Map<String, dynamic>> availableLahan = [];

        if (jsonData['data'] is List) {
          // Jika data berupa array
          final List<dynamic> lahanList = jsonData['data'] ?? [];
          availableLahan =
              lahanList.map((item) => Map<String, dynamic>.from(item)).toList();
        } else if (jsonData['data'] is Map) {
          // Jika data berupa object dengan array di dalamnya
          final Map<String, dynamic> dataMap = jsonData['data'];
          if (dataMap.containsKey('lahan') && dataMap['lahan'] is List) {
            final List<dynamic> lahanList = dataMap['lahan'];
            availableLahan = lahanList
                .map((item) => Map<String, dynamic>.from(item))
                .toList();
          } else {
            // Jika data adalah single object, wrap dalam array
            availableLahan = [Map<String, dynamic>.from(dataMap)];
          }
        }

        print(
            '✅ [LAPORAN_SERVICE] Available lahan loaded: ${availableLahan.length} items');

        return ApiResponse<List<Map<String, dynamic>>>(
          status: 'success',
          message: 'Daftar lahan berhasil dimuat',
          data: availableLahan,
        );
      } else {
        return ApiResponse<List<Map<String, dynamic>>>(
          status: jsonData['status'] ?? 'error',
          message: jsonData['message'] ?? 'Gagal memuat daftar lahan',
        );
      }
    } catch (e, stackTrace) {
      print('💥 [LAPORAN_SERVICE] Error fetching lahan: $e');
      print('📚 [LAPORAN_SERVICE] Stack trace: $stackTrace');
      return ApiResponse<List<Map<String, dynamic>>>(
        status: 'error',
        message: 'Koneksi gagal: ${e.toString()}',
      );
    }
  }

  /// Validate laporan request parameters
  static String? validateLaporanRequest({
    required int lahanId,
    String? tanggalDari,
    String? tanggalSampai,
  }) {
    if (lahanId <= 0) {
      return 'ID Lahan tidak valid';
    }

    // If both dates provided, validate them
    if (tanggalDari != null && tanggalSampai != null) {
      try {
        final dari = DateTime.parse(formatDateForApi(tanggalDari));
        final sampai = DateTime.parse(formatDateForApi(tanggalSampai));

        if (dari.isAfter(sampai)) {
          return 'Tanggal dari tidak boleh lebih besar dari tanggal sampai';
        }

        if (sampai.isAfter(DateTime.now())) {
          return 'Tanggal sampai tidak boleh melebihi hari ini';
        }

        // Check if date range is not too far in the past (optional validation)
        final oneYearAgo = DateTime.now().subtract(const Duration(days: 365));
        if (dari.isBefore(oneYearAgo)) {
          return 'Tanggal dari tidak boleh lebih dari 1 tahun yang lalu';
        }
      } catch (e) {
        return 'Format tanggal tidak valid';
      }
    }

    // If only one date provided
    if ((tanggalDari != null && tanggalSampai == null) ||
        (tanggalDari == null && tanggalSampai != null)) {
      return 'Jika menggunakan filter tanggal, kedua tanggal harus diisi';
    }

    return null;
  }

  /// Validate summary request parameters (for date filtering)
  static String? validateSummaryRequest({
    String? tanggalDari,
    String? tanggalSampai,
  }) {
    if (tanggalDari != null && tanggalSampai != null) {
      try {
        final dari = DateTime.parse(formatDateForApi(tanggalDari));
        final sampai = DateTime.parse(formatDateForApi(tanggalSampai));

        if (dari.isAfter(sampai)) {
          return 'Tanggal dari tidak boleh lebih besar dari tanggal sampai';
        }

        if (sampai.isAfter(DateTime.now())) {
          return 'Tanggal sampai tidak boleh melebihi hari ini';
        }
      } catch (e) {
        return 'Format tanggal tidak valid';
      }
    }

    if ((tanggalDari != null && tanggalSampai == null) ||
        (tanggalDari == null && tanggalSampai != null)) {
      return 'Jika menggunakan filter tanggal, kedua tanggal harus diisi';
    }

    return null;
  }

  /// Format date for API (convert DD-MM-YYYY to YYYY-MM-DD)
  static String formatDateForApi(String dateStr) {
    try {
      // If already in YYYY-MM-DD format
      if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateStr)) {
        return dateStr;
      }

      // If in DD-MM-YYYY format
      if (RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(dateStr)) {
        final parts = dateStr.split('-');
        return '${parts[2]}-${parts[1]}-${parts[0]}';
      }

      // If in DD/MM/YYYY format
      if (RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(dateStr)) {
        final parts = dateStr.split('/');
        return '${parts[2]}-${parts[1]}-${parts[0]}';
      }

      // If in other format, try parsing and format
      final date = DateTime.parse(dateStr);
      return dateTimeToApiFormat(date);
    } catch (e) {
      print('⚠️ [LAPORAN_SERVICE] Date format error: $e');
      return dateStr; // Return original if parsing fails
    }
  }

  /// Convert DateTime to API format (YYYY-MM-DD)
  static String dateTimeToApiFormat(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Convert API format (YYYY-MM-DD) to display format (DD-MM-YYYY)
  static String formatDateForDisplay(String apiDateStr) {
    try {
      if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(apiDateStr)) {
        final parts = apiDateStr.split('-');
        return '${parts[2]}-${parts[1]}-${parts[0]}';
      }
      return apiDateStr;
    } catch (e) {
      print('⚠️ [LAPORAN_SERVICE] Display date format error: $e');
      return apiDateStr;
    }
  }

  /// Get month name in Indonesian
  static String getMonthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return (month >= 1 && month <= 12) ? months[month - 1] : 'Invalid';
  }

  /// Format date to Indonesian format (DD MMMM YYYY)
  static String formatDateToIndonesian(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day} ${getMonthName(date.month)} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  /// Check if date range is valid
  static bool isValidDateRange(String? tanggalDari, String? tanggalSampai) {
    if (tanggalDari == null || tanggalSampai == null) return true;

    try {
      final dari = DateTime.parse(formatDateForApi(tanggalDari));
      final sampai = DateTime.parse(formatDateForApi(tanggalSampai));
      return !dari.isAfter(sampai);
    } catch (e) {
      return false;
    }
  }

  /// Format currency for display
  static String formatCurrency(int amount) {
    if (amount == 0) return 'Rp 0';

    final formatted = amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );

    return 'Rp $formatted';
  }

  /// Get date range text for display
  static String getDateRangeText(String? tanggalDari, String? tanggalSampai) {
    if (tanggalDari == null || tanggalSampai == null) {
      return 'Semua periode';
    }

    try {
      final dari = formatDateToIndonesian(formatDateForApi(tanggalDari));
      final sampai = formatDateToIndonesian(formatDateForApi(tanggalSampai));
      return '$dari - $sampai';
    } catch (e) {
      return 'Periode tidak valid';
    }
  }
}
