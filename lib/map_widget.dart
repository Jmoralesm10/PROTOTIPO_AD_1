import 'package:flutter/material.dart';

import 'custom_google_map_mobile.dart'
    if (dart.library.html) 'custom_google_map.dart';

class MapWidget extends StatelessWidget {
  final double lat;
  final double lng;

  const MapWidget({super.key, required this.lat, required this.lng});

  @override
  Widget build(BuildContext context) {
    return CustomGoogleMap(lat: lat, lng: lng);
  }
}
