import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wavrix/scanner/widgets/device_card_widget.dart';
import 'package:wavrix/scanner/controller/scanner_controller.dart';
import 'package:wavrix/utils/app_colors.dart';
import 'package:wavrix/utils/enums.dart';

class ScannerScreen extends GetView<ScannerController> {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: GetBuilder<ScannerController>(
          init: ScannerController(),
          assignId: true,
          builder: (controller) {
            return Obx(
              () => CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _headerView(),
                        const SizedBox(height: 30),
                        const Text(
                          'SCAN SOURCE',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 11,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _tabWidget(),
                        const SizedBox(height: 24),
                        _scannerCardWidget(controller: controller),
                        const SizedBox(height: 28),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Nearby devices',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.darkNavy,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${controller.devices.length} found',
                                style: const TextStyle(
                                  color: AppColors.skyBlue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Column(
                          children: List.generate(controller.devices.length, (index) {

                            final device = controller.devices[index];
                            return
                            DeviceCard(
                            name: device.name ?? "",
                            address: device.id ?? "",
                            rssi: device.rssi ?? 0,
                          );}),
                        ),

                      ]),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _scannerCardWidget({
    required ScannerController controller
}){
    return  Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.gradientStart,
            AppColors.gradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.blueGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Bluetooth scanner',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(
                controller.isScanning.value
                    ? Icons.radar
                    : Icons.bluetooth_searching,
                color: AppColors.skyBlue,
                size: 28,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            controller.selectedMode.value == ScanMode.phone
                ? 'Scan using this phone'
                : 'Scan using your ESP32 board',
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 22),
         _scannerButtonWidget(controller: controller),
          const SizedBox(height: 10),
          Text(
            controller.errorMessage.value.isNotEmpty
                ? controller.errorMessage.value
                : controller.isScanning.value
                ? 'Scanning for nearby BLE devices...'
                : 'Ready to scan nearby BLE devices',
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _scannerButtonWidget ({required ScannerController controller}){
    return  SizedBox(
      width: double.infinity,
      height: 50,
      child: FilledButton.icon(
        onPressed: controller.toggleScanning,
        icon: Icon(
          controller.isScanning.value
              ? Icons.stop
              : Icons.radar,
        ),
        label: Text(
          controller.isScanning.value
              ? 'Stop scan'
              : 'Start scan',
        ),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.skyBlue,
          foregroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _headerView(){
    return   Row(
      children: [
        Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.radar,
            color: AppColors.skyBlue,
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Wireless Explorer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Discover the wireless world',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.settings_outlined,
          color: AppColors.muted,
        ),
      ],
    );
  }

  Widget _scanModeButton(String label, IconData icon, ScanMode mode) {
    final selected = controller.selectedMode.value == mode;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeMode(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: selected ? AppColors.slateBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: selected ? AppColors.skyBlue : AppColors.muted,
                size: 18,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.muted,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabWidget(){
    return  Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.darkNavy,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          _scanModeButton(
            'Phone Scan',
            Icons.smartphone,
            ScanMode.phone,
          ),
          _scanModeButton(
            'ESP32 Scan',
            Icons.memory,
            ScanMode.esp32,
          ),
        ],
      ),
    );
  }
}
