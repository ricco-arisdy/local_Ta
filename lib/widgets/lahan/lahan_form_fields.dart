import 'package:flutter/material.dart';
import 'package:ta_project/models/app_constants.dart';

class LahanFormFields extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController namaController;
  final TextEditingController lokasiController;
  final TextEditingController luasController;
  final TextEditingController titikTanamController;
  final TextEditingController waktuBeliController;
  final String selectedStatusKepemilikan;
  final String selectedStatusKebun;
  final String selectedLuas;
  final Function(String?) onStatusKepemilikanChanged;
  final Function(String?) onStatusKebunChanged;
  final VoidCallback onDatePicker;
  final bool isCustomLuas;
  final Function(String?) onLuasChanged;

  const LahanFormFields({
    Key? key,
    required this.formKey,
    required this.namaController,
    required this.lokasiController,
    required this.luasController,
    required this.titikTanamController,
    required this.waktuBeliController,
    required this.selectedStatusKepemilikan,
    required this.selectedStatusKebun,
    required this.selectedLuas,
    required this.onStatusKepemilikanChanged,
    required this.onStatusKebunChanged,
    required this.onDatePicker,
    required this.isCustomLuas,
    required this.onLuasChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama Lahan
          _buildTextField(
            controller: namaController,
            label: 'Nama Lahan',
            icon: Icons.grass_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nama lahan harus diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Lokasi
          _buildTextField(
            controller: lokasiController,
            label: 'Lokasi Lahan',
            icon: Icons.location_on_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Lokasi harus diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Luas Lahan
          _buildLuasField(),
          const SizedBox(height: 16),

          // Titik Tanam
          _buildTextField(
            controller: titikTanamController,
            label: 'Jumlah Titik Tanam',
            icon: Icons.eco_outlined,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Jumlah titik tanam harus diisi';
              }
              if (int.tryParse(value) == null) {
                return 'Harus berupa angka';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Waktu Beli
          _buildDateField(),
          const SizedBox(height: 16),

          // Status Kepemilikan
          _buildDropdownField(
            label: 'Status Kepemilikan',
            icon: Icons.badge_outlined,
            value: selectedStatusKepemilikan,
            items: LahanConstants.statusKepemilikanOptions,
            onChanged: onStatusKepemilikanChanged,
          ),
          const SizedBox(height: 16),

          // Status Kebun
          _buildDropdownField(
            label: 'Status Kebun',
            icon: Icons.park_outlined,
            value: selectedStatusKebun,
            items: LahanConstants.statusKebunOptions,
            onChanged: onStatusKebunChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
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
          readOnly: readOnly,
          onTap: onTap,
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  // ✅ FIX: Perbaiki _buildLuasField dengan getter selectedLuas
  // Widget _buildLuasField() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text(
  //         'Luas Lahan (Hektar)',
  //         style: TextStyle(
  //           fontSize: 14,
  //           fontWeight: FontWeight.w600,
  //           color: Color(AppColors.darkGreen),
  //         ),
  //       ),
  //       const SizedBox(height: 8),

  //       // ✅ DROPDOWN untuk pilihan predefined
  //       DropdownButtonFormField<String>(
  //         value:
  //             _getSelectedLuasValue(), // ✅ Method baru untuk ambil value yang benar
  //         decoration: InputDecoration(
  //           prefixIcon: const Icon(
  //             Icons.square_foot_outlined,
  //             color: Color(AppColors.primaryGreen),
  //           ),
  //           filled: true,
  //           fillColor: Colors.grey.shade50,
  //           border: OutlineInputBorder(
  //             borderRadius: BorderRadius.circular(12),
  //             borderSide: BorderSide(color: Colors.grey.shade300),
  //           ),
  //           enabledBorder: OutlineInputBorder(
  //             borderRadius: BorderRadius.circular(12),
  //             borderSide: BorderSide(color: Colors.grey.shade300),
  //           ),
  //           focusedBorder: OutlineInputBorder(
  //             borderRadius: BorderRadius.circular(12),
  //             borderSide: const BorderSide(
  //               color: Color(AppColors.primaryGreen),
  //               width: 2,
  //             ),
  //           ),
  //           contentPadding: const EdgeInsets.symmetric(
  //             horizontal: 16,
  //             vertical: 14,
  //           ),
  //         ),
  //         items: LahanConstants.luasOptions.map((String value) {
  //           return DropdownMenuItem<String>(
  //             value: value,
  //             child: Text(
  //               value == 'Lainnya' ? value : '$value Ha',
  //               style: const TextStyle(fontSize: 14),
  //             ),
  //           );
  //         }).toList(),
  //         onChanged: onLuasChanged,
  //         validator: (value) {
  //           if (value == null || value.isEmpty) {
  //             return 'Pilih luas lahan';
  //           }
  //           // ✅ Validasi untuk custom input
  //           if (value == 'Lainnya' && (luasController.text.isEmpty)) {
  //             return 'Isi luas lahan custom';
  //           }
  //           return null;
  //         },
  //       ),

  //       // ✅ Custom input jika pilih "Lainnya"
  //       if (isCustomLuas) ...[
  //         const SizedBox(height: 12),
  //         TextFormField(
  //           controller: luasController,
  //           keyboardType: const TextInputType.numberWithOptions(decimal: true),
  //           decoration: InputDecoration(
  //             labelText: 'Masukkan Luas (Ha)',
  //             hintText: 'Contoh: 2.5',
  //             prefixIcon: const Icon(
  //               Icons.edit_outlined,
  //               color: Color(AppColors.primaryGreen),
  //             ),
  //             filled: true,
  //             fillColor: Colors.grey.shade50,
  //             border: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(12),
  //               borderSide: BorderSide(color: Colors.grey.shade300),
  //             ),
  //             enabledBorder: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(12),
  //               borderSide: BorderSide(color: Colors.grey.shade300),
  //             ),
  //             focusedBorder: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(12),
  //               borderSide: const BorderSide(
  //                 color: Color(AppColors.primaryGreen),
  //                 width: 2,
  //               ),
  //             ),
  //             errorBorder: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(12),
  //               borderSide: const BorderSide(color: Colors.red, width: 2),
  //             ),
  //             contentPadding: const EdgeInsets.symmetric(
  //               horizontal: 16,
  //               vertical: 14,
  //             ),
  //           ),
  //           validator: (value) {
  //             if (isCustomLuas && (value == null || value.isEmpty)) {
  //               return 'Luas lahan harus diisi';
  //             }
  //             if (isCustomLuas && double.tryParse(value!) == null) {
  //               return 'Harus berupa angka';
  //             }
  //             return null;
  //           },
  //         ),
  //       ],
  //     ],
  //   );
  // }
  Widget _buildLuasField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Luas Lahan (Hektar)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(AppColors.darkGreen),
          ),
        ),
        const SizedBox(height: 8),

        // ✅ DROPDOWN untuk pilihan predefined
        DropdownButtonFormField<String>(
          value: _getSelectedLuasValue(),
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.square_foot_outlined,
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
          items: LahanConstants.luasOptions.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value == 'Lainnya' ? value : '$value Ha',
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: onLuasChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Pilih luas lahan';
            }
            if (value == 'Lainnya' && luasController.text.isEmpty) {
              return 'Isi luas lahan custom';
            }
            return null;
          },
        ),

        // ✅ Custom input jika pilih "Lainnya"
        if (isCustomLuas) ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: luasController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Masukkan Luas (Ha)',
              hintText: 'Contoh: 2.5',
              prefixIcon: const Icon(
                Icons.edit_outlined,
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
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            validator: (value) {
              if (isCustomLuas && (value == null || value.isEmpty)) {
                return 'Luas lahan harus diisi';
              }
              if (isCustomLuas && double.tryParse(value!) == null) {
                return 'Harus berupa angka';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  // ✅ TAMBAHKAN METHOD INI untuk menentukan value dropdown yang benar
  // String? _getSelectedLuasValue() {
  //   // Jika sedang custom input, return "Lainnya"
  //   if (selectedLuas.isNotEmpty) {
  //     return selectedLuas;
  //   }

  //   // Jika luasController ada isi (saat edit mode dengan custom value)
  //   if (luasController.text.isNotEmpty) {
  //     // Cek apakah ada di predefined options
  //     if (LahanConstants.luasOptions.contains(luasController.text)) {
  //       return luasController.text;
  //     }
  //     // Jika tidak ada, berarti custom, return "Lainnya"
  //     return 'Lainnya';
  //   }

  //   // Return null jika belum ada pilihan
  //   return null;
  // }
  String? _getSelectedLuasValue() {
    // Jika selectedLuas sudah diset dan valid
    if (selectedLuas.isNotEmpty &&
        LahanConstants.luasOptions.contains(selectedLuas)) {
      return selectedLuas;
    }

    // Jika luasController ada isi (saat edit mode)
    if (luasController.text.isNotEmpty) {
      final luasValue = luasController.text.trim();

      // ✅ TAMBAHAN: Cek apakah value ada di predefined options
      if (LahanConstants.luasOptions.contains(luasValue)) {
        return luasValue;
      }

      // ✅ PENTING: Jika tidak ada, otomatis set ke "Lainnya"
      // Dan trigger isCustomLuas
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!isCustomLuas) {
          onLuasChanged('Lainnya');
        }
      });

      return 'Lainnya';
    }

    // Return null jika belum ada pilihan
    return null;
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Waktu Beli/Sewa',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(AppColors.darkGreen),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: waktuBeliController,
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
              return 'Tanggal harus dipilih';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
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
        DropdownButtonFormField<String>(
          value: value.isEmpty ? null : value,
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '$label harus dipilih';
            }
            return null;
          },
        ),
      ],
    );
  }
}
