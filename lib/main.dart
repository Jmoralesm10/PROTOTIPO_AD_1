import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'login_page.dart'; // Importa el nuevo archivo

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
      home: LoginPage(), // Usa LoginPage como la página inicial
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
        _buildNewAnnouncementButton(),
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

  Widget _buildNewAnnouncementButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        icon: Icon(Icons.add),
        label: Text('Agregar anuncio'),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: SingleChildScrollView(
                  child: _buildNewAnnouncementForm(),
                ),
              );
            },
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 2, 56, 174),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildNewAnnouncementForm() {
    final TextEditingController _textController = TextEditingController();
    File? _selectedImage;
    File? _selectedPdf;

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nueva publicación',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _textController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Escribe la descripción del anuncio...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.image, color: Colors.blue),
                    label: Text('Agregar imagen',
                        style: TextStyle(color: Colors.blue)),
                    onPressed: () async {
                      final pickedFile = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        setState(() {
                          _selectedImage = File(pickedFile.path);
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.blue),
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.picture_as_pdf, color: Colors.blue),
                    label: Text('Agregar PDF',
                        style: TextStyle(color: Colors.blue)),
                    onPressed: () async {
                      // Implementar lógica para seleccionar PDF
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Funcionalidad de agregar PDF no implementada')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.blue),
                    ),
                  ),
                ],
              ),
              if (_selectedImage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Image.file(_selectedImage!, height: 100),
                ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      child: Text('Publicar anuncio'),
                      onPressed: () {
                        // Implementar lógica para publicar el anuncio
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Anuncio publicado (simulado)')),
                        );
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      child: Text('Cancelar'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class BuildMenu extends StatefulWidget {
  final VoidCallback onBack;

  BuildMenu({required this.onBack});

  @override
  _BuildMenuState createState() => _BuildMenuState();
}

class _BuildMenuState extends State<BuildMenu> {
  final Completer<GoogleMapController> _controller = Completer();
  bool showAddForm = false;
  File? _image;
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos del formulario
  final _nombreIglesiaController = TextEditingController();
  final _nombrePastorController = TextEditingController();
  final _latitudController = TextEditingController();
  final _longitudController = TextEditingController();
  final _facebookController = TextEditingController();
  final _instagramController = TextEditingController();
  final _sitioWebController = TextEditingController();

  // Mapa para almacenar los horarios de servicios
  Map<String, List<TimeOfDay>> horarios = {
    'Lunes': [],
    'Martes': [],
    'Miércoles': [],
    'Jueves': [],
    'Viernes': []
  };

  Future getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

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
                            ? 'Agregar nueva iglesia'
                            : 'Búsqueda de Iglesia',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                if (isDesktop)
                  Text(
                    showAddForm
                        ? 'Agregar nueva iglesia'
                        : 'Búsqueda de Iglesia',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                SizedBox(height: 20),
                if (!showAddForm) ...[
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Ingrese el nombre de la iglesia',
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
                          child: Text('Agregar nueva',
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
                  _buildChurchCard(),
                ] else ...[
                  _buildAddChurchForm(isDesktop),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddChurchForm(bool isDesktop) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: GestureDetector(
              onTap: getImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _image != null ? FileImage(_image!) : null,
                child:
                    _image == null ? Icon(Icons.add_a_photo, size: 50) : null,
              ),
            ),
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: _nombreIglesiaController,
            decoration: InputDecoration(labelText: 'Nombre de la Iglesia'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese el nombre de la iglesia';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _nombrePastorController,
            decoration: InputDecoration(labelText: 'Nombre del Pastor'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese el nombre del pastor';
              }
              return null;
            },
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _latitudController,
                  decoration: InputDecoration(labelText: 'Latitud'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese la latitud';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _longitudController,
                  decoration: InputDecoration(labelText: 'Longitud'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese la longitud';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text('Horarios de Servicios',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ..._buildServiceSchedules(),
          SizedBox(height: 20),
          Text('Redes Sociales',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          TextFormField(
            controller: _facebookController,
            decoration: InputDecoration(labelText: 'Facebook'),
          ),
          TextFormField(
            controller: _instagramController,
            decoration: InputDecoration(labelText: 'Instagram'),
          ),
          TextFormField(
            controller: _sitioWebController,
            decoration: InputDecoration(labelText: 'Sitio Web'),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  child: Text('Guardar', style: TextStyle(fontSize: 16)),
                  onPressed: _submitForm,
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
                  child: Text('Cancelar', style: TextStyle(fontSize: 16)),
                  onPressed: () {
                    setState(() {
                      showAddForm = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildServiceSchedules() {
    return horarios.entries.map((entry) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(entry.key, style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              ElevatedButton(
                child: Text('Agregar Horario'),
                onPressed: () => _selectTime(entry.key),
              ),
              ...entry.value
                  .map((time) => Chip(
                        label: Text('${time.format(context)}'),
                        onDeleted: () => _removeTime(entry.key, time),
                      ))
                  .toList(),
            ],
          ),
        ],
      );
    }).toList();
  }

  void _selectTime(String day) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && !horarios[day]!.contains(picked)) {
      setState(() {
        horarios[day]!.add(picked);
      });
    }
  }

  void _removeTime(String day, TimeOfDay time) {
    setState(() {
      horarios[day]!.remove(time);
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Aquí iría la lógica para guardar los datos de la iglesia
      print('Formulario válido, datos listos para ser guardados');
      // Después de guardar, volvemos a la vista de búsqueda
      setState(() {
        showAddForm = false;
      });
    }
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
            height: 200,
            width: double.infinity,
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nombre de la Iglesia: Nueva vida',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text('Pastor: Enrique Cardona Garcia',
                    style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                Text('Ubicación: Ciudad de Guatemala',
                    style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                Text('Coordenadas:',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Latitud: ${churchLocation.latitude}'),
                Text('Longitud: ${churchLocation.longitude}'),
                SizedBox(height: 20),
                Text('Mapa:',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Container(
                  height: 200,
                  child: _buildGoogleMap(churchLocation),
                ),
                SizedBox(height: 20),
                Text('Horarios de Servicios:',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                _buildServiceScheduleTable(),
                SizedBox(height: 20),
                Text('Redes Sociales:',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                _buildSocialMediaLinks(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceScheduleTable() {
    final Map<String, List<String>> horarios = {
      'Lunes': ['19:00'],
      'Martes': [],
      'Miércoles': ['19:00'],
      'Jueves': [],
      'Viernes': ['19:00'],
    };

    return Table(
      border: TableBorder.all(),
      children: horarios.entries.map((entry) {
        return TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(entry.key,
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(entry.value.isEmpty
                  ? 'No hay servicios'
                  : entry.value.join(', ')),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSocialMediaLinks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          child: Text('Facebook: facebook.com/nuevavida',
              style: TextStyle(
                  color: Colors.blue, decoration: TextDecoration.underline)),
          onTap: () => launchUrl(Uri.parse('https://facebook.com/nuevavida')),
        ),
        InkWell(
          child: Text('Instagram: @nuevavida',
              style: TextStyle(
                  color: Colors.blue, decoration: TextDecoration.underline)),
          onTap: () => launchUrl(Uri.parse('https://instagram.com/nuevavida')),
        ),
        InkWell(
          child: Text('Sitio Web: www.nuevavida.org',
              style: TextStyle(
                  color: Colors.blue, decoration: TextDecoration.underline)),
          onTap: () => launchUrl(Uri.parse('https://www.nuevavida.org')),
        ),
      ],
    );
  }

  Widget _buildGoogleMap(LatLng location) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: location,
        zoom: 15,
      ),
      markers: {
        Marker(
          markerId: MarkerId('church'),
          position: location,
        ),
      },
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
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
  final Completer<GoogleMapController> _controller = Completer();
  bool showAddForm = false;
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos del formulario
  final _nombrePastorController = TextEditingController();
  final _nombreIglesiaController = TextEditingController();
  final _latitudController = TextEditingController();
  final _longitudController = TextEditingController();
  final _facebookController = TextEditingController();
  final _instagramController = TextEditingController();
  final _sitioWebController = TextEditingController();

  // Mapa para almacenar los horarios de servicios
  Map<String, List<TimeOfDay>> horarios = {
    'Lunes': [],
    'Martes': [],
    'Miércoles': [],
    'Jueves': [],
    'Viernes': []
  };

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
                  _buildPastorCard(),
                ] else ...[
                  _buildAddPastorForm(isDesktop),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddPastorForm(bool isDesktop) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _nombrePastorController,
            decoration: InputDecoration(labelText: 'Nombre del Pastor'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese el nombre del pastor';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _nombreIglesiaController,
            decoration: InputDecoration(labelText: 'Nombre de la Iglesia'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese el nombre de la iglesia';
              }
              return null;
            },
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _latitudController,
                  decoration: InputDecoration(labelText: 'Latitud'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese la latitud';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _longitudController,
                  decoration: InputDecoration(labelText: 'Longitud'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese la longitud';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text('Horarios de Servicios',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ..._buildServiceSchedules(),
          SizedBox(height: 20),
          Text('Redes Sociales',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          TextFormField(
            controller: _facebookController,
            decoration: InputDecoration(labelText: 'Facebook'),
          ),
          TextFormField(
            controller: _instagramController,
            decoration: InputDecoration(labelText: 'Instagram'),
          ),
          TextFormField(
            controller: _sitioWebController,
            decoration: InputDecoration(labelText: 'Sitio Web'),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  child: Text('Guardar', style: TextStyle(fontSize: 16)),
                  onPressed: _submitForm,
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
                  child: Text('Cancelar', style: TextStyle(fontSize: 16)),
                  onPressed: () {
                    setState(() {
                      showAddForm = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildServiceSchedules() {
    return horarios.entries.map((entry) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(entry.key, style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              ElevatedButton(
                child: Text('Agregar Horario'),
                onPressed: () => _selectTime(entry.key),
              ),
              ...entry.value
                  .map((time) => Chip(
                        label: Text('${time.format(context)}'),
                        onDeleted: () => _removeTime(entry.key, time),
                      ))
                  .toList(),
            ],
          ),
        ],
      );
    }).toList();
  }

  void _selectTime(String day) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && !horarios[day]!.contains(picked)) {
      setState(() {
        horarios[day]!.add(picked);
      });
    }
  }

  void _removeTime(String day, TimeOfDay time) {
    setState(() {
      horarios[day]!.remove(time);
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Aquí iría la lógica para guardar los datos del pastor
      print('Formulario válido, datos listos para ser guardados');
      // Después de guardar, volvemos a la vista de búsqueda
      setState(() {
        showAddForm = false;
      });
    }
  }

  Widget _buildPastorCard() {
    final LatLng pastorLocation =
        LatLng(14.531549169574864, -90.58678918875388);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            'https://100noticias.com.ni/media/news/1321dfea429711ee829df929e97d2ea0.jpg',
            fit: BoxFit.cover,
            height: 200,
            width: double.infinity,
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nombre del Pastor: Juan Pérez',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text('Iglesia: Iglesia Nueva Vida',
                    style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                Text('Ubicación: Ciudad de Guatemala',
                    style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                Text('Coordenadas:',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Latitud: ${pastorLocation.latitude}'),
                Text('Longitud: ${pastorLocation.longitude}'),
                SizedBox(height: 20),
                Text('Mapa:',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Container(
                  height: 200,
                  child: _buildGoogleMap(pastorLocation),
                ),
                SizedBox(height: 20),
                Text('Horarios de Servicios:',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                _buildServiceScheduleTable(),
                SizedBox(height: 20),
                Text('Redes Sociales:',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                _buildSocialMediaLinks(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceScheduleTable() {
    final Map<String, List<String>> horarios = {
      'Lunes': ['19:00'],
      'Martes': [],
      'Miércoles': ['19:00'],
      'Jueves': [],
      'Viernes': ['19:00'],
    };

    return Table(
      border: TableBorder.all(),
      children: horarios.entries.map((entry) {
        return TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(entry.key,
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(entry.value.isEmpty
                  ? 'No hay servicios'
                  : entry.value.join(', ')),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSocialMediaLinks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          child: Text('Facebook: facebook.com/nuevavida',
              style: TextStyle(
                  color: Colors.blue, decoration: TextDecoration.underline)),
          onTap: () => launchUrl(Uri.parse('https://facebook.com/nuevavida')),
        ),
        InkWell(
          child: Text('Instagram: @nuevavida',
              style: TextStyle(
                  color: Colors.blue, decoration: TextDecoration.underline)),
          onTap: () => launchUrl(Uri.parse('https://instagram.com/nuevavida')),
        ),
        InkWell(
          child: Text('Sitio Web: www.nuevavida.org',
              style: TextStyle(
                  color: Colors.blue, decoration: TextDecoration.underline)),
          onTap: () => launchUrl(Uri.parse('https://www.nuevavida.org')),
        ),
      ],
    );
  }

  Widget _buildGoogleMap(LatLng location) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: location,
        zoom: 15,
      ),
      markers: {
        Marker(
          markerId: MarkerId('pastor'),
          position: location,
        ),
      },
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
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
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(anuncio.imagenPerfil),
                ),
                SizedBox(width: 16),
                Text(
                  anuncio.nombre,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(anuncio.texto),
            SizedBox(height: 16),
            if (anuncio.esImagen)
              Image.network(
                anuncio.archivo,
                fit: BoxFit.cover,
                height: 200,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: Center(
                      child: Icon(Icons.error, color: Colors.red),
                    ),
                  );
                },
              )
            else
              InkWell(
                child: Text(
                  anuncio.archivo,
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
                onTap: () => launchUrl(Uri.parse(anuncio.archivo)),
              ),
          ],
        ),
      ),
    );
  }
}
