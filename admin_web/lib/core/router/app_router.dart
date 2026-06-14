import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../layout/admin_layout.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/listings/screens/my_listings_screen.dart';
import '../../features/listings/screens/add_listing_screen.dart';
import '../../features/listings/screens/edit_listing_screen.dart';
import '../../models/property.dart';

import '../../features/settings/screens/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final loggingIn = state.uri.path == '/login';

      if (auth.status == AuthStatus.initial || auth.status == AuthStatus.authenticating) {
        return null;
      }

      final isLoggedIn = auth.status == AuthStatus.authenticated;

      if (!isLoggedIn) {
        return loggingIn ? null : '/login';
      }

      if (loggingIn) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AdminLayout(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/listings',
            builder: (context, state) => const MyListingsScreen(),
          ),
          GoRoute(
            path: '/listings/add',
            builder: (context, state) => const AddListingScreen(),
          ),
          GoRoute(
            path: '/listings/edit',
            builder: (context, state) {
              final property = state.extra as Property;
              return EditListingScreen(property: property);
            },
          ),

          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
});
