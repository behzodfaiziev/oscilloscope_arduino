import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothListTile extends ListTile {
  BluetoothListTile({
    super.key,
    required BluetoothDevice device,
    GestureTapCallback? onTap,
    bool enabled = true,
  }) : super(
          onTap: onTap,
          enabled: enabled,
          leading: CircleAvatar(
              backgroundColor: Colors.grey[800],
              child: const Icon(Icons.bluetooth, color: Colors.grey)),
          title: Text(device.name ?? "Unknown device"),
          subtitle: Text(device.address.toString()),
        );
}
