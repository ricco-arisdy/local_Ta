import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ta_project/models/lahan_models.dart';
import 'package:ta_project/models/app_constants.dart';
import 'package:ta_project/viewsModels/lahan_view_models.dart';
import 'package:ta_project/widgets/lahan/lahan_form_fields.dart';
import 'package:ta_project/widgets/theme/tema_utama.dart';

class LahanFormPage extends StatefulWidget {
  final Lahan? lahan;

  const LahanFormPage({
    Key? key,
    this.lahan,
  }) : super(key: key);

  @override
  State<LahanFormPage> createState() => _LahanFormPageState();
}

class _LahanFormPageState extends State<LahanFormPage> {
  late LahanViewModel viewModel;
  bool get isEditing => widget.lahan != null;

  @override
  void initState() {
    super.initState();

    // ✅ PENTING: Delay untuk memastikan widget sudah build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<LahanViewModel>(context, listen: false);

      if (isEditing && widget.lahan != null) {
        // Mode edit - set data lahan
        vm.setSelectedLahan(widget.lahan!);
      } else {
        // Mode tambah baru - pastikan form bersih
        vm.clearForm();
      }
    });
  }

  @override
  void dispose() {
    // ✅ Reset form saat keluar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final vm = context.read<LahanViewModel>();
        vm.resetForm();
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
              final vm = Provider.of<LahanViewModel>(context, listen: false);
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
              isEditing ? 'Edit Lahan' : 'Tambah Lahan Baru',
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
    return Consumer<LahanViewModel>(
      builder: (context, vm, child) {
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
                            Icons.landscape,
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
                                'Informasi Lahan',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Isi data dengan lengkap dan benar',
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
                        LahanFormFields(
                          formKey: vm.formKey,
                          namaController: vm.namaController,
                          lokasiController: vm.lokasiController,
                          luasController: vm.luasController,
                          titikTanamController: vm.titikTanamController,
                          waktuBeliController: vm.waktuBeliController,
                          selectedStatusKepemilikan:
                              vm.selectedStatusKepemilikan,
                          selectedStatusKebun: vm.selectedStatusKebun,
                          selectedLuas: vm.selectedLuas,
                          onStatusKepemilikanChanged: vm.setStatusKepemilikan,
                          onStatusKebunChanged: vm.setStatusKebun,
                          onDatePicker: () => vm.selectDate(context),
                          isCustomLuas: vm.isCustomLuas,
                          onLuasChanged: vm.setLuas,
                        ),

                        // Error Message
                        if (vm.hasError)
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
                                        vm.errorMessage,
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
                        const SizedBox(height: 24),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey.shade200,
                        ),
                        const SizedBox(height: 20),
                        // Ganti bagian Action Buttons (mulai dari Row yang berisi button Batal dan Simpan)
// dengan kode ini:

                        Row(
                          children: [
                            // Button Batal - Red Outline
                            Expanded(
                              child: OutlinedButton(
                                onPressed: vm.isLoading
                                    ? null
                                    : () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  side: BorderSide(
                                    color: vm.isLoading
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
                                    color: vm.isLoading
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
                                onPressed:
                                    vm.isLoading ? null : () => _handleSave(vm),
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  side: BorderSide(
                                    color: vm.isLoading
                                        ? Colors.grey.shade300
                                        : const Color(0xFF2F8653), // Hijau
                                    width: 2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: vm.isLoading
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            const Color(0xFF2F8653),
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
                                                ? 'Update Lahan'
                                                : 'Simpan Lahan',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF2F8653), // Hijau
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        )
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

  void _handleSave(LahanViewModel vm) async {
    bool success;

    if (isEditing) {
      success = await vm.updateLahan(widget.lahan!.id);
    } else {
      success = await vm.createLahan();
    }

    if (mounted) {
      if (success) {
        final message = isEditing
            ? 'Lahan berhasil diupdate'
            : 'Lahan berhasil ditambahkan';

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
