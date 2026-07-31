import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/saca.dart';
import '../services/saca_service.dart';
import 'scanner_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = SacaService();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Armazém'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Saca>>(
        stream: service.streamSacas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final sacas = snapshot.data ?? [];
          if (sacas.isEmpty) {
            return const Center(
              child: Text('Nenhuma saca cadastrada ainda.\nToque em "+" para escanear.',
                  textAlign: TextAlign.center),
            );
          }
          return ListView.separated(
            itemCount: sacas.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final saca = sacas[index];
              return ListTile(
                leading: const Icon(Icons.local_cafe, color: Color(0xFFB25A2E)),
                title: Text('Saca nº ${saca.numero}'),
                subtitle: Text(
                    '${saca.tipoBebida.isEmpty ? "Tipo não informado" : saca.tipoBebida} • ${saca.quantidade} sacas\n${dateFormat.format(saca.dataEntrada)}'),
                isThreeLine: true,
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => service.deleteSaca(saca.id!),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Escanear'),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ScannerScreen()),
          );
        },
      ),
    );
  }
}
