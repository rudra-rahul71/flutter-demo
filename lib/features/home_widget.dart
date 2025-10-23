import 'package:flutter/material.dart';
import 'package:flutter_tester/features/financial_overview.dart';
import 'package:flutter_tester/features/transaction_history.dart';
import 'package:flutter_tester/models/transaction_data.dart';

class HomeWidget extends StatefulWidget {
  final List<TransactionData> transactionData;
  final List<dynamic> accounts;

  const HomeWidget({
    super.key,
    this.transactionData = const [],
    this.accounts = const [],
  });

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> with TickerProviderStateMixin {
  late TabController _tabController;
  List<TransactionData>_transactionData = [];
  List<dynamic>_accounts = [];
  String title = 'Financial Overview';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _transactionData = widget.transactionData;
    _accounts = widget.accounts;
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.sizeOf(context).height;
    return Column(
      children: [
        Text(title),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: height / 4),
          child: Stack(
            alignment: AlignmentGeometry.bottomCenter,
            children: [
              PageView(
                onPageChanged: (value) {
                  _tabController.index = value;
                  setState(() {
                    title = value == 0 ? 'Financial Overview' : 'Total Money Spent';
                  });
                },
                children: [
                  FinancialOverview(accounts: _accounts),
                  TransactionHistory(transactionData: _transactionData),
                ],
              ),
              PageIndicator(
                tabController: _tabController
              ),
            ],
          )
        )
      ],
    );
  }
}


class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.tabController,
  });

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TabPageSelector(
            controller: tabController,
            color: colorScheme.surface,
            selectedColor: colorScheme.primary,
          ),
        ],
      ),
    );
  }
}