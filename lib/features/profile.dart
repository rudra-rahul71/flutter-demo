import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:plaid_flutter/plaid_flutter.dart';

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
              ElevatedButton(
                onPressed: _isLoading ? null : _initPlaidIntegration,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.onPrimary,
                  foregroundColor: Theme.of(context).colorScheme.inverseSurface,
                ),
                child: const Text('Init Account'),
              ),
              ElevatedButton(
                onPressed: _isLoading ? null : _checkAccountBalance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.onPrimary,
                  foregroundColor: Theme.of(context).colorScheme.inverseSurface,
                ),
                child: const Text('Check Balance'),
              ),
              const SizedBox(height: 20),
              // Display either a loading indicator or the response text.
              _isLoading ? const CircularProgressIndicator()
                : linkToken != null ? Text(linkToken!) : Text("Load link token")
            ],
          ),
        ),
    );
  }
  // A string to hold the data fetched from the API.
  // It defaults to a prompt for the user.
  String? linkToken;
  bool _isLoading = false;

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

          await http.get(url2);
        });
        PlaidLink.open();
        setState(() {
          linkToken = data['link_token'];
          // _apiResponse = 'Title: ${data['title']}\n\nBody: ${data['body']}';
        });
      } else {
        throw Exception('Failed to load data from the API');
      }
    } catch (e) {
      setState(() {
        linkToken = 'Error: $e';
      });
    } finally {
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