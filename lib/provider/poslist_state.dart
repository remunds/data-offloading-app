import 'package:flutter/material.dart';

import '../data/box_position.dart';

class PosListProvider with ChangeNotifier {
  List<BoxPosition> _posList = List();
  //getterFunc()
  List<BoxPosition> get posList => _posList;

  void setPositions(List<BoxPosition> posList) {
    _posList = posList;
  }
}
