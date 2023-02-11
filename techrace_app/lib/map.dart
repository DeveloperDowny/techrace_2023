import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:techrace/client/location.dart';
import 'utils/mapstyle.dart';

import 'package:geolocator/geolocator.dart';

//gmap controller
Completer<GoogleMapController> _controller = Completer();

//updates location to be centered on screen if isTracking is true
StreamSubscription<Position> positionStream =
    Geolocator.getPositionStream().listen(
  onError: (error) {
    print("Error: $error");
  },
  (Position position) async {
    // Handle position changes
    final GoogleMapController controller = await _controller.future;
    // debugPrint("animateCamera");
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            position.latitude,
            position.longitude,
          ),
          zoom: 17,
        ),
      ),
    );
    // distanceBetween(position.latitude, position.longitude);
  },
);
//updates location to be centered on screen if isTracking is true

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => MapWidgetState();
}

//late Marker mapMarker;
Set<Marker> mapMarker = <Marker>{};

class MapWidgetState extends State<MapWidget> {
  //map variables
  // double mapTopPadding = 0;

  static const LatLng source = LatLng(19.123188, 72.836062);
  //static const LatLng destination = LatLng(19.240522, 72.869566);
  void markersFromStorage() {
    final box = GetStorage();
    Map markers = box.read('markers_stored') ?? {};
    markers.forEach((key, value) {
      addMarker(
          "Clue #$key", double.parse(value['lat'].toString()), double.parse(value['lng'].toString()), false);
      // print('Marker key: $key, value: $value, lat: ${value["lat"]}, long: ${value["lng"]}');
    });
  }

  void addMarker(String title, double lat, double lng, bool state) {
    Marker marker = Marker(
      infoWindow: InfoWindow(
        title: title,
      ),
      markerId: MarkerId(title),
      position: LatLng(lat, lng),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueGreen,
      ),
    );
    if (state) {
      setState(() {
        mapMarker.add(marker);
      });
    } else {
      mapMarker.add(marker);
    }
  }

  //late Marker marker;
  @override
  void initState() {
    super.initState();
    //add all markers for positions that the user has already visited
    Marker marker = Marker(
      infoWindow: const InfoWindow(
        title: 'SPIT',
      ),
      markerId: const MarkerId('SPIT'),
      position: source,
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueRed,
      ),
    );
    mapMarker.add(marker);
    markersFromStorage();
  }

  @override
  void dispose() {
    positionStream.cancel();
    _controller = Completer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      markers: mapMarker,
      mapToolbarEnabled: false,
      myLocationEnabled: true,
      compassEnabled: false,
      myLocationButtonEnabled: false,
      onMapCreated: (controller) {
        // newMapController = controller;
        _controller.complete(controller);
        controller.setMapStyle(
          mapStyleDark,
        );
        // setState(() {
        //   mapTopPadding = 30;
        // });
        Future.delayed(
          const Duration(seconds: 1),
          () async {
            await controller.animateCamera(
              CameraUpdate.newCameraPosition(
                const CameraPosition(
                  target: LatLng(19.123089, 72.836084),
                  zoom: 12,
                  tilt: 30,
                  // bearing: 90,
                ),
              ),
            );
          },
        );
      },
      trafficEnabled: true,
      zoomControlsEnabled: false,
      mapType: MapType.normal,
      initialCameraPosition: const CameraPosition(
        target: source,
        zoom: 9.25,
        // bearing: -25,
      ),
    );
  }
}
//test function to add markers

void currentLocation() async {
  final GoogleMapController controller = await _controller.future;
  try {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 16.13,
          tilt: 30,
          bearing: 90,
        ),
      ),
    );
  } catch (e) {
    //print("tedErr: $e");
    // showAboutDialog(context: context);

  }
}
