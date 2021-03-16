/// This class wraps the lat and long coordinates of the sensor boxes
class BoxPosition {
  final double lat;
  final double long;

  BoxPosition({this.lat, this.long});

  /// parses the lat and long coordinates from a json file [json]
  factory BoxPosition.fromJson(MapEntry<String, dynamic> json) {
    return BoxPosition(
        lat: json.value[0].toDouble(), long: json.value[1].toDouble());
  }
}
