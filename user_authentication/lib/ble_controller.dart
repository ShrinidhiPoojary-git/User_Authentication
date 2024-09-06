import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:permission_handler/permission_handler.dart';

class BleController extends GetxController{
  FlutterBlue ble = FlutterBlue.instance;
  Future scanBleDevices() async{
    if (await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted &&
        await Permission.locationWhenInUse.request().isGranted){
      print("shri: bluetooth permission scan request isgranted");
        ble.startScan(timeout: Duration(seconds: 10));
        await Future.delayed(Duration(seconds: 10));
        ble.stopScan();
      }
  }
  Stream<List<ScanResult>> get scanResults => ble.scanResults;
}