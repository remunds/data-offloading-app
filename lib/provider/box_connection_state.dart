import 'package:flutter/material.dart';

enum Connection { SENSORBOX, KNOWN_WIFI, NONE, UNKNOWN_WIFI }

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
