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
                      'Material perawatan (Kg & Liter)',
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

          // Chart Material Padat (Kg)
          _buildSingleChart(
            chartData,
            'Material Padat (Kg)',
            'kg',
            const Color(0xFFFF5722),
          ),

          const SizedBox(height: 24),

          // Chart Material Cair (Liter)
          _buildSingleChart(
            chartData,
            'Material Cair (Liter)',
            'liter',
            const Color(0xFF2196F3),
          ),

          const SizedBox(height: 16),

          // Summary info
          _buildSummaryInfo(chartData),
        ],
      ),
    );
  }

  Widget _buildSingleChart(
    Map<String, dynamic> chartData,
    String title,
    String dataKey,
    Color color,
  ) {
    final months = chartData['months'] as List<String>;
    final data = chartData[dataKey] as List<double>;

    // Find max value
    double maxValue = data.isEmpty ? 0 : data.reduce((a, b) => a > b ? a : b);
    maxValue = maxValue * 1.2; // Add 20% padding
    if (maxValue == 0) maxValue = 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Legend
        Row(
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
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Chart
        SizedBox(
          height: 200,
          child: LineChart(
            _buildSingleLineChartData(
              months,
              data,
              maxValue,
              color,
              dataKey,
            ),
          ),
        ),
      ],
    );
  }

  LineChartData _buildSingleLineChartData(
    List<String> months,
    List<double> data,
    double maxY,
    Color color,
    String dataKey,
  ) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxY / 5,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.shade200,
            strokeWidth: 1,
            dashArray: [5, 5],
          );
        },
      ),
      titlesData: FlTitlesData(
        // Left Y-axis
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            interval: maxY / 5,
            getTitlesWidget: (value, meta) {
              if (value == meta.max) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  '${value.toInt()}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.right,
                ),
              );
            },
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
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
        ),
      ),
      minX: 0,
      maxX: months.length > 0 ? months.length.toDouble() - 1 : 0,
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        _buildLineChartBarData(
          data,
          color,
          dataKey,
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final monthIndex = spot.x.toInt();
              final month =
                  monthIndex < months.length ? months[monthIndex] : '';
              final unit = dataKey == 'kg' ? 'kg' : 'liter';

              return LineTooltipItem(
                '$month\n${spot.y.toInt()} $unit',
                const TextStyle(
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
        months.add(DateFormat('MMM', 'id_ID').format(date));
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

  LineChartBarData _buildLineChartBarData(
    List<double> data,
    Color color,
    String label,
  ) {
    // Convert data to FlSpot
    final spots = <FlSpot>[];
    for (int i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i]));
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
            color: color,
            strokeWidth: 0,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: false,
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
              '${chartData['totalKg'].toInt()} Kg',
              '${chartData['countKg']}x perawatan',
              const Color(0xFFFF5722),
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
              '${chartData['totalLiter'].toInt()} Liter',
              '${chartData['countLiter']}x perawatan',
              const Color(0xFF2196F3),
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
