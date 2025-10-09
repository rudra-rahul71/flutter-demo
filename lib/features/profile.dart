import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:plaid_flutter/plaid_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Center(
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
      ),
    );
  }
  // A string to hold the data fetched from the API.
  // It defaults to a prompt for the user.
  String? accessToken;
  bool _isLoading = false;

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

    try {
      final url = Uri.parse('http://10.0.2.2:8080/init');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        LinkTokenConfiguration configuration = LinkTokenConfiguration(
            token: data['link_token'],
        );
        await PlaidLink.create(configuration: configuration);
        PlaidLink.onSuccess.listen((LinkSuccess event) async {
          final publicToken = event.toJson()['publicToken'];
          final url2 = Uri.parse('http://10.0.2.2:8080/create/$publicToken');

          final response2 = await http.get(url2);

          if (response2.statusCode == 200) {
            final data2 = json.decode(response2.body);
            if(data2 != null && data2['access_token'] != null) {
              final SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('accessToken', data2['access_token']);
              setState(() {
                accessToken = data2['access_token'];
              });
            }
          }
        });
        PlaidLink.open();
        setState(() {
          // _apiResponse = 'Title: ${data['title']}\n\nBody: ${data['body']}';
        });
      } else {
        throw Exception('Failed to load data from the API');
      }
    } catch (e) {
      setState(() {

      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}