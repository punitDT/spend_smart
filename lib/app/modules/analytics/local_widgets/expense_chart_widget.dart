import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

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
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(
                    labelRotation: 45,
                    maximumLabels: chartData.length,
                  ),
                  primaryYAxis: NumericAxis(
                    numberFormat: NumberFormat.currency(symbol: '₹'),
                    labelFormat: '{value}',
                  ),
                  tooltipBehavior: TooltipBehavior(
                    enable: true,
                    format: 'point.x : ₹point.y',
                  ),
                  series: <CartesianSeries>[
                    ColumnSeries<Map<String, dynamic>, String>(
                      dataSource: chartData,
                      xValueMapper: (Map<String, dynamic> data, _) =>
                          data['label'] as String,
                      yValueMapper: (Map<String, dynamic> data, _) =>
                          data['value'] as double,
                      pointColorMapper: (Map<String, dynamic> data, _) =>
                          data['color'] as Color? ?? Colors.blue,
                      width: 0.8,
                      borderRadius: BorderRadius.circular(4),
                      dataLabelSettings: DataLabelSettings(
                        isVisible: showLabels,
                        labelAlignment: ChartDataLabelAlignment.top,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
