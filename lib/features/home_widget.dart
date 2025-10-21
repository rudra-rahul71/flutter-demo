import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HomeWidget extends StatefulWidget {
  final List<dynamic> accounts;

  const HomeWidget({
    super.key,
    this.accounts = const [],
  });

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  List<dynamic>_accounts = [];
  int? selected;
  double _totalValue = 0.0;
  List<MapEntry<String, double>> categorizedSpend = List.empty();
  
  @override
  void initState() {
    super.initState();

    _accounts = widget.accounts;
    _totalValue = _accounts.fold(
      0.0,
      (double previousSum, dynamic account) => previousSum + (account['balances']['available'] ?? 0.0),
    );


    categorizedSpend = _accounts.fold(
      <String, double>{},
      (Map<String, double> categoryMap, dynamic account) {

        if(account['balances']['available'] != null) {
          categoryMap.update(
            account['subtype'],
            (value) => value + (account['balances']['available'] as num).toDouble(),
            ifAbsent: () => (account['balances']['available'] as num).toDouble(),
          );
        }
        
        return categoryMap;
      },
    ).entries.toList();
  }

  @override
  Widget build(BuildContext context) {
    return 
    Row(
      children: [
        Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 0,
                sections: List.generate(_accounts.length, (index) {
                  final value = (_accounts[index]['balances']['available'] as num?)?.toDouble() ?? 0.0;
                  return PieChartSectionData(
                    value: value,
                    title: '\$${value.toStringAsFixed(2)}',
                    radius: selected == index ? 100 : 90,
                    color: Theme.of(context).colorScheme.onPrimary,
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2
                    ),
                  );
                }),
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent e, PieTouchResponse? r) {
                    if(r != null && r.touchedSection != null) {
                      setState(() {
                        selected = r.touchedSection!.touchedSectionIndex;
                      });
                    }
                  },
                )
              ),
            ),
          ),
        ),
        Expanded(
          child: selected != null && selected != -1 ? 
            Column(
              children: [
                Text(_accounts[selected!]['name']),
                Text(_accounts[selected!]['subtype']),
                Text('available: \$${(_accounts[selected!]['balances']['available'] as num).toDouble().toStringAsFixed(2)}'),
                Text('current: \$${(_accounts[selected!]['balances']['current'] as num).toDouble().toStringAsFixed(2)}'),
              ],
            ) :
            Column(
              children: [
                Text('Financial Overview'),
                Text('Total Amount Held: \$${_totalValue.toStringAsFixed(2)}'),
                ...categorizedSpend.map((entry) {
                  return Text(
                    '${entry.key}: \$${entry.value.toStringAsFixed(2)}',
                  );
                }),
              ],
            ),
        ),
      ],
    );
  }
}