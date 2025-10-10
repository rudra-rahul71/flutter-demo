import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tester/features/profile.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance Tracker'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      drawer: const Drawer(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.account_circle), label: 'Profile')
        ],
        onDestinationSelected: (value) async => {
          if(value == 1) {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage())),
            _loadPrefs()
          }
        },
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_isLoading)
              const CircularProgressIndicator()
            else if (accounts == null)
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
                  Text(item['institution_name']),
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
      )
    );
  }

  String? accessToken;
  dynamic accounts;
  dynamic item;
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
    accessToken = prefs.getString('accessToken');

    if (accessToken != null) {
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

    final (accounts, item) = await _apiService.checkAccountBalance(accessToken!);
    this.accounts = accounts;
    this.item = item;

    setState(() {
      _isLoading = false;
    });
  }
}