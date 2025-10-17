import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:plaid_flutter/plaid_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {

  Future<(dynamic, dynamic)> checkAccountBalance(String accessToken) async {
    final url = Uri.parse('http://10.0.2.2:8080/balance/$accessToken');

    final response = await http.get(url);

    try {
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        return (data['accounts'], data['item']);
      } else {
        throw Exception('Failed to check account balance');
      }
    } catch (e) {
      throw Exception('Failed to check account balance');
    }
  }

  Future<(dynamic, dynamic, dynamic)> getTransactions(String accessToken) async {
    final url = Uri.parse('http://10.0.2.2:8080/transactions/$accessToken');

    final response = await http.get(url);

    try {
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        return (data['accounts'], data['transactions'], data['total_transactions']);
      } else {
        throw Exception('Failed to check account balance');
      }
    } catch (e) {
      throw Exception('Failed to check account balance');
    }
  }

  Future<void> initPlaidIntegration() async {
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
              final List<String> tokens = prefs.getStringList('accessTokens') ?? [];
              tokens.add(data2['access_token']);
              
              await prefs.setStringList('accessTokens', tokens);

              return;
            }
          }
        });
        PlaidLink.open();
      } else {
        throw Exception('Failed to load data from the API');
      }
    } catch (e) {
      throw Exception('Failed to load data from the API');
    }
  }
}