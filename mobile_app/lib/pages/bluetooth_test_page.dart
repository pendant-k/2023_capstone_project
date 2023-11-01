import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  List<DiscoveredDevice> _devices = [];
  StreamSubscription<DiscoveredDevice>? _scanSubscription;
  Uuid serviceUuid = Uuid.parse("0000ffff-0000-1000-8000-00805f9b34fb");

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  @override
  void dispose() {
    _stopScan();
    super.dispose();
  }

  void _startScan() {
    _scanSubscription = _ble.scanForDevices(
      withServices: [serviceUuid],
    ).listen((device) {
      setState(() {
        _devices.add(device);
      });
    }, onError: (error) {
      print('Error during scan: $error');
    });
  }

  void _stopScan() {
    _scanSubscription?.cancel();
    _scanSubscription = null;
  }

  void _connectToDevice(DiscoveredDevice device) async {
    try {
      await _ble.connectToDevice(id: device.id);
      print(device.name + "connected");
      // Do something with the device
    } catch (error) {
      print('Error connecting to device: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan for Bluetooth devices'),
      ),
      body: ListView.builder(
        itemCount: _devices.length,
        itemBuilder: (context, index) {
          final device = _devices[index];
          return ListTile(
            title: Text(device.name),
            subtitle: Text(device.id.toString()),
            onTap: () => _connectToDevice(device),
          );
        },
      ),
    );
  }
}
