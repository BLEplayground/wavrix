
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wavrix/scanner/view/scanner_view.dart';

void main() {
  runApp(const WirelessExplorerApp());
}

class WirelessExplorerApp extends StatelessWidget {
  const WirelessExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Wireless Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0D111B),
      ),
      home: const ScannerScreen(),
    );
  }
}
