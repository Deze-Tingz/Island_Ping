import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/connectivity_service.dart';

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(() => service.dispose());
  return service;
});

final connectionStatusProvider = StreamProvider<ConnectionStatus>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.statusStream;
});

final currentConnectionStatusProvider = Provider<ConnectionStatus>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.currentStatus;
});
