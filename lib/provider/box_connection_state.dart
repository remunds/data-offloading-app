import 'package:flutter/material.dart';

/// enum for connection state
/// - SENSORBOX: connection with a Sensorbox
/// - KNOWN_WIFI: connection with a Wifi which has been permitted or denied upload rights
/// - UNKNOWN_WIFI: connection to a new Wifi
/// - NONE: no Wifi connection
enum Connection { SENSORBOX, KNOWN_WIFI, NONE, UNKNOWN_WIFI }

/// Provider for the [BoxConnectionState]
class BoxConnectionState with ChangeNotifier {
  Connection _connectionState = Connection.NONE;
  String wifiName = "";

  Connection get connectionState => _connectionState;

  void disconnected() {
    _connectionState = Connection.NONE;
    notifyListeners();
  }

  void connectedToKnownWifi() {
    _connectionState = Connection.KNOWN_WIFI;
    notifyListeners();
  }

  void connectedToUnknownWifi() {
    _connectionState = Connection.UNKNOWN_WIFI;
    notifyListeners();
  }

  void connectedToSensorbox() {
    _connectionState = Connection.SENSORBOX;
    notifyListeners();
  }
}
