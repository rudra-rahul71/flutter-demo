import 'package:flutter/material.dart';
import 'package:flutter_tester/main.dart';
import 'package:flutter_tester/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (_isLoading)
            CircularProgressIndicator(),
          if(!_isLoading)
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  final item = items[index];
                  return Card(
                    child: ListTile(
                      title: Text(item['institution_name'])
                    ),
                  );
                },
              )
            ),

          ElevatedButton(
            onPressed: _isLoading ? null : _initPlaidIntegration,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
              foregroundColor: Theme.of(context).colorScheme.inverseSurface,
            ),
            child: const Text('Connect to Financial Institution'),
          ),
        ],
      ),
    );
  }

  List<dynamic> items = [];
  List<String>? accessTokens;
  bool _isLoading = false;
  final ApiService _apiService = getIt<ApiService>();

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      accessTokens = prefs.getStringList('accessTokens');
      if(accessTokens!.isNotEmpty) {
        _isLoading = true;
      }
    });

    for (dynamic token in accessTokens!) {
      final (accounts, item) = await _apiService.checkAccountBalance(token);
      items.add(item);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _initPlaidIntegration() async {
    setState(() {
      _isLoading = true;
    });

    await _apiService.initPlaidIntegration();
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      accessTokens = prefs.getStringList('accessTokens');
      _isLoading = false;
    });
  }
}