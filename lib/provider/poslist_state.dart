import 'package:flutter/material.dart';

import '../data/box_position.dart';

class PosListProvider with ChangeNotifier {
  List<BoxPosition> _posList = List();
  //getter
  List<BoxPosition> get posList => _posList;
  //setter
  void setPositions(List<BoxPosition> posList) {
    _posList = posList;
  }
}
