import 'package:flutter/material.dart';

/// This provider switches between different download states
class DownloadAllState with ChangeNotifier {
  /// initially in normal download state (0)
  /// with button on settings page downloadAll state (1) can be enabled
  /// finally, download completed state (2)
  int _downloadState = 0;

  int get downloadState => _downloadState;

  void initial() {
    _downloadState = 0;
    notifyListeners();
  }

  void downloadingAll() {
    _downloadState = 1;
    notifyListeners();
  }

  void completed() {
    _downloadState = 2;
    notifyListeners();
  }
}
