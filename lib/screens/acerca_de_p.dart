import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  final String agentName = "Franklyn Muñoz Salcedo";
  final String agentId = "2021-2296";
  final String motivation = "En cada acción migratoria reside la noble tarea de proteger nuestra patria y,"
  "a la vez, de honrar la dignidad humana. El servicio al país se mide en la integridad con la que custodiamos"
  "nuestras fronteras y la humanidad con la que recibimos al mundo...";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Acerca del Agente', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[900],
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/agent.jpg'),
                    radius: 60,
                    backgroundColor: Colors.blue[200],
                  ),
                  SizedBox(height: 20),
                  Text(
                    agentName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Matrícula: $agentId',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 15),
                  Divider(color: Colors.blue[100]),
                  SizedBox(height: 15),
                  Text(
                    motivation,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}