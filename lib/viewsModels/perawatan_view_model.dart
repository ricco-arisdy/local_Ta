import 'package:flutter/material.dart';
import 'package:ta_project/models/app_constants.dart';
import '../models/perawatan_models.dart';
import '../repositories/perawatan_repository.dart';

class PerawatanViewModel extends ChangeNotifier {
  final PerawatanRepository _perawatanRepository = PerawatanRepository();

  // State variables
  List<Perawatan> _perawatanList = [];
  Perawatan? _selectedPerawatan;
  bool _isLoading = false;
  String _errorMessage = '';
  Map<String, dynamic> _statistics = {};

  // Form state
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController kegiatanController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();
  final TextEditingController jumlahController = TextEditingController();
  final TextEditingController biayaController = TextEditingController();
  final TextEditingController catatanController = TextEditingController();
  int? _selectedKebunId;
  String? _selectedSatuan;
  bool _isFormLoading = false;

  // Getters
  List<Perawatan> get perawatanList => _perawatanList;
  Perawatan? get selectedPerawatan => _selectedPerawatan;
  bool get isLoading => _isLoading;
  bool get isFormLoading => _isFormLoading;
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;
  int? get selectedKebunId => _selectedKebunId;
  String? get selectedSatuan => _selectedSatuan;
  Map<String, dynamic> get statistics => _statistics;

  // Statistics getters
  int get totalPerawatan => _statistics['totalPerawatan'] ?? 0;
  int get totalBiaya => _statistics['totalBiaya'] ?? 0;
  double get rataRataBiaya => (_statistics['rataRataBiaya'] ?? 0.0).toDouble();
  Perawatan? get perawatanTerbaru => _statistics['perawatanTerbaru'];
  String? get kegiatanTerbanyak => _statistics['kegiatanTerbanyak'];

  // Load all perawatan
  Future<void> loadAllPerawatan() async {
    print('🌿 [PERAWATAN_VM] Loading all perawatan...');

    _setLoading(true);
    _clearError();

    try {
      final response = await _perawatanRepository.getAllPerawatan();

      if (response.isSuccess && response.data != null) {
        _perawatanList = response.data!;

        // ✅ Double check sorting di ViewModel juga
        _sortPerawatanByDateDesc();

        await _loadStatistics();
        print(
            '✅ [PERAWATAN_VM] Successfully loaded ${_perawatanList.length} perawatan (sorted)');
      } else {
        _setError(response.message ?? 'Gagal memuat data perawatan');
        print('❌ [PERAWATAN_VM] Failed to load perawatan: ${response.message}');
      }
    } catch (e) {
      _setError('Terjadi kesalahan sistem: ${e.toString()}');
      print('💥 [PERAWATAN_VM] Error loading perawatan: $e');
    } finally {
      _setLoading(false);
    }
  }

  // method untuk set satuan
  void setSelectedSatuan(String? satuan) {
    if (satuan != null && PerawatanConstants.satuanOptions.contains(satuan)) {
      _selectedSatuan = satuan;
    } else {
      _selectedSatuan = null;
    }
    notifyListeners();
  }

  // Method untuk mengurutkan perawatan berdasarkan tanggal (terbaru ke terlama) dan ID (terbesar ke terkecil)
  void _sortPerawatanByDateDesc() {
    _perawatanList.sort((a, b) => a.compareByDateAndId(b));

    print(
        '🔄 [PERAWATAN_VM] Sorted ${_perawatanList.length} perawatan by date desc + ID desc');
    if (_perawatanList.isNotEmpty) {
      print(
          '🔄 [PERAWATAN_VM] First item: ID ${_perawatanList.first.id}, Date: ${_perawatanList.first.tanggal}');
    }
  }

  // Load perawatan by kebun ID
  Future<void> loadPerawatanByKebun(int kebunId) async {
    print('🌿 [PERAWATAN_VM] Loading perawatan for kebun: $kebunId');

    _setLoading(true);
    _clearError();

    try {
      final response =
          await _perawatanRepository.getPerawatanByKebunId(kebunId);

      if (response.isSuccess && response.data != null) {
        _perawatanList = response.data!;
        print(
            '✅ [PERAWATAN_VM] Successfully loaded ${_perawatanList.length} perawatan for kebun $kebunId');
      } else {
        _setError(response.message ?? 'Gagal memuat data perawatan');
        print('❌ [PERAWATAN_VM] Failed to load perawatan: ${response.message}');
      }
    } catch (e) {
      _setError('Terjadi kesalahan sistem: ${e.toString()}');
      print('💥 [PERAWATAN_VM] Error loading perawatan by kebun: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get perawatan by ID
  Future<void> getPerawatanById(int id) async {
    print('🌿 [PERAWATAN_VM] Getting perawatan by ID: $id');

    _setLoading(true);
    _clearError();

    try {
      final response = await _perawatanRepository.getPerawatanById(id);

      if (response.isSuccess && response.data != null) {
        _selectedPerawatan = response.data!;
        _populateFormFromPerawatan(_selectedPerawatan!);
        print(
            '✅ [PERAWATAN_VM] Successfully got perawatan: ${_selectedPerawatan!.id}');
      } else {
        _setError(response.message ?? 'Perawatan tidak ditemukan');
        print('❌ [PERAWATAN_VM] Failed to get perawatan: ${response.message}');
      }
    } catch (e) {
      _setError('Terjadi kesalahan sistem: ${e.toString()}');
      print('💥 [PERAWATAN_VM] Error getting perawatan by ID: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Create new perawatan
  Future<bool> createPerawatan() async {
    print('🌿 [PERAWATAN_VM] Creating new perawatan...');

    if (!_validateForm()) {
      return false;
    }

    _setFormLoading(true);
    _clearError();

    try {
      final response = await _perawatanRepository.createPerawatan(
        kebunId: _selectedKebunId!,
        kegiatan: kegiatanController.text.trim(),
        tanggal: tanggalController.text.trim(),
        jumlah: int.parse(jumlahController.text.trim()),
        satuan: _selectedSatuan,
        biaya: int.parse(biayaController.text.trim()),
        catatan: catatanController.text.trim().isNotEmpty
            ? catatanController.text.trim()
            : null,
      );

      if (response.isSuccess) {
        print(
            '✅ [PERAWATAN_VM] Successfully created perawatan: ${response.data?.id}');
        clearForm();
        await loadAllPerawatan(); // Refresh list
        return true;
      } else {
        _setError(response.message ?? 'Gagal menambahkan perawatan');
        print(
            '❌ [PERAWATAN_VM] Failed to create perawatan: ${response.message}');
        return false;
      }
    } catch (e) {
      _setError('Terjadi kesalahan sistem: ${e.toString()}');
      print('💥 [PERAWATAN_VM] Error creating perawatan: $e');
      return false;
    } finally {
      _setFormLoading(false);
    }
  }

  // Update perawatan
  Future<bool> updatePerawatan(int id) async {
    print('🌿 [PERAWATAN_VM] Updating perawatan ID: $id');

    if (!_validateForm()) {
      return false;
    }

    _setFormLoading(true);
    _clearError();

    try {
      final response = await _perawatanRepository.updatePerawatan(
        id: id,
        kebunId: _selectedKebunId!,
        kegiatan: kegiatanController.text.trim(),
        tanggal: tanggalController.text.trim(),
        jumlah: int.parse(jumlahController.text.trim()),
        satuan: _selectedSatuan,
        biaya: int.parse(biayaController.text.trim()),
        catatan: catatanController.text.trim().isNotEmpty
            ? catatanController.text.trim()
            : null,
      );

      if (response.isSuccess) {
        print(
            '✅ [PERAWATAN_VM] Successfully updated perawatan: ${response.data?.id}');
        clearForm();
        await loadAllPerawatan(); // Refresh list
        return true;
      } else {
        _setError(response.message ?? 'Gagal mengupdate perawatan');
        print(
            '❌ [PERAWATAN_VM] Failed to update perawatan: ${response.message}');
        return false;
      }
    } catch (e) {
      _setError('Terjadi kesalahan sistem: ${e.toString()}');
      print('💥 [PERAWATAN_VM] Error updating perawatan: $e');
      return false;
    } finally {
      _setFormLoading(false);
    }
  }

  // Delete perawatan
  Future<bool> deletePerawatan(int id) async {
    print('🌿 [PERAWATAN_VM] Deleting perawatan ID: $id');

    _setLoading(true);
    _clearError();

    try {
      final response = await _perawatanRepository.deletePerawatan(id);

      if (response.isSuccess) {
        print('✅ [PERAWATAN_VM] Successfully deleted perawatan ID: $id');
        await loadAllPerawatan(); // Refresh list
        return true;
      } else {
        _setError(response.message ?? 'Gagal menghapus perawatan');
        print(
            '❌ [PERAWATAN_VM] Failed to delete perawatan: ${response.message}');
        return false;
      }
    } catch (e) {
      _setError('Terjadi kesalahan sistem: ${e.toString()}');
      print('💥 [PERAWATAN_VM] Error deleting perawatan: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Load statistics
  Future<void> _loadStatistics() async {
    try {
      _statistics = await _perawatanRepository.getPerawatanStatistics();
      print('✅ [PERAWATAN_VM] Statistics loaded: $_statistics');
    } catch (e) {
      print('💥 [PERAWATAN_VM] Error loading statistics: $e');
      _statistics = {};
    }
  }

  // Form methods
  void setSelectedKebun(int? kebunId) {
    _selectedKebunId = kebunId;
    notifyListeners();
  }

  void setSelectedPerawatan(Perawatan perawatan) {
    _selectedPerawatan = perawatan;
    _populateFormFromPerawatan(perawatan);
    notifyListeners();
  }

  void _populateFormFromPerawatan(Perawatan perawatan) {
    kegiatanController.text = perawatan.kegiatan;

    try {
      final date = DateTime.parse(perawatan.tanggal);
      tanggalController.text =
          "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
    } catch (e) {
      tanggalController.text = perawatan.tanggal;
    }

    jumlahController.text = perawatan.jumlah.toString();
    biayaController.text = perawatan.biaya.toString();
    catatanController.text = perawatan.catatan ?? '';
    _selectedKebunId = perawatan.kebunId;

    if (perawatan.satuan != null) {
      final normalizedSatuan = PerawatanConstants.satuanOptions.firstWhere(
        (option) => option.toLowerCase() == perawatan.satuan!.toLowerCase(),
        orElse: () => '', // Return empty string jika tidak ditemukan
      );

      _selectedSatuan = normalizedSatuan.isNotEmpty ? normalizedSatuan : null;
    } else {
      _selectedSatuan = null;
    }

    print(
        '🔧 [PERAWATAN_VM] Populated satuan: ${perawatan.satuan} -> $_selectedSatuan');
  }

  void clearForm() {
    kegiatanController.clear();
    tanggalController.clear();
    jumlahController.clear();
    biayaController.clear();
    catatanController.clear();
    _selectedKebunId = null;
    _selectedSatuan = null;
    _selectedPerawatan = null;
    _clearError();
    notifyListeners();
  }

  bool _validateForm() {
    if (_selectedKebunId == null || _selectedKebunId! <= 0) {
      _setError('Pilih kebun terlebih dahulu');
      return false;
    }

    if (kegiatanController.text.trim().isEmpty) {
      _setError('Jenis kegiatan harus diisi');
      return false;
    }

    if (tanggalController.text.trim().isEmpty) {
      _setError('Tanggal perawatan harus diisi');
      return false;
    }

    if (jumlahController.text.trim().isEmpty) {
      _setError('Jumlah harus diisi');
      return false;
    }

    final jumlah = int.tryParse(jumlahController.text.trim());
    if (jumlah == null || jumlah <= 0) {
      _setError('Jumlah harus berupa angka positif');
      return false;
    }

    if (biayaController.text.trim().isEmpty) {
      _setError('Biaya harus diisi');
      return false;
    }

    final biaya = int.tryParse(biayaController.text.trim());
    if (biaya == null || biaya < 0) {
      _setError('Biaya harus berupa angka yang valid');
      return false;
    }

    // Validate date format
    try {
      final tanggalStr = tanggalController.text.trim();

      // Check if format is DD-MM-YYYY
      final datePattern = RegExp(r'^\d{2}-\d{2}-\d{4}$');
      if (!datePattern.hasMatch(tanggalStr)) {
        _setError('Format tanggal harus DD-MM-YYYY');
        return false;
      }

      // Parse DD-MM-YYYY format
      final parts = tanggalStr.split('-');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      // Validate date components
      if (month < 1 || month > 12) {
        _setError('Bulan tidak valid (1-12)');
        return false;
      }

      if (day < 1 || day > 31) {
        _setError('Tanggal tidak valid (1-31)');
        return false;
      }

      // Create DateTime to validate complete date
      final date = DateTime(year, month, day);
      if (date.day != day || date.month != month || date.year != year) {
        _setError('Tanggal tidak valid');
        return false;
      }
    } catch (e) {
      _setError('Format tanggal tidak valid. Gunakan DD-MM-YYYY');
      return false;
    }

    return true;
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setFormLoading(bool loading) {
    _isFormLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Helper method untuk check apakah kebun memiliki perawatan
  Future<bool> hasAnyPerawatan(int kebunId) async {
    return await _perawatanRepository.hasAnyPerawatan(kebunId);
  }

  // Method untuk mendapatkan perawatan terbaru untuk kebun tertentu
  List<Perawatan> getRecentPerawatanByKebun(int kebunId, {int limit = 3}) {
    final filtered = _perawatanList
        .where((perawatan) => perawatan.kebunId == kebunId)
        .toList();

    // Sort by date descending
    filtered.sort((a, b) =>
        DateTime.parse(b.tanggal).compareTo(DateTime.parse(a.tanggal)));

    return filtered.take(limit).toList();
  }

  // Method untuk mendapatkan total biaya perawatan per kebun
  int getTotalBiayaByKebun(int kebunId) {
    return _perawatanList
        .where((perawatan) => perawatan.kebunId == kebunId)
        .fold(0, (sum, perawatan) => sum + perawatan.biaya);
  }

  // Method untuk mendapatkan perawatan berdasarkan kegiatan
  Future<void> loadPerawatanByKegiatan(String kegiatan) async {
    print('🌿 [PERAWATAN_VM] Loading perawatan by kegiatan: $kegiatan');

    _setLoading(true);
    _clearError();

    try {
      final response =
          await _perawatanRepository.getPerawatanByKegiatan(kegiatan);

      if (response.isSuccess && response.data != null) {
        _perawatanList = response.data!;
        print(
            '✅ [PERAWATAN_VM] Successfully loaded ${_perawatanList.length} perawatan for kegiatan $kegiatan');
      } else {
        _setError(response.message ?? 'Gagal memuat data perawatan');
        print('❌ [PERAWATAN_VM] Failed to load perawatan: ${response.message}');
      }
    } catch (e) {
      _setError('Terjadi kesalahan sistem: ${e.toString()}');
      print('💥 [PERAWATAN_VM] Error loading perawatan by kegiatan: $e');
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    formKey.currentState?.dispose();
    kegiatanController.dispose();
    tanggalController.dispose();
    jumlahController.dispose();
    biayaController.dispose();
    catatanController.dispose();
    super.dispose();
  }
}
