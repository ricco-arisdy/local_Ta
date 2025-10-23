class Perawatan {
  final int id;
  final int kebunId;
  final String kegiatan;
  final String tanggal;
  final int jumlah;
  final String? satuan;
  final int biaya;
  final String? catatan;
  final String? namaKebun;
  final String? lokasiKebun;
  final String? namaUser;

  Perawatan({
    required this.id,
    required this.kebunId,
    required this.kegiatan,
    required this.tanggal,
    required this.jumlah,
    this.satuan,
    required this.biaya,
    this.catatan,
    this.namaKebun,
    this.lokasiKebun,
    this.namaUser,
  });

  factory Perawatan.fromJson(Map<String, dynamic> json) {
    // Normalisasi satuan dari database
    String? normalizedSatuan;
    if (json['satuan'] != null && json['satuan'].toString().isNotEmpty) {
      final rawSatuan = json['satuan'].toString().trim();

      // Cari satuan yang cocok dengan opsi yang tersedia (case insensitive)
      final validSatuans = ['Kg', 'Liter'];
      normalizedSatuan = validSatuans.firstWhere(
        (option) => option.toLowerCase() == rawSatuan.toLowerCase(),
        orElse: () => '',
      );

      // Jika tidak ditemukan yang cocok, set ke null
      if (normalizedSatuan.isEmpty) {
        normalizedSatuan = null;
      }
    }

    return Perawatan(
      id: json['id'] ?? 0,
      kebunId: json['kebun_id'] ?? 0,
      kegiatan: json['kegiatan'] ?? '',
      tanggal: json['tanggal'] ?? '',
      jumlah: json['jumlah'] ?? 0,
      satuan: normalizedSatuan,
      biaya: json['biaya'] ?? 0,
      catatan: json['catatan'],
      namaKebun: json['nama_kebun'],
      lokasiKebun: json['lokasi_kebun'],
      namaUser: json['nama_user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kebun_id': kebunId,
      'kegiatan': kegiatan,
      'tanggal': tanggal,
      'jumlah': jumlah,
      if (satuan != null) 'satuan': satuan,
      'biaya': biaya,
      if (catatan != null) 'catatan': catatan,
      if (namaKebun != null) 'nama_kebun': namaKebun,
      if (lokasiKebun != null) 'lokasi_kebun': lokasiKebun,
      if (namaUser != null) 'nama_user': namaUser,
    };
  }

  // Helper method untuk format tanggal input (DD-MM-YYYY)
  String get formattedDateInput {
    try {
      DateTime parsedDate = DateTime.parse(tanggal);
      return '${parsedDate.day.toString().padLeft(2, '0')}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.year}';
    } catch (e) {
      return tanggal;
    }
  }

  // Helper method untuk format tanggal yang lebih readable
  String get formattedDate {
    try {
      DateTime parsedDate = DateTime.parse(tanggal);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des'
      ];
      return '${parsedDate.day} ${months[parsedDate.month - 1]} ${parsedDate.year}';
    } catch (e) {
      return tanggal;
    }
  }

  DateTime get parsedDate {
    try {
      return DateTime.parse(tanggal);
    } catch (e) {
      // Jika format tanggal tidak standar, coba parsing manual
      if (tanggal.contains('-') && tanggal.split('-').length == 3) {
        final parts = tanggal.split('-');

        // Cek apakah format DD-MM-YYYY
        if (parts[0].length == 2 &&
            parts[1].length == 2 &&
            parts[2].length == 4) {
          try {
            return DateTime(
              int.parse(parts[2]), // year
              int.parse(parts[1]), // month
              int.parse(parts[0]), // day
            );
          } catch (e) {
            // Fallback ke tanggal hari ini
            return DateTime.now();
          }
        }
      }

      // Fallback default
      return DateTime.now();
    }
  }

  int compareByDateAndId(Perawatan other) {
    // Primary sort: Date (newest first)
    final dateComparison = other.parsedDate.compareTo(parsedDate);

    // Secondary sort: ID (newest first) jika tanggal sama
    if (dateComparison == 0) {
      return other.id.compareTo(id);
    }

    return dateComparison;
  }

  // Helper method untuk format biaya dengan pemisah ribuan
  String get formattedBiaya {
    final formatter = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return biaya
        .toString()
        .replaceAllMapped(formatter, (Match m) => '${m[1]},');
  }

  // Method untuk membuat object baru dengan perubahan tertentu
  Perawatan copyWith({
    int? id,
    int? kebunId,
    String? kegiatan,
    String? tanggal,
    int? jumlah,
    String? satuan,
    int? biaya,
    String? catatan,
    String? namaKebun,
    String? lokasiKebun,
    String? namaUser,
  }) {
    return Perawatan(
      id: id ?? this.id,
      kebunId: kebunId ?? this.kebunId,
      kegiatan: kegiatan ?? this.kegiatan,
      tanggal: tanggal ?? this.tanggal,
      jumlah: jumlah ?? this.jumlah,
      satuan: satuan ?? this.satuan,
      biaya: biaya ?? this.biaya,
      catatan: catatan ?? this.catatan,
      namaKebun: namaKebun ?? this.namaKebun,
      lokasiKebun: lokasiKebun ?? this.lokasiKebun,
      namaUser: namaUser ?? this.namaUser,
    );
  }

  @override
  String toString() {
    return 'Perawatan{id: $id, kebunId: $kebunId, kegiatan: $kegiatan, tanggal: $tanggal, jumlah: $jumlah, satuan: $satuan, biaya: $biaya, catatan: $catatan}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Perawatan &&
        other.id == id &&
        other.kebunId == kebunId &&
        other.kegiatan == kegiatan &&
        other.tanggal == tanggal &&
        other.jumlah == jumlah &&
        other.satuan == satuan &&
        other.biaya == biaya &&
        other.catatan == catatan;
  }

  @override
  int get hashCode {
    return Object.hash(
        id, kebunId, kegiatan, tanggal, jumlah, satuan, biaya, catatan);
  }
}

// Model untuk request create/update perawatan
class PerawatanRequest {
  final int kebunId;
  final String kegiatan;
  final String tanggal;
  final int jumlah;
  final String? satuan;
  final int biaya;
  final String? catatan;

  PerawatanRequest({
    required this.kebunId,
    required this.kegiatan,
    required this.tanggal,
    required this.jumlah,
    this.satuan,
    required this.biaya,
    this.catatan,
  });

  Map<String, dynamic> toJson() {
    return {
      'kebun_id': kebunId,
      'kegiatan': kegiatan,
      'tanggal': tanggal,
      'jumlah': jumlah,
      if (satuan != null) 'satuan': satuan,
      'biaya': biaya,
      'catatan': catatan,
    };
  }

  factory PerawatanRequest.fromPerawatan(Perawatan perawatan) {
    return PerawatanRequest(
      kebunId: perawatan.kebunId,
      kegiatan: perawatan.kegiatan,
      tanggal: perawatan.tanggal,
      jumlah: perawatan.jumlah,
      satuan: perawatan.satuan,
      biaya: perawatan.biaya,
      catatan: perawatan.catatan,
    );
  }
}

// Model untuk metadata response dari API
class PerawatanMetadata {
  final int totalRecords;
  final int totalPages;
  final int currentPage;
  final int totalBiaya;

  PerawatanMetadata({
    required this.totalRecords,
    required this.totalPages,
    required this.currentPage,
    required this.totalBiaya,
  });

  factory PerawatanMetadata.fromJson(Map<String, dynamic> json) {
    return PerawatanMetadata(
      totalRecords: json['total_records'] ?? 0,
      totalPages: json['total_pages'] ?? 0,
      currentPage: json['current_page'] ?? 1,
      totalBiaya: json['total_biaya'] ?? 0,
    );
  }
}

// Model untuk response list perawatan dengan metadata
class PerawatanListResponse {
  final List<Perawatan> data;
  final PerawatanMetadata metadata;

  PerawatanListResponse({
    required this.data,
    required this.metadata,
  });

  factory PerawatanListResponse.fromJson(Map<String, dynamic> json) {
    return PerawatanListResponse(
      data: (json['data']['perawatan'] as List?)
              ?.map((item) => Perawatan.fromJson(item))
              .toList() ??
          [],
      metadata: PerawatanMetadata.fromJson(json['data']['metadata'] ?? {}),
    );
  }
}
