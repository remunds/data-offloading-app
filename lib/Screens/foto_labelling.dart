import 'package:flutter/material.dart';
import 'package:item_selector/item_selector.dart';

final labels = ["dachs", "fuchs", "reh", "idk", "sonstiges"];
int selectedLabel = -1;

class FotoLabelPage extends StatefulWidget {
  // TODO: a label set should probably passed as well
  // TODO: so that user and box images have different label sets
  final Image img;
  const FotoLabelPage(this.img);
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
      body: Center(
          child: Column(
        children: [
          Expanded(
              // here goes the image
              child: Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(10),
            child: widget.img,
          )),
          Expanded(
            // here goes the label selection
            child: AnimatedSwitcher(
                duration: Duration(milliseconds: 246),
                child: Container(
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.all(10),
                  child: GridViewPage(),
                )),
          ),
        ],
      )),
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
              // go back to taks page and return the selected label
              Navigator.pop(context, labels[selectedLabel]);
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
        child: Center(child: Text(labels[index])),
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
        children: List.generate(labels.length, (int index) {
          return ItemSelectionBuilder(
            index: index,
            builder: buildGridItem,
          );
        }),
      ),
    );
  }
}
