import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

final connectivityStreamProvider = StreamProvider<bool>((ref) {
  return ref.watch(connectivityServiceProvider).connectionStream;
});

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Stream<bool> get connectionStream {
    return _connectivity.onConnectivityChanged.map((result) {
      // result is a ConnectivityResult enum, return true if it's not 'none'
      return result != ConnectivityResult.none;
    });
  }

  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
