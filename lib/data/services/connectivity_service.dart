import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';

enum ConnectionStatus { online, offline, checking }

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: AppConstants.connectionTimeout,
    receiveTimeout: AppConstants.connectionTimeout,
  ));

  final _statusController = StreamController<ConnectionStatus>.broadcast();
  Stream<ConnectionStatus> get statusStream => _statusController.stream;

  ConnectionStatus _currentStatus = ConnectionStatus.checking;
  ConnectionStatus get currentStatus => _currentStatus;

  Timer? _pingTimer;

  ConnectivityService() {
    _init();
  }

  void _init() {
    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen((results) {
      _checkConnection();
    });

    // Start periodic ping checks
    _startPingTimer();

    // Initial check
    _checkConnection();
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(AppConstants.pingInterval, (_) {
      _checkConnection();
    });
  }

  Future<void> _checkConnection() async {
    _updateStatus(ConnectionStatus.checking);

    // First check device connectivity
    final connectivityResult = await _connectivity.checkConnectivity();
    // Check if completely disconnected
    if (connectivityResult == ConnectivityResult.none) {
      _updateStatus(ConnectionStatus.offline);
      return;
    }

    // Then verify actual internet access by pinging
    final hasInternet = await _pingServers();
    _updateStatus(hasInternet ? ConnectionStatus.online : ConnectionStatus.offline);
  }

  Future<bool> _pingServers() async {
    for (final url in AppConstants.pingUrls) {
      try {
        final response = await _dio.head(url);
        if (response.statusCode != null && response.statusCode! < 400) {
          return true;
        }
      } catch (_) {
        continue;
      }
    }
    return false;
  }

  void _updateStatus(ConnectionStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;
      _statusController.add(status);
    }
  }

  Future<void> forceCheck() async {
    await _checkConnection();
  }

  void dispose() {
    _pingTimer?.cancel();
    _statusController.close();
  }
}
