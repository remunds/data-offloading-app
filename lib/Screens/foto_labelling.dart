import 'package:flutter/material.dart';
import 'package:item_selector/item_selector.dart';

var labelSet;
int selectedLabel = -1;

class FotoLabelPage extends StatefulWidget {
  final Image img;

  FotoLabelPage(this.img, labels){
    labelSet = labels;
  }

  @override
  _FotoLabelPageState createState() => _FotoLabelPageState();
}

class _FotoLabelPageState extends State<FotoLabelPage> {
  @override
  Widget build(BuildContext context) {
    // on new build, reset label selection
    selectedLabel = -1;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Foto Labelling"),
        backgroundColor: Colors.green,
      ),
      body: Column(
            children: [
              Expanded(
              // here goes the image
                child: Container(
                  color: Colors.grey,
                  margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: widget.img
                )
              ),
              Expanded(
                // here goes the label selection
                child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 246),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.2,
                      margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
                      padding: EdgeInsets.all(10),
                      child: GridViewPage(),
                    )),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.done_all),
          backgroundColor: Colors.green,
          onPressed: () {
            // if there is no label selected, show dialog if user wants to
            // cancel the process or go back to labelling
            if (selectedLabel == -1) {
              showDialog(
                  context: context,
                  builder: (BuildContext buttonContext) {
                    return AlertDialog(
                      title: Text("Du hast kein Label ausgewählt."),
                      content: Text(
                          "Willst du abbrechen oder es nochmal probieren?"),
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
              Navigator.pop(context, labelSet[selectedLabel]);
            }
            // write label to database
          }),
    );
  }
}

// taken from the item selector package example
Widget buildGridItem(BuildContext context, int index, bool selected) {
  if (selected) {
    selectedLabel = index;
  }
  return Card(
      margin: EdgeInsets.all(3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: selected ? Colors.green : Colors.white,
      elevation: selected ? 5 : 10,
      child: GridTile(
        child: Center(child: Text(labelSet[index])),
      ));
}

class GridViewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final selection = ItemSelection();
    return ItemSelectionController(
      selection: selection,
      selectionMode: ItemSelectionMode.single,
      child: GridView.count(
        childAspectRatio: 2.5,
        crossAxisCount: 4, // number of label in a row
        children: List.generate(labelSet.length, (int index) {
          return ItemSelectionBuilder(
            index: index,
            builder: buildGridItem,
          );
        }),
      ),
    );
  }
}
