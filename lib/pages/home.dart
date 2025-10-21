import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tester/main.dart';
import 'package:flutter_tester/models/transaction_data.dart';
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
                      centerSpaceRadius: 0,
                      sections: accounts.map<PieChartSectionData>((account) {
                        final value = (account['balances']['available'] as num?)?.toDouble() ?? 0.0;
                        return PieChartSectionData(
                          value: value,
                          title: '\$${value.toStringAsFixed(2)}',
                          radius: 90,
                          color: Theme.of(context).colorScheme.onPrimary,
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2
                          ),
                        );
                      }).toList()
                    )
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: transactionData.length,
                  itemBuilder: (BuildContext context, int index) {
                    final entry = transactionData[index];
                    return ExpansionTile(
                      title: Text(entry.item['institution_name']),
                      subtitle: Text('${entry.accounts.length} connected accounts'),
                      children: <Widget>[
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: entry.accounts.length,
                          itemBuilder: (BuildContext context, int index) {
                            final account = entry.accounts[index];
                            return Card(
                              color: account['subtype'] == 'credit card' ? Theme.of(context).colorScheme.onError
                                    : account['subtype'] == 'savings' ? Theme.of(context).colorScheme.onPrimary
                                    : account['subtype'] == 'checking' ? Theme.of(context).colorScheme.onTertiary : null,
                              child: ListTile(
                                title: Text(account['name']),
                                subtitle: Text(account['official_name']),
                                trailing: account['subtype'] == 'credit card' ? Text(account['balances']['current'].toString())
                                          : Text(account['balances']['available'].toString()),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  }
                )
              ],
            )
          )
        ],
      )
    );
  }

  List<String>? accessTokens;
  List<TransactionData> transactionData = [];
  List<dynamic> accounts = [];
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
      _getTransactions();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getTransactions() async {
    setState(() {
      _isLoading = true;
    });

    for (dynamic token in accessTokens!) {
      final response = await _apiService.getTransactions(token);

      for (dynamic account in response.accounts) {
        account['color'] = '';
        accounts.add(account);
      }

      transactionData.add(response);
    }

    setState(() {
      _isLoading = false;
    });
  }
}