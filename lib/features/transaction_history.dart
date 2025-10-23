import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tester/models/transaction_data.dart';

class TransactionHistory extends StatefulWidget {
  final List<TransactionData> transactionData;

  const TransactionHistory({
    super.key,
    this.transactionData = const [],
  });

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {

  final Map<String, List<(double, double)>> _groupedTransactions = {};
  final Map<String, (String, dynamic)> accounts = {};

  @override
  void initState() {
    super.initState();

    for (var item in widget.transactionData) {
      for(var account in item.accounts) {
        accounts[account['account_id']] = (account['name'], item.item);
      }
      for (var transaction in item.transactions) {
        final String? accountId = transaction['account_id'];
        final DateTime? date = DateTime.tryParse(transaction['date'] ?? '');
        final double amount = (transaction['amount'] as num? ?? 0.0).toDouble();

        if (accountId == null || date == null || amount < 0) {
          continue; 
        }

        final double dateEpoch = date.microsecondsSinceEpoch.toDouble();

        _groupedTransactions
            .putIfAbsent(accountId, () => [])
            .add((dateEpoch, amount));
      }
    }

    for (var entry in _groupedTransactions.entries) {
      List<(double, double)> transactions = entry.value;
      transactions.sort((a, b) => a.$1.compareTo(b.$1));

      if(DateTime.fromMicrosecondsSinceEpoch(transactions[0].$1.toInt()).day != 1) {
        transactions.insert(0, (DateTime(DateTime.now().year, DateTime.now().month, 1).microsecondsSinceEpoch.toDouble(), 0.0));
      }

      if(DateTime.fromMicrosecondsSinceEpoch(transactions[transactions.length - 1].$1.toInt()).day != DateTime.now().day) {
        transactions.add((DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).microsecondsSinceEpoch.toDouble(), 0.0));
      }

      double runningTotal = 0.0;
      List<(double, double)> cumulativeList = [];
      for (var x in transactions) {
        runningTotal += x.$2;
        cumulativeList.add((x.$1, runningTotal));
      }
      _groupedTransactions.update(entry.key, (current) {
        return cumulativeList;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    final accountEntries = _groupedTransactions.entries.toList();

    if (accountEntries.isEmpty) {
      return Center(child: Text("No transactions found."));
    }

    return AspectRatio(
      aspectRatio: 1,
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              axisNameWidget: RotatedBox(
                quarterTurns: -1,
                child: Icon(Icons.attach_money),
              ),
              axisNameSize: 30,
            ),
            bottomTitles: AxisTitles(
              axisNameWidget: Text('Day'),
              sideTitles: SideTitles(
                showTitles: true,
                interval: 777600000000, //calculate half of what the timespan would be
                getTitlesWidget: (value, meta) {
                  final int micros = value.toInt();
                  final DateTime date = DateTime.fromMicrosecondsSinceEpoch(micros);
                  final String formattedDate = '${date.month}/${date.day}';

                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      formattedDate,
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(
              axisNameWidget: Text('')
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 70,
                interval: 200,
                getTitlesWidget: (value, meta) {
                  return Text('  \$${value.toStringAsFixed(2)}');
                },
              ),
            ),
          ),
          gridData: FlGridData(
          ),
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              fitInsideVertically: true,
              fitInsideHorizontally: true,
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((LineBarSpot touchedSpot) {
                  final String accountId = accountEntries[touchedSpot.barIndex].key;

                  final DateTime date = DateTime.fromMicrosecondsSinceEpoch(touchedSpot.x.toInt());
                  final String formattedDate = '${date.month}/${date.day}';

                  final String amount = '\$${touchedSpot.y.toStringAsFixed(2)}';
                  final String account = '${accounts[accountId]!.$2['institution_name']}\n';
                  final String body = '$formattedDate\n$amount';

                  final TextStyle textStyle = TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11
                  );

                  return LineTooltipItem(
                    account,
                    textStyle,
                    children: [
                      TextSpan(
                        text: '${accounts[accountId]!.$1}\n',
                        style: textStyle.copyWith(fontSize: 8, fontWeight: FontWeight.normal)
                      ),
                      TextSpan(
                        text: body,
                        style: textStyle.copyWith(fontWeight: FontWeight.normal)
                      ),
                    ],
                    textAlign: TextAlign.left,
                  );
                }).toList();
              }
            ),
            distanceCalculator: (touchPoint, spotPixelCoordinates) {
              return (touchPoint - spotPixelCoordinates).distance;
            },
            getTouchedSpotIndicator: (barData, spotIndexes) {
              return spotIndexes.map((spotIndex) {
                return TouchedSpotIndicatorData(FlLine(
                  strokeWidth: 0.0,
                ), FlDotData(
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 6,
                      color: Theme.of(context).colorScheme.onPrimary,
                      strokeWidth: 2,
                      strokeColor: Theme.of(context).colorScheme.primary,
                    );
                  },
                ));
              }).toList();
            },
          ),
          lineBarsData: [
            ...accountEntries.map((entry) {
              return LineChartBarData(
                color: Theme.of(context).colorScheme.primary,
                spots: [
                  ...entry.value.map((transaction) {
                    return FlSpot(transaction.$1, transaction.$2);
                  }),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}