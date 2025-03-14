import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
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
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                await controller.refreshData();
                Get.snackbar(
                  'Success',
                  'Analytics data refreshed',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                );
              },
            ),
          ],
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
        Material(
          color: Get.theme.primaryColor,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Filter: ',
                      style: TextStyle(
                        color: Get.theme.colorScheme.onPrimary,
                        fontSize: 12,
                      ),
                    ),
                    Obx(
                      () => DropdownButton<int>(
                        value: controller.selectedMonth.value,
                        dropdownColor: Get.theme.primaryColor,
                        isDense: true,
                        items: List.generate(12, (index) => index + 1)
                            .map(
                              (month) => DropdownMenuItem(
                                value: month,
                                child: Text(
                                  DateFormat('MMM').format(
                                    DateTime(2024, month),
                                  ),
                                  style: TextStyle(
                                    color: Get.theme.colorScheme.onPrimary,
                                    fontSize: 12,
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
                    const SizedBox(width: 8),
                    Obx(
                      () => DropdownButton<int>(
                        value: controller.selectedYear.value,
                        dropdownColor: Get.theme.primaryColor,
                        isDense: true,
                        items: List.generate(
                                5, (index) => DateTime.now().year - index)
                            .map(
                              (year) => DropdownMenuItem(
                                value: year,
                                child: Text(
                                  year.toString(),
                                  style: TextStyle(
                                    color: Get.theme.colorScheme.onPrimary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => value != null
                            ? controller.updateSelectedYear(value)
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: Row(
            children: [
              Expanded(child: _buildExpensePieChart()),
              Expanded(child: _buildIncomePieChart()),
            ],
          ),
        ),
        Expanded(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'Expenses'),
                    Tab(text: 'Income'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildCategoryListContent(isExpense: true),
                      _buildCategoryListContent(isExpense: false),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpensePieChart() {
    return Obx(() {
      final entries = controller.getSortedExpenseTotals();
      if (entries.isEmpty) {
        return const Center(child: Text('No expenses data'));
      }

      return SfCircularChart(
        margin: const EdgeInsets.all(0),
        annotations: [
          CircularChartAnnotation(
            widget: Text(
              'Total\n₹${NumberFormat.compact().format(controller.getTotalExpenses())}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Get.theme.colorScheme.error,
              ),
            ),
          ),
        ],
        series: <CircularSeries>[
          PieSeries<MapEntry<String, double>, String>(
            dataSource: entries,
            xValueMapper: (MapEntry<String, double> data, _) =>
                controller.getCategoryName(data.key),
            yValueMapper: (MapEntry<String, double> data, _) => data.value,
            dataLabelMapper: (MapEntry<String, double> data, _) =>
                '${controller.getCategoryName(data.key)}\n₹${NumberFormat.compact().format(data.value)}',
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelPosition: ChartDataLabelPosition.outside,
              labelIntersectAction: LabelIntersectAction.shift,
              connectorLineSettings: ConnectorLineSettings(
                type: ConnectorType.line,
                width: 0.5,
                length: '15%',
              ),
            ),
            enableTooltip: true,
            pointColorMapper: (MapEntry<String, double> data, _) =>
                Colors.red[(entries.indexOf(data) + 1) * 100],
          )
        ],
      );
    });
  }

  Widget _buildIncomePieChart() {
    return Obx(() {
      final entries = controller.getSortedIncomeTotals();
      if (entries.isEmpty) {
        return const Center(child: Text('No income data'));
      }

      return SfCircularChart(
        margin: const EdgeInsets.all(0),
        annotations: [
          CircularChartAnnotation(
            widget: Text(
              'Total\n₹${NumberFormat.compact().format(controller.getTotalIncome())}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Get.theme.colorScheme.primary,
              ),
            ),
          ),
        ],
        series: <CircularSeries>[
          PieSeries<MapEntry<String, double>, String>(
            dataSource: entries,
            xValueMapper: (MapEntry<String, double> data, _) =>
                controller.getCategoryName(data.key),
            yValueMapper: (MapEntry<String, double> data, _) => data.value,
            dataLabelMapper: (MapEntry<String, double> data, _) =>
                '${controller.getCategoryName(data.key)}\n₹${NumberFormat.compact().format(data.value)}',
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelPosition: ChartDataLabelPosition.outside,
              labelIntersectAction: LabelIntersectAction.shift,
              connectorLineSettings: ConnectorLineSettings(
                type: ConnectorType.line,
                width: 0.5,
                length: '15%',
              ),
            ),
            enableTooltip: true,
            pointColorMapper: (MapEntry<String, double> data, _) =>
                Colors.green[(entries.indexOf(data) + 1) * 100],
          )
        ],
      );
    });
  }

  Widget _buildCategoryListContent({required bool isExpense}) {
    return Obx(() {
      final entries = isExpense
          ? controller.getSortedExpenseTotals()
          : controller.getSortedIncomeTotals();

      if (entries.isEmpty) {
        return Center(
          child: Text('No ${isExpense ? 'expenses' : 'income'} data'),
        );
      }

      return ListView.builder(
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          final categoryName = controller.getCategoryName(entry.key);
          final color = isExpense
              ? Colors.red[(index + 1) * 100]
              : Colors.green[(index + 1) * 100];

          return ListTile(
            leading: CircleAvatar(backgroundColor: color, radius: 8),
            title: Text(categoryName),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  NumberFormat.currency(symbol: '₹').format(entry.value),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${(isExpense ? controller.getPercentageForExpenseCategory(entry.key) : controller.getPercentageForIncomeCategory(entry.key)).toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: Get.theme.colorScheme.secondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildMonthlyAnalytics() {
    return Column(
      children: [
        Material(
          color: Get.theme.primaryColor,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Filter: ',
                      style: TextStyle(
                        color: Get.theme.colorScheme.onPrimary,
                        fontSize: 12,
                      ),
                    ),
                    Obx(
                      () => DropdownButton<int>(
                        value: controller.selectedYear.value,
                        dropdownColor: Get.theme.primaryColor,
                        isDense: true,
                        items: List.generate(
                                5, (index) => DateTime.now().year - index)
                            .map(
                              (year) => DropdownMenuItem(
                                value: year,
                                child: Text(
                                  year.toString(),
                                  style: TextStyle(
                                    color: Get.theme.colorScheme.onPrimary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => value != null
                            ? controller.updateSelectedYear(value)
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            final trends = controller.categoryMonthlyTotals;
            if (trends.isEmpty) {
              return const Center(child: Text('No data available'));
            }

            // Process data for monthly chart
            final months = [
              'Jan',
              'Feb',
              'Mar',
              'Apr',
              'May',
              'Jun',
              'Jul',
              'Aug',
              'Sep',
              'Oct',
              'Nov',
              'Dec'
            ];
            final List<MonthlyData> chartData = [];

            // Initialize data for all months
            for (final month in months) {
              final monthData = MonthlyData(month);
              double expenseTotal = 0;
              double incomeTotal = 0;

              for (final entry in trends.entries) {
                final amount = trends[entry.key]![month]?.abs() ?? 0.0;
                if (entry.key.startsWith('expense_')) {
                  expenseTotal += amount;
                } else {
                  incomeTotal += amount;
                }
              }

              monthData.expense = expenseTotal;
              monthData.income = incomeTotal;
              monthData.balance = incomeTotal - expenseTotal;
              chartData.add(monthData);
            }

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: SfCartesianChart(
                      plotAreaBorderWidth: 0,
                      primaryXAxis: CategoryAxis(
                        majorGridLines: const MajorGridLines(width: 0),
                        labelStyle: const TextStyle(fontSize: 12),
                      ),
                      primaryYAxis: NumericAxis(
                        numberFormat: NumberFormat.compactCurrency(symbol: '₹'),
                        majorGridLines: const MajorGridLines(
                          width: 0.5,
                          dashArray: [5, 5],
                        ),
                        minimum: 0,
                      ),
                      series: <CartesianSeries>[
                        ColumnSeries<MonthlyData, String>(
                          name: 'Income',
                          dataSource: chartData,
                          xValueMapper: (MonthlyData data, _) => data.month,
                          yValueMapper: (MonthlyData data, _) => data.income,
                          width: 0.4,
                          spacing: 0.2,
                          color: Colors.green[300],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                          dataLabelSettings: const DataLabelSettings(
                            isVisible: true,
                            labelAlignment: ChartDataLabelAlignment.top,
                            textStyle: TextStyle(fontSize: 10),
                          ),
                        ),
                        ColumnSeries<MonthlyData, String>(
                          name: 'Expense',
                          dataSource: chartData,
                          xValueMapper: (MonthlyData data, _) => data.month,
                          yValueMapper: (MonthlyData data, _) => data.expense,
                          width: 0.4,
                          spacing: 0.2,
                          color: Colors.red[300],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                          dataLabelSettings: const DataLabelSettings(
                            isVisible: true,
                            labelAlignment: ChartDataLabelAlignment.top,
                            textStyle: TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem('Income', Colors.green[300]!),
                      const SizedBox(width: 16),
                      _buildLegendItem('Expense', Colors.red[300]!),
                    ],
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class ChartData {
  ChartData(this.month);
  final String month;
  final Map<String, double> values = {};
}

class MonthlyData {
  MonthlyData(this.month);
  final String month;
  double income = 0;
  double expense = 0;
  double balance = 0;
}
