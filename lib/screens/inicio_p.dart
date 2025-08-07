import 'package:flutter/material.dart';
import 'registro_p.dart';
import 'registros_p.dart';
import 'acerca_de_p.dart';
import '../data/basededatos.dart';

// La pantalla principal de la aplicacion.
// Muestra los botones de navegacion a las diferentes secciones.
class HomeScreen extends StatelessWidget {
  // Muestra un dialogo de confirmacion antes de borrar todos los registros.
  void _confirmDeleteAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Borrar Todo', style: TextStyle(color: Colors.blue[900])),
        content: Text('¿Estás seguro de eliminar todos los registros?', style: TextStyle(color: Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: Colors.blue[900])),
          ),
          TextButton(
            onPressed: () async {
              // Llama al metodo de la base de datos para borrar todo.
              await DatabaseHelper.instance.deleteAll();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Todos los datos fueron eliminados')),
              );
            },
            child: Text('Confirmar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Migración 2021 - 2296', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // Alinea el contenido de la columna arriba.
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // GridView con los botones principales de la app.
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              shrinkWrap: true, // Se adapta al tamaño del contenido.
              children: [
                _buildGridButton(
                  context,
                  'Registrar Persona',
                  Icons.person_add,
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen())),
                  Colors.blue,
                ),
                _buildGridButton(
                  context,
                  'Ver Registros',
                  Icons.list_alt,
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecordsScreen())),
                  Colors.blue,
                ),
                _buildGridButton(
                  context,
                  'Acerca del Agente',
                  Icons.info,
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => AboutScreen())),
                  Colors.blue,
                ),
                _buildGridButton(
                  context,
                  'Borrar Todo',
                  Icons.delete_forever,
                      () => _confirmDeleteAll(context),
                  Colors.red,
                ),
              ],
            ),

            SizedBox(height: 30),

            // Logo de la institucion de migracion.
            Image.asset(
              'assets/logo.png',
              height: 150,
            ),
          ],
        ),
      ),
    );
  }

  // Crea un boton reutilizable para la cuadricula.
  Widget _buildGridButton(BuildContext context, String text, IconData icon, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.all(16),
        elevation: 5,
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40),
          SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}