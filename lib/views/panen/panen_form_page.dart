import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ta_project/models/panen_models.dart';
import 'package:ta_project/models/app_constants.dart';
import 'package:ta_project/viewsModels/panen_view_models.dart';
import 'package:ta_project/viewsModels/lahan_view_models.dart';
import 'package:ta_project/widgets/panen/panen_form_fields.dart';
import 'package:ta_project/widgets/theme/tema_utama.dart';

class PanenFormPage extends StatefulWidget {
  final Panen? panen;

  const PanenFormPage({
    Key? key,
    this.panen,
  }) : super(key: key);

  @override
  State<PanenFormPage> createState() => _PanenFormPageState();
}

class _PanenFormPageState extends State<PanenFormPage> {
  bool get isEditing => widget.panen != null;

  @override
  void initState() {
    super.initState();

    // ✅ PENTING: Delay untuk memastikan widget sudah build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final panenVm = Provider.of<PanenViewModel>(context, listen: false);
      final lahanVm = Provider.of<LahanViewModel>(context, listen: false);

      // Load data lahan terlebih dahulu
      lahanVm.loadAllLahan();

      if (isEditing && widget.panen != null) {
        // Mode edit - set data panen
        panenVm.setSelectedPanen(widget.panen!);
      } else {
        // Mode tambah baru - pastikan form bersih
        panenVm.clearForm();
      }
    });
  }

  @override
  void dispose() {
    // ✅ Reset form saat keluar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final vm = context.read<PanenViewModel>();
        vm.clearForm();
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AuthBackgroundCore(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(child: _buildForm()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 8,
        16,
        8,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              // ✅ Clear form saat back
              final vm = Provider.of<PanenViewModel>(context, listen: false);
              vm.clearForm();
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: Text(
              isEditing ? 'Edit Panen' : 'Tambah Panen Baru',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Consumer2<PanenViewModel, LahanViewModel>(
      builder: (context, panenVm, lahanVm, child) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20,
                0,
                20,
                MediaQuery.of(context).padding.bottom +
                    20 // ✅ Navigation bar padding
                ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Card Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2F8653).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.agriculture_outlined,
                            color: Color(0xFF2F8653),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Data Panen',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Catat hasil panen dengan lengkap',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Divider
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.grey.shade200,
                  ),

                  // Form Fields Container
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Loading state untuk lahan
                        if (lahanVm.isLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF2F8653),
                                ),
                              ),
                            ),
                          )
                        else if (lahanVm.hasError)
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.red.shade200,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Gagal memuat data lahan: ${lahanVm.errorMessage}',
                                  style: TextStyle(
                                    color: Colors.red.shade600,
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () => lahanVm.loadAllLahan(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade600,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(0, 32),
                                  ),
                                  child: const Text('Coba Lagi'),
                                ),
                              ],
                            ),
                          )
                        else if (lahanVm.lahanList.isEmpty)
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.orange.shade200,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.orange.shade600,
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Belum ada lahan yang tersedia',
                                  style: TextStyle(
                                    color: Colors.orange.shade800,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Silakan tambahkan lahan terlebih dahulu',
                                  style: TextStyle(
                                    color: Colors.orange.shade600,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/lahan');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange.shade600,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(0, 32),
                                  ),
                                  child: const Text('Tambah Lahan'),
                                ),
                              ],
                            ),
                          )
                        else
                          PanenFormFields(
                            formKey: panenVm.formKey,
                            tanggalController: panenVm.tanggalController,
                            jumlahController: panenVm.jumlahController,
                            hargaController: panenVm.hargaController,
                            catatanController: panenVm.catatanController,
                            lahanList: lahanVm.lahanList,
                            selectedLahanId: panenVm.selectedLahanId,
                            onLahanChanged: (int? value) =>
                                panenVm.setSelectedLahan(value), // ✅ FIX INI
                            onDatePicker: () => _selectDate(context, panenVm),
                          ),

                        // Monthly Limit Warning
                        if (!isEditing && // Only show for new panen
                            panenVm.selectedLahanId != null &&
                            panenVm.tanggalController.text.isNotEmpty)
                          _buildMonthlyLimitWarning(panenVm, lahanVm),

                        // Error Message
                        if (panenVm.hasError)
                          Container(
                            margin: const EdgeInsets.only(top: 20),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.red.shade200,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.error_outline,
                                    color: Colors.red.shade700,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Terjadi Kesalahan',
                                        style: TextStyle(
                                          color: Colors.red.shade700,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        panenVm.errorMessage,
                                        style: TextStyle(
                                          color: Colors.red.shade600,
                                          fontSize: 13,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Action Buttons
                        if (!lahanVm.isLoading &&
                            lahanVm.lahanList.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.grey.shade200,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              // Button Batal - Red Outline
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: panenVm.isFormLoading
                                      ? null
                                      : () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    side: BorderSide(
                                      color: panenVm.isFormLoading
                                          ? Colors.grey.shade300
                                          : const Color(0xFFE53935), // Merah
                                      width: 2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Batal',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: panenVm.isFormLoading
                                          ? Colors.grey.shade400
                                          : const Color(0xFFE53935), // Merah
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Button Simpan - Green Outline
                              Expanded(
                                flex: 2,
                                child: OutlinedButton(
                                  onPressed: panenVm.isFormLoading
                                      ? null
                                      : () => _handleSave(panenVm),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    side: BorderSide(
                                      color: panenVm.isFormLoading
                                          ? Colors.grey.shade300
                                          : const Color(0xFF2F8653), // Hijau
                                      width: 2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: panenVm.isFormLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Color(0xFF2F8653),
                                            ),
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              isEditing
                                                  ? Icons.check_circle
                                                  : Icons.save,
                                              size: 20,
                                              color: const Color(
                                                  0xFF2F8653), // Hijau
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              isEditing
                                                  ? 'Update Panen'
                                                  : 'Simpan Panen',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    Color(0xFF2F8653), // Hijau
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMonthlyLimitWarning(
      PanenViewModel panenVm, LahanViewModel lahanVm) {
    if (panenVm.isCheckingLimit) {
      return Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(
              'Mengecek limit bulanan...',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    if (panenVm.monthlyLimitInfo != null) {
      final limitInfo = panenVm.monthlyLimitInfo!;
      final currentCount = limitInfo['current_count'] ?? 0;
      final maxLimit = limitInfo['max_limit'] ?? 2;
      final canAdd = limitInfo['can_add'] ?? false;
      final monthYear = limitInfo['month_year'] ?? '';

      // Find lahan name
      String lahanName = 'Lahan';
      try {
        final lahan = lahanVm.lahanList.firstWhere(
          (l) => l.id == panenVm.selectedLahanId,
        );
        lahanName = lahan.nama;
      } catch (e) {
        // Keep default name if not found
      }

      Color bgColor;
      Color borderColor;
      Color textColor;
      IconData icon;
      String title;

      if (canAdd) {
        if (currentCount == 0) {
          bgColor = Colors.green.shade50;
          borderColor = Colors.green.shade200;
          textColor = Colors.green.shade700;
          icon = Icons.check_circle_outline;
          title = 'Dapat Menambah Data';
        } else {
          bgColor = Colors.orange.shade50;
          borderColor = Colors.orange.shade200;
          textColor = Colors.orange.shade700;
          icon = Icons.warning_amber_outlined;
          title = 'Perhatian';
        }
      } else {
        bgColor = Colors.red.shade50;
        borderColor = Colors.red.shade200;
        textColor = Colors.red.shade700;
        icon = Icons.block_outlined;
        title = 'Limit Terlampaui';
      }

      return Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: textColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              canAdd
                  ? 'Lahan "$lahanName" memiliki $currentCount/$maxLimit data panen di bulan $monthYear.'
                  : 'Lahan "$lahanName" sudah mencapai batas maksimal $maxLimit data panen di bulan $monthYear.',
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            if (!canAdd) ...[
              const SizedBox(height: 8),
              Text(
                'Hapus salah satu data panen bulan ini untuk menambah data baru.',
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // Date picker method
  Future<void> _selectDate(BuildContext context, PanenViewModel vm) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2F8653),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // ✅ UBAH FORMAT KE DD-MM-YYYY
      vm.tanggalController.text =
          "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
    }
  }

  void _handleSave(PanenViewModel vm) async {
    // Validasi form key
    if (!vm.formKey.currentState!.validate()) {
      return;
    }

    bool success;

    if (isEditing) {
      success = await vm.updatePanen(widget.panen!.id);
    } else {
      success = await vm.createPanen();
    }

    if (mounted) {
      if (success) {
        final message = isEditing
            ? 'Panen berhasil diupdate'
            : 'Panen berhasil ditambahkan';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(message)),
              ],
            ),
            backgroundColor: const Color(AppColors.successGreen),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );

        Navigator.pop(context);
      }
    }
  }
}
