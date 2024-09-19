import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomGoogleMap extends StatelessWidget {
  final double lat;
  final double lng;

  const CustomGoogleMap({super.key, required this.lat, required this.lng});

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(lat, lng),
        zoom: 14.0,
      ),
      markers: {
        Marker(
          markerId: const MarkerId('marker_1'),
          position: LatLng(lat, lng),
        ),
      },
    );
  }
}
