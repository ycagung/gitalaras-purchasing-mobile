import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:gspro/models/device.dart';

class DeviceService {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static Device? _cachedDevice;

  static Future<Device> getDevice() async {
    if (_cachedDevice != null) {
      return _cachedDevice!;
    }

    String deviceId;
    String deviceType;
    String deviceName;
    String os;

    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      deviceId = androidInfo.id;
      deviceType = 'mobile';
      deviceName = '${androidInfo.manufacturer} ${androidInfo.model}';
      os = 'Android ${androidInfo.version.release}';
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor ?? 'ios-${iosInfo.model}-${DateTime.now().millisecondsSinceEpoch}';
      deviceType = 'mobile';
      deviceName = '${iosInfo.name} (${iosInfo.model})';
      os = 'iOS ${iosInfo.systemVersion}';
    } else if (Platform.isWindows) {
      final windowsInfo = await _deviceInfo.windowsInfo;
      deviceId = windowsInfo.deviceId;
      deviceType = 'desktop';
      deviceName = windowsInfo.computerName;
      os = 'Windows ${windowsInfo.displayVersion}';
    } else if (Platform.isMacOS) {
      final macInfo = await _deviceInfo.macOsInfo;
      deviceId = macInfo.systemGUID ?? 'macos-${DateTime.now().millisecondsSinceEpoch}';
      deviceType = 'desktop';
      deviceName = macInfo.computerName;
      os = 'macOS ${macInfo.osRelease}';
    } else if (Platform.isLinux) {
      final linuxInfo = await _deviceInfo.linuxInfo;
      deviceId = (linuxInfo.machineId != null && linuxInfo.machineId!.isNotEmpty) 
          ? linuxInfo.machineId! 
          : 'linux-${DateTime.now().millisecondsSinceEpoch}';
      deviceType = 'desktop';
      deviceName = linuxInfo.prettyName;
      os = 'Linux ${linuxInfo.version}';
    } else {
      deviceId = 'unknown';
      deviceType = 'unknown';
      deviceName = 'Unknown Device';
      os = 'Unknown';
    }

    final packageInfo = await PackageInfo.fromPlatform();
    final device = Device(
      id: deviceId,
      type: deviceType,
      name: '$deviceName (${packageInfo.appName})',
      os: os,
    );

    _cachedDevice = device;
    return device;
  }
}

