import 'package:flutter/material.dart';
import 'package:item_selector/item_selector.dart';

final labels = ["dachs", "fuchs", "reh", "idk", "sonstiges"];
int selectedLabel = -1;

class FotoLabelPage extends StatefulWidget {
  final Image img;
  const FotoLabelPage(this.img);
  @override
  _FotoLabelPageState createState() => _FotoLabelPageState();
}

class _FotoLabelPageState extends State<FotoLabelPage> {
  @override
  Widget build(BuildContext context) {
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
              child: Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(10),
            child: widget.img,
          )),
          Expanded(
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
            if (selectedLabel == -1) {
              showDialog(
                  context: context,
                  builder: (BuildContext buttonContext) {
                    List<String> str = [
                      "Du hast kein Label ausgewählt.",
                      "Willst du abbrechen oder es nochmal probieren?",
                      "Nochmal",
                      "Abbrechen"
                    ];
                    List<Widget> actions = [
                      FlatButton(
                          onPressed: () {
                            Navigator.of(buttonContext).pop();
                          },
                          child: Text(str[2])),
                      FlatButton(
                          onPressed: () {
                            Navigator.of(buttonContext).pop();
                            Navigator.of(context).pop();
                          },
                          child: Text(str[3])),
                    ];

                    return AlertDialog(
                      title: Text(str[0]),
                      content: Text(str[1]),
                      actions: actions,
                    );
                  });
            } else {
              Navigator.pop(context, selectedLabel);
            }
            // write label to database
          }),
    );
  }
}

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
        crossAxisCount: 4,
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
