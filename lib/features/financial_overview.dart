import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class FinancialOverview extends StatefulWidget {
  final List<dynamic> accounts;

  const FinancialOverview({
    super.key,
    this.accounts = const [],
  });

  @override
  State<FinancialOverview> createState() => _FinancialOverviewState();
}

class _FinancialOverviewState extends State<FinancialOverview> {
  List<dynamic>_accounts = [];
  int? _selected;
  double _totalValue = 0.0;
  List<MapEntry<String, double>> _categorizedSpend = List.empty();

  @override
  void initState() {
    super.initState();

    _accounts = widget.accounts;

    _totalValue = _accounts.fold(
      0.0,
      (double previousSum, dynamic account) => previousSum + (account['balances']['available'] ?? 0.0),
    );

    _categorizedSpend = _accounts.fold(
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
    return Row(
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
                    radius: _selected == index ? 100 : 90,
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
                        _selected = r.touchedSection!.touchedSectionIndex;
                      });
                    }
                  },
                )
              ),
            ),
          ),
      ),
      Expanded(
        child: _selected != null && _selected != -1 ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_accounts[_selected!]['name']),
              Text(_accounts[_selected!]['subtype']),
              Text('available: \$${(_accounts[_selected!]['balances']['available'] as num).toDouble().toStringAsFixed(2)}'),
              Text('current: \$${(_accounts[_selected!]['balances']['current'] as num).toDouble().toStringAsFixed(2)}'),
            ],
          ) : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Financial Overview'),
              Text('Total Amount Held: \$${_totalValue.toStringAsFixed(2)}'),
              ..._categorizedSpend.map((entry) {
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