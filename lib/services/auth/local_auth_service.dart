import 'package:local_auth/local_auth.dart';

class LocalAuthService {
  final LocalAuthentication _localAuth;

  LocalAuthService(this._localAuth);

  // Check if device supports biometric authentication
  Future<bool> isDeviceSupported() async {
    return await _localAuth.isDeviceSupported();
  }

  // Check available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    return await _localAuth.getAvailableBiometrics();
  }

  // Check if biometrics are available
  Future<bool> canCheckBiometrics() async {
    return await _localAuth.canCheckBiometrics;
  }

  // Authenticate with biometrics
  Future<bool> authenticate({
    String localizedReason = 'Please authenticate to continue',
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: false,
        ),
        // Custom auth messages can be added here if needed
        // authMessages: const <AuthMessages>[],
      );
    } catch (e) {
      return false;
    }
  }

  // Stop authentication
  Future<bool> stopAuthentication() async {
    return await _localAuth.stopAuthentication();
  }
}
