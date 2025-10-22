class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://192.168.100.6/tani-api/';
  static const Duration timeoutDuration = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 15);

  // App Configuration
  static const String appName = 'TA Project';
  static const String appVersion = '1.0.0';

  // SharedPreferences Keys
  static const String userDataKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';
  static const String rememberMeKey = 'remember_me';
  static const String savedEmailKey = 'saved_email';
  static const String savedPasswordKey = 'saved_password';
  static const String tokenKey = 'auth_token';
}

class ApiEndpoints {
  // Auth endpoints
  static const String login = 'auth.php?endpoint=login';
  static const String register = 'auth.php?endpoint=register';
  static const String profile = 'auth.php?endpoint=profile';
  static const String logout = 'auth.php?endpoint=logout';

  // Lahan endpoints
  static const String lahan = 'lahan.php?endpoint=create';

  //Lahan endpoints
  static const String panen = 'panen.php';

  // Perawatan endpoints
  static const String perawatan = 'perawatan.php';

  // Laporan endpoints
  static const String laporanData = 'laporan_data.php';
}

class AppColors {
  static const int primaryGreen = 0xFF4CAF50;
  static const int secondaryGreen = 0xFF6B8E23;
  static const int lightGreen = 0xFF8FBC8F;
  static const int darkGreen = 0xFF2C5F2D;
  static const int errorRed = 0xFFE53E3E;
  static const int warningOrange = 0xFFFF8A00;
  static const int successGreen = 0xFF10B981;
  static const int infoBlue = 0xFF3B82F6;

  // warna untuk laporan
  static const int profitGreen = 0xFF10B981;
  static const int lossRed = 0xFFF44336;
  static const int neutralGray = 0xFF6B7280;
}

class LahanConstants {
  // Status Kepemilikan options
  static const List<String> statusKepemilikanOptions = [
    'Pribadi',
    'Sewa',
    'Bagi Hasil',
    'Kontrak',
  ];

  // Status Kebun options
  static const List<String> statusKebunOptions = [
    'Aktif',
    'Tidak Aktif',
    'Peremajaan',
  ];

  // Luas options (dalam hektar)
  static const List<String> luasOptions = [
    '0.5',
    '1.0',
    '1.5',
    '2.0',
    '2.5',
    '3.0',
    '5.0',
    'Lainnya',
  ];
}

class PerawatanConstants {
  // Jenis kegiatan perawatan yang umum
  static const List<String> jenisKegiatanOptions = [
    'Pemupukan',
    'Penyemprotan',
    'Pemangkasan Tunas',
    'Pemangkasan Gulma',
    'Penyiraman',
  ];

  // Satuan untuk jumlah
  static const List<String> satuanOptions = [
    'Kg',
    'Liter',
  ];
}

class LaporanConstants {
  // Quick date range options
  static const List<String> quickDateRanges = [
    'Bulan Ini',
    'Tahun Ini',
    '30 Hari Terakhir',
    '3 Bulan Terakhir',
    'Periode Kustom',
  ];

  // Export format options
  static const List<String> exportFormats = [
    'PDF',
    'Excel',
    'CSV',
  ];

  // Report types
  static const List<String> reportTypes = [
    'Ringkasan',
    'Detail Perawatan',
    'Detail Panen',
    'Analisis Keuntungan',
  ];

  // Performance categories
  static const Map<String, String> performanceCategories = {
    'sangat_menguntungkan': 'Sangat Menguntungkan',
    'menguntungkan': 'Menguntungkan',
    'sedikit_menguntungkan': 'Sedikit Menguntungkan',
    'impas': 'Impas',
    'sedikit_merugikan': 'Sedikit Merugikan',
    'merugikan': 'Merugikan',
    'sangat_merugikan': 'Sangat Merugikan',
    'belum_ada_aktivitas': 'Belum Ada Aktivitas',
  };

  // ROI thresholds
  static const double excellentROI = 50.0;
  static const double goodROI = 20.0;
  static const double fairROI = 0.0;
  static const double poorROI = -20.0;
  static const double veryPoorROI = -50.0;
}
