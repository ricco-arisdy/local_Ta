import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ta_project/models/app_constants.dart';
import 'package:ta_project/models/lahan_models.dart';
import 'package:ta_project/views/lahan/lahan_form_page.dart';
import 'package:ta_project/viewsModels/lahan_view_models.dart';
import 'package:ta_project/widgets/theme/tema_utama.dart';

class LahanDetailPage extends StatefulWidget {
  final int lahanId;

  const LahanDetailPage({
    Key? key,
    required this.lahanId,
  }) : super(key: key);

  @override
  State<LahanDetailPage> createState() => _LahanDetailPageState();
}

class _LahanDetailPageState extends State<LahanDetailPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LahanViewModel()
        ..loadLahanById(widget.lahanId), // ✅ Create dan load data
      child: Scaffold(
        body: AuthBackgroundCore(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildContent()),
            ],
          ),
        ),
        floatingActionButton: Consumer<LahanViewModel>(
          builder: (context, vm, child) {
            if (vm.selectedLahan == null) return const SizedBox();

            return FloatingActionButton(
              onPressed: () => _navigateToEdit(vm.selectedLahan!),
              backgroundColor: const Color(AppColors.primaryGreen),
              foregroundColor: Colors.white,
              child: const Icon(Icons.edit),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<LahanViewModel>(
      builder: (context, vm, child) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 24,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vm.selectedLahan?.nama ?? 'Detail Lahan',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      vm.selectedLahan?.lokasi ?? 'Memuat informasi...',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.white,
                ),
                onSelected: (value) {
                  if (value == 'edit' && vm.selectedLahan != null) {
                    _navigateToEdit(vm.selectedLahan!);
                  } else if (value == 'delete' && vm.selectedLahan != null) {
                    _showDeleteConfirmation(vm.selectedLahan!);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Hapus', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return Consumer<LahanViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(AppColors.primaryGreen),
              ),
            ),
          );
        }

        if (vm.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  vm.errorMessage,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => vm.loadLahanById(widget.lahanId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(AppColors.primaryGreen),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        if (vm.selectedLahan == null) {
          return const Center(
            child: Text('Lahan tidak ditemukan'),
          );
        }

        final lahan = vm.selectedLahan!;

        return SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header Image/Icon
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(AppColors.primaryGreen).withOpacity(0.1),
                        const Color(AppColors.lightGreen).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(AppColors.primaryGreen)
                              .withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.grass_outlined,
                          size: 48,
                          color: Color(AppColors.primaryGreen),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        lahan.nama,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(AppColors.darkGreen),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Detail Information
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildDetailRow(
                          'Lokasi', lahan.lokasi, Icons.location_on),
                      _buildDetailRow('Luas Lahan', '${lahan.luas} Hektar',
                          Icons.square_foot),
                      _buildDetailRow('Titik Tanam',
                          '${lahan.titikTanam} Titik', Icons.place),
                      _buildDetailRow('Waktu Beli/Sewa', lahan.waktuBeli,
                          Icons.calendar_today),
                      _buildDetailRow('Status Kepemilikan',
                          lahan.statusKepemilikan, Icons.business),
                      _buildDetailRow(
                          'Status Kebun', lahan.statusKebun, Icons.eco,
                          statusColor: _getStatusKebunColor(lahan.statusKebun)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon,
      {Color? statusColor}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (statusColor ?? const Color(AppColors.primaryGreen))
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: statusColor ?? const Color(AppColors.primaryGreen),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: statusColor ?? const Color(AppColors.darkGreen),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusKebunColor(String status) {
    switch (status.toLowerCase()) {
      case 'belum ditanam':
        return const Color(AppColors.warningOrange);
      case 'sudah ditanam':
        return const Color(AppColors.primaryGreen);
      case 'masa panen':
        return const Color(AppColors.successGreen);
      case 'istirahat':
        return Colors.grey;
      default:
        return const Color(AppColors.primaryGreen);
    }
  }

  void _navigateToEdit(Lahan lahan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LahanFormPage(lahan: lahan),
      ),
    ).then((_) {
      // Refresh data setelah kembali dari edit
      final vm = Provider.of<LahanViewModel>(context, listen: false);
      vm.loadLahanById(widget.lahanId);
    });
  }

  void _showDeleteConfirmation(Lahan lahan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red.shade600,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Konfirmasi Hapus',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus lahan "${lahan.nama}"?\n\nData yang sudah dihapus tidak dapat dikembalikan.',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => _handleDelete(lahan),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Hapus',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleDelete(Lahan lahan) async {
    Navigator.of(context).pop(); // Close dialog

    final vm = Provider.of<LahanViewModel>(context, listen: false);
    final success = await vm.deleteLahan(lahan.id);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lahan "${lahan.nama}" berhasil dihapus'),
            backgroundColor: const Color(AppColors.successGreen),
          ),
        );
        Navigator.pop(context); // Back to list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
