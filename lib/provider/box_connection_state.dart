import 'package:flutter/material.dart';

class BoxConnectionState with ChangeNotifier {
  bool _connectionState = false;

  bool get connectionState => _connectionState;

  void disconnected() {
    _connectionState = false;
    notifyListeners();
  }

  void connected() {
    _connectionState = true;
    notifyListeners();
  }
}
