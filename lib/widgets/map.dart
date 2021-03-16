import 'package:data_offloading_app/logic/known_wifi_dialog.dart';
import 'package:data_offloading_app/provider/box_connection_state.dart';

import '../provider/poslist_state.dart';
import 'package:data_offloading_app/logic/box_communicator.dart';

import 'package:flutter_map/flutter_map.dart';
import "package:latlong/latlong.dart" as latLng;
import 'package:user_location/user_location.dart';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

//MyMap class
class FMap extends StatefulWidget {
  @override
  _FMapState createState() => _FMapState();
}

//MyMap state to keep track of the _boxes list
class _FMapState extends State<FMap> {
  MapController mapController = MapController();
  List<Marker> _boxes = [];
  UserLocationOptions userLocationOptions;

  @override
  Widget build(BuildContext context) {
    BoxCommunicator().fetchPositions(context, this);
    BoxConnectionState boxConnectionState = context.watch<BoxConnectionState>();
    context.watch<PosListProvider>().posList.forEach((e) {
      _boxes.add(_buildBoxMarker(e.lat, e.long));
    });
    Connection _connection = boxConnectionState.connectionState;

    if (_connection == Connection.UNKNOWN_WIFI) {
      KnownWifiDialog.showAddWifiDialog(context, boxConnectionState);
    }

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
          zoom: 13.0,
          center: latLng.LatLng(50.8022, 8.7668),
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
      point: new latLng.LatLng(lat, long),
      builder: (ctx) => Icon(
        Icons.location_on,
        color: Colors.brown,
        size: 40,
      ),
    );
  }
}
