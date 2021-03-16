import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final List<String> labelSetTrees = [
  "Tanne",
  "Fichte",
  "Laubbaum",
  "Kiefer",
  "Buche",
  "Birke",
  "Kastanie",
  "Anderer Baum"
];
final List<String> labelSetAnimals = [
  "Dachs",
  "Reh",
  "Fuchs",
  "Sonstiges",
  "Ich weiß nicht"
];
List<String> labelSet;

/// This page is displayed when the user does the photo labelling task.
class FotoLabelPage extends StatefulWidget {
  final Image img;
  final String takenBy;

  FotoLabelPage(this.img, this.takenBy) {
    labelSet = takenBy == "box" ? labelSetAnimals : labelSetTrees;
  }

  @override
  _FotoLabelPageState createState() => _FotoLabelPageState();
}

class _FotoLabelPageState extends State<FotoLabelPage> {
  List<String> _selectedLabels = [];

  @override
  Widget build(BuildContext context) {
    Widget gridViewSelection = GridView.count(
      childAspectRatio: 4,
      crossAxisCount: 3,
      children: labelSet.map((label) {
        return GestureDetector(
          onTap: () {
            setState(() {
              if (_selectedLabels.contains(label)) {
                _selectedLabels.remove(label);
              } else {
                _selectedLabels.add(label);
              }
            });
          },
          child: GridViewItem(label, _selectedLabels.contains(label)),
        );
      }).toList(),
    );

    // disable auto rotation of screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Foto Labelling"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Flexible(
              flex: 2,
              child: Padding(
                  child: widget.img, padding: EdgeInsets.fromLTRB(0, 20, 0, 0)))
          // here goes the image
          ,
          Flexible(
            flex: 1,
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 246),
              child: Container(
                margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
                padding: EdgeInsets.all(10),
                child: gridViewSelection,
              ),
            ),
          )
        ],
      ),
      floatingActionButton: buildActionButton(context, _selectedLabels),
    );
  }
}

/// This button is clicked when the user has selected all the appropriate labels in the photo labeling task
Widget buildActionButton(BuildContext context, List<String> selectedLabels) {
  return FloatingActionButton(
      child: Icon(Icons.done_all),
      backgroundColor: Colors.green,
      onPressed: () {
        // if there is no label selected, show dialog if user wants to
        // cancel the process or go back to labelling
        if (selectedLabels.isEmpty) {
          showDialog(
              context: context,
              builder: (BuildContext buttonContext) {
                return AlertDialog(
                  title: Text("Du hast kein Label ausgewählt."),
                  content:
                      Text("Willst du abbrechen oder es nochmal probieren?"),
                  actions: [
                    FlatButton(
                        onPressed: () {
                          // close dialog window and go back to labelling
                          Navigator.of(buttonContext).pop();
                        },
                        child: Text("Nochmal")),
                    FlatButton(
                        onPressed: () {
                          // close dialog window and go back to task page
                          // without setting a label
                          Navigator.of(buttonContext).pop();
                          Navigator.of(context).pop();
                        },
                        child: Text("Abbrechen")),
                  ],
                );
              });
        } else {
          // go back to tasks page and return the selected label
          Navigator.pop(context, selectedLabels);
        }
        // write label to database
      });
}

/// This class is used to create the labels for the labelling task
class GridViewItem extends StatelessWidget {
  final bool _isSelected;
  final String _label;

  GridViewItem(this._label, this._isSelected);

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.all(3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: _isSelected ? Colors.green : Colors.white,
        elevation: _isSelected ? 5 : 10,
        child: GridTile(
          child: Center(child: Text(_label, textAlign: TextAlign.center)),
        ));
  }
}
