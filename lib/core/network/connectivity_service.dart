import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  ConnectivityService({
    Connectivity? connectivity,
  }) : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  Stream<bool> get onlineStatusStream {
    return _connectivity.onConnectivityChanged.map(
          (results) {
        return results.any(
              (result) => result != ConnectivityResult.none,
        );
      },
    );
  }

  Future<bool> get isOnline async {
    final results = await _connectivity.checkConnectivity();

    return results.any(
          (result) => result != ConnectivityResult.none,
    );
  }
}