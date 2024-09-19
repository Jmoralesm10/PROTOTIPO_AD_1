import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:ui_web' as ui_web;

class CustomGoogleMap extends StatelessWidget {
  final double lat;
  final double lng;

  const CustomGoogleMap({Key? key, required this.lat, required this.lng})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String viewType = 'google-map-${UniqueKey().toString()}';

    print('Registrando factory para el mapa');
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      print('Creando elemento del mapa');
      final elem = html.DivElement()
        ..id = viewType
        ..style.width = '100%'
        ..style.height = '100%';

      print('Solicitando frame de animación');
      html.window.requestAnimationFrame((_) {
        print('Llamando a initMap');
        js.context.callMethod('initMap', [elem, lat, lng]);
      });

      return elem;
    });

    return HtmlElementView(viewType: viewType);
  }
}
