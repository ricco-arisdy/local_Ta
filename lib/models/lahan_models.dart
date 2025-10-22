class Lahan {
  final int id;
  final int userId;
  final String nama;
  final String lokasi;
  final String luas;
  final int titikTanam;
  final String waktuBeli;
  final String statusKepemilikan;
  final String statusKebun;
  final String? namaUser;

  Lahan({
    required this.id,
    required this.userId,
    required this.nama,
    required this.lokasi,
    required this.luas,
    required this.titikTanam,
    required this.waktuBeli,
    required this.statusKepemilikan,
    required this.statusKebun,
    this.namaUser,
  });

  factory Lahan.fromJson(Map<String, dynamic> json) {
    return Lahan(
      id: json['id'],
      userId: json['user_id'],
      nama: json['nama'],
      lokasi: json['lokasi'],
      luas: json['luas'],
      // luas: (json['luas'] as String).trim(),
      titikTanam: json['titik_tanam'],
      waktuBeli: json['waktu_beli'],
      statusKepemilikan: json['status_kepemilikan'],
      statusKebun: json['status_kebun'],
      namaUser: json['nama_user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'nama': nama,
      'lokasi': lokasi,
      'luas': luas,
      // 'luas': luas.trim(),
      'titik_tanam': titikTanam,
      'waktu_beli': waktuBeli,
      'status_kepemilikan': statusKepemilikan,
      'status_kebun': statusKebun,
      if (namaUser != null) 'nama_user': namaUser,
    };
  }
}
