import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ta_project/models/app_constants.dart';
import 'package:ta_project/models/panen_models.dart';
import 'package:ta_project/views/panen/panen_form_page.dart';
import 'package:ta_project/viewsModels/panen_view_models.dart';
import 'package:ta_project/viewsModels/lahan_view_models.dart';
import 'package:ta_project/viewsModels/login_view_models.dart';
import 'package:ta_project/widgets/buttomnavigation/buttom_navigation.dart';
import 'package:ta_project/widgets/panen/panen_card.dart';
import 'package:ta_project/widgets/skeleton/skeleton_screen.dart';
import 'package:ta_project/widgets/theme/tema_utama.dart';

class PanenPage extends StatefulWidget {
  const PanenPage({Key? key}) : super(key: key);

  @override
  State<PanenPage> createState() => _PanenPageState();
}

class _PanenPageState extends State<PanenPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = true;
  int _currentIndex = 2; // Panen page index
  String _selectedFilter = 'Semua'; // Filter untuk lahan

  @override
  void initState() {
    super.initState();

    // ✅ FIX: Delay initial operations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
      _setupLoginListener();
    });
  }

  void _setupLoginListener() {
    LoginViewModel.logoutNotifier.addListener(() {
      print('🔄 [PANEN_PAGE] Login state changed - reloading data...');

      // ✅ FIX: Safe state update
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _loadData();
        });
      }
    });
  }

  void _handleLoginStateChange() {
    print('🔄 [PANEN_PAGE] Login state changed - reloading data...');
    _loadData();
  }

  Future<void> _loadInitialData() async {
    await _checkToken();
    if (mounted) {
      await _loadData();
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

  Future<void> _loadData() async {
    if (!mounted) return;

    final panenVm = Provider.of<PanenViewModel>(context, listen: false);
    final lahanVm = Provider.of<LahanViewModel>(context, listen: false);

    // Load lahan data untuk dropdown filter dan mapping nama
    await lahanVm.loadAllLahan();
    // Load panen data
    await panenVm.loadAllPanen();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    LoginViewModel.logoutNotifier.removeListener(_handleLoginStateChange);
    _searchController.dispose();
    super.dispose();
  }

  void _handleNavigation(int index) {
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
        break; // Stay on panen page
      case 3:
        Navigator.pushReplacementNamed(context, '/perawatan');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/laporan');
        break;
    }
  }

  //Method untuk mendapatkan data panen yang sudah difilter
  List<Panen> _getFilteredPanen(List<Panen> allPanen, List lahanList) {
    return allPanen.where((panen) {
      bool matchesSearch = true;
      bool matchesFilter = true;

      // Search filter
      if (_searchQuery.isNotEmpty) {
        final lahanName = _getLahanName(panen.lahanId, lahanList);
        matchesSearch = lahanName.toLowerCase().contains(_searchQuery) ||
            panen.catatan?.toLowerCase().contains(_searchQuery) == true;
      }

      // Lahan filter
      if (_selectedFilter != 'Semua') {
        matchesFilter = panen.lahanId.toString() == _selectedFilter;
      }

      return matchesSearch && matchesFilter;
    }).toList();
  }

  //Method untuk mendapatkan data panen yang sudah difilter
  Map<String, dynamic> _calculateFilteredStatistics(List<Panen> filteredPanen) {
    if (filteredPanen.isEmpty) {
      return {
        'totalPanen': 0,
        'totalJumlah': 0,
        'totalNilai': 0,
        'rataRataHarga': 0.0,
      };
    }

    final totalJumlah =
        filteredPanen.fold<int>(0, (sum, panen) => sum + panen.jumlah);
    final totalNilai =
        filteredPanen.fold<int>(0, (sum, panen) => sum + panen.totalNilai);
    final rataRataHarga =
        filteredPanen.fold<int>(0, (sum, panen) => sum + panen.harga) /
            filteredPanen.length;

    return {
      'totalPanen': filteredPanen.length,
      'totalJumlah': totalJumlah,
      'totalNilai': totalNilai,
      'rataRataHarga': rataRataHarga,
    };
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
                        type: SkeletonType.lahan, // Gunakan skeleton yang sama
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
                  await _loadData();
                },
                color: const Color(0xFF4CAF50),
                child: Stack(
                  children: [
                    AuthBackgroundCore(child: Container()),
                    Positioned.fill(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top + 12,
                          bottom: 110 + bottomPadding,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 20),
                            _buildSearchAndFilterSection(),
                            const SizedBox(height: 20),
                            _buildStatisticsCard(),
                            const SizedBox(height: 20),
                            _buildPanenContent(),
                            const SizedBox(height: 20),
                          ],
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
                ),
              ),
        floatingActionButton: Padding(
          padding: EdgeInsets.only(
            bottom: 70 + bottomPadding,
          ),
          child: PanenFloatingActionButton(
            onPressed: () => _navigateToForm(context),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  // ✅ PANEN-SPECIFIC: Header
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Icon(
              Icons.agriculture_outlined,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kelola Panen',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Catat hasil panen pertanian Anda',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // PANEN-SPECIFIC: Search and Filter section
  Widget _buildSearchAndFilterSection() {
    return Consumer<LahanViewModel>(
      builder: (context, lahanVm, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            children: [
              // Search Bar
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Cari panen...',
                    hintStyle: TextStyle(fontSize: 14),
                    border: InputBorder.none,
                    icon: Icon(
                      Icons.search,
                      color: Color(0xFF4CAF50),
                      size: 20,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 4),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),

              const SizedBox(height: 12),
              // Filter Dropdown
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.filter_list,
                      color: Color(0xFF4CAF50),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Flexible(
                      flex: 0,
                      child: Text(
                        'Filter Lahan:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // 🔽 Expanded agar Dropdown bisa menyesuaikan ruang tersisa
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedFilter,
                          isDense: true,
                          isExpanded: true, // penting!
                          items: [
                            const DropdownMenuItem(
                              value: 'Semua',
                              child: Text('Semua Lahan',
                                  overflow: TextOverflow.ellipsis),
                            ),
                            ...lahanVm.lahanList.map((lahan) {
                              return DropdownMenuItem(
                                value: lahan.id.toString(),
                                child: Text(
                                  lahan.nama,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedFilter = value ?? 'Semua';
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // PANEN-SPECIFIC: Statistics card with filtering
  Widget _buildStatisticsCard() {
    return Consumer2<PanenViewModel, LahanViewModel>(
      builder: (context, panenVm, lahanVm, child) {
        // ✅ Gunakan data terfilter untuk statistik
        final filteredPanen =
            _getFilteredPanen(panenVm.panenList, lahanVm.lahanList);
        final filteredStats = _calculateFilteredStatistics(filteredPanen);

        String formatNumber(int number) {
          final formatter = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
          return number
              .toString()
              .replaceAllMapped(formatter, (Match m) => '${m[1]}.');
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // ✅ Header untuk menunjukkan status filter
                if (_selectedFilter != 'Semua' || _searchQuery.isNotEmpty) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF4CAF50).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.filter_alt,
                          size: 14,
                          color: const Color(0xFF4CAF50),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _selectedFilter != 'Semua'
                              ? 'Filter: ${_getLahanNameById(_selectedFilter, lahanVm.lahanList)}'
                              : 'Pencarian Aktif',
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFF4CAF50),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(
                      'Total Panen',
                      filteredStats['totalPanen']
                          .toString(), // ✅ Gunakan data terfilter
                      Icons.agriculture_outlined,
                      const Color(0xFF4CAF50),
                    ),
                    _buildStatItem(
                      'Total Kg',
                      formatNumber(filteredStats[
                          'totalJumlah']), // ✅ Gunakan data terfilter
                      Icons.scale_outlined,
                      const Color(0xFF2196F3),
                    ),
                    _buildStatItem(
                      'Total Nilai',
                      'Rp ${formatNumber(filteredStats['totalNilai'])}', // ✅ Gunakan data terfilter
                      Icons.monetization_on_outlined,
                      const Color(0xFFFF9800),
                    ),
                  ],
                ),
                if (filteredStats['rataRataHarga'] > 0) ...[
                  const SizedBox(height: 12),
                  Divider(color: Colors.grey.shade300),
                  const SizedBox(height: 8),
                  Text(
                    'Rata-rata Harga: Rp ${formatNumber((filteredStats['rataRataHarga'] as double).round())}/Kg', // ✅ Gunakan data terfilter
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // method untuk mendapatkan nama lahan berdasarkan ID
  String _getLahanNameById(String lahanId, List lahanList) {
    if (lahanId == 'Semua') return 'Semua Lahan';

    try {
      final lahan = lahanList.firstWhere((l) => l.id.toString() == lahanId);
      return lahan.nama;
    } catch (e) {
      return 'Lahan ID: $lahanId';
    }
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // PANEN-SPECIFIC: Panen content
  Widget _buildPanenContent() {
    return Consumer2<PanenViewModel, LahanViewModel>(
      builder: (context, panenVm, lahanVm, child) {
        print(
            '🔍 [PANEN_CONTENT] Loading: ${panenVm.isLoading}, Error: ${panenVm.hasError}');
        print('🔍 [PANEN_CONTENT] Data count: ${panenVm.panenList.length}');

        if (panenVm.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(50),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              ),
            ),
          );
        }

        if (panenVm.hasError) {
          return _buildErrorSection(panenVm);
        }

        // ✅ Gunakan method terpusat untuk filtering
        final filteredPanen =
            _getFilteredPanen(panenVm.panenList, lahanVm.lahanList);

        if (filteredPanen.isEmpty) {
          return _buildEmptySection();
        }

        return _buildPanenList(filteredPanen, lahanVm.lahanList);
      },
    );
  }

  // Helper method untuk mendapatkan nama lahan
  String _getLahanName(int lahanId, List lahanList) {
    try {
      final lahan = lahanList.firstWhere((l) => l.id == lahanId);
      return lahan.nama;
    } catch (e) {
      return 'Lahan ID: $lahanId';
    }
  }

  // ✅ PANEN-SPECIFIC: Error section
  Widget _buildErrorSection(PanenViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
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
              onPressed: () => vm.loadAllPanen(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ PANEN-SPECIFIC: Empty section
  Widget _buildEmptySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToForm(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.agriculture_outlined,
                    color: Color(0xFF4CAF50),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Belum ada data panen',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C5F2D),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Catat hasil panen pertama Anda',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.add,
                  color: Color(0xFF4CAF50),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ PANEN-SPECIFIC: Panen list
  Widget _buildPanenList(List<Panen> filteredPanen, List lahanList) {
    // ✅ DEBUG: Log urutan panen
    print('🔍 [PANEN_PAGE] Displaying ${filteredPanen.length} panen:');
    for (int i = 0; i < filteredPanen.length && i < 3; i++) {
      print(
          '  $i. ID: ${filteredPanen[i].id}, Date: ${filteredPanen[i].tanggal}');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Column(
        children: [
          ...filteredPanen.asMap().entries.map((entry) {
            int index = entry.key;
            Panen panen = entry.value;
            String lahanNama = _getLahanName(panen.lahanId, lahanList);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PanenCard(
                // ✅ FIX: Tambahkan SEMUA parameter yang diperlukan
                panen: panen,
                lahanNama: lahanNama,
                onTap: () => _showPanenDetail(panen, lahanNama),
                onEdit: () => _navigateToForm(context, panen: panen),
                onDelete: () => _handleDelete(context, panen),
              ),
            );
          }),
        ],
      ),
    );
  }

  // Navigation methods
  void _navigateToForm(BuildContext context, {Panen? panen}) {
    final panenVm = Provider.of<PanenViewModel>(context, listen: false);

    // ✅ PENTING: Clear form state sebelum navigasi
    if (panen == null) {
      // Mode tambah baru - clear semua state
      panenVm.clearForm();
    } else {
      // Mode edit - set data panen
      panenVm.setSelectedPanen(panen);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PanenFormPage(panen: panen),
      ),
    ).then((_) {
      // Refresh data setelah kembali
      _loadData();
      // ✅ TAMBAHAN: Clear form setelah kembali dari form
      panenVm.clearForm();
    });
  }

  void _showPanenDetail(Panen panen, String lahanNama) {
    // ✅ Gunakan format manual
    String formatNumber(int number) {
      final formatter = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
      return number
          .toString()
          .replaceAllMapped(formatter, (Match m) => '${m[1]}.');
    }

    // Format: DD-MM-YYYY
    String formatDate(DateTime date) {
      String day = date.day.toString().padLeft(2, '0');
      String month = date.month.toString().padLeft(2, '0');
      return '$day-$month-${date.year}';
    }

    DateTime tanggalPanen;
    try {
      tanggalPanen = DateTime.parse(panen.tanggal);
    } catch (e) {
      tanggalPanen = DateTime.now();
    }

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
                    Icons.agriculture_outlined,
                    color: Color(0xFF4CAF50),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detail Panen',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        lahanNama,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Detail content - ✅ GUNAKAN FORMAT MANUAL
            _buildDetailRow('Tanggal Panen', formatDate(tanggalPanen)),
            _buildDetailRow('Jumlah Panen', '${formatNumber(panen.jumlah)} Kg'),
            _buildDetailRow('Harga per Kg', 'Rp ${formatNumber(panen.harga)}'),
            _buildDetailRow(
                'Total Nilai', 'Rp ${formatNumber(panen.totalNilai)}'),

            if (panen.catatan != null && panen.catatan!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Catatan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  panen.catatan!,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],

            SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDelete(BuildContext context, Panen panen) async {
    // ✅ Tampilkan confirmation dialog
    final bool? shouldDelete = await _showDeleteConfirmation(context, panen);

    if (shouldDelete == true) {
      final vm = Provider.of<PanenViewModel>(context, listen: false);
      final success = await vm.deletePanen(panen.id);

      if (mounted) {
        if (success) {
          // ✅ Format tanggal manual
          DateTime tanggalPanen;
          try {
            tanggalPanen = DateTime.parse(panen.tanggal);
          } catch (e) {
            tanggalPanen = DateTime.now();
          }

          const months = [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'Mei',
            'Jun',
            'Jul',
            'Agu',
            'Sep',
            'Okt',
            'Nov',
            'Des'
          ];
          String formattedDate =
              '${tanggalPanen.day} ${months[tanggalPanen.month - 1]} ${tanggalPanen.year}';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Panen tanggal $formattedDate berhasil dihapus'), // ✅ GUNAKAN VARIABEL LOKAL
              backgroundColor: const Color(0xFF4CAF50),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(vm.errorMessage),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    }
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context, Panen panen) {
    // ✅ Format tanggal manual
    DateTime tanggalPanen;
    try {
      tanggalPanen = DateTime.parse(panen.tanggal);
    } catch (e) {
      tanggalPanen = DateTime.now();
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    String formattedDate =
        '${tanggalPanen.day} ${months[tanggalPanen.month - 1]} ${tanggalPanen.year}';

    return showModalBottomSheet<bool>(
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
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Icon(
              Icons.delete_forever_rounded,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Hapus Panen?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Panen tanggal $formattedDate akan dihapus permanen', // ✅ GUNAKAN VARIABEL LOKAL
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Batal',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Hapus',
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
}

// Floating Action Button untuk panen
class PanenFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const PanenFloatingActionButton({
    Key? key,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: const Color(AppColors.primaryGreen),
      foregroundColor: Colors.white,
      elevation: 8,
      child: const Icon(Icons.add, size: 28),
    );
  }
}
