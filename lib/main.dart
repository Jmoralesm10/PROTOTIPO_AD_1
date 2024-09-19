import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'login_page.dart'; // Importa el nuevo archivo
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'platform_file.dart';
import 'package:http_parser/http_parser.dart';
import 'map_widget.dart';

// Importación condicional
import 'web_image_picker.dart' if (dart.library.io) 'mobile_image_picker.dart'
    as image_picker;

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
        colorScheme: ColorScheme.fromSeed(
            seedColor:
                const Color.fromARGB(255, 2, 56, 174)), // Cambiado el color
        useMaterial3: true,
      ),
      home:
          const LoginPage(), // Asegúrate de que LoginPage esté correctamente implementado
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
  //final Completer<GoogleMapController> _controller = Completer();
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
                  color: const Color.fromARGB(255, 2, 56, 174),
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
                  width: MediaQuery.of(context).size.width * 0.75,
                  child: _buildMobileMenu(context),
                ),
        );
      },
    );
  }

  PreferredSizeWidget _buildMobileAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(110),
      child: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 2, 56, 174),
        flexibleSpace: SafeArea(
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  iconSize: 70,
                  padding: const EdgeInsets.all(10.0),
                  icon: const Icon(Icons.menu, color: Colors.white),
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
      padding: const EdgeInsets.all(16),
      child: const Row(
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
      color: const Color.fromARGB(255, 2, 56, 174),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
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
          leading: const Icon(Icons.home, color: Colors.white),
          title: const Text('Inicio', style: TextStyle(color: Colors.white)),
          onTap: () {
            setState(() {
              _showSearchForm = false;
              _showPastorSearchForm = false;
            });
          },
        ),
        ListTile(
          leading: const Icon(Icons.search, color: Colors.white),
          title: const Text('Buscar Iglesia',
              style: TextStyle(color: Colors.white)),
          onTap: () {
            setState(() {
              _showSearchForm = true;
              _showPastorSearchForm = false;
            });
          },
        ),
        ListTile(
          leading: const Icon(Icons.person_search, color: Colors.white),
          title: const Text('Búsqueda de Pastor',
              style: TextStyle(color: Colors.white)),
          onTap: () {
            setState(() {
              _showPastorSearchForm = true;
              _showSearchForm = false;
            });
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.white),
          title: const Text('Cerrar sesión',
              style: TextStyle(color: Colors.white)),
          onTap: () {
            // Llamar al método para cerrar sesión
            _cerrarSesion();
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
        const DrawerHeader(
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
          leading: const Icon(Icons.home),
          title: const Text('Inicio'),
          onTap: () {
            setState(() {
              _showSearchForm = false;
              _showPastorSearchForm = false;
            });
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.search),
          title: const Text('Buscar Iglesia'),
          onTap: () {
            setState(() {
              _showSearchForm = true;
              _showPastorSearchForm = false;
            });
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.person_search),
          title: const Text('Búsqueda de Pastor'),
          onTap: () {
            setState(() {
              _showPastorSearchForm = true;
              _showSearchForm = false;
            });
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.exit_to_app),
          title: const Text('Cerrar sesión'),
          onTap: () {
            Navigator.pop(context);
            _cerrarSesion();
          },
        ),
        // Otros elementos del menú para móvil...
      ],
    );
  }

  void _cerrarSesion() {
    // Aquí puedes agregar lógica adicional si es necesario, como limpiar datos de usuario, etc.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
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
        icon: const Icon(Icons.add),
        label: const Text('Agregar anuncio'),
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
          backgroundColor: const Color.fromARGB(255, 2, 56, 174),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildNewAnnouncementForm() {
    final TextEditingController textController = TextEditingController();
    File? selectedImage;
    //File? selectedPdf;

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nueva publicación',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Escribe la descripción del anuncio...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.image, color: Colors.blue),
                    label: const Text('Agregar imagen',
                        style: TextStyle(color: Colors.blue)),
                    onPressed: () async {
                      final pickedFile = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        setState(() {
                          selectedImage = File(pickedFile.path);
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.blue),
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.blue),
                    label: const Text('Agregar PDF',
                        style: TextStyle(color: Colors.blue)),
                    onPressed: () async {
                      // Implementar lógica para seleccionar PDF
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Funcionalidad de agregar PDF no implementada')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.blue),
                    ),
                  ),
                ],
              ),
              if (selectedImage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Image.file(selectedImage!, height: 100),
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Implementar lógica para publicar el anuncio
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Anuncio publicado (simulado)')),
                        );
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Publicar anuncio'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Cancelar'),
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

  const BuildMenu({super.key, required this.onBack});

  @override
  _BuildMenuState createState() => _BuildMenuState();
}

class _BuildMenuState extends State<BuildMenu> {
  bool showAddForm = false;
  PlatformFile? _image;
  final _formKey = GlobalKey<FormState>();

  final _nombreIglesiaController = TextEditingController();
  final _nombrePastorController = TextEditingController();
  final _latitudController = TextEditingController();
  final _longitudController = TextEditingController();
  final _facebookController = TextEditingController();
  final _instagramController = TextEditingController();
  final _sitioWebController = TextEditingController();
  final _direccionController = TextEditingController();

  final TextEditingController _searchController = TextEditingController();
  List<Iglesia> _iglesias = [];
  bool _isLoading = false;

  // Mapa actualizado para incluir todos los días de la semana
  Map<String, List<TimeOfDay>> horarios = {
    'Lunes': [],
    'Martes': [],
    'Miércoles': [],
    'Jueves': [],
    'Viernes': [],
    'Sábado': [],
    'Domingo': []
  };

  String timeOfDayToString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> getImage() async {
    final PlatformFile? result = await image_picker.getWebImage();
    if (result != null) {
      setState(() {
        _image = result;
      });
    }
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
                        icon: const Icon(Icons.arrow_back),
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
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                if (isDesktop)
                  Text(
                    showAddForm
                        ? 'Agregar nueva iglesia'
                        : 'Búsqueda de Iglesia',
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                const SizedBox(height: 20),
                if (!showAddForm) ...[
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Ingrese el nombre de la iglesia',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _buscarIglesias,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 2, 56, 174),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text('Buscar',
                              style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showAddForm = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 2, 56, 174),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text('Agregar nueva',
                              style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    _buildIglesiasList(),
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
                radius: 75,
                backgroundImage: _image != null
                    ? (kIsWeb
                        ? NetworkImage(_image!.path)
                        : FileImage(File(_image!.path)) as ImageProvider)
                    : null,
                child: _image == null
                    ? const Icon(Icons.add_a_photo, size: 75)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _nombreIglesiaController,
            decoration:
                const InputDecoration(labelText: 'Nombre de la Iglesia'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese el nombre de la iglesia';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _nombrePastorController,
            decoration: const InputDecoration(labelText: 'Nombre del Pastor'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese el nombre del pastor';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _direccionController,
            decoration: const InputDecoration(labelText: 'Dirección'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese la dirección de la iglesia';
              }
              return null;
            },
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _latitudController,
                  decoration: const InputDecoration(labelText: 'Latitud'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese la latitud';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _longitudController,
                  decoration: const InputDecoration(labelText: 'Longitud'),
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
          const SizedBox(height: 20),
          const Text('Horarios de Servicios',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ..._buildServiceSchedules(),
          const SizedBox(height: 20),
          const Text('Redes Sociales',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          TextFormField(
            controller: _facebookController,
            decoration: const InputDecoration(labelText: 'Facebook'),
          ),
          TextFormField(
            controller: _instagramController,
            decoration: const InputDecoration(labelText: 'Instagram'),
          ),
          TextFormField(
            controller: _sitioWebController,
            decoration: const InputDecoration(labelText: 'Sitio Web'),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 2, 56, 174),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text('Guardar', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showAddForm = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
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
          Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              ElevatedButton(
                child: const Text('Agregar Horario'),
                onPressed: () => _selectTime(entry.key),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: entry.value
                      .map((time) => Chip(
                            label: Text(timeOfDayToString(time)),
                            onDeleted: () => _removeTime(entry.key, time),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
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

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Convertir los horarios a un formato serializable
      Map<String, List<String>> horariosSerializables = {};
      horarios.forEach((dia, tiempos) {
        horariosSerializables[dia] =
            tiempos.map((t) => timeOfDayToString(t)).toList();
      });

      // URL de tu API
      String apiUrl =
          'http://asambleasdedios.gt/api.asambleasdedios.gt/api/asambleas/registro-iglesia';

      try {
        var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

        // Agregar los campos de texto
        request.fields['nombre'] = _nombreIglesiaController.text;
        request.fields['pastor'] = _nombrePastorController.text;
        request.fields['direccion'] = _direccionController.text;
        request.fields['latitud'] = _latitudController.text;
        request.fields['longitud'] = _longitudController.text;
        request.fields['facebook'] = _facebookController.text;
        request.fields['instagram'] = _instagramController.text;
        request.fields['sitioWeb'] = _sitioWebController.text;
        request.fields['horarios'] = json.encode(horariosSerializables);

        // Agregar la imagen si existe
        if (_image != null) {
          var bytes = await _image!.readAsBytes();
          var multipartFile = http.MultipartFile.fromBytes(
            'imagen',
            bytes,
            filename: 'imagen_iglesia.jpg',
            contentType: MediaType('image', 'jpeg'),
          );
          request.files.add(multipartFile);
        }

        // Enviar la solicitud
        var streamedResponse =
            await request.send().timeout(const Duration(seconds: 30));
        var response = await http.Response.fromStream(streamedResponse);

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 201) {
          // La iglesia se guardó exitosamente
          _showAlert(
              'Guardada con éxito', 'La iglesia se registró correctamente');
          setState(() {
            showAddForm = false;
          });
        } else {
          // Mostrar el mensaje de error devuelto por la API
          _showAlert('Error',
              responseData['message'] ?? 'Ocurrió un error desconocido');
        }
      } on TimeoutException {
        _showAlert('Error de conexión',
            'La solicitud excedió el tiempo de espera. Por favor, inténtelo de nuevo.');
      } on SocketException {
        _showAlert('Error de conexión',
            'No se pudo establecer una conexión con el servidor. Verifique su conexión a internet y que el servidor esté en funcionamiento.');
      } on FormatException {
        _showAlert(
            'Error', 'Hubo un problema al procesar la respuesta del servidor.');
      } catch (e) {
        _showAlert('Error', 'Ocurrió un error inesperado: $e');
      }
    }
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  Widget _buildIglesiasList() {
    if (_iglesias.isEmpty) {
      return const Center(child: Text('No se encontraron iglesias'));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _iglesias.length,
      itemBuilder: (context, index) {
        return _buildIglesiaCard(_iglesias[index]);
      },
    );
  }

  Widget _buildIglesiaCard(Iglesia iglesia) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: iglesia.fotoPerfil != null
                      ? NetworkImage(
                          'http://asambleasdedios.gt/api.asambleasdedios.gt${iglesia.fotoPerfil}')
                      : null,
                  child: iglesia.fotoPerfil == null
                      ? const Icon(Icons.church)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        iglesia.nombre,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text('Pastor: ${iglesia.pastor}'),
                      const SizedBox(height: 8),
                      Text('Dirección: ${iglesia.direccion}'),
                      Text(
                          'Coordenadas: ${iglesia.latitud}, ${iglesia.longitud}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Horarios de servicios:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            _buildHorariosTable(iglesia.horariosServicios),
            const SizedBox(height: 16),
            const Text('Redes sociales:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            _buildSocialMediaLinks(iglesia.redesSociales),
            const SizedBox(height: 16),
            const Text('Ubicación:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(
              height: 300,
              child: MapWidget(
                lat: iglesia.latitud,
                lng: iglesia.longitud,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorariosTable(Map<String, List<String>> horarios) {
    return Table(
      border: TableBorder.all(color: Colors.grey),
      children: [
        const TableRow(
          children: [
            TableCell(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child:
                    Text('Día', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            TableCell(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Hora(s)',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        ...horarios.entries
            .map((entry) => TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(entry.key),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            entry.value.map((hora) => '$hora:00').join(', ')),
                      ),
                    ),
                  ],
                ))
            .toList(),
      ],
    );
  }

  Widget _buildSocialMediaLinks(Map<String, String> redes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (redes.containsKey('Facebook'))
          Builder(
            builder: (context) {
              final originalUrl = redes['Facebook']!;
              final processedUrl = _processSocialUrl(originalUrl);
              return _buildSocialMediaButton(
                icon: Icons.facebook,
                color: Colors.blue,
                text: 'Facebook',
                url: processedUrl,
                fallbackUrl: processedUrl,
              );
            },
          ),
        if (redes.containsKey('Instagram'))
          Builder(
            builder: (context) {
              final originalUrl = redes['Instagram']!;
              final processedUrl = _processSocialUrl(originalUrl);
              return _buildSocialMediaButton(
                icon: Icons.camera_alt,
                color: Colors.purple,
                text: 'Instagram',
                url: processedUrl,
                fallbackUrl: processedUrl,
              );
            },
          ),
        if (redes.containsKey('Sitio Web'))
          Builder(
            builder: (context) {
              final originalUrl = redes['Sitio Web']!;
              final processedUrl = _processSocialUrl(originalUrl);
              return _buildSocialMediaButton(
                icon: Icons.language,
                color: Colors.green,
                text: 'Sitio Web',
                url: processedUrl,
                fallbackUrl: processedUrl,
              );
            },
          ),
      ],
    );
  }

  String _processSocialUrl(String url) {
    // Eliminar comillas dobles extras al principio y al final
    url = url.replaceAll(RegExp(r'^"|"$'), '');

    // Eliminar el prefijo '@' si existe
    if (url.startsWith('@')) {
      url = url.substring(1);
    }

    // Verificar si la URL ya es válida
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    // Si no es una URL válida, intentar corregirla
    return 'https://$url';
  }

  Widget _buildSocialMediaButton({
    required IconData icon,
    required Color color,
    required String text,
    required String url,
    required String fallbackUrl,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ElevatedButton.icon(
        icon: Icon(icon, color: color),
        label: Text(text),
        onPressed: () => _launchURL(url, fallbackUrl: fallbackUrl),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String url, {required String fallbackUrl}) async {
    try {
      if (url.isEmpty) {
        throw 'URL vacía';
      }
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        final bool launched =
            await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!launched) {
          throw 'No se pudo lanzar $url';
        }
      } else {
        throw 'No se puede lanzar $url';
      }
    } catch (e) {
      print('Error al abrir la URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir el enlace: $url\nError: $e')),
      );
    }
  }

  void _buscarIglesias() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'http://asambleasdedios.gt/api.asambleasdedios.gt/api/asambleas/buscar-iglesias?nombre=${_searchController.text}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> iglesiasData = json.decode(response.body);
        setState(() {
          _iglesias =
              iglesiasData.map((item) => Iglesia.fromJson(item)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load iglesias');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al buscar iglesias: $e')),
      );
    }
  }
}

class Iglesia {
  final int id;
  final String nombre;
  final String pastor;
  final String direccion;
  final double latitud;
  final double longitud;
  final String? fotoPerfil;
  final Map<String, String> redesSociales;
  final Map<String, List<String>> horariosServicios;

  Iglesia({
    required this.id,
    required this.nombre,
    required this.pastor,
    required this.direccion,
    required this.latitud,
    required this.longitud,
    this.fotoPerfil,
    required this.redesSociales,
    required this.horariosServicios,
  });

  LatLng get coordenadas => LatLng(latitud, longitud);

  factory Iglesia.fromJson(Map<String, dynamic> json) {
    return Iglesia(
      id: json['id_iglesia'],
      nombre: json['nombre'],
      pastor: json['pastor'],
      direccion: json['direccion'],
      latitud: json['latitud'],
      longitud: json['longitud'],
      fotoPerfil: json['foto_perfil'],
      redesSociales: Map<String, String>.from(
        json['redes_sociales']
            .map((key, value) => MapEntry(key, value.toString())),
      ),
      horariosServicios: Map<String, List<String>>.from(
        json['horarios_servicios']
            .map((key, value) => MapEntry(key, List<String>.from(value))),
      ),
    );
  }
}

class BuildPastorSearchMenu extends StatefulWidget {
  final VoidCallback onBack;

  const BuildPastorSearchMenu({super.key, required this.onBack});

  @override
  _BuildPastorSearchMenuState createState() => _BuildPastorSearchMenuState();
}

class _BuildPastorSearchMenuState extends State<BuildPastorSearchMenu> {
  //final Completer<GoogleMapController> _controller = Completer();
  bool showAddForm = false;
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos del formulario
  final _primerNombreController = TextEditingController();
  final _segundoNombreController = TextEditingController();
  final _primerApellidoController = TextEditingController();
  final _segundoApellidoController = TextEditingController();
  final _dpiController = TextEditingController();
  final _fechaNacimientoController = TextEditingController();
  final _carnetPastorController = TextEditingController();
  final _iglesiaController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _cargoController = TextEditingController();
  final _fechaInicioCargo = TextEditingController();
  bool? _estudioBiblico;

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
                        icon: const Icon(Icons.arrow_back),
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
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                if (isDesktop)
                  Text(
                    showAddForm ? 'Agregar nuevo pastor' : 'Búsqueda de Pastor',
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                const SizedBox(height: 20),
                if (!showAddForm) ...[
                  const TextField(
                    decoration: InputDecoration(
                      hintText: 'Ingrese el nombre del pastor',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Implementar lógica de búsqueda
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 2, 56, 174),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text('Buscar',
                              style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showAddForm = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 2, 56, 174),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text('Agregar nuevo',
                              style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
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
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 20 : 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isDesktop)
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _primerNombreController,
                        decoration:
                            const InputDecoration(labelText: 'Primer Nombre'),
                        validator: (value) =>
                            value!.isEmpty ? 'Campo requerido' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _segundoNombreController,
                        decoration:
                            const InputDecoration(labelText: 'Segundo Nombre'),
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    TextFormField(
                      controller: _primerNombreController,
                      decoration:
                          const InputDecoration(labelText: 'Primer Nombre'),
                      validator: (value) =>
                          value!.isEmpty ? 'Campo requerido' : null,
                    ),
                    TextFormField(
                      controller: _segundoNombreController,
                      decoration:
                          const InputDecoration(labelText: 'Segundo Nombre'),
                    ),
                  ],
                ),
              if (isDesktop)
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _primerApellidoController,
                        decoration:
                            const InputDecoration(labelText: 'Primer Apellido'),
                        validator: (value) =>
                            value!.isEmpty ? 'Campo requerido' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _segundoApellidoController,
                        decoration: const InputDecoration(
                            labelText: 'Segundo Apellido'),
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    TextFormField(
                      controller: _primerApellidoController,
                      decoration:
                          const InputDecoration(labelText: 'Primer Apellido'),
                      validator: (value) =>
                          value!.isEmpty ? 'Campo requerido' : null,
                    ),
                    TextFormField(
                      controller: _segundoApellidoController,
                      decoration:
                          const InputDecoration(labelText: 'Segundo Apellido'),
                    ),
                  ],
                ),
              TextFormField(
                controller: _dpiController,
                decoration: const InputDecoration(labelText: 'DPI'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _fechaNacimientoController,
                decoration:
                    const InputDecoration(labelText: 'Fecha de Nacimiento'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    _fechaNacimientoController.text =
                        pickedDate.toIso8601String().split('T')[0];
                  }
                },
              ),
              TextFormField(
                controller: _carnetPastorController,
                decoration: const InputDecoration(
                    labelText: 'Número de Carnet de Pastor'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _iglesiaController,
                decoration:
                    const InputDecoration(labelText: 'Iglesia que Pastorea'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration:
                    const InputDecoration(labelText: 'Correo Electrónico'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _telefonoController,
                decoration:
                    const InputDecoration(labelText: 'Número de Teléfono'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _cargoController,
                decoration: const InputDecoration(labelText: 'Cargo Ocupado'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _fechaInicioCargo,
                decoration: const InputDecoration(
                    labelText: 'Fecha de Inicio del Cargo'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    _fechaInicioCargo.text =
                        pickedDate.toIso8601String().split('T')[0];
                  }
                },
              ),
              DropdownButtonFormField<bool>(
                decoration: const InputDecoration(
                    labelText: '¿Estudió en Instituto Bíblico?'),
                items: const [
                  DropdownMenuItem(value: true, child: Text('Sí')),
                  DropdownMenuItem(value: false, child: Text('No')),
                ],
                onChanged: (value) {
                  setState(() {
                    _estudioBiblico = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Seleccione una opción' : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 2, 56, 174),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child:
                          const Text('Guardar', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showAddForm = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text('Cancelar',
                          style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildServiceSchedules() {
    return horarios.entries.map((entry) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              ElevatedButton(
                child: const Text('Agregar Horario'),
                onPressed: () => _selectTime(entry.key),
              ),
              ...entry.value.map((time) => Chip(
                    label: Text(time.format(context)),
                    onDeleted: () => _removeTime(entry.key, time),
                  )),
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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                    'https://cdn-icons-png.flaticon.com/512/3135/3135768.png'),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Nombre: Enrique Cardona Garcia',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Edad: 46'),
            Text('Fecha de nacimiento: 05/02/1978'),
            Text('Nombre de la Iglesia: Nueva vida'),
            Text('Ubicación de la Iglesia: Guastatoya, El Progreso'),
            Text('Teléfono: 37564265'),
            Text('Correo: enriquecardona@gmail.com'),
            Text('Cargo actual: Pastor'),
            Text('Fecha de inicio del cargo: 03/11/2020'),
            Text('Estudió en instituto bíblico: Sí'),
            SizedBox(height: 16),
            Text('Ubicación:', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
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
                  style: const TextStyle(fontWeight: FontWeight.bold)),
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
          child: const Text('Facebook: facebook.com/nuevavida',
              style: TextStyle(
                  color: Colors.blue, decoration: TextDecoration.underline)),
          onTap: () => launchUrl(Uri.parse('https://facebook.com/nuevavida')),
        ),
        InkWell(
          child: const Text('Instagram: @nuevavida',
              style: TextStyle(
                  color: Colors.blue, decoration: TextDecoration.underline)),
          onTap: () => launchUrl(Uri.parse('https://instagram.com/nuevavida')),
        ),
        InkWell(
          child: const Text('Sitio Web: www.nuevavida.org',
              style: TextStyle(
                  color: Colors.blue, decoration: TextDecoration.underline)),
          onTap: () => launchUrl(Uri.parse('https://www.nuevavida.org')),
        ),
      ],
    );
  }

  /*Widget _buildGoogleMap(LatLng location) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: location,
        zoom: 15,
      ),
      markers: {
        Marker(
          markerId: const MarkerId('pastor'),
          position: location,
        ),
      },
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
    );
  }*/
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

  const AnuncioCard({super.key, required this.anuncio});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(anuncio.imagenPerfil),
                ),
                const SizedBox(width: 16),
                Text(
                  anuncio.nombre,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(anuncio.texto),
            const SizedBox(height: 16),
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
                    child: const Center(
                      child: Icon(Icons.error, color: Colors.red),
                    ),
                  );
                },
              )
            else
              InkWell(
                child: Text(
                  anuncio.archivo,
                  style: const TextStyle(
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
