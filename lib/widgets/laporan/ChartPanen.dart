import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/laporan_models.dart';

class ChartPanenWidget extends StatelessWidget {
  final LaporanData laporanData;

  const ChartPanenWidget({
    Key? key,
    required this.laporanData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Group data panen by month
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
                  Icons.agriculture_outlined,
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
                      'Grafik Panen',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C5F2D),
                      ),
                    ),
                    Text(
                      'Perbandingan hasil panen per bulan',
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
              _buildLegendItem('Panen Pertama', const Color(0xFF2196F3)),
              const SizedBox(width: 24),
              _buildLegendItem('Panen Kedua', const Color(0xFF4CAF50)),
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
    final panenData = laporanData.panen.data;

    // Group by year-month
    Map<String, List<PanenLaporanItem>> groupedByMonth = {};

    for (var panen in panenData) {
      try {
        final date = DateTime.parse(panen.tanggal);
        final monthKey = DateFormat('yyyy-MM').format(date);

        if (!groupedByMonth.containsKey(monthKey)) {
          groupedByMonth[monthKey] = [];
        }
        groupedByMonth[monthKey]!.add(panen);
      } catch (e) {
        print('Error parsing date: ${panen.tanggal}');
      }
    }

    // Sort months chronologically
    final sortedMonths = groupedByMonth.keys.toList()..sort();

    // Prepare data for chart
    List<String> months = [];
    List<double?> panen1Data = [];
    List<double?> panen2Data = [];

    for (var monthKey in sortedMonths) {
      final panenList = groupedByMonth[monthKey]!;

      // Sort by date within month (oldest first)
      panenList.sort((a, b) {
        try {
          return DateTime.parse(a.tanggal).compareTo(DateTime.parse(b.tanggal));
        } catch (e) {
          return 0;
        }
      });

      // Format month label (e.g., "Jan 2024")
      try {
        final date = DateTime.parse('$monthKey-01');
        months.add(DateFormat('MMM yy', 'id_ID').format(date));
      } catch (e) {
        months.add(monthKey);
      }

      // First harvest of the month
      panen1Data
          .add(panenList.isNotEmpty ? panenList[0].jumlah.toDouble() : null);

      // Second harvest of the month (if exists)
      panen2Data
          .add(panenList.length > 1 ? panenList[1].jumlah.toDouble() : null);
    }

    // Calculate statistics
    int totalPanen1 = 0;
    int totalPanen2 = 0;
    int countPanen1 = 0;
    int countPanen2 = 0;

    for (int i = 0; i < panen1Data.length; i++) {
      if (panen1Data[i] != null) {
        totalPanen1 += panen1Data[i]!.toInt();
        countPanen1++;
      }
      if (panen2Data[i] != null) {
        totalPanen2 += panen2Data[i]!.toInt();
        countPanen2++;
      }
    }

    return {
      'months': months,
      'panen1': panen1Data,
      'panen2': panen2Data,
      'totalPanen1': totalPanen1,
      'totalPanen2': totalPanen2,
      'avgPanen1': countPanen1 > 0 ? (totalPanen1 / countPanen1) : 0.0,
      'avgPanen2': countPanen2 > 0 ? (totalPanen2 / countPanen2) : 0.0,
      'countPanen1': countPanen1,
      'countPanen2': countPanen2,
    };
  }

  LineChartData _buildLineChartData(Map<String, dynamic> chartData) {
    final months = chartData['months'] as List<String>;
    final panen1Data = chartData['panen1'] as List<double?>;
    final panen2Data = chartData['panen2'] as List<double?>;

    // Find max value for Y-axis
    double maxY = 0;
    for (var value in [...panen1Data, ...panen2Data]) {
      if (value != null && value > maxY) {
        maxY = value;
      }
    }

    // Add 20% padding to max
    maxY = maxY * 1.2;
    if (maxY == 0) maxY = 100; // Default if no data

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
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 45,
            interval: maxY / 5,
            getTitlesWidget: (value, meta) {
              return Text(
                '${value.toInt()} kg',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
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
      maxX: months.length.toDouble() - 1,
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        // Line for Panen 1
        _buildLineChartBarData(
          panen1Data,
          const Color(0xFF2196F3),
          'Panen 1',
        ),
        // Line for Panen 2
        _buildLineChartBarData(
          panen2Data,
          const Color(0xFF4CAF50),
          'Panen 2',
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
              final isPanen1 = spot.barIndex == 0;

              return LineTooltipItem(
                '${isPanen1 ? 'Panen 1' : 'Panen 2'}\n$month\n${spot.y.toInt()} kg',
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

  LineChartBarData _buildLineChartBarData(
    List<double?> data,
    Color color,
    String label,
  ) {
    // Convert data to FlSpot, filtering out null values
    final spots = <FlSpot>[];
    for (int i = 0; i < data.length; i++) {
      if (data[i] != null) {
        spots.add(FlSpot(i.toDouble(), data[i]!));
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
              'Total Panen 1',
              '${chartData['totalPanen1']} kg',
              '${chartData['countPanen1']}x panen',
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
              'Total Panen 2',
              '${chartData['totalPanen2']} kg',
              '${chartData['countPanen2']}x panen',
              const Color(0xFF4CAF50),
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
            Icons.agriculture_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum Ada Data Panen',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Data panen akan ditampilkan di sini',
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
