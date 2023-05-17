import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BluetoothApp(),
    );
  }
}

class BluetoothApp extends StatefulWidget {
  @override
  _BluetoothAppState createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp> {

  @override
  void initState() {
    super.initState();

    checkPermissions();

    getConnection();
  }


  Future<void> checkPermissions() async {
    var bluetoothStatus = await Permission.bluetooth.status;

    var bluetoothAdStatus = await Permission.bluetoothAdvertise.status;

    var bluetoothConnStatus = await Permission.bluetoothConnect.status;

    var bluetoothScanStatus = await Permission.bluetoothScan.status;

    List<Permission> permissions = [
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
    ];

    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    var permBlue = Permission.bluetooth.request();

    print(statuses[Permission.location]);

    print(statuses[Permission.bluetooth]);

    print(statuses[Permission.bluetoothAdvertise]);

    print(statuses[Permission.bluetoothScan]);

    print(statuses[Permission.bluetoothConnect]);
    print('permBlue - $permBlue');


  }

  getConnection() async {
      var device;
      FlutterBluePlus conn = FlutterBluePlus.instance;

      conn.startScan(timeout: Duration(seconds: 60));

      var subscription = conn.scanResults.listen((results) async {
        for (ScanResult r in results) {
          print('${r.device.name}');

          if (r.device.name == "Siri's M01")
            {
              print('device: ${r.device}');
              device = r.device;
              print('second device : ${device.name}');
              conn.stopScan();

              await r.device.connect();
              Future<List<BluetoothService>> v = await device.discoverServices();
              print('Connection status: $v');
            }

        }

      });



    const service_uuid = "29f6548b-91d5-423a-9af2-719cf9420b62";
    //device char for ISSC characteristics
    const char_uuid = "0000180d-0000-1000-8000-00805f9b34fb";

      BluetoothCharacteristic c;

      Stream<List<int>> listStream;

      List<BluetoothService> services = await device.discoverServices();

      for (var service in services) {
        print('Service UUID is ${service.uuid.toString()}');
        if (service.uuid.toString() == service_uuid){
          for (var characteristic in service.characteristics) {
            if (characteristic.uuid.toString() == char_uuid) {
              listStream = characteristic.value;
              characteristic.setNotifyValue(!characteristic.isNotifying);
              print('Characteristic');
          }
        }
      }
          }




  }

  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter Bluetooth Serial'),
          backgroundColor: Colors.lime,
        ),
        body: Container(
            child: Column(
              children: [
                Text('Printed names'),
              ],
            )),
      ),
    );
  }
}
