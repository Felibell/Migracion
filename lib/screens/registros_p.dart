import 'package:flutter/material.dart';
import '../data/basededatos.dart';
import '../models/persona.dart';
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';

// Pantalla para visualizar todos los registros de personas guardados.
class RecordsScreen extends StatelessWidget {
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  // Reproduce un archivo de audio desde una ruta específica.
  Future<void> _playAudio(String path) async {
    try {
      await _player.openPlayer();
      await _player.startPlayer(fromURI: path);
    } catch (e) {
      print('Error al reproducir el audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registros', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[900],
      ),
      body: FutureBuilder<List<Person>>(
        // Llama a la base de datos para obtener todos los registros.
        future: DatabaseHelper.instance.getAllPeople(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.blue[900]));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay registros.', style: TextStyle(color: Colors.black54)));
          }
          // Muestra los registros en una lista si existen.
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, i) {
              final p = snapshot.data![i];
              return Card(
                elevation: 2,
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  leading: Icon(Icons.person, color: Colors.blue[800]),
                  title: Text(p.name ?? 'Desconocido', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Edad: ${p.age} - Fecha: ${p.datetime}'),
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(p.name ?? 'Desconocido', style: TextStyle(color: Colors.blue[900])),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Muestra la foto si está disponible.
                            if (p.photoPath != null && File(p.photoPath!).existsSync())
                              Image.file(File(p.photoPath!), height: 150),

                            SizedBox(height: 10),

                            // Muestra el botón para reproducir el audio si existe.
                            if (p.audioPath != null && File(p.audioPath!).existsSync())
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[800],
                                  foregroundColor: Colors.white,
                                ),
                                icon: Icon(Icons.play_arrow),
                                label: Text('Reproducir Audio'),
                                onPressed: () => _playAudio(p.audioPath!),
                              ),

                            // Muestra la ubicacion GPS si está disponible.
                            if (p.gps != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text('Ubicación GPS: ${p.gps}', style: TextStyle(fontStyle: FontStyle.italic)),
                              ),

                            Divider(),

                            Text('Edad: ${p.age}', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Nacionalidad: ${p.nationality ?? 'No registrada'}'),
                            Text('Descripción: ${p.description}'),
                            Text('Fecha: ${p.datetime}'),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cerrar', style: TextStyle(color: Colors.blue[900])),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}