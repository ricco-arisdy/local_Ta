import 'package:flutter/material.dart';
import 'package:ta_project/models/app_constants.dart';
import 'package:ta_project/models/lahan_models.dart';

class PanenFormFields extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController tanggalController;
  final TextEditingController jumlahController;
  final TextEditingController hargaController;
  final TextEditingController catatanController;
  final List<Lahan> lahanList;
  final int? selectedLahanId;
  final Function(int?) onLahanChanged;
  final VoidCallback onDatePicker;

  const PanenFormFields({
    Key? key,
    required this.formKey,
    required this.tanggalController,
    required this.jumlahController,
    required this.hargaController,
    required this.catatanController,
    required this.lahanList,
    required this.selectedLahanId,
    required this.onLahanChanged,
    required this.onDatePicker,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pilih Lahan
          _buildLahanDropdown(),
          const SizedBox(height: 16),

          // Tanggal Panen
          _buildDateField(),
          const SizedBox(height: 16),

          // Jumlah Panen
          _buildTextField(
            controller: jumlahController,
            label: 'Jumlah Panen (Kg)',
            icon: Icons.scale_outlined,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Jumlah panen harus diisi';
              }
              if (int.tryParse(value) == null) {
                return 'Harus berupa angka';
              }
              if (int.parse(value) <= 0) {
                return 'Jumlah harus lebih dari 0';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Harga per Kg
          _buildTextField(
            controller: hargaController,
            label: 'Harga per Kg (Rp)',
            icon: Icons.attach_money_outlined,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Harga harus diisi';
              }
              if (int.tryParse(value) == null) {
                return 'Harus berupa angka';
              }
              if (int.parse(value) < 0) {
                return 'Harga tidak boleh negatif';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Catatan (Optional)
          _buildTextField(
            controller: catatanController,
            label: 'Catatan (Opsional)',
            icon: Icons.note_outlined,
            maxLines: 3,
            validator: null, // Optional field
          ),
        ],
      ),
    );
  }

  Widget _buildLahanDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Lahan',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(AppColors.darkGreen),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: selectedLahanId,
          isExpanded: true,
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.local_activity_outlined,
              color: Color(AppColors.primaryGreen),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(AppColors.primaryGreen),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          hint: const Text('Pilih lahan untuk panen'),
          items: lahanList.map((Lahan lahan) {
            return DropdownMenuItem<int>(
              value: lahan.id,
              child: Container(
                // ✅ TAMBAH Container untuk kontrol layout
                constraints: const BoxConstraints(
                  maxWidth: double.infinity, // Maksimal lebar
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      lahan.nama,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1, // ✅ TAMBAH maxLines
                      overflow:
                          TextOverflow.ellipsis, // ✅ TAMBAH overflow handling
                    ),
                    Text(
                      '${lahan.lokasi} - ${lahan.luas} Ha',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1, // ✅ TAMBAH maxLines
                      overflow:
                          TextOverflow.ellipsis, // ✅ TAMBAH overflow handling
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          onChanged: onLahanChanged,
          validator: (value) {
            if (value == null) {
              return 'Pilih lahan terlebih dahulu';
            }
            return null;
          },
          menuMaxHeight: 300, // Maksimal tinggi dropdown menu
          selectedItemBuilder: (BuildContext context) {
            // ✅ TAMBAH custom builder untuk item yang terpilih
            return lahanList.map<Widget>((Lahan lahan) {
              return Container(
                alignment: Alignment.centerLeft,
                constraints: const BoxConstraints(
                  maxWidth: double.infinity,
                ),
                child: Text(
                  '${lahan.nama} (${lahan.luas} Ha)',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList();
          },
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tanggal Panen',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(AppColors.darkGreen),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: tanggalController,
          readOnly: true,
          onTap: onDatePicker,
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.calendar_today_outlined,
              color: Color(AppColors.primaryGreen),
            ),
            hintText: 'Pilih tanggal',
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(AppColors.primaryGreen),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Tanggal panen harus dipilih';
            }

            // ✅ ADD DD-MM-YYYY format validation
            final datePattern = RegExp(r'^\d{2}-\d{2}-\d{4}$');
            if (!datePattern.hasMatch(value)) {
              return 'Format tanggal harus DD-MM-YYYY';
            }

            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(AppColors.darkGreen),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(AppColors.primaryGreen)),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(AppColors.primaryGreen),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines > 1 ? 16 : 14,
            ),
          ),
        ),
      ],
    );
  }
}
