class BoxPosition {
  final double lat;
  final double long;

  BoxPosition({this.lat, this.long});

  factory BoxPosition.fromJson(MapEntry<String, dynamic> json) {
    return BoxPosition(
        lat: json.value[0].toDouble(), long: json.value[1].toDouble());
  }
}
