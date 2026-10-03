import 'package:flutter/material.dart';

class NetworkStatusBanner extends StatelessWidget {
  const NetworkStatusBanner({
    super.key,
    required this.isOnline,
  });

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    if (isOnline) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      color: Colors.orange.shade100,
      child: Row(
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 18,
            color: Colors.orange.shade900,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Offline mode. Changes will sync later.',
              style: TextStyle(
                color: Colors.orange.shade900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}