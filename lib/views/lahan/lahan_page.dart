import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ta_project/models/app_constants.dart';
import 'package:ta_project/models/lahan_models.dart';
import 'package:ta_project/views/lahan/lahan_detail_page.dart';
import 'package:ta_project/views/lahan/lahan_form_page.dart';
import 'package:ta_project/viewsModels/lahan_view_models.dart';
import 'package:ta_project/viewsModels/login_view_models.dart';
import 'package:ta_project/widgets/buttomnavigation/buttom_navigation.dart';
import 'package:ta_project/widgets/lahan/lahan_actions.dart';
import 'package:ta_project/widgets/skeleton/skeleton_screen.dart';
import 'package:ta_project/widgets/theme/tema_utama.dart';
import 'package:ta_project/widgets/lahan/lahan_card.dart';

class LahanPage extends StatefulWidget {
  const LahanPage({Key? key}) : super(key: key);

  @override
  State<LahanPage> createState() => _LahanPageState();
}

class _LahanPageState extends State<LahanPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = true;
  int _currentIndex = 1;

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
      print('🔄 [LAHAN_PAGE] Login state changed - reloading data...');

      // ✅ FIX: Safe state update
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _loadData();
        });
      }
    });
  }

  void _handleLoginStateChange() {
    print('🔄 [LAHAN_PAGE] Login state changed - reloading data...');
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

    final vm = Provider.of<LahanViewModel>(context, listen: false);
    await vm.loadAllLahan();

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
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/panen');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/perawatan');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/laporan');
        break;
    }
  }

  // void _showComingSoon(String feature) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text('$feature - Coming Soon!'),
  //       backgroundColor: const Color(0xFF4CAF50),
  //       behavior: SnackBarBehavior.floating,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(10),
  //       ),
  //     ),
  //   );
  // }

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
                  final vm =
                      Provider.of<LahanViewModel>(context, listen: false);
                  await vm.loadAllLahan();
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
                            _buildSearchSection(),
                            const SizedBox(height: 20),
                            _buildStatisticsCard(),
                            const SizedBox(height: 20),
                            _buildLahanContent(),
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
          child: LahanFloatingActionButton(
            onPressed: () => _navigateToForm(context),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  // ✅ LAHAN-SPECIFIC: Header (same structure as HomePage header)
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Icon(
              Icons.grass_outlined,
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
                  'Kelola Lahan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Manajemen lahan pertanian Anda',
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

  // ✅ LAHAN-SPECIFIC: Search section (compact version)
  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 8), // Reduced padding
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(10), // Slightly smaller radius
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08), // Lighter shadow
              blurRadius: 6, // Reduced blur
              offset: const Offset(0, 2), // Reduced offset
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(fontSize: 14), // Smaller text
          decoration: const InputDecoration(
            hintText: 'Cari lahan...',
            hintStyle: TextStyle(fontSize: 14), // Smaller hint text
            border: InputBorder.none,
            icon: Icon(
              Icons.search,
              color: Color(0xFF4CAF50),
              size: 20, // Smaller icon
            ),
            contentPadding:
                EdgeInsets.symmetric(vertical: 4), // Reduced padding
            isDense: true, // Makes the field more compact
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
        ),
      ),
    );
  }

  // ✅ LAHAN-SPECIFIC: Statistics card (same structure as HomePage summary card)
  Widget _buildStatisticsCard() {
    return Consumer<LahanViewModel>(
      builder: (context, vm, child) {
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(
                      'Total Lahan',
                      vm.totalLahan.toString(),
                      Icons.landscape,
                      const Color(0xFF4CAF50),
                    ),
                    _buildStatItem(
                      'Total Luas',
                      '${vm.totalLuas.toStringAsFixed(1)} ha',
                      Icons.square_foot,
                      const Color(0xFF2196F3),
                    ),
                    _buildStatItem(
                      'Titik Tanam',
                      vm.totalTitikTanam.toString(),
                      Icons.place,
                      const Color(0xFFFF9800),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ✅ LAHAN-SPECIFIC: Content section (similar to HomePage quick actions)
  Widget _buildLahanContent() {
    return Consumer<LahanViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(50),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              ),
            ),
          );
        }

        if (vm.hasError) {
          return _buildErrorSection(vm);
        }

        final filteredLahan = vm.lahanList.where((lahan) {
          return lahan.nama.toLowerCase().contains(_searchQuery) ||
              lahan.lokasi.toLowerCase().contains(_searchQuery);
        }).toList();

        if (filteredLahan.isEmpty) {
          return _buildEmptySection();
        }

        return _buildLahanList(filteredLahan);
      },
    );
  }

  // ✅ LAHAN-SPECIFIC: Error section (similar to HomePage empty sections)
  Widget _buildErrorSection(LahanViewModel vm) {
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
              onPressed: () => vm.loadAllLahan(),
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

  // ✅ LAHAN-SPECIFIC: Empty section (same structure as HomePage empty sections)
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
                    Icons.grass_outlined,
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
                        'Belum ada lahan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C5F2D),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tambahkan lahan pertama Anda',
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

  // ✅ LAHAN-SPECIFIC: Lahan list (similar to HomePage content structure)
  Widget _buildLahanList(List<Lahan> filteredLahan) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Column(
        children: [
          ...filteredLahan.asMap().entries.map((entry) {
            int index = entry.key;
            Lahan lahan = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: LahanCard(
                lahan: lahan,
                cardIndex: index, // Tambahkan parameter cardIndex
                onTap: () => _navigateToDetail(context, lahan.id),
                onEdit: () => _navigateToForm(context, lahan: lahan),
                onDelete: () => _handleDelete(context, lahan),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _navigateToForm(BuildContext context, {Lahan? lahan}) {
    final vm = Provider.of<LahanViewModel>(context, listen: false);

    // ✅ PENTING: Clear form state sebelum navigasi
    if (lahan == null) {
      // Mode tambah baru - clear semua state
      vm.clearForm();
    } else {
      // Mode edit - set data lahan
      vm.setSelectedLahan(lahan);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LahanFormPage(lahan: lahan),
      ),
    ).then((_) {
      // Refresh data setelah kembali
      vm.loadAllLahan();
      // ✅ TAMBAHAN: Clear form setelah kembali dari form
      vm.clearForm();
    });
  }

  void _navigateToDetail(BuildContext context, int lahanId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LahanDetailPage(lahanId: lahanId),
      ),
    ).then((_) {
      final vm = Provider.of<LahanViewModel>(context, listen: false);
      vm.loadAllLahan();
    });
  }

  void _handleDelete(BuildContext context, Lahan lahan) async {
    // ✅ Tampilkan confirmation dialog
    final bool? shouldDelete = await _showDeleteConfirmation(context, lahan);

    if (shouldDelete == true) {
      final vm = Provider.of<LahanViewModel>(context, listen: false);
      final success = await vm.deleteLahan(lahan.id);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lahan "${lahan.nama}" berhasil dihapus'),
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

  // Alternative menggunakan bottom sheet (lebih modern)
  Future<bool?> _showDeleteConfirmation(BuildContext context, Lahan lahan) {
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
              'Hapus Lahan?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Lahan "${lahan.nama}" akan dihapus permanen',
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
