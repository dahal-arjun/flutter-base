import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../utils/app_logger.dart';

enum NetworkStatus { online, offline }

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final _controller = StreamController<NetworkStatus>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Stream<NetworkStatus> get connectivityStream => _controller.stream;
  NetworkStatus _currentStatus = NetworkStatus.online;

  NetworkStatus get currentStatus => _currentStatus;

  ConnectivityService() {
    _init();
  }

  Future<void> _init() async {
    // Check initial status
    await checkConnectivity();

    // Listen to connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      _updateStatus(results);
    });
  }

  Future<void> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateStatus(results);
    } catch (e) {
      AppLogger.e('Error checking connectivity', e);
      _updateStatus([ConnectivityResult.none]);
    }
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final isOnline = results.any(
      (result) =>
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet,
    );

    final newStatus = isOnline ? NetworkStatus.online : NetworkStatus.offline;

    if (_currentStatus != newStatus) {
      _currentStatus = newStatus;
      _controller.add(newStatus);
      // Log network status changes (simplified format)
      // Only log the status name, not the full object
      final statusName = newStatus == NetworkStatus.online
          ? 'online'
          : 'offline';
      AppLogger.i('Network status: $statusName');
    }
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
