import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ta_project/models/app_constants.dart';
import 'package:ta_project/models/perawatan_models.dart';
import 'package:ta_project/views/perawatan/perawatan_form_page.dart';
import 'package:ta_project/viewsModels/perawatan_view_model.dart';
import 'package:ta_project/viewsModels/login_view_models.dart';
import 'package:ta_project/widgets/buttomnavigation/buttom_navigation.dart';
import 'package:ta_project/widgets/perawatan/perawatan_card.dart';
import 'package:ta_project/widgets/skeleton/skeleton_screen.dart';
import 'package:ta_project/widgets/theme/tema_utama.dart'; // ✅ Import tema_utama

class PerawatanPage extends StatefulWidget {
  const PerawatanPage({Key? key}) : super(key: key);

  @override
  State<PerawatanPage> createState() => _PerawatanPageState();
}

class _PerawatanPageState extends State<PerawatanPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = true;
  int _currentIndex = 3; // Perawatan page index
  String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();

    // ✅ FIX: Delay initial operations (sama seperti panen_page)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
      _setupLoginListener();
    });
  }

  void _setupLoginListener() {
    LoginViewModel.logoutNotifier.addListener(() {
      print('🔄 [PERAWATAN_PAGE] Login state changed - reloading data...');

      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _loadData();
        });
      }
    });
  }

  void _handleLoginStateChange() {
    print('🔄 [PERAWATAN_PAGE] Login state changed - reloading data...');
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

    setState(() {
      _isLoading = true;
    });

    try {
      final vm = Provider.of<PerawatanViewModel>(context, listen: false);
      await vm.loadAllPerawatan();
    } catch (e) {
      print('💥 [PERAWATAN_PAGE] Error loading data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Method untuk mendapatkan data perawatan yang sudah difilter
  List<Perawatan> _getFilteredPerawatan(List<Perawatan> allPerawatan) {
    return allPerawatan.where((perawatan) {
      bool matchesSearch = true;
      bool matchesFilter = true;

      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final kegiatan = perawatan.kegiatan.toLowerCase();
        final namaKebun = (perawatan.namaKebun ?? '').toLowerCase();
        final lokasi = (perawatan.lokasiKebun ?? '').toLowerCase();

        matchesSearch = kegiatan.contains(query) ||
            namaKebun.contains(query) ||
            lokasi.contains(query);
      }

      // Kegiatan filter
      if (_selectedFilter != 'Semua') {
        matchesFilter = perawatan.kegiatan == _selectedFilter;
      }

      return matchesSearch && matchesFilter;
    }).toList();
  }

  // Method untuk menghitung statistik berdasarkan data perawatan yang sudah difilter
  Map<String, dynamic> _calculateFilteredStatistics(
      List<Perawatan> filteredPerawatan) {
    if (filteredPerawatan.isEmpty) {
      return {
        'totalPerawatan': 0,
        'totalBiaya': 0,
        'rataRataBiaya': 0.0,
        'kegiatanTerbanyak': null,
      };
    }

    final totalBiaya = filteredPerawatan.fold<int>(
        0, (sum, perawatan) => sum + perawatan.biaya);
    final rataRataBiaya = totalBiaya / filteredPerawatan.length;

    // Hitung kegiatan terbanyak dari data terfilter
    final activityCount = <String, int>{};
    for (var perawatan in filteredPerawatan) {
      activityCount[perawatan.kegiatan] =
          (activityCount[perawatan.kegiatan] ?? 0) + 1;
    }

    String? kegiatanTerbanyak;
    var maxCount = 0;
    activityCount.forEach((activity, count) {
      if (count > maxCount) {
        maxCount = count;
        kegiatanTerbanyak = activity;
      }
    });

    return {
      'totalPerawatan': filteredPerawatan.length,
      'totalBiaya': totalBiaya,
      'rataRataBiaya': rataRataBiaya,
      'kegiatanTerbanyak': kegiatanTerbanyak,
    };
  }

  List<Perawatan> _filterPerawatanList(List<Perawatan> list) {
    var filtered = list;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((perawatan) {
        final query = _searchQuery.toLowerCase();
        final kegiatan = perawatan.kegiatan.toLowerCase();
        final namaKebun = (perawatan.namaKebun ?? '').toLowerCase();
        final lokasi = (perawatan.lokasiKebun ?? '').toLowerCase();

        return kegiatan.contains(query) ||
            namaKebun.contains(query) ||
            lokasi.contains(query);
      }).toList();
    }

    if (_selectedFilter != 'Semua') {
      filtered = filtered.where((perawatan) {
        return perawatan.kegiatan == _selectedFilter;
      }).toList();
    }

    return filtered;
  }

  @override
  void dispose() {
    LoginViewModel.logoutNotifier.removeListener(_handleLoginStateChange);
    _searchController.dispose();
    super.dispose();
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
                  AuthBackgroundCore(
                      child: Container()), // ✅ Gunakan tema_utama
                  Positioned.fill(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 12,
                        bottom: 110 + bottomPadding,
                      ),
                      child: const SkeletonScreen(
                        type: SkeletonType
                            .lahan, // ✅ FIX: Tambahkan type parameter
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
                        // ✅ FIX: Nama class yang benar
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
                color: const Color(
                    0xFFFF9800), // ✅ FIX: Gunakan color code langsung
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
                            _buildPerawatanContent(),
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
          child: PerawatanFloatingActionButton(
            onPressed: () => _navigateToForm(context),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Icon(
              Icons.handyman_outlined,
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
                  'Kelola Perawatan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Catat kegiatan perawatan kebun',
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

  Widget _buildSearchAndFilterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                hintText: 'Cari perawatan...',
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    'Filter Kegiatan:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedFilter,
                      isDense: true,
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem(
                          value: 'Semua',
                          child: Text('Semua Kegiatan',
                              overflow: TextOverflow.ellipsis),
                        ),
                        ...PerawatanConstants.jenisKegiatanOptions
                            .map((kegiatan) {
                          return DropdownMenuItem(
                            value: kegiatan,
                            child: Text(
                              kegiatan,
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
          ),
        ],
      ),
    );
  }

  // Statistik Card
  Widget _buildStatisticsCard() {
    return Consumer<PerawatanViewModel>(
      builder: (context, vm, child) {
        // ✅ Gunakan data terfilter untuk statistik
        final filteredPerawatan = _getFilteredPerawatan(vm.perawatanList);
        final filteredStats = _calculateFilteredStatistics(filteredPerawatan);

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
                      color: const Color(0xFFFF9800).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFFF9800).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.filter_alt,
                          size: 14,
                          color: const Color(0xFFFF9800),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _selectedFilter != 'Semua'
                              ? 'Filter: $_selectedFilter'
                              : 'Pencarian Aktif',
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFFFF9800),
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
                      'Total Perawatan',
                      filteredStats['totalPerawatan']
                          .toString(), // ✅ Gunakan data terfilter
                      Icons.handyman_outlined,
                      const Color(0xFFFF9800),
                    ),
                    _buildStatItem(
                      'Total Biaya',
                      'Rp ${formatNumber(filteredStats['totalBiaya'])}', // ✅ Gunakan data terfilter
                      Icons.account_balance_wallet_outlined,
                      const Color(0xFF4CAF50),
                    ),
                    _buildStatItem(
                      'Rata-rata',
                      'Rp ${formatNumber((filteredStats['rataRataBiaya'] as double).toInt())}', // ✅ Gunakan data terfilter
                      Icons.analytics_outlined,
                      const Color(0xFF2196F3),
                    ),
                  ],
                ),
                if (filteredStats['kegiatanTerbanyak'] != null &&
                    (filteredStats['kegiatanTerbanyak'] as String)
                        .isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Divider(color: Colors.grey.shade300),
                  const SizedBox(height: 8),
                  Text(
                    'Kegiatan Terbanyak: ${filteredStats['kegiatanTerbanyak']}', // ✅ Gunakan data terfilter
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

  // Perawatan Content
  Widget _buildPerawatanContent() {
    return Consumer<PerawatanViewModel>(
      builder: (context, vm, child) {
        print(
            '🔍 [PERAWATAN_CONTENT] Loading: ${vm.isLoading}, Error: ${vm.hasError}');
        print('🔍 [PERAWATAN_CONTENT] Data count: ${vm.perawatanList.length}');

        if (vm.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(50),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF9800)),
              ),
            ),
          );
        }

        if (vm.hasError) {
          return _buildErrorSection(vm);
        }

        // ✅ Gunakan method terpusat untuk filtering
        final filteredPerawatan = _getFilteredPerawatan(vm.perawatanList);

        if (filteredPerawatan.isEmpty) {
          return _buildEmptySection();
        }

        return _buildPerawatanList(filteredPerawatan);
      },
    );
  }

  Widget _buildErrorSection(PerawatanViewModel vm) {
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
              onPressed: () => vm.loadAllPerawatan(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800),
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
                    color: const Color(0xFFFF9800).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.handyman_outlined,
                    color: Color(0xFFFF9800),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Belum ada data perawatan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C5F2D),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Catat kegiatan perawatan pertama Anda',
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
                  color: Color(0xFFFF9800),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPerawatanList(List<Perawatan> filteredPerawatan) {
    print(
        '🔍 [PERAWATAN_PAGE] Displaying ${filteredPerawatan.length} perawatan');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Column(
        children: [
          ...filteredPerawatan.asMap().entries.map((entry) {
            Perawatan perawatan = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PerawatanCard(
                perawatan: perawatan,
                onTap: () => _showPerawatanDetail(perawatan),
                onEdit: () => _navigateToForm(context, perawatan: perawatan),
                onDelete: () => _handleDelete(context, perawatan),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _navigateToForm(BuildContext context, {Perawatan? perawatan}) {
    final vm = Provider.of<PerawatanViewModel>(context, listen: false);

    if (perawatan == null) {
      vm.clearForm();
    } else {
      vm.setSelectedPerawatan(perawatan);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PerawatanFormPage(perawatan: perawatan),
      ),
    ).then((_) {
      _loadData();
      vm.clearForm();
    });
  }

  void _showPerawatanDetail(Perawatan perawatan) {
    String formatNumber(int number) {
      final formatter = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
      return number
          .toString()
          .replaceAllMapped(formatter, (Match m) => '${m[1]}.');
    }

    String formatDate(DateTime date) {
      String day = date.day.toString().padLeft(2, '0');
      String month = date.month.toString().padLeft(2, '0');
      return '$day-$month-${date.year}';
    }

    DateTime tanggalPerawatan;
    try {
      tanggalPerawatan = DateTime.parse(perawatan.tanggal);
    } catch (e) {
      tanggalPerawatan = DateTime.now();
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.handyman_outlined,
                    color: Color(0xFFFF9800),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detail Perawatan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        perawatan.kegiatan,
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
            _buildDetailRow('Kebun', perawatan.namaKebun ?? '-'),
            _buildDetailRow('Lokasi', perawatan.lokasiKebun ?? '-'),
            _buildDetailRow('Tanggal', formatDate(tanggalPerawatan)),
            _buildDetailRow('Jumlah',
                '${perawatan.jumlah.toString()}${perawatan.satuan != null ? ' ${perawatan.satuan}' : ''}'),
            _buildDetailRow('Biaya', 'Rp ${formatNumber(perawatan.biaya)}'),
            if (perawatan.catatan != null && perawatan.catatan!.isNotEmpty) ...[
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
                  perawatan.catatan!,
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

  void _handleDelete(BuildContext context, Perawatan perawatan) async {
    final bool? shouldDelete =
        await _showDeleteConfirmation(context, perawatan);

    if (shouldDelete == true) {
      final vm = Provider.of<PerawatanViewModel>(context, listen: false);
      final success = await vm.deletePerawatan(perawatan.id);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perawatan berhasil dihapus'),
              backgroundColor: Color(0xFF4CAF50),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(vm.errorMessage),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          );
        }
      }
    }
  }

  Future<bool?> _showDeleteConfirmation(
      BuildContext context, Perawatan perawatan) {
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
              'Hapus Perawatan?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Perawatan "${perawatan.kegiatan}" akan dihapus permanen',
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
        break; // Current page
      case 4:
        Navigator.pushReplacementNamed(context, '/laporan');
        break;
    }
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon!'),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    );
  }
}

// FAB untuk perawatan
class PerawatanFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const PerawatanFloatingActionButton({
    Key? key,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: const Color(0xFFFF9800), // Orange
      foregroundColor: Colors.white,
      elevation: 8,
      child: const Icon(Icons.add, size: 28),
    );
  }
}
