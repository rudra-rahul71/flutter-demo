import 'package:flutter/material.dart';
import 'package:flutter_tester/features/financial_overview.dart';

class HomeWidget extends StatefulWidget {
  final List<dynamic> accounts;

  const HomeWidget({
    super.key,
    this.accounts = const [],
  });

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> with TickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic>_accounts = [];
  
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _accounts = widget.accounts;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentGeometry.bottomCenter,
      children: [
        PageView(
          onPageChanged: (value) {
            _tabController.index = value;
          },
          children: [
            FinancialOverview(accounts: _accounts),
            Text('data'),
          ],
        ),
        PageIndicator(
          tabController: _tabController
        ),
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