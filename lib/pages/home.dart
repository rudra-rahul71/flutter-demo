import 'package:flutter/material.dart';
import 'package:flutter_tester/features/home_widget.dart';
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
                HomeWidget(transactionData: transactionData, accounts: accounts),
                Expanded(
                  child: ListView(
                    children: [
                      ...transactionData.map((entry) {
                          return ExpansionTile(
                            title: Text(entry.item['institution_name']),
                            subtitle: Text('${entry.accounts.length} connected accounts'),
                            children: <Widget>[
                              ...entry.accounts.map((account) {
                                return Card(
                                  color: account['subtype'] == 'credit card' ? Theme.of(context).colorScheme.onError
                                    : account['subtype'] == 'savings' ? Theme.of(context).colorScheme.onPrimary
                                    : account['subtype'] == 'checking' ? Theme.of(context).colorScheme.onTertiary : null,
                                  child: ListTile(
                                    title: Text(account['name']),
                                    subtitle: Text(account['official_name']),
                                    trailing: account['subtype'] == 'credit card' ? Text(account['balances']['current'].toString())
                                      : Text(account['balances']['available'].toString()),
                                  )
                                );
                              }),
                            ],
                          );
                      }),
                    ],
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
        accounts.add(account);
      }

      transactionData.add(response);
    }

    setState(() {
      _isLoading = false;
    });
  }
}