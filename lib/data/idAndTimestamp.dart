
/// This class stores which files and chunks are stored on device.
class IdListAndTimeStamp {

  /// timestamp is used as device ID
  final int timestamp;

  /// list of chunk and file IDs on device
  final List idList;

  IdListAndTimeStamp({this.timestamp, this.idList});

  Map<String, dynamic> toJson() {
    return {'timestamp': timestamp, 'idList': idList};
  }
}
