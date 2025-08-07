import 'package:flutter/material.dart';
import '../data/basededatos.dart';
import '../models/persona.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

// Pantalla para registrar los datos de una persona.
class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _nationality;
  int _age = 0;
  String _description = '';
  String? _photoPath;
  String? _audioPath;
  String? _gpsLocation;

  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _openRecorder();
  }

  // Pide permiso para usar el microfono y abre el grabador de audio.
  Future<void> _openRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Permiso de micrófono no concedido');
    }

    if (_recorder!.isStopped) {
      await _recorder!.openRecorder();
    }
  }

  // Abre la camara del dispositivo para tomar una foto.
  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File newImage = await File(photo.path).copy(path);
      setState(() {
        _photoPath = newImage.path;
      });
    }
  }

  // Inicia o detiene la grabacion de una nota de voz.
  Future<void> _recordAudio() async {
    if (_recorder == null) return;

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.aac';

    if (!_isRecording) {
      await _recorder!.startRecorder(toFile: path);
      setState(() {
        _isRecording = true;
        _audioPath = path;
      });
    } else {
      final result = await _recorder!.stopRecorder();
      setState(() {
        _audioPath = result;
        _isRecording = false;
      });
    }
  }

  // Obtiene la ubicacion GPS del dispositivo.
  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, activa el servicio de ubicación.')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('El permiso de ubicación fue denegado permanentemente.')),
        );
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _gpsLocation = '${position.latitude}, ${position.longitude}';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ubicación obtenida.')),
    );
  }

  // Guarda los datos de la persona en la base de datos.
  void _savePerson() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final now = DateTime.now();
      final formatted = DateFormat('yyyy-MM-dd HH:mm').format(now);

      Person person = Person(
        name: _name,
        age: _age,
        nationality: _nationality,
        datetime: formatted,
        description: _description,
        photoPath: _photoPath,
        audioPath: _audioPath,
        gps: _gpsLocation,
      );

      await DatabaseHelper.instance.insert(person);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _recorder?.closeRecorder();
    _recorder = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Persona', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[900],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey, // Clave para validar el formulario.
              child: ListView(
                children: [
                  // Campo de texto para el nombre.
                  _buildTextField(labelText: 'Nombre', onSaved: (value) => _name = value),
                  // Campo de texto para la edad.
                  _buildTextField(
                    labelText: 'Edad Estimada',
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Requerido' : null,
                    onSaved: (value) => _age = int.tryParse(value ?? '0') ?? 0,
                  ),
                  // Campo de texto para la nacionalidad.
                  _buildTextField(labelText: 'Nacionalidad', onSaved: (value) => _nationality = value),
                  // Campo de texto para la descripción.
                  _buildTextField(
                    labelText: 'Descripción del encuentro',
                    maxLines: 3,
                    validator: (value) => value!.isEmpty ? 'Requerido' : null,
                    onSaved: (value) => _description = value!,
                  ),
                  SizedBox(height: 20),
                  // Boton para tomar una foto.
                  _buildActionButton(
                    icon: Icons.camera_alt,
                    label: 'Tomar Foto',
                    onPressed: _takePhoto,
                    color: Colors.blue[800]!,
                  ),
                  SizedBox(height: 10),
                  // Boton para grabar audio.
                  _buildActionButton(
                    icon: _isRecording ? Icons.stop : Icons.mic,
                    label: _isRecording ? 'Detener grabación' : 'Grabar Nota de Voz',
                    onPressed: _recordAudio,
                    color: _isRecording ? Colors.red : Colors.blue[800]!,
                  ),
                  SizedBox(height: 10),
                  // Boton para obtener la ubicacion.
                  _buildActionButton(
                    icon: Icons.location_on,
                    label: 'Obtener Ubicación',
                    onPressed: _getLocation,
                    color: Colors.blue[800]!,
                  ),
                  SizedBox(height: 20),
                  // Boton para guardar todos los datos.
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Guardar'),
                    onPressed: _savePerson,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget reutilizable para crear campos de texto.
  Widget _buildTextField({
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
    int? maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.blue[900]),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue[900]!),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        keyboardType: keyboardType,
        validator: validator,
        onSaved: onSaved,
        maxLines: maxLines,
      ),
    );
  }

  // Widget reutilizable para crear botones de accion con iconos.
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
    );
  }
}