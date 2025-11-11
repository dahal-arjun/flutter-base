import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/router/app_routes.dart';
import '../../../../services/auth/local_auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LocalAuthService _localAuthService = di.getIt<LocalAuthService>();
  bool _isAuthenticating = false;
  String? _errorMessage;

  Future<void> _authenticateWithBiometrics() async {
    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    try {
      final isSupported = await _localAuthService.isDeviceSupported();
      
      if (!isSupported) {
        setState(() {
          _errorMessage = 'Biometric authentication is not supported on this device';
          _isAuthenticating = false;
        });
        return;
      }

      final canCheck = await _localAuthService.canCheckBiometrics();
      
      if (!canCheck) {
        setState(() {
          _errorMessage = 'Biometric authentication is not available';
          _isAuthenticating = false;
        });
        return;
      }

      final authenticated = await _localAuthService.authenticate(
        localizedReason: 'Please authenticate to access the app',
      );

      if (authenticated && mounted) {
        // Navigate to dashboard
        context.go(AppRoutes.dashboard);
      } else {
        setState(() {
          _errorMessage = 'Authentication failed or was cancelled';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.lock_outline,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 32),
              Text(
                'Welcome',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Authenticate to continue',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              ElevatedButton.icon(
                onPressed: _isAuthenticating ? null : _authenticateWithBiometrics,
                icon: _isAuthenticating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.fingerprint),
                label: Text(_isAuthenticating ? 'Authenticating...' : 'Authenticate with Biometrics'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // Skip authentication for demo purposes
                  context.go(AppRoutes.dashboard);
                },
                child: const Text('Skip (Demo Mode)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

