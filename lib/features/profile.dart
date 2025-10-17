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
          _isLoading ? CircularProgressIndicator() :
          accessToken != null ? Text("Profile Setup Complete") : ElevatedButton(
            onPressed: _initPlaidIntegration,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
              foregroundColor: Theme.of(context).colorScheme.inverseSurface,
            ),
            child: const Text('Integrate with Plaid'),
          ),
        ],
      ),
    );
  }

  String? accessToken;
  // List<String>? accessTokens;
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
      accessToken = prefs.getString('accessToken');
    });
  }

  Future<void> _initPlaidIntegration() async {
    setState(() {
      _isLoading = true;
    });

    await _apiService.initPlaidIntegration();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken');

    setState(() {
      _isLoading = false;
    });
  }
}