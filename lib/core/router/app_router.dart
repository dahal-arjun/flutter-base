import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/users/presentation/pages/users_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/posts/presentation/pages/post_detail_page_wrapper.dart';
import '../../core/l10n/app_localizations.dart';
import 'app_routes.dart';

/// App router configuration
/// Manages all app routes and navigation
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: AppRoutes.splashName,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.loginName,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: AppRoutes.dashboardName,
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: AppRoutes.users,
        name: AppRoutes.usersName,
        builder: (context, state) => const UsersPage(),
      ),
      GoRoute(
        path: '${AppRoutes.posts}/:id',
        name: AppRoutes.postDetailName,
        builder: (context, state) {
          final idString = state.pathParameters['id'];
          if (idString == null) {
            return _buildErrorPage(context, 'Post ID is required');
          }
          try {
            final id = int.parse(idString);
            return PostDetailPageWrapper(postId: id);
          } catch (e) {
            return _buildErrorPage(context, 'Invalid post ID: $idString');
          }
        },
      ),

    ],
    errorBuilder: (context, state) => _buildErrorPage(
      context,
      state.error?.toString() ?? 'Unknown error occurred',
    ),
  );

  /// Build error page widget
  static Widget _buildErrorPage(BuildContext context, String message) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(localizations?.error ?? 'Error')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                localizations?.error ?? 'Error',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.dashboard),
                child: Text(localizations?.goToHome ?? 'Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
