import 'package:flutter/material.dart';

import '../../core/di/injection_container.dart' as di;
import '../network/connectivity_service.dart';
import '../../shared/presentation/widgets/offline_banner.dart';

class NetworkAwareWidget extends StatelessWidget {
  final Widget child;

  const NetworkAwareWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final connectivityService = di.getIt<ConnectivityService>();

    return StreamBuilder<NetworkStatus>(
      stream: connectivityService.connectivityStream,
      initialData: connectivityService.currentStatus,
      builder: (context, snapshot) {
        final isOffline = snapshot.data == NetworkStatus.offline;

        // Always show child, overlay banner on top when offline
        return Stack(
          fit: StackFit.expand,
          children: [
            child,
            if (isOffline)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Material(elevation: 4, child: const OfflineBanner()),
                ),
              ),
          ],
        );
      },
    );
  }
}
