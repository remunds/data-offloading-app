import 'package:flutter/material.dart';

import '../data/box_position.dart';

/// Provider for list of [BoxPosition]
class PosListProvider with ChangeNotifier {
  List<BoxPosition> _posList = List();

  List<BoxPosition> get posList => _posList;

  void setPositions(List<BoxPosition> posList) {
    _posList = posList;
    notifyListeners();
  }
}
