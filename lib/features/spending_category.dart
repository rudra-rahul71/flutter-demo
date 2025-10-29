import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SpendingCategory extends StatefulWidget {
  const SpendingCategory({super.key});

  @override
  State<SpendingCategory> createState() => _SpendingCategoryState();
}

class _SpendingCategoryState extends State<SpendingCategory> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: BarChart(
              BarChartData(
                barGroups: [
                  BarChartGroupData(
                    groupVertically: true,
                    x: 0,
                    barRods: [
                      BarChartRodData(toY: 10),
                      BarChartRodData(fromY: 10, toY: 15,
                      color: Colors.green),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(toY: 20),
                    ],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barRods: [
                      BarChartRodData(toY: 30),
                    ],
                  ),
                ],
              ),
              duration: Duration(milliseconds: 150), // Optional
              curve: Curves.linear, // Optional
            ),
          ),
        ),
      ]
    );
  }
}

