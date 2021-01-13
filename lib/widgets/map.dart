import 'package:data_offloading_app/Screens/box_info.dart';
import 'package:data_offloading_app/logic/box_communicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import "package:latlong/latlong.dart" as latLng;
import 'package:user_location/user_location.dart';
import '../provider/poslist_state.dart';
import 'package:provider/provider.dart';

//MyMap class
class MyMap extends StatefulWidget {
  @override
  _MyMapState createState() => _MyMapState();
}

//MyMap state to keep track of the _boxes list
class _MyMapState extends State<MyMap> {
  MapController mapController = MapController();
  List<Marker> _boxes = [];
  UserLocationOptions userLocationOptions;
  latLng.LatLng pos;

  @override
  Widget build(BuildContext context) {
    userLocationOptions = UserLocationOptions(
      context: context,
      mapController: mapController,
      markers: _boxes,
      zoomToCurrentLocationOnLoad: true,
      showMoveToCurrentLocationFloatingActionButton: true,
      updateMapLocationOnPositionChange: false,
    );

    return new Scaffold(
      body: FlutterMap(
        options: MapOptions(
          center: new latLng.LatLng(49.8728, 8.6512),
          zoom: 13.0,
          plugins: [
            //to track user
            UserLocationPlugin(),
          ],
        ),
        layers: [
          TileLayerOptions(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c']),
          //add list of markers to map
          MarkerLayerOptions(markers: _boxes),
          userLocationOptions,
        ],
        mapController: mapController,
      ),
      //the standart Container is overwritten by the user_location package
      //the action button focuses the camera on the current position of the user
      floatingActionButton: Container(),
    );
  }

  //Wrapper function to build a Marker from the flutter_map package for a sensor box.
  //pass latitude and longitude as parameter
  Marker _buildBoxMarker(double lat, double long) {
    return Marker(
      width: 20.0,
      height: 20.0,
      point: new latLng.LatLng(lat, long),
      builder: (ctx) => Container(
        //GestureDetector to detect if marker is clicked
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: Icon(
            Icons.location_on,
            color: Colors.brown,
          ),
          onTap: () {
            //push the boxinfopage to the navigator
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => BoxInfo(1337, 7331)));
          },
        ),
      ),
    );
  }

  //used to initialize the _boxes List. In the real application the entries from the DB would be read at this point.
  @protected
  @mustCallSuper
  void initState() {
    super.initState();

    //context.read<PosListProvider>().awaitPositions();
    BoxCommunicator bC = new BoxCommunicator();
    bC.fetchPositions().then((value) {
      context.read<PosListProvider>().setPositions(value);
      int numOfBoxes = bC.numberOfBoxes;
      for (int box = 0; box < numOfBoxes; ++box) {
        _boxes.add(_buildBoxMarker(value[box].lat, value[box].long));
      }
    });
  }
}
