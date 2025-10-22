import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/laporan_models.dart';

class ChartPerawatanWidget extends StatelessWidget {
  final LaporanData laporanData;

  const ChartPerawatanWidget({
    Key? key,
    required this.laporanData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Prepare chart data
    final chartData = _prepareChartData();

    if (chartData['months'].isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.spa_outlined,
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
                      'Grafik Perawatan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C5F2D),
                      ),
                    ),
                    Text(
                      'Material perawatan per bulan (Kg & Liter)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Material Padat (Kg)', const Color(0xFF2196F3)),
              const SizedBox(width: 24),
              _buildLegendItem(
                  'Material Cair (Liter)', const Color(0xFFFF9800)),
            ],
          ),

          const SizedBox(height: 24),

          // Chart
          SizedBox(
            height: 250,
            child: LineChart(
              _buildLineChartData(chartData),
            ),
          ),

          const SizedBox(height: 16),

          // Summary info
          _buildSummaryInfo(chartData),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _prepareChartData() {
    final perawatanData = laporanData.perawatan.data;

    // Group by year-month
    Map<String, Map<String, double>> groupedByMonth = {};

    for (var perawatan in perawatanData) {
      try {
        final date = DateTime.parse(perawatan.tanggal);
        final monthKey = DateFormat('yyyy-MM').format(date);

        if (!groupedByMonth.containsKey(monthKey)) {
          groupedByMonth[monthKey] = {'kg': 0.0, 'liter': 0.0};
        }

        // Categorize by satuan (now available from API)
        final satuan = perawatan.satuan?.toLowerCase() ?? '';

        if (satuan == 'liter') {
          groupedByMonth[monthKey]!['liter'] =
              (groupedByMonth[monthKey]!['liter'] ?? 0) + perawatan.jumlah;
        } else if (satuan == 'kg') {
          groupedByMonth[monthKey]!['kg'] =
              (groupedByMonth[monthKey]!['kg'] ?? 0) + perawatan.jumlah;
        } else {
          // Default: if satuan is null or other, categorize as kg
          groupedByMonth[monthKey]!['kg'] =
              (groupedByMonth[monthKey]!['kg'] ?? 0) + perawatan.jumlah;
        }
      } catch (e) {
        print('Error parsing perawatan date: ${perawatan.tanggal}');
      }
    }

    // Sort months chronologically
    final sortedMonths = groupedByMonth.keys.toList()..sort();

    // Prepare data for chart
    List<String> months = [];
    List<double> kgData = [];
    List<double> literData = [];

    for (var monthKey in sortedMonths) {
      // Format month label
      try {
        final date = DateTime.parse('$monthKey-01');
        months.add(DateFormat('MMM yy', 'id_ID').format(date));
      } catch (e) {
        months.add(monthKey);
      }

      kgData.add(groupedByMonth[monthKey]!['kg'] ?? 0);
      literData.add(groupedByMonth[monthKey]!['liter'] ?? 0);
    }

    // Calculate statistics
    final totalKg = kgData.fold<double>(0, (sum, val) => sum + val);
    final totalLiter = literData.fold<double>(0, (sum, val) => sum + val);
    final avgKg = kgData.isNotEmpty ? totalKg / kgData.length : 0.0;
    final avgLiter = literData.isNotEmpty ? totalLiter / literData.length : 0.0;

    // Count occurrences
    int countKg = kgData.where((val) => val > 0).length;
    int countLiter = literData.where((val) => val > 0).length;

    return {
      'months': months,
      'kg': kgData,
      'liter': literData,
      'totalKg': totalKg,
      'totalLiter': totalLiter,
      'avgKg': avgKg,
      'avgLiter': avgLiter,
      'countKg': countKg,
      'countLiter': countLiter,
    };
  }

  LineChartData _buildLineChartData(Map<String, dynamic> chartData) {
    final months = chartData['months'] as List<String>;
    final kgData = chartData['kg'] as List<double>;
    final literData = chartData['liter'] as List<double>;

    // Find max values for both Y-axes
    double maxKg = kgData.isEmpty ? 0 : kgData.reduce((a, b) => a > b ? a : b);
    double maxLiter =
        literData.isEmpty ? 0 : literData.reduce((a, b) => a > b ? a : b);

    // Add 20% padding
    maxKg = maxKg * 1.2;
    maxLiter = maxLiter * 1.2;

    if (maxKg == 0) maxKg = 100;
    if (maxLiter == 0) maxLiter = 100;

    // Use unified scale for better visualization
    final maxY = maxKg > maxLiter ? maxKg : maxLiter;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxY / 5,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.shade200,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        // Left Y-axis: Kg (Blue)
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            interval: maxKg / 5,
            getTitlesWidget: (value, meta) {
              if (value == 0 || value == meta.max) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  '${value.toInt()}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF2196F3),
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.right,
                ),
              );
            },
          ),
          axisNameWidget: const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Text(
              'Kg',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF2196F3),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        // Right Y-axis: Liter (Orange)
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            interval: maxLiter / 5,
            getTitlesWidget: (value, meta) {
              if (value == 0 || value == meta.max) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  '${value.toInt()}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFFFF9800),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
          axisNameWidget: const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Text(
              'Liter',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFFFF9800),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < months.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    months[index],
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
          left: BorderSide(color: Colors.grey.shade300, width: 1),
          right: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      minX: 0,
      maxX: months.length.toDouble() - 1,
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        // Line for Kg (Blue) - mapped to left axis
        _buildLineChartBarData(
          kgData,
          const Color(0xFF2196F3),
          'Material Kg',
        ),
        // Line for Liter (Orange) - mapped to right axis
        _buildLineChartBarData(
          literData,
          const Color(0xFFFF9800),
          'Material Liter',
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final monthIndex = spot.x.toInt();
              final months = chartData['months'] as List<String>;
              final month =
                  monthIndex < months.length ? months[monthIndex] : '';
              final isKg = spot.barIndex == 0;

              return LineTooltipItem(
                '${isKg ? 'Material Kg' : 'Material Liter'}\n$month\n${spot.y.toInt()} ${isKg ? 'kg' : 'liter'}',
                TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
        ),
        handleBuiltInTouches: true,
      ),
    );
  }

  LineChartBarData _buildLineChartBarData(
    List<double> data,
    Color color,
    String label,
  ) {
    // Convert data to FlSpot
    final spots = <FlSpot>[];
    for (int i = 0; i < data.length; i++) {
      if (data[i] > 0) {
        // Only add non-zero values
        spots.add(FlSpot(i.toDouble(), data[i]));
      }
    }

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.3,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 4,
            color: Colors.white,
            strokeWidth: 2,
            strokeColor: color,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        color: color.withOpacity(0.1),
      ),
    );
  }

  Widget _buildSummaryInfo(Map<String, dynamic> chartData) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4CAF50).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              'Total Kg',
              '${chartData['totalKg'].toInt()} kg',
              '${chartData['countKg']}x perawatan',
              const Color(0xFF2196F3),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.shade300,
          ),
          Expanded(
            child: _buildSummaryItem(
              'Total Liter',
              '${chartData['totalLiter'].toInt()} L',
              '${chartData['countLiter']}x perawatan',
              const Color(0xFFFF9800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
      String label, String value, String subtext, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          subtext,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Icon(
            Icons.spa_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum Ada Data Perawatan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Data perawatan akan ditampilkan di sini',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
