
import 'package:flutter/material.dart';
import 'package:wavrix/utils/app_colors.dart';



class DeviceCard extends StatelessWidget {
  final String name;
  final String address;
  final int rssi;

  const DeviceCard({
    super.key,
    required this.name,
    required this.address,
    required this.rssi,
  });

  @override
  Widget build(BuildContext context) {
    final strength = ((rssi + 100) / 70).clamp(0.0, 1.0);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: AppColors.darkNavy,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.darkSlate),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.bluetooth,
                color: AppColors.skyBlue,
                size: 27,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    address,
                    style: const TextStyle(
                      color:AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: strength,
                      minHeight: 5,
                      backgroundColor:  AppColors.slateGrey,
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.skyBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$rssi',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Text(
                  'dBm',
                  style: TextStyle(
                    color:AppColors.muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
