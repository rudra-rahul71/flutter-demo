import 'package:flutter/material.dart';
import 'package:flutter_tester/features/profile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance Tracker'),
        centerTitle: true,
        // Now, Theme.of(context) will find the redAccent-based theme.
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      drawer: const Drawer(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.account_circle), label: 'Profile')
        ],
        onDestinationSelected: (value) => {
          if(value == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage()))
          }
        },
      ),
    );
  }
}