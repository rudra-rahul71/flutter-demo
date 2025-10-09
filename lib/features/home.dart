import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_tester/features/profile.dart';
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
          children: _isLoading ? [CircularProgressIndicator()] :
                    accessToken != null ? [Text(accessToken!)] : [Text("Go to Profile and set up Plaid integration!")],
        )
      )
    );
  }

  String? accessToken;
  bool _isLoading = false;

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

    final url = Uri.parse('http://10.0.2.2:8080/balance');

    final response = await http.get(url);

    try {
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data['accounts']);
      } else {
        throw Exception('Failed to check account balance');
      }
    } catch (e) {
      setState(() {
        // linkToken = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}