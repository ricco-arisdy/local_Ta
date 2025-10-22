import 'package:flutter/material.dart';
import 'package:ta_project/services/panen_service.dart';
import '../models/panen_models.dart';
import '../repositories/panen_repository.dart';

class PanenViewModel extends ChangeNotifier {
  final PanenRepository _panenRepository = PanenRepository();

  // State variables
  List<Panen> _panenList = [];
  Panen? _selectedPanen;
  bool _isLoading = false;
  String _errorMessage = '';
  Map<String, dynamic> _statistics = {};

  // Form state
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController tanggalController = TextEditingController();
  final TextEditingController jumlahController = TextEditingController();
  final TextEditingController hargaController = TextEditingController();
  final TextEditingController catatanController = TextEditingController();
  int? _selectedLahanId;
  bool _isFormLoading = false;

  bool _isCheckingLimit = false;
  Map<String, dynamic>? _monthlyLimitInfo;

  // Getters
  List<Panen> get panenList => _panenList;
  Panen? get selectedPanen => _selectedPanen;
  bool get isLoading => _isLoading;
  bool get isCheckingLimit => _isCheckingLimit;
  bool get isFormLoading => _isFormLoading;
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;
  int? get selectedLahanId => _selectedLahanId;
  Map<String, dynamic> get statistics => _statistics;
  Map<String, dynamic>? get monthlyLimitInfo => _monthlyLimitInfo;

  // Statistics getters
  int get totalPanen => _statistics['totalPanen'] ?? 0;
  int get totalJumlah => _statistics['totalJumlah'] ?? 0;
  int get totalNilai => _statistics['totalNilai'] ?? 0;
  double get rataRataHarga => (_statistics['rataRataHarga'] ?? 0.0).toDouble();
  Panen? get panenTerbaru => _statistics['panenTerbaru'];

  //metod untuk limit data panen per bulan
  Future<bool> checkMonthlyLimit() async {
    if (_selectedLahanId == null || tanggalController.text.trim().isEmpty) {
      return true; // Skip validation if data incomplete
    }

    print(
        '🔍 [PANEN_VM] Checking monthly limit for lahan: $_selectedLahanId, date: ${tanggalController.text}');

    _isCheckingLimit = true;
    notifyListeners();

    try {
      final response = await PanenService.checkMonthlyLimit(
        lahanId: _selectedLahanId!,
        tanggal: tanggalController.text.trim(),
      );

      if (response.isSuccess && response.data != null) {
        _monthlyLimitInfo = response.data;
        final canAdd = response.data!['can_add'] ?? false;

        print('✅ [PANEN_VM] Monthly limit check result: canAdd=$canAdd');
        print(
            '📊 [PANEN_VM] Current count: ${response.data!['current_count']}/2');

        return canAdd;
      } else {
        print(
            '❌ [PANEN_VM] Failed to check monthly limit: ${response.message}');
        return true; // Allow if check fails
      }
    } catch (e) {
      print('💥 [PANEN_VM] Error checking monthly limit: $e');
      return true; // Allow if error occurs
    } finally {
      _isCheckingLimit = false;
      notifyListeners();
    }
  }

  // Load all panen
  Future<void> loadAllPanen() async {
    print('🌾 [PANEN_VM] Loading all panen...');

    _setLoading(true);
    _clearError();

    try {
      final response = await _panenRepository.getAllPanen();

      if (response.isSuccess && response.data != null) {
        _panenList = response.data!;

        // ✅ ADD: Double check sorting di ViewModel juga
        _sortPanenByDateDesc();

        await _loadStatistics();
        print(
            '✅ [PANEN_VM] Successfully loaded ${_panenList.length} panen (sorted)');
      } else {
        _setError(response.message ?? 'Gagal memuat data panen');
        print('❌ [PANEN_VM] Failed to load panen: ${response.message}');
      }
    } catch (e) {
      _setError('Terjadi kesalahan sistem: ${e.toString()}');
      print('💥 [PANEN_VM] Error loading panen: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Method untuk mengurutkan panen berdasarkan tanggal (terbaru ke terlama) dan ID (terbesar ke terkecil)
  void _sortPanenByDateDesc() {
    _panenList.sort((a, b) => a.compareByDateAndId(b));

    print(
        '🔄 [PANEN_VM] Sorted ${_panenList.length} panen by date desc + ID desc');
    if (_panenList.isNotEmpty) {
      print(
          '🔄 [PANEN_VM] First item: ID ${_panenList.first.id}, Date: ${_panenList.first.tanggal}');
    }
  }

  // Load panen by lahan ID
  Future<void> loadPanenByLahan(int lahanId) async {
    print('🌾 [PANEN_VM] Loading panen for lahan: $lahanId');

    _setLoading(true);
    _clearError();

    try {
      final response = await _panenRepository.getPanenByLahanId(lahanId);

      if (response.isSuccess && response.data != null) {
        _panenList = response.data!;
        print(
            '✅ [PANEN_VM] Successfully loaded ${_panenList.length} panen for lahan $lahanId');
      } else {
        _setError(response.message ?? 'Gagal memuat data panen');
        print('❌ [PANEN_VM] Failed to load panen: ${response.message}');
      }
    } catch (e) {
      _setError('Terjadi kesalahan sistem: ${e.toString()}');
      print('💥 [PANEN_VM] Error loading panen by lahan: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get panen by ID
  Future<void> getPanenById(int id) async {
    print('🌾 [PANEN_VM] Getting panen by ID: $id');

    _setLoading(true);
    _clearError();

    try {
      final response = await _panenRepository.getPanenById(id);

      if (response.isSuccess && response.data != null) {
        _selectedPanen = response.data!;
        _populateFormFromPanen(_selectedPanen!);
        print('✅ [PANEN_VM] Successfully got panen: ${_selectedPanen!.id}');
      } else {
        _setError(response.message ?? 'Panen tidak ditemukan');
        print('❌ [PANEN_VM] Failed to get panen: ${response.message}');
      }
    } catch (e) {
      _setError('Terjadi kesalahan sistem: ${e.toString()}');
      print('💥 [PANEN_VM] Error getting panen by ID: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Create new panen
  Future<bool> createPanen() async {
    print('🌾 [PANEN_VM] Creating new panen...');

    if (!_validateForm()) {
      return false;
    }

    _setFormLoading(true);
    _clearError();

    try {
      final response = await _panenRepository.createPanen(
        lahanId: _selectedLahanId!,
        tanggal: tanggalController.text.trim(),
        jumlah: int.parse(jumlahController.text.trim()),
        harga: int.parse(hargaController.text.trim()),
        catatan: catatanController.text.trim().isNotEmpty
            ? catatanController.text.trim()
            : null,
      );

      if (response.isSuccess) {
        print('✅ [PANEN_VM] Successfully created panen: ${response.data?.id}');
        clearForm();
        await loadAllPanen(); // Refresh list
        return true;
      } else {
        // ✅ NEW: Handle monthly limit exceeded error specifically
        if (response.isMonthlyLimitExceeded) {
          _setError('⚠️ LIMIT BULANAN TERLAMPAUI\n\n${response.message}');
          print('🚫 [PANEN_VM] Monthly limit exceeded: ${response.message}');
        } else {
          _setError(response.message ?? 'Gagal menambahkan panen');
          print('❌ [PANEN_VM] Failed to create panen: ${response.message}');
        }
        return false;
      }
    } catch (e) {
      _setError('Terjadi kesalahan sistem: ${e.toString()}');
      print('💥 [PANEN_VM] Error creating panen: $e');
      return false;
    } finally {
      _setFormLoading(false);
    }
  }

  // Update panen
  Future<bool> updatePanen(int id) async {
    print('🌾 [PANEN_VM] Updating panen ID: $id');

    if (!_validateForm()) {
      return false;
    }

    _setFormLoading(true);
    _clearError();

    try {
      final response = await _panenRepository.updatePanen(
        id: id,
        lahanId: _selectedLahanId!,
        tanggal: tanggalController.text.trim(),
        jumlah: int.parse(jumlahController.text.trim()),
        harga: int.parse(hargaController.text.trim()),
        catatan: catatanController.text.trim().isNotEmpty
            ? catatanController.text.trim()
            : null,
      );

      if (response.isSuccess) {
        print('✅ [PANEN_VM] Successfully updated panen: ${response.data?.id}');
        clearForm();
        await loadAllPanen(); // Refresh list
        return true;
      } else {
        _setError(response.message ?? 'Gagal mengupdate panen');
        print('❌ [PANEN_VM] Failed to update panen: ${response.message}');
        return false;
      }
    } catch (e) {
      _setError('Terjadi kesalahan sistem: ${e.toString()}');
      print('💥 [PANEN_VM] Error updating panen: $e');
      return false;
    } finally {
      _setFormLoading(false);
    }
  }

  // Delete panen
  Future<bool> deletePanen(int id) async {
    print('🌾 [PANEN_VM] Deleting panen ID: $id');

    _setLoading(true);
    _clearError();

    try {
      final response = await _panenRepository.deletePanen(id);

      if (response.isSuccess) {
        print('✅ [PANEN_VM] Successfully deleted panen ID: $id');
        await loadAllPanen(); // Refresh list
        return true;
      } else {
        _setError(response.message ?? 'Gagal menghapus panen');
        print('❌ [PANEN_VM] Failed to delete panen: ${response.message}');
        return false;
      }
    } catch (e) {
      _setError('Terjadi kesalahan sistem: ${e.toString()}');
      print('💥 [PANEN_VM] Error deleting panen: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Load statistics
  Future<void> _loadStatistics() async {
    try {
      _statistics = await _panenRepository.getPanenStatistics();
      print('✅ [PANEN_VM] Statistics loaded: $_statistics');
    } catch (e) {
      print('💥 [PANEN_VM] Error loading statistics: $e');
      _statistics = {};
    }
  }

  // Form methods
  void setSelectedLahan(int? lahanId) {
    _selectedLahanId = lahanId;
    _monthlyLimitInfo = null; // Reset limit info when lahan changes
    notifyListeners();
  }

  void setSelectedPanen(Panen panen) {
    _selectedPanen = panen;
    _populateFormFromPanen(panen);
    notifyListeners();
  }

  void _populateFormFromPanen(Panen panen) {
    try {
      final date = DateTime.parse(panen.tanggal);
      tanggalController.text =
          "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
    } catch (e) {
      // If parsing fails, keep original format
      tanggalController.text = panen.tanggal;
    }
    // tanggalController.text = panen.tanggal;
    jumlahController.text = panen.jumlah.toString();
    hargaController.text = panen.harga.toString();
    catatanController.text = panen.catatan ?? '';
    _selectedLahanId = panen.lahanId;
  }

  void clearForm() {
    tanggalController.clear();
    jumlahController.clear();
    hargaController.clear();
    catatanController.clear();
    _selectedLahanId = null;
    _selectedPanen = null;
    _monthlyLimitInfo = null; // ✅ NEW: Clear limit info
    _clearError();
    notifyListeners();
  }

  bool _validateForm() {
    if (_selectedLahanId == null || _selectedLahanId! <= 0) {
      _setError('Pilih lahan terlebih dahulu');
      return false;
    }

    if (tanggalController.text.trim().isEmpty) {
      _setError('Tanggal panen harus diisi');
      return false;
    }

    if (jumlahController.text.trim().isEmpty) {
      _setError('Jumlah panen harus diisi');
      return false;
    }

    final jumlah = int.tryParse(jumlahController.text.trim());
    if (jumlah == null || jumlah <= 0) {
      _setError('Jumlah panen harus berupa angka positif');
      return false;
    }

    if (hargaController.text.trim().isEmpty) {
      _setError('Harga harus diisi');
      return false;
    }

    final harga = int.tryParse(hargaController.text.trim());
    if (harga == null || harga < 0) {
      _setError('Harga harus berupa angka yang valid');
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

  // Helper method untuk check apakah lahan memiliki panen
  Future<bool> hasAnyPanen(int lahanId) async {
    return await _panenRepository.hasAnyPanen(lahanId);
  }

  // Method untuk mendapatkan panen terbaru untuk lahan tertentu
  List<Panen> getRecentPanenByLahan(int lahanId, {int limit = 3}) {
    final filtered =
        _panenList.where((panen) => panen.lahanId == lahanId).toList();

    // Sort by date descending
    filtered.sort((a, b) =>
        DateTime.parse(b.tanggal).compareTo(DateTime.parse(a.tanggal)));

    return filtered.take(limit).toList();
  }

  // Method untuk mendapatkan total nilai panen per lahan
  int getTotalNilaiByLahan(int lahanId) {
    return _panenList
        .where((panen) => panen.lahanId == lahanId)
        .fold(0, (sum, panen) => sum + panen.totalNilai);
  }

  @override
  void dispose() {
    formKey.currentState?.dispose();
    tanggalController.dispose();
    jumlahController.dispose();
    hargaController.dispose();
    catatanController.dispose();
    super.dispose();
  }
}
