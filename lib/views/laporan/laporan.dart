import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ta_project/widgets/laporan/laporan_konten.dart';
import 'package:ta_project/widgets/laporan/laporan_pdf.dart';
import '../../viewsModels/laporan_view_models.dart';
import '../../viewsModels/login_view_models.dart';
import '../../models/app_constants.dart';
import '../../widgets/buttomnavigation/buttom_navigation.dart';
import '../../widgets/skeleton/skeleton_screen.dart';
import '../../widgets/theme/tema_utama.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  bool _isLoading = true;
  int _currentIndex = 4;
  bool _isFirstLoad = true;

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
      _setupLoginListener();
    });
  }

  void _setupLoginListener() {
    LoginViewModel.logoutNotifier.addListener(() {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _loadData();
        });
      }
    });
  }

  void _handleLoginStateChange() {
    _loadData(shouldReset: true);
  }

  Future<void> _loadInitialData() async {
    await _checkToken();
    if (mounted) {
      await _loadData(shouldReset: true);
    }
  }

  Future<void> _checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    final isLoggedIn = prefs.getBool(AppConstants.isLoggedInKey) ?? false;

    if (token == null || token.isEmpty || !isLoggedIn) {
      if (mounted) {
        await prefs.clear();
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }
  }

  Future<void> _loadData({bool shouldReset = false}) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final vm = Provider.of<LaporanViewModel>(context, listen: false);
      final needsReset = shouldReset || _isFirstLoad || vm.needsDataReload;
      await vm.initialize(shouldReset: needsReset);
      _isFirstLoad = false;
    } catch (e) {
      print('💥 [LAPORAN_PAGE] Error loading data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    LoginViewModel.logoutNotifier.removeListener(_handleLoginStateChange);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isFirstLoad && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadData(shouldReset: true);
      });
    }
  }

  void _handleNavigation(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/lahan');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/panen');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/perawatan');
        break;
      case 4:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/home');
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: _isLoading
            ? Stack(
                children: [
                  AuthBackgroundCore(child: Container()),
                  Positioned.fill(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 12,
                        bottom: 110 + bottomPadding,
                      ),
                      child: const SkeletonScreen(
                        type: SkeletonType.lahan,
                        itemCount: 4,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: bottomPadding,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 1),
                      child: CustomBottomNavigationBar(
                        currentIndex: _currentIndex,
                        onTap: _handleNavigation,
                      ),
                    ),
                  ),
                ],
              )
            : RefreshIndicator(
                onRefresh: () async {
                  await _loadData(shouldReset: true);
                },
                color: const Color(AppColors.primaryGreen),
                child: Stack(
                  children: [
                    AuthBackgroundCore(child: Container()),

                    // Full screen scroll view
                    Positioned.fill(
                      child: Consumer<LaporanViewModel>(
                        builder: (context, viewModel, child) {
                          return SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.only(
                              top: MediaQuery.of(context).padding.top + 12,
                              bottom: 110 + bottomPadding,
                            ),
                            child: Column(
                              children: [
                                // ✅ Header terpisah (tanpa container)
                                _buildHeader(viewModel),

                                const SizedBox(height: 16),

                                // Content area
                                LaporanContentWidget(viewModel: viewModel),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Bottom Navigation (Fixed at bottom)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: bottomPadding,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 1),
                        child: CustomBottomNavigationBar(
                          currentIndex: _currentIndex,
                          onTap: _handleNavigation,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(LaporanViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Icon(
              Icons.assessment_outlined,
              size: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Laporan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Analisa performa',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius:
                  BorderRadius.circular(24), // Membuat bentuk pill/kapsul
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ Tombol Filter
                IconButton(
                  onPressed: () => _showFilterModal(
                      viewModel), // ✅ Ganti dari coming soon ke modal
                  icon: Icon(
                    Icons.filter_list,
                    color: Colors.white.withOpacity(0.9),
                    size: 24,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  constraints: const BoxConstraints(),
                ),
                // ✅ Divider vertikal
                Container(
                  height: 24,
                  width: 1,
                  color: Colors.white.withOpacity(0.3),
                ),
                // ✅ Tombol Download
                IconButton(
                  onPressed: viewModel.hasData
                      ? () => LaporanPdfExport.exportToPDF(
                            context,
                            viewModel.currentLaporan!,
                          )
                      : null,
                  icon: Icon(
                    Icons.cloud_download_outlined,
                    color: viewModel.hasData
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                    size: 24,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterModal(LaporanViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.filter_list,
                    color: Color(0xFF4CAF50),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filter Laporan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Pilih lahan dan periode untuk analisa',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ✅ COPY EXACT dari _buildFilterSection yang sudah ada
            // Lahan Dropdown
            const Text(
              'Pilih Lahan',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C5F2D),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: viewModel.isLoadingLahan
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  : DropdownButtonFormField<int>(
                      value: viewModel.selectedLahan?.id,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        isDense: false,
                      ),
                      hint: Text(
                        'Pilih lahan untuk analisa',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      icon: Icon(Icons.keyboard_arrow_down,
                          size: 24, color: Colors.grey.shade600),
                      items: viewModel.availableLahan.map((lahan) {
                        return DropdownMenuItem<int>(
                          value: lahan.id,
                          child: Text(
                            lahan.nama,
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          final selectedLahan = viewModel.availableLahan
                              .firstWhere((lahan) => lahan.id == value);
                          viewModel.setSelectedLahan(selectedLahan);
                          Timer(const Duration(milliseconds: 300), () {
                            if (viewModel.canGenerateReport) {
                              _generateReport(viewModel);
                            }
                          });
                        }
                      },
                    ),
            ),

            const SizedBox(height: 16),

            // Period Section
            Row(
              children: [
                const Text(
                  'Periode',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C5F2D),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _selectDateRange(viewModel),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF4CAF50).withOpacity(0.3),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Color(0xFF4CAF50),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Pilih Tanggal',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF4CAF50),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Quick Date Buttons
            Row(
              children: [
                Expanded(
                  child: _buildQuickDateButton(
                    'Bulan Ini',
                    viewModel.isFilterActive &&
                        viewModel.dateRangeText.contains('Bulan'),
                    () {
                      viewModel.setThisMonth();
                      _generateWithDelay(viewModel);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickDateButton(
                    'Tahun Ini',
                    viewModel.isFilterActive &&
                        viewModel.dateRangeText.contains('Tahun'),
                    () {
                      viewModel.setThisYear();
                      _generateWithDelay(viewModel);
                    },
                  ),
                ),
              ],
            ),

            // Custom Date Display
            if (viewModel.tanggalDari != null &&
                viewModel.tanggalSampai != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF4CAF50).withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.date_range,
                      size: 16,
                      color: Color(0xFF4CAF50),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_formatDate(viewModel.tanggalDari!)} - ${_formatDate(viewModel.tanggalSampai!)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF2C5F2D),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        viewModel.clearDateFilter();
                      },
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Action buttons
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Tutup',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (viewModel.canGenerateReport) {
                        _generateReport(viewModel);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Terapkan Filter',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickDateButton(
      String text, bool isActive, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF4CAF50) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: isActive
              ? Border.all(color: const Color(0xFF4CAF50), width: 2)
              : Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  void _generateWithDelay(LaporanViewModel viewModel) {
    if (viewModel.canGenerateReport) {
      Timer(const Duration(milliseconds: 300), () {
        _generateReport(viewModel);
      });
    }
  }

  Future<void> _selectDateRange(LaporanViewModel viewModel) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange:
          viewModel.tanggalDari != null && viewModel.tanggalSampai != null
              ? DateTimeRange(
                  start: viewModel.tanggalDari!, end: viewModel.tanggalSampai!)
              : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme:
                const ColorScheme.light(primary: Color(AppColors.primaryGreen)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      viewModel.setDateRange(picked.start, picked.end);
      _generateWithDelay(viewModel);
    }
  }

  Future<void> _generateReport(LaporanViewModel viewModel) async {
    final success = await viewModel.generateLaporan();

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Data laporan berhasil dimuat'),
          backgroundColor: Color(AppColors.successGreen),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${viewModel.errorMessage}'),
          backgroundColor: const Color(AppColors.errorRed),
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      );
    }
  }
}
