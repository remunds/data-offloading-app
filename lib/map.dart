import 'package:data_offloading_app/boxinfopage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import "package:latlong/latlong.dart" as latLng;
import 'package:user_location/user_location.dart';

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

  @override
  Widget build(BuildContext context) {
    userLocationOptions = UserLocationOptions(
      context: context,
      mapController: mapController,
      markers: _boxes,
<<<<<<< HEAD
      zoomToCurrentLocationOnLoad: true,
      showMoveToCurrentLocationFloatingActionButton: true,
      updateMapLocationOnPositionChange: false,
=======
      zoomToCurrentLocationOnLoad: false,
      showMoveToCurrentLocationFloatingActionButton: false,
      updateMapLocationOnPositionChange: true,
>>>>>>> b0aaf01 (removed unecessary widget from map)
    );
    return new Scaffold(
      body: FlutterMap(
        options: new MapOptions(
          center: new latLng.LatLng(50.8022, 8.7668),
          zoom: 13.0,
          plugins: [
            //to track user
            UserLocationPlugin(),
          ],
        ),
        layers: [
          new TileLayerOptions(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c']),
          //add list of markers to map
          new MarkerLayerOptions(markers: _boxes),
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
    return new Marker(
      width: 20.0,
      height: 20.0,
      point: new latLng.LatLng(lat, long),
      builder: (ctx) => Container(
        //GestureDetector to detect if marker is clicked
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: new Icon(
            Icons.location_on,
            color: Colors.brown,
          ),
          onTap: () {
            //push the boxinfopage to the navigator
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => BoxInfoPage(1337, 7331)));
          },
        ),
      ),
    );
  }

  //used to initialize the _boxes List. In the real application the entries from the DB would be read at this point.
  @protected
  @mustCallSuper
  void initState() {
    _boxes.add(_buildBoxMarker(50.8050, 8.7669));
    _boxes.add(_buildBoxMarker(50.8160, 8.7669));
    _boxes.add(_buildBoxMarker(50.8080, 8.7769));
    _boxes.add(_buildBoxMarker(50.8280, 8.7769));
    _boxes.add(_buildBoxMarker(50.8080, 8.7869));
  }
}
