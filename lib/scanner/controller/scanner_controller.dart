
import 'dart:async';

import 'package:get/get.dart';
import 'package:wavrix/scanner/model/near_by_device_model.dart';
import 'package:wavrix/utils/api_endpoints.dart';
import 'package:wavrix/utils/enums.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class ScannerController extends GetxController {
  Rx<ScanMode> selectedMode = ScanMode.phone.obs;
  RxBool isScanning = false.obs;
  RxList<NearbyDeviceModel> devices = <NearbyDeviceModel>[].obs;
  RxString errorMessage = ''.obs;
  bool _esp32LoopRunning = false;
  StreamSubscription<List<ScanResult>>? _resultsSubscription;
  StreamSubscription<bool>? _scanningSubscription;

  @override
  void onInit() {
    super.onInit();

    _resultsSubscription = FlutterBluePlus.onScanResults.listen(
          (results) {
        final found = results.map((result) {
          final advertisedName = result.advertisementData.advName.trim();
          final platformName = result.device.platformName.trim();

          return NearbyDeviceModel(
            id: result.device.remoteId.str,
            name: advertisedName.isNotEmpty
                ? advertisedName
                :  platformName,
            rssi: result.rssi,
            source: ScanMode.phone,
          );
        }).toList();

        devices.assignAll(found);
      },
      onError: (Object error) {
        errorMessage.value = 'Scan error: $error';
      },
    );

    _scanningSubscription =
        FlutterBluePlus.isScanning.listen((scanning) {
          isScanning.value = scanning;
        });
  }

  Future<void> changeMode(ScanMode mode) async {
    if (isScanning.value) {
      await stopScan();
    }

    selectedMode.value = mode;
    devices.clear();
    errorMessage.value = '';
  }

  Future<void> startScan() async {
    errorMessage.value = '';
    devices.clear();

    if (selectedMode.value == ScanMode.esp32) {
      _esp32LoopRunning = true;
      isScanning.value = true;

      unawaited(_scanEsp32Repeatedly());
      return;
    }

    try {
      final supported = await FlutterBluePlus.isSupported;

      if (!supported) {
        errorMessage.value = 'This phone does not support Bluetooth.';
        return;
      }

      final adapterState = await FlutterBluePlus.adapterState.first;

      if (adapterState != BluetoothAdapterState.on) {
        errorMessage.value = 'Turn on Bluetooth on your phone.';
        return;
      }

      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 20),
      );
    } catch (error) {
      errorMessage.value = 'Unable to start scan: $error';
    }
  }
  Future<void> _scanEsp32Repeatedly() async {
    while (_esp32LoopRunning && selectedMode.value == ScanMode.esp32)
    {
      try {
        final response = await http
              .get(Uri.parse(ApiEndpoints.scanDevices))
            .timeout(const Duration(seconds: 15));

        if (response.statusCode != 200) {
          throw Exception('HTTP ${response.statusCode}');
        }

        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final list = data['devices'] as List<dynamic>;

        final found = list.map((item) {
          final device = item as Map<String, dynamic>;

          return NearbyDeviceModel(
            id: device['address'],
            name: (device['name']).toString().trim().isNotEmpty == true
                ? (device['name']).toString().trim()
                : 'Unnamed BLE device',
            rssi: (device['rssi'] as num).toInt(),
            source: ScanMode.esp32,
          );
        }).toList();

        devices.assignAll(found);
        errorMessage.value = '';
      } catch (error) {
        errorMessage.value =
        'ESP32 connection failed: $error';
      }

      // Give the ESP32 a short pause before the next scan.
      if (_esp32LoopRunning) {
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  Future<void> stopScan() async {
    if (selectedMode.value == ScanMode.esp32) {
      _esp32LoopRunning = false;
      isScanning.value = false;
      return;
    }

    try {
      await FlutterBluePlus.stopScan();
    } catch (error) {
      errorMessage.value = 'Unable to stop scan: $error';
    }
  }

  Future<void> toggleScanning() async {
    if (isScanning.value) {
      await stopScan();
    } else {
      await startScan();
    }
  }

  @override
  void onClose() {
    _esp32LoopRunning = false;
    _resultsSubscription?.cancel();
    _scanningSubscription?.cancel();
    super.onClose();
  }
}
