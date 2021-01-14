import 'package:flutter/material.dart';

enum Connection { SENSORBOX, WIFI, NONE }

class BoxConnectionState with ChangeNotifier {
  Connection _connectionState = Connection.NONE;

  Connection get connectionState => _connectionState;

  void disconnected() {
    _connectionState = Connection.NONE;
    notifyListeners();
  }

  void connectedToWifi() {
    _connectionState = Connection.WIFI;
    notifyListeners();
  }

  void connectedToSensorbox() {
    _connectionState = Connection.SENSORBOX;
    notifyListeners();
  }
}
