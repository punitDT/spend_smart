import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ExpenseChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> chartData;
  final String title;
  final bool showLabels;

  const ExpenseChartWidget({
    Key? key,
    required this.chartData,
    required this.title,
    this.showLabels = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (chartData.isEmpty)
              const Center(heightFactor: 2.0, child: Text('No data available'))
            else
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _getMaxValue() * 1.2,
                    backgroundColor: Colors.white,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipRoundedRadius: 8,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final value = rod.toY;
                          return BarTooltipItem(
                            '${chartData[groupIndex]['label']}\n₹${value.toStringAsFixed(2)}',
                            TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: showLabels,
                          getTitlesWidget: _bottomTitles,
                          reservedSize: 30,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: _leftTitles,
                        ),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      horizontalInterval: _getMaxValue() / 5,
                      checkToShowHorizontalLine: (value) =>
                          value % (_getMaxValue() / 5) == 0,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.withOpacity(0.3),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: _generateBarGroups(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  double _getMaxValue() {
    if (chartData.isEmpty) return 100.0;
    return chartData
        .map((item) => item['value'] as double)
        .reduce((value, element) => value > element ? value : element);
  }

  List<BarChartGroupData> _generateBarGroups() {
    return List.generate(chartData.length, (index) {
      final item = chartData[index];
      Color barColor = item['color'] ?? Colors.blue;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: item['value'],
            color: barColor,
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    });
  }

  Widget _bottomTitles(double value, TitleMeta meta) {
    if (value >= 0 && value < chartData.length) {
      final style = TextStyle(
        color: Colors.grey[600],
        fontWeight: FontWeight.bold,
        fontSize: 12,
      );

      String text = chartData[value.toInt()]['label'];
      // Truncate long labels
      if (text.length > 8) {
        text = '${text.substring(0, 6)}...';
      }

      return SideTitleWidget(
        axisSide: meta.axisSide,
        child: Text(text, style: style),
      );
    }
    return Container();
  }

  Widget _leftTitles(double value, TitleMeta meta) {
    if (value == 0) {
      return Container();
    }

    final style = TextStyle(
      color: Colors.grey[600],
      fontWeight: FontWeight.normal,
      fontSize: 10,
    );

    // Format currency values with 2 decimal places
    String text = '₹${value.toStringAsFixed(2)}';

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style),
    );
  }
}
