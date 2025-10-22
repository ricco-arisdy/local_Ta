import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ta_project/models/lahan_models.dart';
import 'package:ta_project/models/panen_models.dart';
import 'package:ta_project/models/perawatan_models.dart';
import 'dart:convert';
import 'package:ta_project/models/user_models.dart';
import 'package:ta_project/models/app_constants.dart';
import 'package:ta_project/services/lahan_service.dart';
import 'package:ta_project/services/panen_service.dart';
import 'package:ta_project/services/perawatan_service.dart';
import 'package:ta_project/views/lahan/lahan_page.dart';
import 'package:ta_project/views/laporan/laporan.dart';
import 'package:ta_project/views/panen/panen_page.dart';
import 'package:ta_project/views/perawatan/perawatan_page.dart';
import 'package:ta_project/views/profile_page.dart';
import 'package:ta_project/viewsModels/login_view_models.dart';
import 'package:ta_project/widgets/HomeCardLahan/card_lahan.dart';
import 'package:ta_project/widgets/HomeCardPanen/card_panen.dart';
import 'package:ta_project/widgets/HomeCardPerawatan/card_perawatan.dart';
import 'package:ta_project/widgets/buttomnavigation/buttom_navigation.dart';
import 'package:ta_project/widgets/skeleton/skeleton_card.dart';
import 'package:ta_project/widgets/skeleton/skeleton_screen.dart';
import 'package:ta_project/widgets/theme/tema_utama.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? _currentUser;
  bool _isLoading = true;
  bool _isDashboardLoading = true;
  int _currentIndex = 0;

  // Data statistics
  int _totalLahan = 0;
  int _totalPanen = 0;
  int _totalPerawatan = 0;
  double _totalLuas = 0.0;
  double _totalPendapatan = 0.0;
  double _totalBiayaPerawatan = 0.0;
  List<Lahan> _recentLahan = [];
  List<Panen> _recentPanen = [];
  List<Perawatan> _recentPerawatan = [];

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
      print('🔄 [HOME] Login state changed - reloading data...');
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _loadDashboardData();
        });
      }
    });
  }

  void _handleLoginStateChange() {
    print('🔄 [HOME] Login state changed - reloading data...');
    _loadDashboardData();
  }

  Future<void> _loadInitialData() async {
    await _loadUser();
    if (mounted) {
      await _loadDashboardData();
    }
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;

    setState(() {
      _isDashboardLoading = true;
    });

    try {
      // ✅ Load lahan data
      final lahanService = LahanService();
      final lahanResponse = await lahanService.getAllLahan();

      // ✅ Load panen data
      final panenResponse = await PanenService.getAllPanen();

      // ✅ Load perawatan data
      final perawatanResponse = await PerawatanService.getAllPerawatan();

      if (mounted) {
        // ✅ Process lahan data
        int totalLahan = 0;
        double totalLuas = 0.0;
        List<Lahan> recentLahan = [];

        if (lahanResponse.isSuccess) {
          final lahanList = lahanResponse.data ?? [];
          totalLahan = lahanList.length;
          totalLuas = lahanList.fold(0.0, (sum, lahan) {
            final luas = double.tryParse(lahan.luas) ?? 0.0;
            return sum + luas;
          });
          recentLahan = lahanList.take(3).toList();
        }

        // ✅ Process panen data
        int totalPanen = 0;
        double totalPendapatan = 0.0;
        List<Panen> recentPanen = [];

        if (panenResponse.isSuccess && panenResponse.data != null) {
          final panenList = panenResponse.data!;

          // Sort by date (newest first)
          panenList.sort((a, b) {
            try {
              final dateA = DateTime.parse(a.tanggal);
              final dateB = DateTime.parse(b.tanggal);
              return dateB.compareTo(dateA);
            } catch (e) {
              return b.id.compareTo(a.id);
            }
          });

          totalPanen = panenList.length;
          totalPendapatan = panenList.fold(
              0.0, (sum, panen) => sum + panen.totalNilai.toDouble());
          recentPanen = panenList.take(3).toList();
        }

        // ✅ Process perawatan data
        int totalPerawatan = 0;
        double totalBiayaPerawatan = 0.0;
        List<Perawatan> recentPerawatan = [];

        if (perawatanResponse.isSuccess && perawatanResponse.data != null) {
          final perawatanList = perawatanResponse.data!;

          // Sort by date (newest first)
          perawatanList.sort((a, b) {
            try {
              final dateA = DateTime.parse(a.tanggal);
              final dateB = DateTime.parse(b.tanggal);
              return dateB.compareTo(dateA);
            } catch (e) {
              return b.id.compareTo(a.id);
            }
          });

          totalPerawatan = perawatanList.length;
          totalBiayaPerawatan = perawatanList.fold(
              0.0, (sum, perawatan) => sum + perawatan.biaya.toDouble());
          recentPerawatan = perawatanList.take(3).toList();
        }

        setState(() {
          // Lahan
          _totalLahan = totalLahan;
          _totalLuas = totalLuas;
          _recentLahan = recentLahan;

          // Panen
          _totalPanen = totalPanen;
          _totalPendapatan = totalPendapatan;
          _recentPanen = recentPanen;

          // ✅ Perawatan
          _totalPerawatan = totalPerawatan;
          _totalBiayaPerawatan = totalBiayaPerawatan;
          _recentPerawatan = recentPerawatan;

          _isDashboardLoading = false;
        });

        print(
            '✅ [HOME] Dashboard loaded: $totalLahan lahan, $totalPanen panen, $totalPerawatan perawatan');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _totalLahan = 0;
          _totalLuas = 0.0;
          _recentLahan = [];
          _totalPanen = 0;
          _totalPendapatan = 0.0;
          _recentPanen = [];
          _totalPerawatan = 0;
          _totalBiayaPerawatan = 0.0;
          _recentPerawatan = [];
          _isDashboardLoading = false;
        });

        print('💥 [HOME] Dashboard error: $e');
      }
    }
  }

  Future<void> _loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(AppConstants.isLoggedInKey) ?? false;

      if (!isLoggedIn) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      final userDataString = prefs.getString(AppConstants.userDataKey);

      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        if (mounted) {
          setState(() {
            _currentUser = User.fromJson(userData);
          });
        }
        print('✅ [HOME] User loaded: ${_currentUser?.nama}');
      } else {
        print('⚠️ [HOME] No user data found');
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }
    } catch (e) {
      print('💥 [HOME] Error loading user: $e');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _refreshDashboard() {
    print('🔄 [HOME] Refreshing dashboard data...');
    _loadDashboardData();
  }

  void _handleNavigation(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LahanPage()),
        ).then((_) {
          _refreshDashboard();
        });
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PanenPage()),
        ).then((_) {
          _refreshDashboard();
        });
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PerawatanPage()),
        ).then((_) {
          _refreshDashboard();
        });
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LaporanPage()),
        ).then((_) {
          _refreshDashboard();
        });
        break;
    }
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon!'),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
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
                      type: SkeletonType.home,
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
              onRefresh: _loadDashboardData,
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
                          _buildSummaryCard(),
                          const SizedBox(height: 20),
                          _buildQuickActions(),
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
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
      child: Row(
        children: [
          InkWell(
            onTap: _navigateToProfile,
            borderRadius: BorderRadius.circular(24),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: const Icon(
                Icons.person,
                size: 32,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hallo,',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  _currentUser?.nama ?? 'Pengguna',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfilePage(),
      ),
    );
  }

  Widget _buildSummaryCard() {
    if (_isDashboardLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const SkeletonCard(height: 160),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4CAF50).withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total Pendapatan Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Total Pendapatan',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.95),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rp ${_formatCurrency(_totalPendapatan)}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),

                // Lihat semua button
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LaporanPage()),
                    ).then((_) {
                      // Refresh dashboard when returning from laporan
                      _refreshDashboard();
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Lihat semua',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.95),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: Colors.white.withOpacity(0.95),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // ==== Statistics Grid ====
            Row(
              children: [
                Expanded(
                  child: _buildCompactStatItem(
                    icon: Icons.landscape_rounded,
                    label: 'Lahan',
                    value: _totalLahan.toString(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCompactStatItem(
                    icon: Icons.agriculture_rounded,
                    label: 'Panen',
                    value: _totalPanen.toString(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCompactStatItem(
                    icon: Icons.grass_rounded,
                    label: 'Perawatan',
                    value: _totalPerawatan.toString(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCompactStatItem(
                    icon: Icons.square_foot_rounded,
                    label: 'Luas',
                    value: '${_totalLuas.toStringAsFixed(1)}Ha',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

// Widget untuk stat item yang compact sesuai wireframe
  Widget _buildCompactStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: 70,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    if (_isDashboardLoading) {
      return const Column(
        children: [
          SkeletonCard(height: 100),
          SizedBox(height: 20),
          SkeletonCard(height: 100),
          SizedBox(height: 20),
          SkeletonCard(height: 100),
        ],
      );
    }

    return Column(
      children: [
        _buildLahanSection(),
        const SizedBox(height: 20),
        _buildPanenSection(),
        const SizedBox(height: 20),
        _buildPerawatanSection(),
      ],
    );
  }

  Widget _buildLahanSection() {
    if (_isDashboardLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: const SkeletonCard(height: 120),
      );
    }

    return LahanHomeCard(
      totalLahan: _totalLahan,
      totalLuas: _totalLuas,
      recentLahan: _recentLahan,
      onTap: () => _handleNavigation(1),
    );
  }

  Widget _buildPanenSection() {
    if (_isDashboardLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: const SkeletonCard(height: 120),
      );
    }

    return _totalPanen > 0
        ? PanenHomeCard(
            totalPanen: _totalPanen,
            totalPendapatan: _totalPendapatan,
            recentPanen: _recentPanen,
            onTap: () => _handleNavigation(2),
          )
        : _buildEmptySection(
            title: 'Panen',
            subtitle: 'Belum ada data panen',
            icon: Icons.agriculture_outlined,
            onTap: () => _handleNavigation(2),
          );
  }

  Widget _buildPerawatanSection() {
    if (_isDashboardLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: const SkeletonCard(height: 120),
      );
    }

    // ✅ Tampilkan data perawatan real atau empty state
    return _totalPerawatan > 0
        ? PerawatanWidget(
            totalPerawatan: _totalPerawatan, // ✅ int
            totalBiaya: _totalBiayaPerawatan.toInt(), // ✅ convert double ke int
            recentPerawatan: _recentPerawatan,
            onTap: () => _handleNavigation(3),
          )
        : _buildEmptySection(
            title: 'Perawatan',
            subtitle: 'Belum ada data perawatan',
            icon: Icons.handyman_outlined,
            onTap: () => _handleNavigation(3),
          );
  }

  Widget _buildEmptySection({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
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
                icon,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C5F2D),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Tambah Data',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount == 0) return '0';

    final formatter = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String result = amount.toStringAsFixed(0);
    return result.replaceAllMapped(formatter, (Match m) => '${m[1]}.');
  }

  @override
  void dispose() {
    LoginViewModel.logoutNotifier.removeListener(_handleLoginStateChange);
    super.dispose();
  }
}
