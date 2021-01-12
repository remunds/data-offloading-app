import 'package:flutter/material.dart';

//This provider switches between different download states to show on settings page
class DownloadAllState with ChangeNotifier {
  int _downloadState = 0;

  int get downloadState => _downloadState;

  void initial() {
    _downloadState = 0;
    notifyListeners();
  }

  void downloading() {
    _downloadState = 1;
    notifyListeners();
  }

  void completed() {
    _downloadState = 2;
    notifyListeners();
  }
}
