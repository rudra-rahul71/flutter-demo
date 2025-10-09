// routes.dart
import 'package:flutter/material.dart';
import 'package:flutter_tester/features/home.dart';
import 'package:flutter_tester/features/profile.dart';

class AppRoutes {
  static const String home = '/';
  static const String profile = '/profile';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      default:
        // You can return a 404 page here
        return MaterialPageRoute(builder: (_) => const Text('Error: Route not found'));
    }
  }
}