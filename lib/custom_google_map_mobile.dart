import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomGoogleMap extends StatelessWidget {
  final double lat;
  final double lng;

  const CustomGoogleMap({Key? key, required this.lat, required this.lng})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(lat, lng),
        zoom: 14.0,
      ),
      markers: {
        Marker(
          markerId: MarkerId('marker_1'),
          position: LatLng(lat, lng),
        ),
      },
    );
  }
}
