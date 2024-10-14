import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  // Función para validar el correo electrónico
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su correo electrónico';
    }
    // Expresión regular para validar el formato del correo electrónico
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Por favor ingrese una dirección de correo electrónico válida';
    }
    return null;
  }

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
          const Text(
            'Regístrate',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Correo electrónico',
              labelStyle: const TextStyle(color: Colors.black54),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail, // Usamos la nueva función de validación
            onSaved: (value) => _email = value!,
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Contraseña',
              labelStyle: const TextStyle(color: Colors.black54),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
            onPressed: _register,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 2, 56, 174),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Registrarse', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color.fromARGB(255, 2, 56, 174),
            ),
            child: const Text('¿Ya tiene una cuenta? Inicie sesión'),
          ),
        ],
      ),
    );
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      bool isConnected = true;
      try {
        var connectivityResult = await (Connectivity().checkConnectivity());
        isConnected = connectivityResult != ConnectivityResult.none;
      } catch (e) {
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
                  'https://asambleasdedios.gt/api.asambleasdedios.gt/api/asambleas/registro'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'email': _email, 'password': _password}),
            )
            .timeout(const Duration(seconds: 10));

        print('Respuesta recibida. Código de estado: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 201) {
          await _showAlert('Registro exitoso',
              'Usuario registrado exitosamente. Por favor inicie sesión.');
          Navigator.of(context).pop(); // Vuelve a la página de inicio de sesión
        } else {
          _showAlert('Error de registro',
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

  Future<void> _showAlert(String title, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // El usuario debe tocar el botón para cerrar
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
            ),
          ],
        );
      },
    );
  }
}
