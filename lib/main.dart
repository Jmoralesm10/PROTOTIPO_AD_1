import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

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
  bool _showPastorSearchForm = false;
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
                          : _showPastorSearchForm
                              ? BuildPastorSearchMenu(
                                  onBack: () {
                                    setState(() {
                                      _showPastorSearchForm = false;
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
                  iconSize: 70,
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
          leading: Icon(Icons.home, color: Colors.white),
          title: Text('Inicio', style: TextStyle(color: Colors.white)),
          onTap: () {
            setState(() {
              _showSearchForm = false;
              _showPastorSearchForm = false;
            });
          },
        ),
        ListTile(
          leading: Icon(Icons.search, color: Colors.white),
          title: Text('Buscar Iglesia', style: TextStyle(color: Colors.white)),
          onTap: () {
            setState(() {
              _showSearchForm = true;
              _showPastorSearchForm = false;
            });
          },
        ),
        ListTile(
          leading: Icon(Icons.person_search, color: Colors.white),
          title:
              Text('Búsqueda de Pastor', style: TextStyle(color: Colors.white)),
          onTap: () {
            setState(() {
              _showPastorSearchForm = true;
              _showSearchForm = false;
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
          leading: Icon(Icons.home),
          title: Text('Inicio'),
          onTap: () {
            setState(() {
              _showSearchForm = false;
              _showPastorSearchForm = false;
            });
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: Icon(Icons.search),
          title: Text('Buscar Iglesia'),
          onTap: () {
            setState(() {
              _showSearchForm = true;
              _showPastorSearchForm = false;
            });
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: Icon(Icons.person_search),
          title: Text('Búsqueda de Pastor'),
          onTap: () {
            setState(() {
              _showPastorSearchForm = true;
              _showSearchForm = false;
            });
            Navigator.pop(context);
          },
        ),
        // Otros elementos del menú para móvil...
      ],
    );
  }

  Widget _buildMainContent() {
    List<Anuncio> anuncios = [
      Anuncio(
        imagenPerfil: 'https://cdn-icons-png.flaticon.com/512/3135/3135768.png',
        nombre: 'Pastor Enrique Cardona Garcia',
        texto:
            'Invitación especial a nuestro servicio dominical en la Iglesia Nueva Vida.',
        archivo: 'https://example.com/invitacion.pdf',
        esImagen: false,
      ),
      Anuncio(
        imagenPerfil:
            'https://100noticias.com.ni/media/news/1321dfea429711ee829df929e97d2ea0.jpg',
        nombre: 'Iglesia Nueva Vida',
        texto: 'Nuevo estudio bíblico disponible: "Caminando en fe".',
        archivo: 'https://example.com/estudio_biblico.jpg',
        esImagen: true,
      ),
      Anuncio(
        imagenPerfil: 'https://cdn-icons-png.flaticon.com/512/3135/3135768.png',
        nombre: 'Pastor Juan Pérez',
        texto: 'Conferencia sobre liderazgo cristiano este sábado.',
        archivo: 'https://example.com/conferencia.pdf',
        esImagen: false,
      ),
      // Puedes añadir más anuncios aquí...
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Anuncios',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: () {
                  // Implementar lógica para agregar anuncio
                },
                child: Text('Agregar Anuncio'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 2, 56, 174),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: anuncios.length,
            itemBuilder: (context, index) {
              return AnuncioCard(anuncio: anuncios[index]);
            },
          ),
        ),
      ],
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

class BuildPastorSearchMenu extends StatefulWidget {
  final VoidCallback onBack;

  BuildPastorSearchMenu({required this.onBack});

  @override
  _BuildPastorSearchMenuState createState() => _BuildPastorSearchMenuState();
}

class _BuildPastorSearchMenuState extends State<BuildPastorSearchMenu> {
  bool showAddForm = false;

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
                        onPressed: showAddForm
                            ? () {
                                setState(() {
                                  showAddForm = false;
                                });
                              }
                            : widget.onBack,
                      ),
                      Text(
                        showAddForm
                            ? 'Agregar nuevo pastor'
                            : 'Búsqueda de Pastor',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                if (isDesktop)
                  Text(
                    showAddForm ? 'Agregar nuevo pastor' : 'Búsqueda de Pastor',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                SizedBox(height: 20),
                if (!showAddForm) ...[
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Ingrese el nombre del pastor',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.search),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          child: Text('Buscar', style: TextStyle(fontSize: 16)),
                          onPressed: () {
                            // Implementar lógica de búsqueda
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 2, 56, 174),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          child: Text('Agregar nuevo',
                              style: TextStyle(fontSize: 16)),
                          onPressed: () {
                            setState(() {
                              showAddForm = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 2, 56, 174),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  _buildPastorCard(isDesktop),
                ] else ...[
                  AddNewPastorForm(
                    onCancel: () {
                      setState(() {
                        showAddForm = false;
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPastorCard(bool isDesktop) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment:
              isDesktop ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipOval(
                child: FadeInImage.assetNetwork(
                  placeholder: 'assets/placeholder.png',
                  image:
                      'https://cdn-icons-png.flaticon.com/512/3135/3135768.png',
                  width: isDesktop ? 150 : 100,
                  height: isDesktop ? 150 : 100,
                  fit: BoxFit.cover,
                  imageErrorBuilder: (context, error, stackTrace) {
                    return CircleAvatar(
                      radius: isDesktop ? 75 : 50,
                      child: Icon(Icons.person,
                          size: isDesktop ? 75 : 50, color: Colors.white),
                      backgroundColor: Colors.grey,
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            _buildInfoRow('Nombre:', 'Enrique Cardona Garcia', isDesktop),
            _buildInfoRow('Edad:', '46', isDesktop),
            _buildInfoRow('Fecha de nacimiento:', '05/02/1978', isDesktop),
            _buildInfoRow('Nombre de la Iglesia:', 'Nueva vida', isDesktop),
            _buildInfoRow('Ubicación de la Iglesia:', 'Guastatoya, El Progreso',
                isDesktop),
            _buildInfoRow('Teléfono:', '37564265', isDesktop),
            _buildInfoRow('Correo:', 'enriquecardona@gmail.com', isDesktop),
            _buildInfoRow('Cargo actual:', 'Pastor', isDesktop),
            _buildInfoRow(
                'Fecha de inicio del cargo:', '03/11/2020', isDesktop),
            _buildInfoRow('Estudió en instituto bíblico:', 'Si', isDesktop),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDesktop) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: isDesktop
          ? Column(
              children: [
                Text(
                  label,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 2, 56, 174),
                      fontSize: 20),
                ),
                SizedBox(height: 4),
                Text(value, style: TextStyle(fontSize: 18)),
                SizedBox(height: 10),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 150,
                  child: Text(
                    label,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 2, 56, 174)),
                  ),
                ),
                Expanded(
                  child: Text(value),
                ),
              ],
            ),
    );
  }
}

class AddNewPastorForm extends StatefulWidget {
  final VoidCallback onCancel;

  AddNewPastorForm({required this.onCancel});

  @override
  _AddNewPastorFormState createState() => _AddNewPastorFormState();
}

class _AddNewPastorFormState extends State<AddNewPastorForm> {
  final _formKey = GlobalKey<FormState>();
  DateTime? fechaNacimiento;
  DateTime? fechaInicioCargo;
  String? iglesiaSelecionada;
  String? cargoSeleccionado;
  String? estudioBiblico;

  final List<String> iglesias = [
    'Iglesia A',
    'Iglesia B',
    'Iglesia C',
    'Iglesia D'
  ];
  final List<String> cargos = [
    'Pastor',
    'Diácono',
    'Anciano',
    'Evangelista',
    'Maestro'
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth >= 600;
        double fontSize = isDesktop ? 18 : 16;
        double spacing = isDesktop ? 20 : 20;

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isDesktop)
                Column(
                  children: [
                    _buildNameFields(fontSize, spacing),
                    SizedBox(height: spacing),
                    _buildPersonalInfoDesktop(fontSize, spacing),
                    SizedBox(height: spacing),
                    _buildChurchInfoDesktop(fontSize, spacing),
                  ],
                )
              else
                Column(
                  children: [
                    _buildPersonalInfo(fontSize, spacing, isDesktop),
                    SizedBox(height: spacing),
                    _buildChurchInfo(fontSize, spacing),
                  ],
                ),
              SizedBox(height: spacing),
              _buildButtons(fontSize),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNameFields(double fontSize, double spacing) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildInputField(
              'Primer nombre',
              (value) => value!.isEmpty ? 'Ingrese el primer nombre' : null,
              fontSize),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: _buildInputField('Segundo nombre', null, fontSize),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: _buildInputField(
              'Primer apellido',
              (value) => value!.isEmpty ? 'Ingrese el primer apellido' : null,
              fontSize),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: _buildInputField('Segundo apellido', null, fontSize),
        ),
      ],
    );
  }

  Widget _buildPersonalInfo(double fontSize, double spacing, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isDesktop) ...[
          _buildInputField(
              'Primer nombre',
              (value) => value!.isEmpty ? 'Ingrese el primer nombre' : null,
              fontSize),
          SizedBox(height: spacing),
          _buildInputField('Segundo nombre', null, fontSize),
          SizedBox(height: spacing),
          _buildInputField(
              'Primer apellido',
              (value) => value!.isEmpty ? 'Ingrese el primer apellido' : null,
              fontSize),
          SizedBox(height: spacing),
          _buildInputField('Segundo apellido', null, fontSize),
          SizedBox(height: spacing),
        ],
        _buildInputField('DPI',
            (value) => value!.isEmpty ? 'Ingrese el DPI' : null, fontSize,
            isNumeric: true, maxLength: 13),
        SizedBox(height: spacing),
        _buildDatePicker('Fecha de nacimiento', fechaNacimiento,
            (date) => setState(() => fechaNacimiento = date), fontSize),
      ],
    );
  }

  Widget _buildPersonalInfoDesktop(double fontSize, double spacing) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildInputField('DPI',
              (value) => value!.isEmpty ? 'Ingrese el DPI' : null, fontSize,
              isNumeric: true, maxLength: 13),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: _buildDatePicker('Fecha de nacimiento', fechaNacimiento,
              (date) => setState(() => fechaNacimiento = date), fontSize),
        ),
      ],
    );
  }

  Widget _buildChurchInfo(double fontSize, double spacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown('Nombre de la Iglesia', iglesias, iglesiaSelecionada,
            (value) => setState(() => iglesiaSelecionada = value), fontSize),
        SizedBox(height: spacing),
        _buildInputField(
            'Ubicación de la Iglesia',
            (value) => value!.isEmpty ? 'Ingrese la ubicación' : null,
            fontSize),
        SizedBox(height: spacing),
        _buildInputField('Teléfono',
            (value) => value!.isEmpty ? 'Ingrese el teléfono' : null, fontSize,
            isNumeric: true, maxLength: 20),
        SizedBox(height: spacing),
        _buildInputField('Correo', (value) {
          if (value!.isEmpty) return 'Ingrese el correo';
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value))
            return 'Ingrese un correo válido';
          return null;
        }, fontSize, isEmail: true, maxLength: 100),
        SizedBox(height: spacing),
        _buildDropdown('Cargo actual', cargos, cargoSeleccionado,
            (value) => setState(() => cargoSeleccionado = value), fontSize),
        SizedBox(height: spacing),
        _buildDatePicker('Fecha de inicio del cargo', fechaInicioCargo,
            (date) => setState(() => fechaInicioCargo = date), fontSize),
        SizedBox(height: spacing),
        _buildDropdown(
            'Estudió en instituto bíblico',
            ['SI', 'NO'],
            estudioBiblico,
            (value) => setState(() => estudioBiblico = value),
            fontSize),
      ],
    );
  }

  Widget _buildChurchInfoDesktop(double fontSize, double spacing) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildDropdown(
                  'Nombre de la Iglesia',
                  iglesias,
                  iglesiaSelecionada,
                  (value) => setState(() => iglesiaSelecionada = value),
                  fontSize),
            ),
            SizedBox(width: spacing),
            Expanded(
              child: _buildInputField(
                  'Ubicación de la Iglesia',
                  (value) => value!.isEmpty ? 'Ingrese la ubicación' : null,
                  fontSize),
            ),
          ],
        ),
        SizedBox(height: spacing),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildInputField(
                  'Teléfono',
                  (value) => value!.isEmpty ? 'Ingrese el teléfono' : null,
                  fontSize,
                  isNumeric: true,
                  maxLength: 20),
            ),
            SizedBox(width: spacing),
            Expanded(
              child: _buildInputField('Correo', (value) {
                if (value!.isEmpty) return 'Ingrese el correo';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) return 'Ingrese un correo válido';
                return null;
              }, fontSize, isEmail: true, maxLength: 100),
            ),
          ],
        ),
        SizedBox(height: spacing),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildDropdown(
                  'Cargo actual',
                  cargos,
                  cargoSeleccionado,
                  (value) => setState(() => cargoSeleccionado = value),
                  fontSize),
            ),
            SizedBox(width: spacing),
            Expanded(
              child: _buildDatePicker(
                  'Fecha de inicio del cargo',
                  fechaInicioCargo,
                  (date) => setState(() => fechaInicioCargo = date),
                  fontSize),
            ),
          ],
        ),
        SizedBox(height: spacing),
        _buildDropdown(
            'Estudió en instituto bíblico',
            ['SI', 'NO'],
            estudioBiblico,
            (value) => setState(() => estudioBiblico = value),
            fontSize),
      ],
    );
  }

  Widget _buildButtons(double fontSize) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            child: Text('Guardar', style: TextStyle(fontSize: fontSize)),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Implementar lógica para guardar el nuevo pastor
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 2, 56, 174),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            child: Text('Cancelar', style: TextStyle(fontSize: fontSize)),
            onPressed: widget.onCancel,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(
      String label, String? Function(String?)? validator, double fontSize,
      {bool isNumeric = false, bool isEmail = false, int? maxLength}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        TextFormField(
          decoration: InputDecoration(border: OutlineInputBorder()),
          validator: validator,
          keyboardType: isNumeric
              ? TextInputType.number
              : (isEmail ? TextInputType.emailAddress : TextInputType.text),
          inputFormatters: [
            if (isNumeric) FilteringTextInputFormatter.digitsOnly,
            if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value,
      void Function(String?) onChanged, double fontSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(border: OutlineInputBorder()),
          value: value,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (value) =>
              value == null ? 'Por favor seleccione una opción' : null,
        ),
      ],
    );
  }

  Widget _buildDatePicker(String label, DateTime? date,
      void Function(DateTime) onDateSelected, double fontSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null && picked != date) {
              onDateSelected(picked);
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(border: OutlineInputBorder()),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(date == null
                    ? 'Seleccionar fecha'
                    : DateFormat('dd/MM/yyyy').format(date)),
                Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class Anuncio {
  final String imagenPerfil;
  final String nombre;
  final String texto;
  final String archivo;
  final bool esImagen;

  Anuncio({
    required this.imagenPerfil,
    required this.nombre,
    required this.texto,
    required this.archivo,
    required this.esImagen,
  });
}

class AnuncioCard extends StatelessWidget {
  final Anuncio anuncio;

  AnuncioCard({required this.anuncio});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(anuncio.imagenPerfil),
                  radius: 30,
                ),
                SizedBox(width: 16),
                Text(
                  anuncio.nombre,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(anuncio.texto),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text(anuncio.esImagen ? 'Ver imagen' : 'Ver PDF'),
              onPressed: () async {
                if (await canLaunch(anuncio.archivo)) {
                  await launch(anuncio.archivo);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No se pudo abrir el archivo')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
