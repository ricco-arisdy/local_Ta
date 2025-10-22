import 'package:flutter/material.dart';
import 'package:ta_project/models/lahan_models.dart';
import 'package:ta_project/models/app_constants.dart';
import 'package:ta_project/repositories/lahan_repository.dart';
import 'package:ta_project/viewsModels/base_view_models.dart';
import 'package:ta_project/viewsModels/login_view_models.dart';

class LahanViewModel extends BaseViewModel {
  final LahanRepository _lahanRepository = LahanRepository();

  // Form controllers
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController lokasiController = TextEditingController();
  final TextEditingController luasController = TextEditingController();
  final TextEditingController titikTanamController = TextEditingController();
  final TextEditingController waktuBeliController = TextEditingController();

  // State variables
  List<Lahan> _lahanList = [];
  Lahan? _selectedLahan;
  String _selectedStatusKepemilikan = '';
  String _selectedStatusKebun = '';
  String _selectedLuas = '';
  bool _isCustomLuas = false;
  DateTime? _selectedDate;

  // Getters
  List<Lahan> get lahanList => _lahanList;
  Lahan? get selectedLahan => _selectedLahan;
  String get selectedStatusKepemilikan => _selectedStatusKepemilikan;
  String get selectedStatusKebun => _selectedStatusKebun;
  String get selectedLuas => _selectedLuas;
  bool get isCustomLuas => _isCustomLuas;
  DateTime? get selectedDate => _selectedDate;

  // Statistics
  int get totalLahan => _lahanList.length;
  double get totalLuas {
    return _lahanList.fold(0.0, (sum, lahan) {
      final luas = double.tryParse(lahan.luas) ?? 0.0;
      return sum + luas;
    });
  }

  int get totalTitikTanam {
    return _lahanList.fold(0, (sum, lahan) => sum + lahan.titikTanam);
  }

  LahanViewModel() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupLoginListener();
    });
  }

  void _setupLoginListener() {
    print('🔧 [LAHAN_VM] Setting up login listener...');
    LoginViewModel.logoutNotifier.addListener(() {
      print('🔔 [LAHAN_VM] Login state notification received');

      // ✅ FIX: Use addPostFrameCallback untuk avoid build conflict
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleLoginStateChange();
      });
    });
  }

  void _handleLoginStateChange() {
    print('🔄 [LAHAN_VM] Handling login state change...');

    // Simple strategy: selalu reload data dengan delay
    Future.delayed(const Duration(milliseconds: 300), () {
      loadAllLahan();
    });
  }

  void _handleLogout() {
    print('🧹 [LAHAN_VM] Handling logout - clearing all state...');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Clear all data
      _lahanList.clear();
      _selectedLahan = null;

      // Clear form
      clearForm();

      // Clear error state
      clearError();

      // Reset loading state
      setLoading(false);

      print('✅ [LAHAN_VM] All state cleared after logout');
      notifyListeners();
    });
  }

  // Load all lahan
  Future<void> loadAllLahan() async {
    print('🌱 [LAHAN_VM] Loading all lahan...');

    final response = await executeAsync(() => _lahanRepository.getAllLahan());

    if (response?.isSuccess == true) {
      _lahanList = response?.data ?? [];
      print('✅ [LAHAN_VM] Successfully loaded ${_lahanList.length} lahan');

      // ✅ Clear error jika berhasil load (even if empty)
      if (hasError) {
        clearError();
      }
    } else {
      // ✅ Set empty list jika gagal
      _lahanList = [];
      print('❌ [LAHAN_VM] Failed to load lahan: ${response?.message}');
    }

    notifyListeners();
  }

  // Get lahan by ID
  Future<void> loadLahanById(int id) async {
    print('🌱 [LAHAN_VM] Loading lahan by ID: $id');

    final response =
        await executeAsync(() => _lahanRepository.getLahanById(id));

    if (response?.isSuccess == true && response?.data != null) {
      _selectedLahan = response!.data;
      _populateFormFields(_selectedLahan!);
      print('✅ [LAHAN_VM] Successfully loaded lahan: ${_selectedLahan!.nama}');
    } else {
      setError(response?.message ?? 'Gagal memuat detail lahan');
    }
  }

  // Create new lahan
  Future<bool> createLahan() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    print('🌱 [LAHAN_VM] Creating new lahan...');

    final response = await executeAsync(() => _lahanRepository.createLahan(
          nama: namaController.text.trim(),
          lokasi: lokasiController.text.trim(),
          luas: _getFinalLuasValue(),
          titikTanam: int.parse(titikTanamController.text),
          waktuBeli: waktuBeliController.text,
          statusKepemilikan: _selectedStatusKepemilikan,
          statusKebun: _selectedStatusKebun,
        ));

    if (response?.isSuccess == true) {
      await loadAllLahan(); // Refresh list
      clearForm();
      print('✅ [LAHAN_VM] Successfully created lahan');
      return true;
    } else {
      setError(response?.message ?? 'Gagal menambahkan lahan');
      return false;
    }
  }

  // Update existing lahan
  Future<bool> updateLahan(int id) async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    print('🌱 [LAHAN_VM] Updating lahan ID: $id');

    final response = await executeAsync(() => _lahanRepository.updateLahan(
          id: id,
          nama: namaController.text.trim(),
          lokasi: lokasiController.text.trim(),
          luas: _getFinalLuasValue(),
          titikTanam: int.parse(titikTanamController.text),
          waktuBeli: waktuBeliController.text,
          statusKepemilikan: _selectedStatusKepemilikan,
          statusKebun: _selectedStatusKebun,
        ));

    if (response?.isSuccess == true) {
      await loadAllLahan(); // Refresh list
      print('✅ [LAHAN_VM] Successfully updated lahan');
      return true;
    } else {
      setError(response?.message ?? 'Gagal mengupdate lahan');
      return false;
    }
  }

  // Delete lahan
  Future<bool> deleteLahan(int id) async {
    print('🌱 [LAHAN_VM] Deleting lahan ID: $id');

    final response = await executeAsync(() => _lahanRepository.deleteLahan(id));

    if (response?.isSuccess == true) {
      await loadAllLahan(); // Refresh list
      print('✅ [LAHAN_VM] Successfully deleted lahan');
      return true;
    } else {
      setError(response?.message ?? 'Gagal menghapus lahan');
      return false;
    }
  }

  // Set selected lahan
  // ...existing code...

// Set selected lahan
  // void setSelectedLahan(Lahan lahan) {
  //   print('🔄 [LAHAN_VM] Setting selected lahan: ${lahan.nama}');
  //   _selectedLahan = lahan;

  //   // ✅ Isi semua controller dengan data lahan
  //   namaController.text = lahan.nama;
  //   lokasiController.text = lahan.lokasi;
  //   titikTanamController.text = lahan.titikTanam.toString();

  //   // ✅ FIX: Handle waktu beli dengan format DD-MM-YYYY (dash)
  //   if (lahan.waktuBeli.isNotEmpty) {
  //     waktuBeliController.text = lahan.waktuBeli;

  //     // Parse String ke DateTime untuk _selectedDate
  //     try {
  //       String dateString = lahan.waktuBeli;
  //       List<String> parts;

  //       // ✅ Support kedua format: DD-MM-YYYY dan DD/MM/YYYY
  //       if (dateString.contains('-')) {
  //         parts = dateString.split('-');
  //       } else if (dateString.contains('/')) {
  //         parts = dateString.split('/');
  //         // Convert format lama ke format baru
  //         waktuBeliController.text = '${parts[0]}-${parts[1]}-${parts[2]}';
  //       } else {
  //         throw Exception('Format tanggal tidak valid');
  //       }

  //       if (parts.length == 3) {
  //         _selectedDate = DateTime(
  //           int.parse(parts[2]), // year
  //           int.parse(parts[1]), // month
  //           int.parse(parts[0]), // day
  //         );
  //       }
  //     } catch (e) {
  //       print('⚠️ [LAHAN_VM] Error parsing date: $e');
  //       _selectedDate = null;
  //     }
  //   } else {
  //     waktuBeliController.clear();
  //     _selectedDate = null;
  //   }

  //   // ✅ Set status
  //   _selectedStatusKepemilikan = lahan.statusKepemilikan;
  //   _selectedStatusKebun = lahan.statusKebun;

  //   // ✅ PENTING: Handle luas lahan
  //   final luasValue = lahan.luas;

  //   // Cek apakah luas ada di predefined options
  //   if (LahanConstants.luasOptions.contains(luasValue)) {
  //     _selectedLuas = luasValue;
  //     _isCustomLuas = false;
  //     luasController.clear(); // Clear custom input
  //   } else {
  //     // Jika tidak ada di options, set sebagai custom
  //     _selectedLuas = 'Lainnya';
  //     _isCustomLuas = true;
  //     luasController.text = luasValue; // ✅ ISI CONTROLLER DENGAN NILAI LUAS
  //   }

  //   print('✅ [LAHAN_VM] Selected lahan set successfully');
  //   notifyListeners();
  // }
  void setSelectedLahan(Lahan lahan) {
    print('🔄 [LAHAN_VM] Setting selected lahan: ${lahan.nama}');
    _selectedLahan = lahan;

    namaController.text = lahan.nama;
    lokasiController.text = lahan.lokasi;
    titikTanamController.text = lahan.titikTanam.toString();

    // ✅ Handle waktu beli
    if (lahan.waktuBeli.isNotEmpty) {
      waktuBeliController.text = lahan.waktuBeli;

      try {
        String dateString = lahan.waktuBeli;
        List<String> parts;

        if (dateString.contains('-')) {
          parts = dateString.split('-');
        } else if (dateString.contains('/')) {
          parts = dateString.split('/');
          waktuBeliController.text = '${parts[0]}-${parts[1]}-${parts[2]}';
        } else {
          throw Exception('Format tanggal tidak valid');
        }

        if (parts.length == 3) {
          _selectedDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      } catch (e) {
        print('⚠️ [LAHAN_VM] Error parsing date: $e');
        _selectedDate = null;
      }
    } else {
      waktuBeliController.clear();
      _selectedDate = null;
    }

    _selectedStatusKepemilikan = lahan.statusKepemilikan;
    _selectedStatusKebun = lahan.statusKebun;

    // ✅ PERBAIKAN: Handle luas dengan lebih aman
    final luasValue = lahan.luas.trim();

    print('🔍 [LAHAN_VM] Processing luas value: "$luasValue"');

    if (LahanConstants.luasOptions.contains(luasValue)) {
      // Value ada di predefined options
      _selectedLuas = luasValue;
      _isCustomLuas = false;
      luasController.clear();
      print('✅ [LAHAN_VM] Luas found in predefined options: $luasValue');
    } else {
      // Value custom (tidak ada di options)
      _selectedLuas = 'Lainnya';
      _isCustomLuas = true;
      luasController.text = luasValue;
      print('✅ [LAHAN_VM] Luas set as custom: $luasValue');
    }

    print('✅ [LAHAN_VM] Selected lahan set successfully');
    print('   - Selected Luas: $_selectedLuas');
    print('   - Is Custom: $_isCustomLuas');
    print('   - Controller Value: ${luasController.text}');

    notifyListeners();
  }
// ...existing code...

  // Form field setters
  void setStatusKepemilikan(String? status) {
    _selectedStatusKepemilikan = status ?? '';
    notifyListeners();
  }

  void setStatusKebun(String? status) {
    _selectedStatusKebun = status ?? '';
    notifyListeners();
  }

  void setLuas(String? luas) {
    _selectedLuas = luas ?? '';
    _isCustomLuas = luas == 'Lainnya';

    if (!_isCustomLuas && luas != null && luas != 'Lainnya') {
      // ✅ Jangan isi luasController untuk predefined options
      // Biarkan kosong, value akan diambil dari selectedLuas
    } else if (_isCustomLuas) {
      // ✅ Kosongkan controller untuk input manual
      // luasController.clear(); // Jangan clear jika sedang edit
    }

    notifyListeners();
  }

  // Date picker
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(AppColors.primaryGreen),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      _selectedDate = picked;
      // ✅ UBAH: Format tanggal ke DD-MM-YYYY dengan dash
      waktuBeliController.text =
          '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
      notifyListeners();
    }
  }

  // Clear form
  void clearForm() {
    print('🧹 [LAHAN_VM] Clearing form...');

    namaController.clear();
    lokasiController.clear();
    luasController.clear();
    titikTanamController.clear();
    waktuBeliController.clear();
    _selectedStatusKepemilikan = '';
    _selectedStatusKebun = '';
    _selectedLuas = '';
    _isCustomLuas = false;
    _selectedDate = null;
    _selectedLahan = null;
    clearError();

    print('✅ [LAHAN_VM] Form cleared successfully');
    notifyListeners();
  }

  void resetForm() {
    clearForm(); // Gunakan method yang sudah ada
  }

  // Private methods
  void _populateFormFields(Lahan lahan) {
    namaController.text = lahan.nama;
    lokasiController.text = lahan.lokasi;

    // Check if luas is in predefined options
    if (LahanConstants.luasOptions.contains(lahan.luas)) {
      _selectedLuas = lahan.luas;
      _isCustomLuas = false;
      luasController.clear(); // ✅ Clear untuk predefined options
    } else {
      _selectedLuas = 'Lainnya';
      _isCustomLuas = true;
      luasController.text = lahan.luas;
    }

    titikTanamController.text = lahan.titikTanam.toString();
    _selectedStatusKepemilikan = lahan.statusKepemilikan;
    _selectedStatusKebun = lahan.statusKebun;

    // ✅ FIX: Handle waktu beli dengan format DD-MM-YYYY (sama seperti setSelectedLahan)
    if (lahan.waktuBeli.isNotEmpty) {
      try {
        String dateString = lahan.waktuBeli;
        List<String> parts;

        // Support kedua format: DD-MM-YYYY dan DD/MM/YYYY
        if (dateString.contains('-')) {
          parts = dateString.split('-');
          waktuBeliController.text = dateString; // Sudah format yang benar
        } else if (dateString.contains('/')) {
          parts = dateString.split('/');
          // Convert format lama ke format baru
          waktuBeliController.text = '${parts[0]}-${parts[1]}-${parts[2]}';
        } else {
          throw Exception('Format tanggal tidak valid');
        }

        if (parts.length == 3) {
          _selectedDate = DateTime(
            int.parse(parts[2]), // year
            int.parse(parts[1]), // month
            int.parse(parts[0]), // day
          );
        }
      } catch (e) {
        print('⚠️ [LAHAN_VM] Error parsing date: $e');
        waktuBeliController.text = lahan.waktuBeli;
        _selectedDate = null;
      }
    } else {
      waktuBeliController.clear();
      _selectedDate = null;
    }

    notifyListeners();
  }

  String formatDateString(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';

    try {
      List<String> parts;

      // Support kedua format
      if (dateString.contains('-')) {
        return dateString; // Sudah format yang benar DD-MM-YYYY
      } else if (dateString.contains('/')) {
        parts = dateString.split('/');
        return '${parts[0]}-${parts[1]}-${parts[2]}'; // Convert ke DD-MM-YYYY
      }

      return dateString; // Return as-is jika format tidak dikenali
    } catch (e) {
      print('⚠️ [LAHAN_VM] Error formatting date: $e');
      return dateString;
    }
  }

  String _getFinalLuasValue() {
    return _isCustomLuas ? luasController.text.trim() : _selectedLuas;
  }

  @override
  void dispose() {
    LoginViewModel.logoutNotifier.removeListener(_handleLogout);
    namaController.dispose();
    lokasiController.dispose();
    luasController.dispose();
    titikTanamController.dispose();
    waktuBeliController.dispose();
    super.dispose();
  }
}
