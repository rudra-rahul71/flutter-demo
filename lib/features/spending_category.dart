import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tester/models/transaction_data.dart';

class SpendingCategory extends StatefulWidget {
  final List<TransactionData> transactionData;

  const SpendingCategory({
    super.key,
    this.transactionData = const [],
  });

  @override
  State<SpendingCategory> createState() => _SpendingCategoryState();
}

class _SpendingCategoryState extends State<SpendingCategory> {

  List<MapEntry<String, double>> _transactionByCategory = [];

  @override
  void initState() {
    super.initState();

    final Map<String, double> groupedTransactions = {};

    for (var item in widget.transactionData) {
      for (var transaction in item.transactions) {
        String category = transaction['personal_finance_category']['primary'];
        if(category != 'INCOME') {
          groupedTransactions.putIfAbsent(category, () => 0.0);

          double currentValue = groupedTransactions[category]!;
          double newValue = currentValue + transaction['amount'];
          
          if (newValue == 0) {
            groupedTransactions.remove(category);
          } else {
            groupedTransactions[category] = newValue;
          }
        }
      }
    }

    _transactionByCategory = groupedTransactions.entries.toList();
    _transactionByCategory.sort((a, b) {
      return b.value.compareTo(a.value);
    });
    print(_transactionByCategory);
  }

  getLabel(String value) {
    return switch(value) {
      "GENERAL_MERCHANDISE" => "Shopping",
      "FOOD_AND_DRINK" => "Food",
      "ENTERTAINMENT" => "Entertainment",
      "PERSONAL_CARE" => "Personal",
      "LOAN_PAYMENTS" => "Loans",
      "TRANSPORTATION" => "Transportation",
      _ => formatSnakeCaseToTitle(value)
    };
  }

  String formatSnakeCaseToTitle(String input) {
  if (input.isEmpty) return "";

  return input
      .split('_').map((word) {
        if (word.isEmpty) return "";
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      }).join(' ');
}

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: BarChart(
              BarChartData(
                backgroundColor: Theme.of(context).colorScheme.onPrimary,
                titlesData: FlTitlesData(
                  topTitles: AxisTitles( axisNameWidget: Text('')),
                  leftTitles: AxisTitles(
                    axisNameWidget: RotatedBox(
                      quarterTurns: -1,
                      child: Icon(Icons.attach_money),
                    ),
                    axisNameSize: 30,
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(getLabel(_transactionByCategory[value.toInt()].key))
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  ..._transactionByCategory.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      groupVertically: true,
                      x: entry.key, 
                      barRods: [
                        BarChartRodData(
                          color: Theme.of(context).colorScheme.primary,
                          toY: entry.value.value
                        ), 
                      ],
                    );
                  }),
                ],
              ),
              curve: Curves.linear,
            ),
          ),
        ),
      ],
    );
  }
}