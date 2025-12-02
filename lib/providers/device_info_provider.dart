import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Device information model
class DeviceInfoModel {
  final String deviceName;
  final String deviceModel;
  final String manufacturer;
  final String osVersion;
  final String networkType;
  final String? ispName;
  final String? wifiName;
  final int batteryLevel;
  final BatteryState batteryState;
  final String batteryHealth;

  const DeviceInfoModel({
    required this.deviceName,
    required this.deviceModel,
    required this.manufacturer,
    required this.osVersion,
    required this.networkType,
    this.ispName,
    this.wifiName,
    required this.batteryLevel,
    required this.batteryState,
    required this.batteryHealth,
  });

  String get displayName => deviceName.isNotEmpty ? deviceName : '$manufacturer $deviceModel';

  String get networkDisplayName {
    if (networkType == 'WiFi' && wifiName != null && wifiName!.isNotEmpty) {
      return wifiName!.replaceAll('"', '');
    }
    if (ispName != null && ispName!.isNotEmpty) {
      return ispName!;
    }
    return networkType;
  }

  String get batteryStateText {
    switch (batteryState) {
      case BatteryState.charging:
        return 'Charging';
      case BatteryState.discharging:
        return 'Discharging';
      case BatteryState.full:
        return 'Full';
      case BatteryState.connectedNotCharging:
        return 'Connected';
      case BatteryState.unknown:
        return 'Unknown';
    }
  }
}

/// Service to get device and network information
class DeviceInfoService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final NetworkInfo _networkInfo = NetworkInfo();
  final Battery _battery = Battery();

  Future<DeviceInfoModel> getDeviceInfo() async {
    String deviceName = '';
    String deviceModel = '';
    String manufacturer = '';
    String osVersion = '';
    String networkType = 'Unknown';
    String? ispName;
    String? wifiName;
    int batteryLevel = 0;
    BatteryState batteryState = BatteryState.unknown;
    String batteryHealth = 'Good';

    try {
      // Get device info
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        deviceName = androidInfo.device;
        deviceModel = androidInfo.model;
        manufacturer = androidInfo.manufacturer;
        osVersion = 'Android ${androidInfo.version.release}';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        deviceName = iosInfo.name;
        deviceModel = iosInfo.model;
        manufacturer = 'Apple';
        osVersion = 'iOS ${iosInfo.systemVersion}';
      }

      // Get network info - connectivity_plus 5.x returns single ConnectivityResult
      final connectivity = await Connectivity().checkConnectivity();

      switch (connectivity) {
        case ConnectivityResult.wifi:
          networkType = 'WiFi';
          try {
            wifiName = await _networkInfo.getWifiName();
          } catch (_) {}
          break;
        case ConnectivityResult.mobile:
          networkType = 'Mobile Data';
          // Try to detect ISP from carrier info
          ispName = await _detectISP();
          break;
        case ConnectivityResult.ethernet:
          networkType = 'Ethernet';
          break;
        case ConnectivityResult.none:
          networkType = 'Offline';
          break;
        default:
          networkType = 'Unknown';
      }

      // Get battery info
      batteryLevel = await _battery.batteryLevel;
      batteryState = await _battery.batteryState;

      // Determine battery health based on level and state
      if (batteryLevel >= 80) {
        batteryHealth = 'Excellent';
      } else if (batteryLevel >= 50) {
        batteryHealth = 'Good';
      } else if (batteryLevel >= 20) {
        batteryHealth = 'Fair';
      } else {
        batteryHealth = 'Low';
      }
    } catch (e) {
      // Return defaults on error
    }

    return DeviceInfoModel(
      deviceName: deviceName,
      deviceModel: deviceModel,
      manufacturer: manufacturer,
      osVersion: osVersion,
      networkType: networkType,
      ispName: ispName,
      wifiName: wifiName,
      batteryLevel: batteryLevel,
      batteryState: batteryState,
      batteryHealth: batteryHealth,
    );
  }

  Future<String?> _detectISP() async {
    // Common Jamaican ISPs detection
    // In a real app, you'd use a carrier info plugin or API
    // For now, we'll return a generic label
    return 'Mobile Network';
  }

  Stream<int> get batteryLevelStream => _battery.onBatteryStateChanged.asyncMap((_) async {
    return await _battery.batteryLevel;
  });

  Stream<BatteryState> get batteryStateStream => _battery.onBatteryStateChanged;
}

/// Provider for device info service
final deviceInfoServiceProvider = Provider<DeviceInfoService>((ref) {
  return DeviceInfoService();
});

/// Provider for device information
final deviceInfoProvider = FutureProvider<DeviceInfoModel>((ref) async {
  final service = ref.watch(deviceInfoServiceProvider);
  return service.getDeviceInfo();
});

/// Provider for real-time battery level
final batteryLevelProvider = StreamProvider<int>((ref) {
  final service = ref.watch(deviceInfoServiceProvider);
  return service.batteryLevelStream;
});

/// Provider for battery state
final batteryStateProvider = StreamProvider<BatteryState>((ref) {
  final service = ref.watch(deviceInfoServiceProvider);
  return service.batteryStateStream;
});
