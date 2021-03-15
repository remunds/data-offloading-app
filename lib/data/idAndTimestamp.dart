class IdListAndTimeStamp {
  //Class which constructs a IdListAndTimestamp Object with timestamp as device
  //id and idList as list of on phone IDs (of chunks and files)
  final int timestamp;
  final List idList;

  IdListAndTimeStamp({this.timestamp, this.idList});

  Map<String, dynamic> toJson() {
    return {'timestamp': timestamp, 'idList': idList};
  }
}
