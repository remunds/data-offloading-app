import 'dart:io';

import 'package:hive/hive.dart';
import 'package:data_offloading_app/logic/stats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  var path = Directory.current.path;
  Hive.init(path + '/test/hive_testing_path');
  Box box = await Hive.openBox('storage');
  Stats.setBox(box);

  //check if openBox returns non null value
  test("openBox", () {
    Stats.openBox().then((value) {
      Box currentBox = Stats.getBox();
      expect(currentBox, isNot(equals(null)));
    });
  });

  test("getAndSetVisitedBoxes1", () {
    List<dynamic> visitedBoxes = ["Box1", "Box2", "Box3"];
    Stats.setVisitedBoxes(visitedBoxes);
    List<dynamic> matcherVisitedBoxes = Stats.getVisitedBoxes();
    for (var i = 0; i < visitedBoxes.length; i++) {
      expect(visitedBoxes[i], matcherVisitedBoxes[i]);
    }
  });

  test("getAndSetVisitedBoxes2", () {
    List<dynamic> visitedBoxes = [];
    Stats.setVisitedBoxes(visitedBoxes);
    List<dynamic> matcherVisitedBoxes = Stats.getVisitedBoxes();
    expect(matcherVisitedBoxes.length, 0);
  });

  test("addVisitedBox", () {
    List<dynamic> visitedBoxes = ["Box1", "Box2", "Box3"];
    Stats.setVisitedBoxes(visitedBoxes);
    String boxName = "ImANewBox";
    Stats.addVisitedBox(boxName);
    List<dynamic> newVisitedBoxes = Stats.getVisitedBoxes();
    //check if last index is the new boxName
    expect(newVisitedBoxes[newVisitedBoxes.length - 1], "ImANewBox");
    //check if all other entries are the same as in the previous array
    for (var i = 0; i < newVisitedBoxes.length - 1; i++) {
      expect(newVisitedBoxes[i], visitedBoxes[i]);
    }
  });

  test("mostFrequentBox1", () {
    List<dynamic> visitedBoxes = [
      "Box1",
      "Box2",
      "Box3",
      "Box1",
      "Box1",
      "Box2",
      "Box3",
      "Box2",
      "Box1"
    ];
    String mostVisitedBox = Stats.mostFrequentBox(visitedBoxes);
    expect("Box1", mostVisitedBox);
  });

  test("mostFrequentBox2", () {
    List<dynamic> visitedBoxes = [];
    String mostVisitedBox = Stats.mostFrequentBox(visitedBoxes);
    expect("", mostVisitedBox);
  });

  test("mostFrequentlyVisitedBoxes1", () {
    List<dynamic> visitedBoxes = [
      "Box1",
      "Box2",
      "Box3",
      "Box1",
      "Box1",
      "Box2",
      "Box3",
      "Box2",
      "Box1",
      "Box4",
      "Box4",
      "Box4",
      "Box4",
      "Box5"
    ];
    Stats.setVisitedBoxes(visitedBoxes);
    List<dynamic> mostVisitedBoxes = Stats.getMostFrequentlyVisitedBoxes();
    expect(mostVisitedBoxes[0], "Box4");
    expect(mostVisitedBoxes[1], "Box1");
    expect(mostVisitedBoxes[2], "Box2");
  });

  test("mostFrequentlyVisitedBoxes2", () {
    List<dynamic> visitedBoxes = [
      "Box1",
    ];
    Stats.setVisitedBoxes(visitedBoxes);
    List<dynamic> mostVisitedBoxes = Stats.getMostFrequentlyVisitedBoxes();
    expect(mostVisitedBoxes[0], "Box1");
    expect(mostVisitedBoxes[1], "");
    expect(mostVisitedBoxes[2], "");
  });

  test("mostFrequentlyVisitedBoxes3", () {
    List<dynamic> visitedBoxes = ["Box1", "Box2", "Box3"];
    Stats.setVisitedBoxes(visitedBoxes);
    List<dynamic> mostVisitedBoxes = Stats.getMostFrequentlyVisitedBoxes();
    expect(mostVisitedBoxes[0], "Box3");
    expect(mostVisitedBoxes[1], "Box2");
    expect(mostVisitedBoxes[2], "Box1");
  });

  test("getFrequency1", () {
    List<dynamic> visitedBoxes = [
      "Box1",
      "Box2",
      "Box3",
      "Box1",
      "Box1",
      "Box2",
      "Box3",
      "Box2",
      "Box1",
      "Box4",
      "Box4",
      "Box4",
      "Box4",
      "Box5"
    ];
    double freqBox4 = Stats.getFrequency("Box4", visitedBoxes);
    expect(freqBox4, 4);
  });

  test("getFrequency2", () {
    List<dynamic> visitedBoxes = [
      "Box1",
      "Box2",
      "Box3",
      "Box1",
      "Box1",
      "Box2",
      "Box3",
      "Box2",
      "Box1",
      "Box4",
      "Box4",
      "Box4",
      "Box4",
      "Box5"
    ];
    double freqBox4 = Stats.getFrequency("Box4", visitedBoxes);
    expect(freqBox4, 4);
  });

  test("getFrequency3", () {
    List<dynamic> visitedBoxes = [];
    double freqBox = Stats.getFrequency("1st", visitedBoxes);
    expect(freqBox, 0);
  });

  test("getFrequency4", () {
    List<dynamic> visitedBoxes = [];
    double freqBox = Stats.getFrequency("2nd", visitedBoxes);
    expect(freqBox, 0);
  });

  test("getFrequency5", () {
    List<dynamic> visitedBoxes = [];
    double freqBox = Stats.getFrequency("3rd", visitedBoxes);
    expect(freqBox, 0);
  });

  test("increaseLevel1", () {
    Stats.setLevel(1);
    Stats.setProgress(0);
    Stats.increaseLevel();
    int newLevel = Stats.getLevel();
    double newProgress = Stats.getProgress();
    expect(newLevel, 2);
    expect(newProgress, 0.0);
  });

  test("increaseLevel2", () {
    Stats.setLevel(1);
    Stats.setProgress(0);
    for (int i = 0; i < 11; i++) {
      Stats.increaseLevel();
    }
    int newLevel = Stats.getLevel();
    double newProgress = Stats.getProgress();
    expect(newLevel, 5);
    expect(newProgress, 0.2);
  });

  test("increaseTask", () {
    Box currentBox = Stats.getBox();
    currentBox.put("dummyTask", 0);
    Stats.increaseTask("dummyTask");
    int finishedDummyTask = currentBox.get("dummyTask");
    expect(finishedDummyTask, 1);
  });

  test("increaseTotalTasks", () {
    Box currentBox = Stats.getBox();
    currentBox.put('totalFinishedTasks', 0);
    Stats.increaseTotalTasks();
    int newTotal = currentBox.get('totalFinishedTasks', defaultValue: 0);
    expect(newTotal, 1);
  });

  test("reset", () {
    Box currentBox = Stats.getBox();
    currentBox.put('totalFinishedTasks', 20);
    currentBox.put('imageTask', 4);
    currentBox.put('cleaningTask', 10);
    currentBox.put('brightnessTask', 2);
    currentBox.put('sensorTask', 4);
    currentBox.put('level', 8);
    currentBox.put('progress', 0.8);
    currentBox.put('visitedBoxes', ["a", "b", "c"]);

    Stats.reset();

    expect(box.get('totalFinishedTasks'), 0);
    expect(box.get('imageTask'), 0);
    expect(box.get('cleaningTask'), 0);
    expect(box.get('brightnessTask'), 0);
    expect(box.get('sensorTask'), 0);
    expect(box.get('level'), 1);
    expect(box.get('progress'), 0.0);
    List<dynamic> vistitedBoxes = box.get('visitedBoxes');
    expect(vistitedBoxes.length, 0);
  });
}
