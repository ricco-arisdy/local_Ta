import 'package:flutter/material.dart';
import 'package:ta_project/models/lahan_models.dart';

class LahanCard extends StatelessWidget {
  final Lahan lahan;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final int? cardIndex; // ✅ Tambahkan parameter untuk variasi warna

  const LahanCard({
    Key? key,
    required this.lahan,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.cardIndex, // ✅ Optional parameter
  }) : super(key: key);

  // ✅ Fungsi untuk mendapatkan gradient berdasarkan index
  List<Color> _getCardGradient() {
    if (cardIndex == null) {
      // Default hijau
      return [const Color(0xFF66BB6A), const Color(0xFF4CAF50)];
    }

    // Rotasi 3 warna berbeda
    switch (cardIndex! % 3) {
      case 0:
        // Hijau
        return [const Color(0xFF66BB6A), const Color(0xFF4CAF50)];
      case 1:
        // Biru
        return [const Color(0xFF42A5F5), const Color(0xFF2196F3)];
      case 2:
        // Orange
        return [const Color(0xFFFF9800), const Color(0xFFF57C00)];
      default:
        return [const Color(0xFF66BB6A), const Color(0xFF4CAF50)];
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      String day = date.day.toString().padLeft(2, '0');
      String month = date.month.toString().padLeft(2, '0');
      return '$day-$month-${date.year}';
    } catch (e) {
      return dateString; // Jika parsing gagal, return string asli
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // ✅ BAGIAN ATAS: Background dengan gradient dinamis
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _getCardGradient(), // ✅ Gunakan fungsi dinamis
                ),
              ),
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lahan.nama,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    lahan.lokasi,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(0, -4),
                        child: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              onEdit();
                            } else if (value == 'delete') {
                              onDelete();
                            }
                          },
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                            size: 20,
                          ),
                          offset: const Offset(0, -8),
                          position: PopupMenuPosition.under,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.zero,
                          itemBuilder: (context) => [
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit,
                                    size: 18,
                                    color: Color(0xFF2196F3),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Edit',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    size: 18,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Hapus',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ✅ BAGIAN BAWAH: Background putih
            InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistics Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            'Luas',
                            '${lahan.luas} ha',
                            Icons.square_foot,
                            const Color(0xFF4CAF50),
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            'Titik Tanam',
                            lahan.titikTanam.toString(),
                            Icons.place,
                            const Color(0xFF2196F3),
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            'Status',
                            lahan.statusKebun,
                            Icons.eco,
                            _getStatusColor(lahan.statusKebun),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Additional info
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          //Fungsi format date
                          Text(
                            'Dibeli: ${_formatDate(lahan.waktuBeli)}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 16,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey, // ✅ Kembali ke grey untuk background putih
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'aktif':
      case 'sudah ditanam':
        return const Color(0xFF4CAF50);
      case 'belum ditanam':
        return const Color(0xFFFF9800);
      case 'masa panen':
        return const Color(0xFF2196F3);
      case 'istirahat':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
