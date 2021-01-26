import 'package:hive/hive.dart';

//this class is used to manage the Hive storage box in relation to the statistics page.
//this class only has class methods.
class Stats {
  static Box box;

  static setBox(Box otherBox) {
    box = otherBox;
  }

  static Box getBox() {
    return box;
  }

  static openBox() async {
    box = await Hive.openBox('storage');
  }

  //a wrapper to set the datafield visitedBoxes of the Hive
  static void setVisitedBoxes(List<dynamic> boxes) {
    box.put('visitedBoxes', boxes);
  }

  //a wrapper to get the datafield visitedBoxes of the Hive
  static List<dynamic> getVisitedBoxes() {
    return box.get('visitedBoxes', defaultValue: []);
  }

  //a wrapper to add a box to the datafield visitedBoxes of the Hive
  static void addVisitedBox(String boxName) {
    List<dynamic> visitedBoxes = Stats.getVisitedBoxes();
    visitedBoxes.add(boxName);
    box.put('visitedBoxes', visitedBoxes);
  }

  //a wrapper to get the used memory of the chunks stored in the Hive
  static int getUsedMemory() {
    //bytes
    return box.get('totalSizeInBytes', defaultValue: 0);
  }

  //a wrapper to get the total usable memory for chunks
  static double getTotalMemory() {
    //megabytes
    return box.get('dataLimitValue', defaultValue: 10.0);
  }

  //this function returns the most frequenlty visited box. In contrary to getTop3Boxes(Box box) only on box-id is returned
  static String mostFrequentBox(List<dynamic> list) {
    if (list.isEmpty) {
      return "";
    }
    return list.toSet().reduce((i, j) =>
        list.where((v) => v == i).length > list.where((v) => v == j).length
            ? i
            : j);
  }

  //this function removes a string (box-id) from a given list
  static List<dynamic> removeFromList(List<dynamic> list, String removeObj) {
    if (!list.contains(removeObj)) {
      return list;
    }
    for (int i = 0; i < list.length; i++) {
      if (list[i] == removeObj) {
        list.removeAt(i);
      }
    }
    return list;
  }

  //this function returns the most visited sensor boxes. The first entry in the returned list is the most frequently visited box and so on.
  static List<dynamic> getMostFrequentlyVisitedBoxes() {
    //this operation writes all values from the list of already visited boxes to a new list. This is necessary because otherwise the '=' operator just copies the pointer to the list. This function however needs a copy.
    List<dynamic> boxes = []..addAll(Stats.getVisitedBoxes());
    List<dynamic> top3 = [];
    for (int i = 0; i < 3; i++) {
      top3.add(mostFrequentBox(boxes));
      boxes = removeFromList(boxes, top3[i]);
    }
    return top3;
  }

  //this function returns how many times a given box a has been visited
  static double getFrequency(String boxid, List<dynamic> visitedBoxes) {
    if (boxid == "1st" || boxid == "2nd" || boxid == "3rd") {
      return 0;
    }
    Map map = Map();
    //this operation iterates over the visitedBoxes list and counts the occurences of every element. The results are written to a ma p which maps the boxid as a key to its frequency as a value.
    visitedBoxes
        .forEach((x) => map[x] = !map.containsKey(x) ? (1) : (map[x] + 1));
    //get the value to the key boxid of the map
    int freq = map[boxid];
    return freq.toDouble();
  }

  static void resetLevel() {
    box.put('level', 1);
  }

  static void resetProgress() {
    box.put('progress', 0.0);
  }

  static void resetVisitedBoxes() {
    box.put('visitedBoxes', []);
  }

  static void resetTasks() {
    box.put('totalFinishedTasks', 0);
    box.put('imageTask', 0);
    box.put('cleaningTask', 0);
    box.put('brightnessTask', 0);
    box.put('sensorTask', 0);
  }

  //this functions resets all data gathered for the tasks, the level and the visited boxes.
  static void reset() {
    resetTasks();
    resetLevel();
    resetProgress();
    resetVisitedBoxes();
  }

  //a wrapper to get the datafield level of the Hive
  static int getLevel() {
    return box.get('level', defaultValue: 1);
  }

  //a wrapper to set the datafield level of the Hive
  static void setLevel(int level) {
    box.put('level', level);
  }

  //a wrapper to get the datafield progress of the Hive
  static double getProgress() {
    return box.get('progress', defaultValue: 0.0);
  }

  //a wrapper to set the datafield progress of the Hive
  static void setProgress(double progress) {
    box.put('progress', progress);
  }

  //this function increases the number of tasks stored in the Hive
  static void increaseTotalTasks() {
    int _total = box.get('totalFinishedTasks', defaultValue: 0);
    box.put('totalFinishedTasks', ++_total);
  }

  static void increaseTask(String taskName) {
    //Stats.openBox();
    Stats.increaseLevel();
    increaseTotalTasks();
    int _finishedTasks = Stats.getBox().get(taskName, defaultValue: 0);
    Stats.getBox().put(taskName, ++_finishedTasks);
  }

  //this function increases the level of the user
  static void increaseLevel() {
    int _currLevel = getLevel();
    double _currProgress = getProgress();
    double _currIncrease = 1 / _currLevel;
    _currProgress += _currIncrease;
    if (_currProgress >= 1.0) {
      setLevel(++_currLevel);
      setProgress(0.0);
      return;
    }
    setProgress(_currProgress);
  }
}
