import 'package:flutter/material.dart';

import '../data/box_position.dart';
import '../logic/box_communicator.dart';

class PosListProvider with ChangeNotifier {
  List<BoxPosition> _posList = List();
  //getterFunc()
  List<BoxPosition> get posList => _posList;

  void setPos(List<BoxPosition> l) {
    _posList = l;
  }
}
