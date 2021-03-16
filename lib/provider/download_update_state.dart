import 'package:flutter/material.dart';

/// enum for download/upload state
/// - DOWNLOAD: download in progress
/// - UPLOAD: upload in progress
/// - IDLE: neither download nor upload in progress
enum DownloadUpload { DOWNLOAD, UPLOAD, IDLE }

/// Provider for the [DownloadUploadState]
class DownloadUploadState with ChangeNotifier {
  /// initially the state is IDLE
  DownloadUpload _downloadUploadState = DownloadUpload.IDLE;

  DownloadUpload get downloadUploadState => _downloadUploadState;

  void idle() {
    _downloadUploadState = DownloadUpload.IDLE;
    notifyListeners();
  }

  void downloading() {
    _downloadUploadState = DownloadUpload.DOWNLOAD;
    notifyListeners();
  }

  void uploading() {
    _downloadUploadState = DownloadUpload.UPLOAD;
    notifyListeners();
  }
}
