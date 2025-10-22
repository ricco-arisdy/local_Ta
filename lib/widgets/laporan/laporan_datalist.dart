import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/laporan_models.dart';
import '../../models/app_constants.dart';

class LaporanDataList extends StatelessWidget {
  final String title;
  final IconData icon;
  final int count;
  final List<PerawatanLaporanItem> perawatanData;
  final List<PanenLaporanItem> panenData;
  final bool isPerawatan;

  const LaporanDataList({
    super.key,
    required this.title,
    required this.icon,
    required this.count,
    required this.perawatanData,
    required this.panenData,
    required this.isPerawatan,
  });

  @override
  Widget build(BuildContext context) {
    final formatCurrency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final formatDate = DateFormat('dd/MM/yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Icon(icon, color: const Color(AppColors.primaryGreen)),
            const SizedBox(width: 8),
            Text(
              '$title ($count)',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(AppColors.darkGreen),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Data List
        if (isPerawatan && perawatanData.isEmpty)
          _buildEmptyState('Belum ada data perawatan')
        else if (!isPerawatan && panenData.isEmpty)
          _buildEmptyState('Belum ada data panen')
        else if (isPerawatan)
          ...perawatanData.map(
              (item) => _buildPerawatanCard(item, formatCurrency, formatDate))
        else
          ...panenData
              .map((item) => _buildPanenCard(item, formatCurrency, formatDate)),
      ],
    );
  }

  Widget _buildPerawatanCard(
    PerawatanLaporanItem item,
    NumberFormat formatCurrency,
    DateFormat formatDate,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange.shade100,
          child: Icon(Icons.build, color: Colors.orange.shade700, size: 20),
        ),
        title: Text(
          item.kegiatan,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${_formatDateForDisplay(item.tanggal, formatDate)} • ${item.jumlah} unit',
        ),
        trailing: Text(
          formatCurrency.format(item.biaya),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red.shade700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildPanenCard(
    PanenLaporanItem item,
    NumberFormat formatCurrency,
    DateFormat formatDate,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(AppColors.lightGreen),
          child: Icon(Icons.eco,
              color: const Color(AppColors.darkGreen), size: 20),
        ),
        title: Text(
          '${item.jumlah} kg',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${_formatDateForDisplay(item.tanggal, formatDate)} • ${formatCurrency.format(item.harga)}/kg',
        ),
        trailing: Text(
          formatCurrency.format(item.total),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(AppColors.primaryGreen),
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.inbox, size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text(
                message,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateForDisplay(String dateStr, DateFormat formatter) {
    try {
      final date = DateTime.parse(dateStr);
      return formatter.format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
