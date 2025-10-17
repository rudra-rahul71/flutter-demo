import 'package:flutter/material.dart';
import 'package:flutter_tester/features/home.dart';
import 'package:flutter_tester/features/profile.dart';
import 'package:flutter_tester/services/api_service.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton<ApiService>(() => ApiService());
}
void main() {
  setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Finance Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Finance Tracker'),
            centerTitle: true,
            backgroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          body: child,
          bottomNavigationBar: NavigationBar(
            selectedIndex: 0,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.account_circle), label: 'Profile')
            ],
            onDestinationSelected: (value) async => {
              if(value == 0) {
                context.go('/')
              } else {
                context.go('/profile')
              }
            },
          ),
        );
      },

      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) {
            return const HomePage();
          },
        ),
        GoRoute(
          path: '/profile',
          builder: (BuildContext context, GoRouterState state) {
            return const ProfilePage();
          },
        ),
      ],
    ),
  ],
);