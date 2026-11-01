import 'package:wavrix/utils/enums.dart';

class NearbyDeviceModel {
   String? id;
   String? name;
   int? rssi;
   ScanMode? source;

   NearbyDeviceModel({
    this.id,
    this.name,
    this.rssi,
    this.source,
  });
}