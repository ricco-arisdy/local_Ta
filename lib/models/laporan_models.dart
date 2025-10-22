class LaporanData {
  final LahanLaporan lahan;
  final PeriodeLaporan periode;
  final PerawatanLaporan perawatan;
  final PanenLaporan panen;
  final SummaryLaporan summary;
  final MetadataLaporan metadata;

  LaporanData({
    required this.lahan,
    required this.periode,
    required this.perawatan,
    required this.panen,
    required this.summary,
    required this.metadata,
  });

  factory LaporanData.fromJson(Map<String, dynamic> json) {
    return LaporanData(
      lahan: LahanLaporan.fromJson(json['lahan']),
      periode: PeriodeLaporan.fromJson(json['periode']),
      perawatan: PerawatanLaporan.fromJson(json['perawatan']),
      panen: PanenLaporan.fromJson(json['panen']),
      summary: SummaryLaporan.fromJson(json['summary']),
      metadata: MetadataLaporan.fromJson(json['metadata']),
    );
  }
}

class LahanLaporan {
  final int id;
  final String nama;
  final String lokasi;
  final String luas;
  final int titikTanam;
  final String waktuBeli;
  final String statusKepemilikan;
  final String statusKebun;
  final String namaUser;

  LahanLaporan({
    required this.id,
    required this.nama,
    required this.lokasi,
    required this.luas,
    required this.titikTanam,
    required this.waktuBeli,
    required this.statusKepemilikan,
    required this.statusKebun,
    required this.namaUser,
  });

  factory LahanLaporan.fromJson(Map<String, dynamic> json) {
    return LahanLaporan(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? '',
      lokasi: json['lokasi'] ?? '',
      luas: json['luas'] ?? '',
      titikTanam: json['titik_tanam'] ?? 0,
      waktuBeli: json['waktu_beli'] ?? '',
      statusKepemilikan: json['status_kepemilikan'] ?? '',
      statusKebun: json['status_kebun'] ?? '',
      namaUser: json['nama_user'] ?? '',
    );
  }
}

class PeriodeLaporan {
  final String? tanggalDari;
  final String? tanggalSampai;
  final String dicetakPada;

  PeriodeLaporan({
    this.tanggalDari,
    this.tanggalSampai,
    required this.dicetakPada,
  });

  factory PeriodeLaporan.fromJson(Map<String, dynamic> json) {
    return PeriodeLaporan(
      tanggalDari: json['tanggal_dari'],
      tanggalSampai: json['tanggal_sampai'],
      dicetakPada: json['dicetak_pada'] ?? '',
    );
  }
}

class PerawatanLaporan {
  final List<PerawatanLaporanItem> data;
  final int totalRecords;
  final int totalBiaya;
  final double rataRataBiaya;

  PerawatanLaporan({
    required this.data,
    required this.totalRecords,
    required this.totalBiaya,
    required this.rataRataBiaya,
  });

  factory PerawatanLaporan.fromJson(Map<String, dynamic> json) {
    return PerawatanLaporan(
      data: (json['data'] as List?)
              ?.map((item) => PerawatanLaporanItem.fromJson(item))
              .toList() ??
          [],
      totalRecords: json['total_records'] ?? 0,
      totalBiaya: json['total_biaya'] ?? 0,
      rataRataBiaya: (json['rata_rata_biaya'] ?? 0.0).toDouble(),
    );
  }
}

// class PerawatanLaporanItem {
//   final int id;
//   final int kebunId;
//   final String kegiatan;
//   final String tanggal;
//   final int jumlah;
//   final int biaya;
//   final String? catatan;

//   PerawatanLaporanItem({
//     required this.id,
//     required this.kebunId,
//     required this.kegiatan,
//     required this.tanggal,
//     required this.jumlah,
//     required this.biaya,
//     this.catatan,
//   });

//   factory PerawatanLaporanItem.fromJson(Map<String, dynamic> json) {
//     return PerawatanLaporanItem(
//       id: json['id'] ?? 0,
//       kebunId: json['kebun_id'] ?? 0,
//       kegiatan: json['kegiatan'] ?? '',
//       tanggal: json['tanggal'] ?? '',
//       jumlah: json['jumlah'] ?? 0,
//       biaya: json['biaya'] ?? 0,
//       catatan: json['catatan'],
//     );
//   }
// }
class PerawatanLaporanItem {
  final int id;
  final int kebunId;
  final String kegiatan;
  final String tanggal;
  final int jumlah;
  final String? satuan; // ✅ TAMBAHKAN INI
  final int biaya;
  final String? catatan;

  PerawatanLaporanItem({
    required this.id,
    required this.kebunId,
    required this.kegiatan,
    required this.tanggal,
    required this.jumlah,
    this.satuan, // ✅ TAMBAHKAN INI
    required this.biaya,
    this.catatan,
  });

  factory PerawatanLaporanItem.fromJson(Map<String, dynamic> json) {
    return PerawatanLaporanItem(
      id: json['id'] ?? 0,
      kebunId: json['kebun_id'] ?? 0,
      kegiatan: json['kegiatan'] ?? '',
      tanggal: json['tanggal'] ?? '',
      jumlah: json['jumlah'] ?? 0,
      satuan: json['satuan'], // ✅ TAMBAHKAN INI
      biaya: json['biaya'] ?? 0,
      catatan: json['catatan'],
    );
  }
}

class PanenLaporan {
  final List<PanenLaporanItem> data;
  final int totalRecords;
  final int totalJumlahKg;
  final int totalPendapatan;
  final double rataRataJumlah;
  final double hargaRataPerKg;

  PanenLaporan({
    required this.data,
    required this.totalRecords,
    required this.totalJumlahKg,
    required this.totalPendapatan,
    required this.rataRataJumlah,
    required this.hargaRataPerKg,
  });

  factory PanenLaporan.fromJson(Map<String, dynamic> json) {
    return PanenLaporan(
      data: (json['data'] as List?)
              ?.map((item) => PanenLaporanItem.fromJson(item))
              .toList() ??
          [],
      totalRecords: json['total_records'] ?? 0,
      totalJumlahKg: json['total_jumlah_kg'] ?? 0,
      totalPendapatan: json['total_pendapatan'] ?? 0,
      rataRataJumlah: (json['rata_rata_jumlah'] ?? 0.0).toDouble(),
      hargaRataPerKg: (json['harga_rata_per_kg'] ?? 0.0).toDouble(),
    );
  }
}

class PanenLaporanItem {
  final int id;
  final int lahanId;
  final String tanggal;
  final int jumlah;
  final int harga;
  final String? catatan;
  final int total;

  PanenLaporanItem({
    required this.id,
    required this.lahanId,
    required this.tanggal,
    required this.jumlah,
    required this.harga,
    this.catatan,
    required this.total,
  });

  factory PanenLaporanItem.fromJson(Map<String, dynamic> json) {
    return PanenLaporanItem(
      id: json['id'] ?? 0,
      lahanId: json['lahan_id'] ?? 0,
      tanggal: json['tanggal'] ?? '',
      jumlah: json['jumlah'] ?? 0,
      harga: json['harga'] ?? 0,
      catatan: json['catatan'],
      total: json['total'] ?? 0,
    );
  }
}

class SummaryLaporan {
  final int totalBiayaPerawatan;
  final int totalPendapatan;
  final int totalKeuntungan;
  final double persentaseKeuntungan;
  final String statusKeuntungan;

  SummaryLaporan({
    required this.totalBiayaPerawatan,
    required this.totalPendapatan,
    required this.totalKeuntungan,
    required this.persentaseKeuntungan,
    required this.statusKeuntungan,
  });

  factory SummaryLaporan.fromJson(Map<String, dynamic> json) {
    return SummaryLaporan(
      totalBiayaPerawatan: json['total_biaya_perawatan'] ?? 0,
      totalPendapatan: json['total_pendapatan'] ?? 0,
      totalKeuntungan: json['total_keuntungan'] ?? 0,
      persentaseKeuntungan: (json['persentase_keuntungan'] ?? 0.0).toDouble(),
      statusKeuntungan: json['status_keuntungan'] ?? 'rugi',
    );
  }

  bool get isUntung => statusKeuntungan == 'untung';
}

class SummaryKeseluruhan {
  final int totalLahan;
  final String totalLuasLahan;
  final int totalBiayaPerawatan;
  final int totalPendapatan;
  final int totalKeuntungan;
  final double persentaseKeuntungan;
  final String statusKeuntungan;
  final int totalPerawatanRecords;
  final int totalPanenRecords;

  SummaryKeseluruhan({
    required this.totalLahan,
    required this.totalLuasLahan,
    required this.totalBiayaPerawatan,
    required this.totalPendapatan,
    required this.totalKeuntungan,
    required this.persentaseKeuntungan,
    required this.statusKeuntungan,
    required this.totalPerawatanRecords,
    required this.totalPanenRecords,
  });

  factory SummaryKeseluruhan.fromJson(Map<String, dynamic> json) {
    // ✅ SOLUSI TERBAIK: Defensive parsing untuk total_luas
    String parseTotalLuas(dynamic value) {
      if (value == null) {
        return '0 Ha';
      }

      String luasStr = value.toString().trim();

      // Jika sudah mengandung "Ha", return as is
      if (luasStr.toLowerCase().contains('ha')) {
        return luasStr;
      }

      // Jika kosong, return default
      if (luasStr.isEmpty || luasStr == '0') {
        return '0 Ha';
      }

      // Tambahkan " Ha" di akhir
      return '$luasStr Ha';
    }

    return SummaryKeseluruhan(
      totalLahan: json['total_lahan'] ?? 0,
      totalLuasLahan: parseTotalLuas(json['total_luas']), // ✅ Gunakan helper
      totalBiayaPerawatan: json['total_biaya_perawatan'] ?? 0,
      totalPendapatan: json['total_pendapatan'] ?? 0,
      totalKeuntungan: json['total_keuntungan'] ?? 0,
      persentaseKeuntungan: (json['persentase_keuntungan'] ?? 0.0).toDouble(),
      statusKeuntungan: json['status_keuntungan'] ?? 'rugi',
      totalPerawatanRecords: json['total_perawatan_records'] ?? 0,
      totalPanenRecords: json['total_panen_records'] ?? 0,
    );
  }

  bool get isUntung => statusKeuntungan == 'untung';
}

class MetadataLaporan {
  final int userId;
  final String userName;
  final String generatedAt;
  final String apiVersion;

  MetadataLaporan({
    required this.userId,
    required this.userName,
    required this.generatedAt,
    required this.apiVersion,
  });

  factory MetadataLaporan.fromJson(Map<String, dynamic> json) {
    return MetadataLaporan(
      userId: json['user_id'] ?? 0,
      userName: json['user_name'] ?? '',
      generatedAt: json['generated_at'] ?? '',
      apiVersion: json['api_version'] ?? '',
    );
  }
}
