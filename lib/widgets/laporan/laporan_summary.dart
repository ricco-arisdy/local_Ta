import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LaporanSummaryCard extends StatelessWidget {
  final Map<String, dynamic> summaryData;
  final int currentPage;
  final int totalPages;
  final Function(int)? onPageChanged;

  const LaporanSummaryCard({
    super.key,
    required this.summaryData,
    this.currentPage = 0,
    this.totalPages = 1,
    this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final formatCurrency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    // Debug print untuk troubleshooting
    print(
        '🔍 [SUMMARY_CARD] Current page: $currentPage, Total pages: $totalPages');
    print('🔍 [SUMMARY_CARD] OnPageChanged: ${onPageChanged != null}');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Stack(
        children: [
          // Main Card with notch - WRAPPED WITH GESTURE DETECTOR
          GestureDetector(
            onHorizontalDragEnd: (details) {
              if (totalPages <= 1) return;

              // Determine swipe direction
              if (details.primaryVelocity! > 0) {
                // Swipe right (previous page)
                if (currentPage > 0 && onPageChanged != null) {
                  print(
                      '🔍 [SWIPE] Swipe right - going to page ${currentPage - 1}');
                  onPageChanged!(currentPage - 1);
                }
              } else if (details.primaryVelocity! < 0) {
                // Swipe left (next page)
                if (currentPage < totalPages - 1 && onPageChanged != null) {
                  print(
                      '🔍 [SWIPE] Swipe left - going to page ${currentPage + 1}');
                  onPageChanged!(currentPage + 1);
                }
              }
            },
            child: ClipPath(
              clipper: NotchedCardClipper(),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.blue.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildSubtitle(),
                    const SizedBox(height: 12),
                    _buildPageContent(formatCurrency),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),

          // Pagination Dots positioned in the notch area
          if (totalPages > 1)
            Positioned(
              bottom: -2,
              left: 0,
              right: 0,
              child: _buildPaginationDots(),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    // final isFiltered = summaryData['isFiltered'] ?? false;
    final totalBiayaPerawatan = summaryData['totalBiayaPerawatan'] ?? 0;
    final totalPendapatan = summaryData['totalPendapatan'] ?? 0;
    final isUntung = summaryData['isUntung'] ?? false;
    final persentaseKeuntungan =
        (summaryData['persentaseKeuntungan'] ?? 0.0) as double;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left side - Dynamic Title
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getPageIcon(),
                size: 24,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getPageTitle(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                // Page indicator
                if (totalPages > 1)
                  Text(
                    '${currentPage + 1} dari $totalPages',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.blue.shade600,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
              ],
            ),
          ],
        ),
        // Right side - Performance Indicator (only on financial page)
        if (currentPage == 0 &&
            _shouldShowPerformanceIndicator(
                totalBiayaPerawatan, totalPendapatan))
          _buildCompactPerformanceIndicator(isUntung, persentaseKeuntungan),
      ],
    );
  }

  Widget _buildSubtitle() {
    if (currentPage != 0) {
      return const SizedBox.shrink();
    }

    final isFiltered = summaryData['isFiltered'] ?? false;
    final totalLahan = summaryData['totalLahan'] ?? 0;
    final lahanName = summaryData['lahanName'] ?? '';
    final lahanLokasi = summaryData['lahanLokasi'] ?? '';
    final totalPerawatan = summaryData['totalPerawatan'] ?? 0;
    final totalPanen = summaryData['totalPanen'] ?? 0;

    if (!_shouldShowSubtitle(isFiltered, totalLahan, lahanName)) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.shade200, width: 0.5),
          ),
          child: isFiltered && lahanName.isNotEmpty
              ? _buildFilteredSubtitle(lahanName, lahanLokasi)
              : _buildUnfilteredSubtitle(totalLahan),
        ),
      ],
    );
  }

  //Widget untuk subtitle FILTERED (dengan nama lahan + lokasi dalam 1 baris)
  Widget _buildFilteredSubtitle(String lahanName, String lahanLokasi) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon Filter
        Icon(
          Icons.filter_list,
          size: 12,
          color: Colors.blue.shade700,
        ),
        const SizedBox(width: 4),

        // Nama Lahan
        Flexible(
          child: Text(
            'Filter: $lahanName',
            style: TextStyle(
              fontSize: 11,
              color: Colors.blue.shade700,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),

        if (lahanLokasi.isNotEmpty) ...[
          const SizedBox(width: 8),
          Icon(
            Icons.location_on,
            size: 12,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              lahanLokasi,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ],
    );
  }

  // Widget untuk subtitle UNFILTERED (total lahan aktif)
  Widget _buildUnfilteredSubtitle(int totalLahan) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.dashboard,
          size: 12,
          color: Colors.blue.shade700,
        ),
        const SizedBox(width: 4),
        Text(
          '$totalLahan Lahan Aktif',
          style: TextStyle(
            fontSize: 10,
            color: Colors.blue.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPageContent(NumberFormat formatCurrency) {
    // Debug print untuk melihat halaman apa yang ditampilkan
    print('🔍 [SUMMARY_CARD] Building page content for page: $currentPage');

    // Animation wrapper for smooth transitions
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey(currentPage),
        child: _getPageContent(formatCurrency),
      ),
    );
  }

  Widget _getPageContent(NumberFormat formatCurrency) {
    switch (currentPage) {
      case 0:
        return _buildFinancialPage(formatCurrency);
      case 1:
        return _buildDetailPage();
      default:
        return _buildFinancialPage(formatCurrency);
    }
  }

  Widget _buildFinancialPage(NumberFormat formatCurrency) {
    final totalBiayaPerawatan = summaryData['totalBiayaPerawatan'] ?? 0;
    final totalPendapatan = summaryData['totalPendapatan'] ?? 0;
    final totalKeuntungan = summaryData['totalKeuntungan'] ?? 0;
    final isUntung = summaryData['isUntung'] ?? false;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Biaya & Pendapatan in Row
          Row(
            children: [
              Expanded(
                child: _buildCompactSummaryItem(
                  'Biaya',
                  totalBiayaPerawatan,
                  Icons.remove_circle_outline,
                  Colors.red.shade600,
                  formatCurrency,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey.shade300,
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              Expanded(
                child: _buildCompactSummaryItem(
                  'Pendapatan',
                  totalPendapatan,
                  Icons.add_circle_outline,
                  Colors.green.shade600,
                  formatCurrency,
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, thickness: 1, color: Colors.grey),
          ),

          // Net Result - Highlighted
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: (isUntung ? Colors.green : Colors.red).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: (isUntung ? Colors.green : Colors.red).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isUntung ? Icons.trending_up : Icons.trending_down,
                      color: isUntung
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isUntung ? 'KEUNTUNGAN' : 'KERUGIAN',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isUntung
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
                Text(
                  formatCurrency.format(totalKeuntungan.abs()),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color:
                        isUntung ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🎯 GABUNGAN Halaman Detail (Statistik + Detail dalam satu halaman)
  Widget _buildDetailPage() {
    final luasLahan = summaryData['luasLahan'] ?? '0 Ha';
    final totalPerawatan = summaryData['totalPerawatan'] ?? 0;
    final totalPanen = summaryData['totalPanen'] ?? 0;
    final totalJumlahKg = summaryData['totalJumlahKg'] ?? 0;
    final rataRataBiaya = (summaryData['rataRataBiaya'] ?? 0.0) as double;
    final hargaRataPerKg = (summaryData['hargaRataPerKg'] ?? 0.0) as double;

    return Container(
      padding: const EdgeInsets.all(12), // ✅ UBAH: Sama dengan financial page
      decoration: BoxDecoration(
        color:
            Colors.white.withOpacity(0.5), // ✅ UBAH: Sama dengan financial page
        borderRadius:
            BorderRadius.circular(12), // ✅ UBAH: Sama dengan financial page
        border: Border.all(
          color: Colors.white.withOpacity(0.6),
          width: 1.5, // ✅ UBAH: Sama dengan financial page
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.05), // ✅ UBAH: Sama dengan financial page
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ Row 1: Panen + Perawatan + Luas Lahan (3 kolom)
          Row(
            children: [
              Expanded(
                child: _buildCompactStatCard(
                  'Panen',
                  totalPanen.toString(),
                  Icons.agriculture_outlined,
                  const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 7), // ✅ UBAH: Dari 6 ke 8
              Expanded(
                child: _buildCompactStatCard(
                  'Perawatan',
                  totalPerawatan.toString(),
                  Icons.grass_outlined,
                  const Color(0xFFFF9800),
                ),
              ),
              const SizedBox(width: 7), // ✅ UBAH: Dari 6 ke 8
              Expanded(
                child: _buildCompactStatCard(
                  'Luas Lahan',
                  luasLahan,
                  Icons.square_foot_outlined,
                  const Color(0xFF2196F3),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(
                vertical: 5), // ✅ TAMBAH: Divider seperti financial page
            child: Divider(height: 1, thickness: 1, color: Colors.grey),
          ),

          // ✅ Row 2: Total Kg + Rata² Biaya + Harga/Kg (3 kolom)
          Row(
            children: [
              Expanded(
                child: _buildCompactStatCard(
                  'Total Kg',
                  _formatKg(totalJumlahKg),
                  Icons.scale_outlined,
                  const Color(0xFFE91E63), // Pink
                ),
              ),
              const SizedBox(width: 7), // ✅ UBAH: Dari 6 ke 8
              Expanded(
                child: _buildCompactStatCard(
                  'Rata² Biaya',
                  _formatRupiah(rataRataBiaya),
                  Icons.money_outlined,
                  const Color(0xFF9C27B0), // Purple
                ),
              ),
              const SizedBox(width: 7), // ✅ UBAH: Dari 6 ke 8
              Expanded(
                child: _buildCompactStatCard(
                  'Harga/Kg',
                  _formatRupiah(hargaRataPerKg),
                  Icons.sell_outlined,
                  const Color(0xFF009688), // Teal
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 4, vertical: 6), // ✅ KURANGI padding
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.08),
            color.withOpacity(0.04),
          ],
        ),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 0.8,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ✅ Icon di atas
          Icon(
            icon,
            color: color,
            size: 16, // ✅ KURANGI: Dari 18 ke 16
          ),
          const SizedBox(height: 3), // ✅ KURANGI: Dari 4 ke 3

          // ✅ Value di tengah
          Text(
            value,
            style: TextStyle(
              fontSize: 12, // ✅ KURANGI: Dari 13 ke 12
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2), // ✅ Tetap 2

          // ✅ Label di bawah
          Text(
            label,
            style: TextStyle(
              fontSize: 9, // ✅ KURANGI: Dari 10 ke 9
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  // Helper methods untuk formatting
  String _formatKg(int kg) {
    if (kg >= 1000) {
      return '${(kg / 1000).toStringAsFixed(1)}k Kg';
    }
    return '$kg Kg';
  }

  String _formatRupiah(double amount) {
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(1)}k';
    }
    return 'Rp ${amount.toStringAsFixed(0)}';
  }

  Widget _buildCompactSummaryItem(
    String label,
    int value,
    IconData icon,
    Color color,
    NumberFormat formatter,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: Colors.grey.shade700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          formatter.format(value),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCompactPerformanceIndicator(bool isUntung, double persentase) {
    String performanceText;
    Color performanceColor;
    IconData performanceIcon;

    if (isUntung) {
      if (persentase >= 50) {
        performanceText = 'Sangat Menguntungkan';
        performanceColor = Colors.green.shade700;
        performanceIcon = Icons.star;
      } else if (persentase >= 20) {
        performanceText = 'Menguntungkan';
        performanceColor = Colors.green.shade600;
        performanceIcon = Icons.thumb_up;
      } else {
        performanceText = 'Cukup Menguntungkan';
        performanceColor = Colors.green.shade500;
        performanceIcon = Icons.thumb_up_outlined;
      }
    } else {
      if (persentase <= -50) {
        performanceText = 'Sangat Merugikan';
        performanceColor = Colors.red.shade700;
        performanceIcon = Icons.warning;
      } else if (persentase <= -20) {
        performanceText = 'Merugikan';
        performanceColor = Colors.red.shade600;
        performanceIcon = Icons.thumb_down;
      } else {
        performanceText = 'Sedikit Merugikan';
        performanceColor = Colors.orange.shade600;
        performanceIcon = Icons.thumb_down_outlined;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: performanceColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: performanceColor.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(performanceIcon, size: 12, color: performanceColor),
          const SizedBox(width: 4),
          Text(
            performanceText,
            style: TextStyle(
              fontSize: 10,
              color: performanceColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // IMPROVED Pagination Dots - Better visual feedback
  Widget _buildPaginationDots() {
    return Container(
      height: 15,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            totalPages,
            (index) => InkWell(
              onTap: () {
                print(
                    '🔍 [PAGINATION] Dot $index tapped, current: $currentPage');
                if (onPageChanged != null && index != currentPage) {
                  print('🔍 [PAGINATION] Calling onPageChanged($index)');
                  onPageChanged!(index);
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: 3), // ✅ Kurangi dari 4 ke 3
                padding: const EdgeInsets.all(3), // ✅ Kurangi dari 4 ke 3
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: index == currentPage
                      ? 20
                      : 8, // ✅ Sedikit perbesar dot aktif
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: index == currentPage
                        ? Colors.white
                            .withOpacity(0.95) // ✅ Lebih solid untuk dot aktif
                        : Colors.white.withOpacity(
                            0.4), // ✅ Lebih transparan untuk dot tidak aktif
                    boxShadow:
                        index == currentPage // ✅ Tambah shadow untuk dot aktif
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : null,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper Methods - Updated untuk 2 halaman
  String _getPageTitle() {
    switch (currentPage) {
      case 0:
        return 'Keuangan';
      case 1:
        return 'Detail';
      default:
        return 'Keuangan';
    }
  }

  IconData _getPageIcon() {
    switch (currentPage) {
      case 0:
        return Icons.account_balance_wallet;
      case 1:
        return Icons.assessment_outlined; // 🎯 Icon untuk Detail
      default:
        return Icons.account_balance_wallet;
    }
  }

  bool _shouldShowSubtitle(bool isFiltered, int totalLahan, String lahanName) {
    return (!isFiltered && totalLahan > 0) ||
        (isFiltered && (lahanName.isNotEmpty || totalLahan > 0));
  }

  bool _shouldShowPerformanceIndicator(int totalBiaya, int totalPendapatan) {
    return totalBiaya > 0 || totalPendapatan > 0;
  }
}

// Custom Clipper remains the same
class NotchedCardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const double cornerRadius = 20.0;
    const double notchWidth = 80.0;
    const double notchHeight = 14.0;
    const double notchRadius = 10.0;

    path.moveTo(cornerRadius, 0);
    path.lineTo(size.width - cornerRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);
    path.lineTo(size.width, size.height - cornerRadius);
    path.quadraticBezierTo(
        size.width, size.height, size.width - cornerRadius, size.height);

    final notchCenterX = size.width / 2;
    final notchStartX = notchCenterX - (notchWidth / 2);
    final notchEndX = notchCenterX + (notchWidth / 2);

    path.lineTo(notchEndX + notchRadius, size.height);
    path.quadraticBezierTo(
        notchEndX, size.height, notchEndX, size.height - notchRadius);
    path.lineTo(notchEndX, size.height - notchHeight + notchRadius);
    path.quadraticBezierTo(notchEndX, size.height - notchHeight,
        notchEndX - notchRadius, size.height - notchHeight);
    path.lineTo(notchStartX + notchRadius, size.height - notchHeight);
    path.quadraticBezierTo(notchStartX, size.height - notchHeight, notchStartX,
        size.height - notchHeight + notchRadius);
    path.lineTo(notchStartX, size.height - notchRadius);
    path.quadraticBezierTo(
        notchStartX, size.height, notchStartX - notchRadius, size.height);
    path.lineTo(cornerRadius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius);
    path.lineTo(0, cornerRadius);
    path.quadraticBezierTo(0, 0, cornerRadius, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
