import 'package:flutter/material.dart';

enum DownloadUpload { DOWNLOAD, UPLOAD, IDLE }

class DownloadUploadState with ChangeNotifier {
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
