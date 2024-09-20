import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'login_page.dart'; // Importa el nuevo archivo
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'platform_file.dart';
import 'package:http_parser/http_parser.dart';
import 'map_widget.dart';
import 'package:intl/intl.dart';
import 'file_picker.dart' as file_picker;
import 'web_image_picker.dart' if (dart.library.io) 'mobile_image_picker.dart'
    as image_picker;
import 'platform_file.dart' as custom;

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
  const MyHomePage({
    Key? key,
    required this.title,
    required this.userEmail,
    required this.userRole,
    required this.token,
  }) : super(key: key);

  final String title;
  final String userEmail;
  final int userRole;
  final String token;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _showSearchForm = false;
  bool _showPastorSearchForm = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Anuncio> _anuncios = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cargarAnuncios();
  }

  Future<void> _cargarAnuncios() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://asambleasdedios.gt/api.asambleasdedios.gt/api/asambleas/obtener-anuncios?email=${widget.userEmail}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> anunciosData = json.decode(response.body);
        setState(() {
          _anuncios =
              anunciosData.map((item) => Anuncio.fromJson(item)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load anuncios');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _mostrarMensaje('Error', 'No se pudieron cargar los anuncios: $e');
    }
  }

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
                  width: 250,
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
                      child: _currentContent(),
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

  Widget _currentContent() {
    if (_showSearchForm) {
      return BuildMenu(
        onBack: () {
          setState(() {
            _showSearchForm = false;
          });
        },
        userRole: widget.userRole,
      );
    } else if (_showPastorSearchForm) {
      return BuildPastorSearchMenu(
        onBack: () {
          setState(() {
            _showPastorSearchForm = false;
          });
        },
        userRole: widget.userRole,
      );
    } else {
      return _buildMainContent();
    }
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
        if (widget.userRole <= 1)
          ListTile(
            leading:
                const Icon(Icons.admin_panel_settings, color: Colors.white),
            title: const Text('Panel de Administración',
                style: TextStyle(color: Colors.white)),
            onTap: () {
              // Implementar navegación al panel de administración
            },
          ),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.white),
          title: const Text('Cerrar sesión',
              style: TextStyle(color: Colors.white)),
          onTap: () {
            _cerrarSesion();
          },
        ),
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
      ],
    );
  }

  void _cerrarSesion() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        if (widget.userRole <= 3) _buildNewAnnouncementButton(),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _cargarAnuncios,
                  child: ListView.builder(
                    itemCount: _anuncios.length,
                    itemBuilder: (context, index) {
                      return AnuncioCard(
                        anuncio: _anuncios[index],
                        userRole: widget.userRole,
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildNewAnnouncementButton() {
    return ElevatedButton(
      onPressed: () {
        _showNewAnnouncementForm();
      },
      child: const Text('Nuevo Anuncio'),
    );
  }

  Widget _buildNewAnnouncementForm() {
    final TextEditingController textController = TextEditingController();
    custom.PlatformFile? selectedImage;
    custom.PlatformFile? selectedFile;

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
                      final result = await image_picker.getWebImage();
                      if (result != null) {
                        setState(() {
                          selectedImage = result;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.blue),
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.attach_file, color: Colors.blue),
                    label: const Text('Agregar archivo',
                        style: TextStyle(color: Colors.blue)),
                    onPressed: () async {
                      final result = await file_picker.pickFile();
                      if (result != null) {
                        setState(() {
                          selectedFile = result;
                        });
                        print('Archivo seleccionado: ${result.name}');
                      }
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Imagen seleccionada: ${selectedImage!.name}'),
                      const SizedBox(height: 8),
                      kIsWeb
                          ? Image.network(selectedImage!.path, height: 100)
                          : Image.file(File(selectedImage!.path), height: 100),
                    ],
                  ),
                ),
              if (selectedFile != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Archivo seleccionado: ${selectedFile!.name}'),
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _publicarAnuncio(
                        textController.text,
                        selectedImage,
                        selectedFile,
                      ),
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

  void _showNewAnnouncementForm() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Nuevo Anuncio'),
          content: _buildNewAnnouncementForm(),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _publicarAnuncio(String texto, custom.PlatformFile? imagen,
      custom.PlatformFile? archivo) async {
    String userEmail = widget.userEmail;
    var uri = Uri.parse(
        'https://asambleasdedios.gt/api.asambleasdedios.gt/api/asambleas/crear-anuncio');
    var request = http.MultipartRequest('POST', uri);

    request.fields['email'] = userEmail;
    request.fields['texto'] = texto;

    try {
      if (imagen != null) {
        var bytes = await imagen.readAsBytes();
        var multipartFile = http.MultipartFile.fromBytes(
          'imagen',
          bytes,
          filename: imagen.name,
          contentType: MediaType.parse(
              imagen.name.endsWith('.png') ? 'image/png' : 'image/jpeg'),
        );
        request.files.add(multipartFile);
      }

      if (archivo != null) {
        print('Archivo seleccionado: ${archivo.name}');
        var bytes = await archivo.readAsBytes();
        print('Tamaño del archivo: ${bytes.length} bytes');
        var mimeType = _getMimeType(archivo.name);
        print('Tipo MIME del archivo: $mimeType');
        var multipartFile = http.MultipartFile.fromBytes(
          'archivo',
          bytes,
          filename: archivo.name,
          contentType: MediaType.parse(mimeType),
        );
        request.files.add(multipartFile);
      }

      print('Enviando solicitud...');
      var streamedResponse =
          await request.send().timeout(const Duration(seconds: 30));
      print(
          'Respuesta recibida. Código de estado: ${streamedResponse.statusCode}');
      var response = await http.Response.fromStream(streamedResponse);

      print('Cuerpo de la respuesta: ${response.body}');

      if (response.statusCode == 201) {
        Navigator.of(context).pop();
        _mostrarMensaje('Éxito', 'Anuncio publicado con éxito');
        _cargarAnuncios(); // Recargar los anuncios después de publicar uno nuevo
      } else {
        print('Error del servidor: ${response.statusCode}');
        print('Respuesta del servidor: ${response.body}');
        _mostrarMensaje('Error',
            'Error al publicar el anuncio: ${response.reasonPhrase}\n${response.body}');
      }
    } catch (e) {
      print('Error al publicar el anuncio: $e');
      _mostrarMensaje(
          'Error', 'Ocurrió un error inesperado al publicar el anuncio: $e');
    }
  }

  String _getMimeType(String fileName) {
    switch (fileName.split('.').last.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      default:
        return 'application/octet-stream';
    }
  }

  void _mostrarMensaje(String titulo, String mensaje) {
    // Asegurarse de que el contexto sea válido antes de mostrar el diálogo
    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(titulo),
            content: Text(mensaje),
            actions: <Widget>[
              TextButton(
                child: const Text('Aceptar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      // Si el widget ya no está montado, imprimir el mensaje en la consola
      print('No se pudo mostrar el mensaje: $titulo - $mensaje');
    }
  }
}

class Anuncio {
  final int id;
  final String texto;
  final String? imagen;
  final String? pdf;
  final DateTime fechaCreacion;
  final String email;
  final String nombreCompleto;
  final String nombreIglesia;
  final String? fotoPerfilPastor;
  final String? fotoPerfilIglesia;

  Anuncio({
    required this.id,
    required this.texto,
    this.imagen,
    this.pdf,
    required this.fechaCreacion,
    required this.email,
    required this.nombreCompleto,
    required this.nombreIglesia,
    this.fotoPerfilPastor,
    this.fotoPerfilIglesia,
  });

  factory Anuncio.fromJson(Map<String, dynamic> json) {
    return Anuncio(
      id: json['id_anuncio'],
      texto: json['texto'],
      imagen: json['imagen'],
      pdf: json['pdf'],
      fechaCreacion: DateTime.parse(json['fecha_creacion']),
      email: json['email'],
      nombreCompleto:
          '${json['primer_nombre']} ${json['segundo_nombre']} ${json['primer_apellido']} ${json['segundo_apellido']}'
              .trim(),
      nombreIglesia: json['nombre_iglesia'],
      fotoPerfilPastor: json['foto_perfil_pastor'],
      fotoPerfilIglesia: json['foto_perfil_iglesia'],
    );
  }
}

class AnuncioCard extends StatelessWidget {
  final Anuncio anuncio;
  final int userRole;

  const AnuncioCard({
    Key? key,
    required this.anuncio,
    required this.userRole,
  }) : super(key: key);

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
                  radius: 30,
                  backgroundImage: anuncio.fotoPerfilIglesia != null
                      ? NetworkImage(
                          'https://asambleasdedios.gt/api.asambleasdedios.gt${anuncio.fotoPerfilIglesia}')
                      : null,
                  child: anuncio.fotoPerfilIglesia == null
                      ? const Icon(Icons.church)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    anuncio.nombreIglesia,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: anuncio.fotoPerfilPastor != null
                      ? NetworkImage(
                          'https://asambleasdedios.gt/api.asambleasdedios.gt${anuncio.fotoPerfilPastor}')
                      : null,
                  child: anuncio.fotoPerfilPastor == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 12),
                Text(
                  anuncio.nombreCompleto,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(anuncio.texto),
            const SizedBox(height: 16),
            if (anuncio.imagen != null)
              GestureDetector(
                onTap: () => _descargarArchivo(
                    context, anuncio.imagen!, 'imagen_anuncio.jpg'),
                child: Image.network(
                  'https://asambleasdedios.gt/api.asambleasdedios.gt${anuncio.imagen}',
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
                ),
              ),
            if (userRole != 4 && anuncio.pdf != null)
              ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Ver PDF'),
                onPressed: () => _descargarArchivo(
                    context, anuncio.pdf!, 'documento_anuncio.pdf'),
              ),
            const SizedBox(height: 8),
            Text(
              'Publicado el ${DateFormat('dd/MM/yyyy HH:mm').format(anuncio.fechaCreacion)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _descargarArchivo(
      BuildContext context, String url, String nombreArchivo) async {
    final Uri uri =
        Uri.parse('https://asambleasdedios.gt/api.asambleasdedios.gt$url');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir el archivo: $nombreArchivo')),
      );
    }
  }
}

class BuildMenu extends StatefulWidget {
  final VoidCallback onBack;
  final int userRole;

  const BuildMenu({
    Key? key,
    required this.onBack,
    required this.userRole,
  }) : super(key: key);

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
                      if (widget.userRole <= 2) ...[
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
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    _buildIglesiasList(),
                ] else ...[
                  _buildAddIglesiaForm(isDesktop),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddIglesiaForm(bool isDesktop) {
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
      Map<String, List<String>> horariosSerializables = {};
      horarios.forEach((dia, tiempos) {
        horariosSerializables[dia] =
            tiempos.map((t) => timeOfDayToString(t)).toList();
      });

      String apiUrl =
          'https://asambleasdedios.gt/api.asambleasdedios.gt/api/asambleas/registro-iglesia';

      try {
        var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

        request.fields['nombre'] = _nombreIglesiaController.text;
        request.fields['pastor'] = _nombrePastorController.text;
        request.fields['direccion'] = _direccionController.text;
        request.fields['latitud'] = _latitudController.text;
        request.fields['longitud'] = _longitudController.text;
        request.fields['facebook'] = _facebookController.text;
        request.fields['instagram'] = _instagramController.text;
        request.fields['sitioWeb'] = _sitioWebController.text;
        request.fields['horarios'] = json.encode(horariosSerializables);

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

        var streamedResponse =
            await request.send().timeout(const Duration(seconds: 30));
        var response = await http.Response.fromStream(streamedResponse);

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 201) {
          _showAlert(
              'Guardada con éxito', 'La iglesia se registró correctamente');
          setState(() {
            showAddForm = false;
          });
        } else {
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
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          if (iglesia.fotoPerfil != null)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(
                'https://asambleasdedios.gt/api.asambleasdedios.gt${iglesia.fotoPerfil}',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          SizedBox(
            height: 200,
            child: MapWidget(lat: iglesia.latitud, lng: iglesia.longitud),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  iglesia.nombre,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                _buildInfoRow(Icons.person, 'Pastor: ${iglesia.pastor}'),
                _buildInfoRow(Icons.location_on, iglesia.direccion),
                _buildInfoRow(Icons.phone,
                    'Teléfono: ${iglesia.redesSociales['Teléfono'] ?? 'No disponible'}'),
                _buildInfoRow(Icons.email,
                    'Email: ${iglesia.redesSociales['Email'] ?? 'No disponible'}'),
                _buildInfoRow(Icons.calendar_today, 'Horarios de servicios:'),
                ...iglesia.horariosServicios.entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text('${entry.key}: ${entry.value.join(", ")}'),
                  ),
                ),
                const SizedBox(height: 10),
                _buildSocialMediaButtons(iglesia.redesSociales),
                if (widget.userRole <= 1) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => _editarIglesia(iglesia),
                        child: const Text('Editar'),
                      ),
                      ElevatedButton(
                        onPressed: () => _eliminarIglesia(iglesia.id),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        child: const Text('Eliminar'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildSocialMediaButtons(Map<String, String> redes) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (redes.containsKey('Facebook'))
          _buildSocialMediaButton(
            icon: Icons.facebook,
            color: Colors.blue,
            url: redes['Facebook']!,
          ),
        if (redes.containsKey('Instagram'))
          _buildSocialMediaButton(
            icon: Icons.camera_alt,
            color: Colors.purple,
            url: redes['Instagram']!,
          ),
        if (redes.containsKey('Sitio Web'))
          _buildSocialMediaButton(
            icon: Icons.language,
            color: Colors.green,
            url: redes['Sitio Web']!,
          ),
      ],
    );
  }

  Widget _buildSocialMediaButton({
    required IconData icon,
    required Color color,
    required String url,
  }) {
    return IconButton(
      icon: Icon(icon, color: color),
      onPressed: () => _launchURL(url),
    );
  }

  Future<void> _launchURL(String url) async {
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
            'https://asambleasdedios.gt/api.asambleasdedios.gt/api/asambleas/buscar-iglesias?nombre=${_searchController.text}'),
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

  void _editarIglesia(Iglesia iglesia) {
    // Implementar la lógica para editar la iglesia
  }

  void _eliminarIglesia(int id) {
    // Implementar la lógica para eliminar la iglesia
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
  final int userRole;

  const BuildPastorSearchMenu({
    Key? key,
    required this.onBack,
    required this.userRole,
  }) : super(key: key);

  @override
  _BuildPastorSearchMenuState createState() => _BuildPastorSearchMenuState();
}

class _BuildPastorSearchMenuState extends State<BuildPastorSearchMenu> {
  bool showAddForm = false;
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  final _dpiController = TextEditingController();
  List<Pastor> _pastores = [];
  bool _isLoading = false;

  // Controladores para los campos del formulario
  final _primerNombreController = TextEditingController();
  final _segundoNombreController = TextEditingController();
  final _primerApellidoController = TextEditingController();
  final _segundoApellidoController = TextEditingController();
  final _fechaNacimientoController = TextEditingController();
  final _carnetPastorController = TextEditingController();
  final _iglesiaController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _cargoController = TextEditingController();
  final _fechaInicioCargo = TextEditingController();
  bool? _estudioBiblico;

  PlatformFile? _fotoPerfil;

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
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Ingrese el nombre del pastor',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.search),
                    ),
                  ),
                  if (widget.userRole <= 2) ...[
                    const SizedBox(height: 10),
                    TextField(
                      controller: _dpiController,
                      decoration: const InputDecoration(
                        hintText: 'Ingrese el DPI del pastor',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.credit_card),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _buscarPastores,
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
                      if (widget.userRole <= 2) ...[
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
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    _buildPastoresList(),
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

  void _buscarPastores() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://asambleasdedios.gt/api.asambleasdedios.gt/api/asambleas/buscar-pastores?nombre=${_searchController.text}&dpi=${_dpiController.text}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> pastoresData = json.decode(response.body);
        setState(() {
          _pastores =
              pastoresData.map((item) => Pastor.fromJson(item)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load pastores');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al buscar pastores: $e')),
      );
    }
  }

  Widget _buildPastoresList() {
    if (_pastores.isEmpty) {
      return const Center(child: Text('No se encontraron pastores'));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _pastores.length,
      itemBuilder: (context, index) {
        return _buildPastorCard(_pastores[index]);
      },
    );
  }

  Widget _buildPastorCard(Pastor pastor) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Container(
            height: 150,
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                backgroundImage: pastor.fotoPerfil != null
                    ? NetworkImage(
                        'https://asambleasdedios.gt${pastor.fotoPerfil}')
                    : const AssetImage('assets/default_profile.png')
                        as ImageProvider,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pastor.nombreCompleto,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                _buildInfoRow(Icons.church, pastor.nombreIglesia),
                _buildInfoRow(Icons.email, pastor.email),
                _buildInfoRow(Icons.phone, pastor.telefono),
                _buildInfoRow(Icons.work, pastor.descripcionCargo),
                _buildInfoRow(Icons.credit_card, 'DPI: ${pastor.dpi}'),
                _buildInfoRow(Icons.cake,
                    'Nacimiento: ${_formatDate(pastor.fechaNacimiento)}'),
                _buildInfoRow(Icons.badge, 'Carnet: ${pastor.carnetPastor}'),
                _buildInfoRow(Icons.calendar_today,
                    'Inicio cargo: ${_formatDate(pastor.fechaInicioCargo)}'),
                _buildInfoRow(Icons.school,
                    'Estudió en instituto bíblico: ${pastor.estudioBiblico == "1" ? 'Sí' : 'No'}'),
                if (widget.userRole <= 1) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => _editarPastor(pastor),
                        child: const Text('Editar'),
                      ),
                      ElevatedButton(
                        onPressed: () => _eliminarPastor(pastor.id),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        child: const Text('Eliminar'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return DateFormat('dd/MM/yyyy').format(date);
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
              Center(
                child: GestureDetector(
                  onTap: _getImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _fotoPerfil != null
                        ? (kIsWeb
                            ? NetworkImage(_fotoPerfil!.path)
                            : FileImage(File(_fotoPerfil!.path))
                                as ImageProvider)
                        : null,
                    child: _fotoPerfil == null
                        ? const Icon(Icons.add_a_photo, size: 50)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),
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

  Future<void> _getImage() async {
    final PlatformFile? result = await image_picker.getWebImage();
    if (result != null) {
      setState(() {
        _fotoPerfil = result;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String apiUrl =
          'https://asambleasdedios.gt/api.asambleasdedios.gt/api/asambleas/insertar-pastor';

      try {
        var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

        // Agregar los campos de texto
        request.fields['primer_nombre'] = _primerNombreController.text;
        request.fields['segundo_nombre'] = _segundoNombreController.text;
        request.fields['primer_apellido'] = _primerApellidoController.text;
        request.fields['segundo_apellido'] = _segundoApellidoController.text;
        request.fields['dpi'] = _dpiController.text;
        request.fields['fecha_nacimiento'] = _fechaNacimientoController.text;
        request.fields['carnet_pastor'] = _carnetPastorController.text;
        request.fields['email'] = _emailController.text;
        request.fields['telefono'] = _telefonoController.text;
        request.fields['fecha_inicio_cargo'] = _fechaInicioCargo.text;
        request.fields['estudio_biblico'] = _estudioBiblico.toString();
        request.fields['iglesia_id'] = _iglesiaController.text;
        request.fields['cargo_id'] = _cargoController.text;

        // Agregar la foto de perfil si existe
        if (_fotoPerfil != null) {
          var bytes = await _fotoPerfil!.readAsBytes();
          var multipartFile = http.MultipartFile.fromBytes(
            'fotoPerfil',
            bytes,
            filename: 'foto_perfil_pastor.jpg',
            contentType: MediaType('image', 'jpeg'),
          );
          request.files.add(multipartFile);
        }

        // Enviar la solicitud
        var streamedResponse =
            await request.send().timeout(const Duration(seconds: 30));
        var response = await http.Response.fromStream(streamedResponse);

        print('Código de estado: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');

        if (response.statusCode == 201) {
          try {
            final responseData = jsonDecode(response.body);
            _showAlert('Guardado con éxito', responseData['mensaje']);
            setState(() {
              showAddForm = false;
            });
          } catch (e) {
            _showAlert('Error',
                'La respuesta del servidor no es JSON válido: ${response.body}');
          }
        } else {
          _showAlert('Error',
              'Error del servidor: ${response.statusCode}\n${response.body}');
        }
      } catch (e) {
        _showAlert('Error', 'Ocurrió un error inesperado: $e');
      }
    }
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _editarPastor(Pastor pastor) {
    // Implementar lógica para editar pastor
  }

  void _eliminarPastor(String id) {
    // Implementar lógica para eliminar pastor
  }
}

class Pastor {
  final String id;
  final String primerNombre;
  final String segundoNombre;
  final String primerApellido;
  final String segundoApellido;
  final String dpi;
  final String fechaNacimiento;
  final String carnetPastor;
  final String email;
  final String telefono;
  final String fechaInicioCargo;
  final String estudioBiblico;
  final String nombreIglesia;
  final String descripcionCargo;
  final String? fotoPerfil;

  Pastor({
    required this.id,
    required this.primerNombre,
    required this.segundoNombre,
    required this.primerApellido,
    required this.segundoApellido,
    required this.dpi,
    required this.fechaNacimiento,
    required this.carnetPastor,
    required this.email,
    required this.telefono,
    required this.fechaInicioCargo,
    required this.estudioBiblico,
    required this.nombreIglesia,
    required this.descripcionCargo,
    this.fotoPerfil,
  });

  String get nombreCompleto =>
      '$primerNombre $segundoNombre $primerApellido $segundoApellido';

  factory Pastor.fromJson(Map<String, dynamic> json) {
    return Pastor(
      id: json['id'].toString(),
      primerNombre: json['primer_nombre'],
      segundoNombre: json['segundo_nombre'],
      primerApellido: json['primer_apellido'],
      segundoApellido: json['segundo_apellido'],
      dpi: json['dpi'],
      fechaNacimiento: json['fecha_nacimiento'],
      carnetPastor: json['carnet_pastor'],
      email: json['email'],
      telefono: json['telefono'],
      fechaInicioCargo: json['fecha_inicio_cargo'],
      estudioBiblico: json['estudio_biblico'],
      nombreIglesia: json['nombre_iglesia'],
      descripcionCargo: json['descripcion_cargo'],
      fotoPerfil: json['fotoPerfil'],
    );
  }
}
