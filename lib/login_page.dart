import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'main.dart'; // Asegúrate de importar el archivo donde está definido MyHomePage
import 'package:http/http.dart'
    as http; // Importar http para la llamada a la API
import 'register_page.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 2, 56, 174),
              Color.fromARGB(255, 100, 181, 246),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                if (constraints.maxWidth > 600) {
                  return _buildDesktopLayout();
                } else {
                  return _buildMobileLayout();
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: _buildForm(),
    );
  }

  Widget _buildMobileLayout() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: _buildForm(),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.asset(
            'assets/logo.png',
            height: 150,
          ),
          const SizedBox(height: 48),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Correo electrónico',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese su correo electrónico';
              }
              return null;
            },
            onSaved: (value) => _email = value!,
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Contraseña',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese su contraseña';
              }
              return null;
            },
            onSaved: (value) => _password = value!,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 2, 56, 174),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Iniciar sesión'),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterPage()),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color.fromARGB(255, 2, 56, 174),
            ),
            child: const Text('¿No tiene una cuenta? Regístrese aquí'),
          ),
        ],
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      bool isConnected = true;
      try {
        var connectivityResult = await (Connectivity().checkConnectivity());
        isConnected = connectivityResult != ConnectivityResult.none;
      } catch (e) {
        // Si falla la verificación de conectividad, asumimos que hay conexión
        print('Error al verificar la conectividad: $e');
      }

      if (!isConnected) {
        _showAlert('Sin conexión',
            'Por favor, verifique su conexión a internet e intente nuevamente.');
        return;
      }

      try {
        print('Intentando conectar a la API...');
        final response = await http
            .post(
              Uri.parse(
                  'http://asambleasdedios.gt/api.asambleasdedios.gt/api/asambleas/login'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'email': _email, 'password': _password}),
            )
            .timeout(
                const Duration(seconds: 10)); // Añade un timeout de 10 segundos

        print('Respuesta recibida. Código de estado: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200) {
          if (responseData['token'] != null) {
            print('Token recibido. Iniciando sesión...');
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => MyHomePage(
                  title: 'Prototipo app',
                  userEmail: _email, // Pasar el email del usuario
                ),
              ),
            );
          } else {
            _showAlert('Error', 'No se recibió token de autenticación');
          }
        } else {
          _showAlert('Error de autenticación',
              responseData['message'] ?? 'Ocurrió un error desconocido');
        }
      } on TimeoutException {
        print('La solicitud excedió el tiempo de espera');
        _showAlert('Error de conexión',
            'La solicitud excedió el tiempo de espera. Por favor, inténtelo de nuevo.');
      } on SocketException catch (e) {
        print('Error de Socket: $e');
        _showAlert('Error de conexión',
            'No se pudo establecer una conexión con el servidor. Verifique su conexión a internet y que el servidor esté en funcionamiento.');
      } on FormatException catch (e) {
        print('Error de formato: $e');
        _showAlert(
            'Error', 'Hubo un problema al procesar la respuesta del servidor.');
      } catch (e) {
        print('Error general: $e');
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
}
