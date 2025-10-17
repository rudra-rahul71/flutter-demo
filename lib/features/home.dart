import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tester/main.dart';
import 'package:flutter_tester/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (_isLoading)
            const CircularProgressIndicator()
          else if (accessTokens == null)
            const Text("Go to Profile and set up Plaid integration!")
          else
          Expanded(
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 2,
                  child: PieChart(
                    PieChartData(
                      sections: accounts.map<PieChartSectionData>((account) {
                        final value = (account['balances']['available'] as num?)?.toDouble() ?? 0.0;
                    
                        return PieChartSectionData(
                          value: value,
                          title: '\$${value.toStringAsFixed(2)}',
                          radius: 20,
                          titleStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xffffffff),
                          ),
                        );
                      }).toList()
                    )
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: accounts.length,
                    itemBuilder: (BuildContext context, int index) {
                      final account = accounts[index];
                      return Card(
                        child: ListTile(
                          title: Text(account['name']),
                          subtitle: Text(account['official_name']),
                          trailing: Text(account['balances']['available'].toString()),
                        ),
                      );
                    },
                  ),
                ),
              ],
            )
          )
        ],
      )
    );
  }

  List<String>? accessTokens;
  List<dynamic> accounts = [];
  List<dynamic> items = [];
  bool _isLoading = false;

  final ApiService _apiService = getIt<ApiService>();

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    setState(() {
      _isLoading = true;
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    accessTokens = prefs.getStringList('accessTokens');

    if (accessTokens!.isNotEmpty) {
      _checkAccountBalance();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkAccountBalance() async {
    setState(() {
      _isLoading = true;
    });

    for (dynamic token in accessTokens!) {
      final (accounts, item) = await _apiService.checkAccountBalance(token);
      for (dynamic account in accounts) {
        this.accounts.add(account);
      }
      items.add(item);
    }

    setState(() {
      _isLoading = false;
    });
  }
}