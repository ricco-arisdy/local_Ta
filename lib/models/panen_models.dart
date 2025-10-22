class Panen {
  final int id;
  final int lahanId;
  final String tanggal;
  final int jumlah;
  final int harga;
  final String? catatan;
  final String? namaLahan;
  final String? lokasiLahan;
  final String? namaUser;

  Panen({
    required this.id,
    required this.lahanId,
    required this.tanggal,
    required this.jumlah,
    required this.harga,
    this.catatan,
    this.namaLahan,
    this.lokasiLahan,
    this.namaUser,
  });

  factory Panen.fromJson(Map<String, dynamic> json) {
    return Panen(
      id: json['id'] ?? 0,
      lahanId: json['lahan_id'] ?? 0,
      tanggal: json['tanggal'] ?? '',
      jumlah: json['jumlah'] ?? 0,
      harga: json['harga'] ?? 0,
      catatan: json['catatan'],
      namaLahan: json['nama_lahan'],
      lokasiLahan: json['lokasi_lahan'],
      namaUser: json['nama_user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lahan_id': lahanId,
      'tanggal': tanggal,
      'jumlah': jumlah,
      'harga': harga,
      if (catatan != null) 'catatan': catatan,
      if (namaLahan != null) 'nama_lahan': namaLahan,
      if (lokasiLahan != null) 'lokasi_lahan': lokasiLahan,
      if (namaUser != null) 'nama_user': namaUser,
    };
  }

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

  int compareByDateAndId(Panen other) {
    // Primary sort: Date (newest first)
    final dateComparison = other.parsedDate.compareTo(parsedDate);

    // Secondary sort: ID (newest first) jika tanggal sama
    if (dateComparison == 0) {
      return other.id.compareTo(id);
    }

    return dateComparison;
  }

  // Helper method untuk format harga dengan pemisah ribuan
  String get formattedHarga {
    final formatter = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return harga
        .toString()
        .replaceAllMapped(formatter, (Match m) => '${m[1]},');
  }

  // Helper method untuk menghitung total nilai panen
  int get totalNilai => jumlah * harga;

  // Helper method untuk format total nilai dengan pemisah ribuan
  String get formattedTotalNilai {
    final formatter = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return totalNilai
        .toString()
        .replaceAllMapped(formatter, (Match m) => '${m[1]},');
  }

  // Method untuk create copy dengan perubahan tertentu
  Panen copyWith({
    int? id,
    int? lahanId,
    String? tanggal,
    int? jumlah,
    int? harga,
    String? catatan,
    String? namaLahan,
    String? lokasiLahan,
    String? namaUser,
  }) {
    return Panen(
      id: id ?? this.id,
      lahanId: lahanId ?? this.lahanId,
      tanggal: tanggal ?? this.tanggal,
      jumlah: jumlah ?? this.jumlah,
      harga: harga ?? this.harga,
      catatan: catatan ?? this.catatan,
      namaLahan: namaLahan ?? this.namaLahan,
      lokasiLahan: lokasiLahan ?? this.lokasiLahan,
      namaUser: namaUser ?? this.namaUser,
    );
  }

  @override
  String toString() {
    return 'Panen{id: $id, lahanId: $lahanId, tanggal: $tanggal, jumlah: $jumlah, harga: $harga, catatan: $catatan}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Panen &&
        other.id == id &&
        other.lahanId == lahanId &&
        other.tanggal == tanggal &&
        other.jumlah == jumlah &&
        other.harga == harga &&
        other.catatan == catatan;
  }

  @override
  int get hashCode {
    return Object.hash(id, lahanId, tanggal, jumlah, harga, catatan);
  }
}

// Model untuk metadata response dari API
class PanenMetadata {
  final int totalRecords;
  final int totalPages;
  final int currentPage;
  final int totalNilai;

  PanenMetadata({
    required this.totalRecords,
    required this.totalPages,
    required this.currentPage,
    required this.totalNilai,
  });

  factory PanenMetadata.fromJson(Map<String, dynamic> json) {
    return PanenMetadata(
      totalRecords: json['total_records'] ?? 0,
      totalPages: json['total_pages'] ?? 0,
      currentPage: json['current_page'] ?? 1,
      totalNilai: json['total_nilai'] ?? 0,
    );
  }
}

// Model untuk response list panen dari API
class PanenListResponse {
  final List<Panen> data;
  final PanenMetadata metadata;

  PanenListResponse({
    required this.data,
    required this.metadata,
  });

  factory PanenListResponse.fromJson(Map<String, dynamic> json) {
    return PanenListResponse(
      data: (json['data']['panen'] as List?)
              ?.map((item) => Panen.fromJson(item))
              .toList() ??
          [],
      metadata: PanenMetadata.fromJson(json['data']['metadata'] ?? {}),
    );
  }
}
