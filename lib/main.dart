import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asambleas de Dios',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 38, 3, 236)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Prototipo app'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Completer<GoogleMapController> _controller = Completer();
  bool _showSearchForm = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth >= 600;

        return Scaffold(
          key: _scaffoldKey,
          appBar: isDesktop ? null : _buildMobileAppBar(),
          body: Row(
            children: [
              if (isDesktop)
                Container(
                  width: 200,
                  color: Color.fromARGB(255, 2, 56, 174),
                  child: Column(
                    children: [
                      _buildDesktopMenuHeader(),
                      Expanded(
                        child: _buildDesktopMenu(context),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: Column(
                  children: [
                    if (isDesktop) _buildDesktopHeader(),
                    Expanded(
                      child: _showSearchForm
                          ? BuildMenu(
                              onBack: () {
                                setState(() {
                                  _showSearchForm = false;
                                });
                              },
                            )
                          : _buildMainContent(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          drawer: isDesktop
              ? null
              : Drawer(
                  child: _buildMobileMenu(context),
                  width: MediaQuery.of(context).size.width * 0.75,
                ),
        );
      },
    );
  }

  PreferredSizeWidget _buildMobileAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(110),
      child: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(255, 2, 56, 174),
        flexibleSpace: SafeArea(
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  iconSize: 80,
                  padding: EdgeInsets.all(10.0),
                  icon: Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),
                Expanded(
                  child: Container(),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Image.asset(
                    'assets/logo.png',
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopMenuHeader() {
    return Container(
      height: 100,
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'MENÚ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopHeader() {
    return Container(
      height: 100,
      color: Color.fromARGB(255, 2, 56, 174),
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Asambleas de Dios',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Image.asset(
            'assets/logo.png',
            height: 80,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopMenu(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        ListTile(
          leading: Icon(Icons.search, color: Colors.white),
          title: Text('Buscar Iglesia', style: TextStyle(color: Colors.white)),
          onTap: () {
            setState(() {
              _showSearchForm = true;
            });
          },
        ),
        // Otros elementos del menú para desktop...
      ],
    );
  }

  Widget _buildMobileMenu(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 2, 56, 174),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MENÚ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
        ListTile(
          leading: Icon(Icons.search),
          title: Text('Buscar Iglesia'),
          onTap: () {
            setState(() {
              _showSearchForm = true;
            });
            Navigator.pop(context);
          },
        ),
        // Otros elementos del menú para móvil...
      ],
    );
  }

  Widget _buildMainContent() {
    return Center(
      child: Text('Bienvenido a Asambleas de Dios'),
    );
  }

  Widget _buildChurchCard() {
    final LatLng churchLocation =
        LatLng(14.531549169574864, -90.58678918875388);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            'https://100noticias.com.ni/media/news/1321dfea429711ee829df929e97d2ea0.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                color: Colors.grey[300],
                child: Center(
                  child: Icon(Icons.error, color: Colors.red),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nombre: Nueva vida',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Ubicación: Ciudad de Guatemala'),
                Text('Pastor: Enrique Cardona Garcia'),
                SizedBox(height: 10),
                Container(
                  height: 200,
                  child: _buildGoogleMap(churchLocation),
                ),
                SizedBox(height: 10),
                Text('SERVICIOS',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                // Tabla de servicios...
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleMap(LatLng location) {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: location,
        zoom: 15,
      ),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      markers: {
        Marker(
          markerId: MarkerId('church'),
          position: location,
          infoWindow: InfoWindow(title: 'Nueva vida'),
        ),
      },
    );
  }
}

class BuildMenu extends StatelessWidget {
  final VoidCallback onBack;
  final Completer<GoogleMapController> _controller = Completer();

  BuildMenu({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth >= 600;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isDesktop)
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: onBack,
                      ),
                      Text('Búsqueda de Iglesia',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                if (isDesktop)
                  Text('Búsqueda de Iglesia',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Ingrese el nombre de la iglesia "Nueva Vida"',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.search),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  child: Text('Agregar +'),
                  onPressed: () {
                    // Implementar lógica para agregar iglesia
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 2, 56, 174),
                    foregroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                _buildChurchCard(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChurchCard() {
    final LatLng churchLocation =
        LatLng(14.531549169574864, -90.58678918875388);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            'https://100noticias.com.ni/media/news/1321dfea429711ee829df929e97d2ea0.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                color: Colors.grey[300],
                child: Center(
                  child: Icon(Icons.error, color: Colors.red),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nombre: Nueva vida',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Ubicación: Ciudad de Guatemala'),
                Text('Pastor: Enrique Cardona Garcia'),
                SizedBox(height: 10),
                Container(
                  height: 200,
                  child: _buildGoogleMap(churchLocation),
                ),
                SizedBox(height: 10),
                Text('SERVICIOS',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                // Tabla de servicios...
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleMap(LatLng location) {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: location,
        zoom: 15,
      ),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      markers: {
        Marker(
          markerId: MarkerId('church'),
          position: location,
          infoWindow: InfoWindow(title: 'Nueva vida'),
        ),
      },
    );
  }
}
