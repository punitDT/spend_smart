import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../controllers/analytics_controller.dart';

class AnalyticsView extends GetView<AnalyticsController> {
  const AnalyticsView({Key? key}) : super(key: key);

  /// ovveride AnalyticsController
  AnalyticsController get controller => Get.put(AnalyticsController());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Analytics'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Categories'), Tab(text: 'Monthly Trend')],
          ),
        ),
        body: TabBarView(
          children: [_buildCategoryAnalytics(), _buildMonthlyAnalytics()],
        ),
      ),
    );
  }

  Widget _buildCategoryAnalytics() {
    return Column(
      children: [
        _buildMonthYearPicker(),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildPieChart()),
              Expanded(child: _buildCategoryList()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMonthYearPicker() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Obx(
              () => DropdownButton<int>(
                value: controller.selectedMonth.value,
                items: List.generate(12, (index) => index + 1)
                    .map(
                      (month) => DropdownMenuItem(
                        value: month,
                        child: Text(
                          DateFormat('MMMM').format(
                            DateTime(controller.selectedYear.value, month),
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) => value != null
                    ? controller.updateSelectedMonth(value)
                    : null,
              ),
            ),
            Obx(
              () => DropdownButton<int>(
                value: controller.selectedYear.value,
                items: List.generate(5, (index) => DateTime.now().year - index)
                    .map(
                      (year) => DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    value != null ? controller.updateSelectedYear(value) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    return Obx(() {
      final entries = controller.getSortedCategoryTotals();
      if (entries.isEmpty) {
        return const Center(child: Text('No data available'));
      }

      return PieChart(
        PieChartData(
          sections: entries
              .map(
                (entry) => PieChartSectionData(
                  value: entry.value,
                  title:
                      '${controller.getPercentageForCategory(entry.key).toStringAsFixed(1)}%',
                  color: Colors.primaries[
                      entries.indexOf(entry) % Colors.primaries.length],
                  radius: 100,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              )
              .toList(),
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      );
    });
  }

  Widget _buildCategoryList() {
    return Obx(() {
      final entries = controller.getSortedCategoryTotals();
      if (entries.isEmpty) {
        return const Center(child: Text('No data available'));
      }

      return ListView.builder(
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          final categoryName = controller.getCategoryName(entry.key);
          final color = Colors.primaries[index % Colors.primaries.length];

          return ListTile(
            leading: CircleAvatar(backgroundColor: color, radius: 8),
            title: Text(categoryName),
            trailing: Text(
              NumberFormat.currency(symbol: '₹').format(entry.value),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        },
      );
    });
  }

  Widget _buildMonthlyAnalytics() {
    return Obx(() {
      final entries = controller.monthlyTotals.entries.toList();
      if (entries.isEmpty) {
        return const Center(child: Text('No data available'));
      }

      final maxAmount =
          entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

      return Padding(
        padding: const EdgeInsets.all(16),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxAmount * 1.2,
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= entries.length) return const Text('');
                    return Text(entries[value.toInt()].key);
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text('₹${value.toInt()}');
                  },
                  reservedSize: 40,
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: false),
            gridData: const FlGridData(show: false),
            barGroups: entries.asMap().entries.map((entry) {
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value.value,
                    color: Colors.blue,
                    width: 20,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      );
    });
  }
}
