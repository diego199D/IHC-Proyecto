import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/cliente.dart';
import '../theme/app_theme.dart';
import 'agregar_cita_servicio_screen.dart';

class AgregarCitaClienteScreen extends StatefulWidget {
  const AgregarCitaClienteScreen({super.key});

  @override
  State<AgregarCitaClienteScreen> createState() => _AgregarCitaClienteScreenState();
}

class _AgregarCitaClienteScreenState extends State<AgregarCitaClienteScreen> {
  late Future<List<Cliente>> _clientesFuture;

  @override
  void initState() {
    super.initState();
    _clientesFuture = DatabaseHelper.instance.getClientes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AGREGAR CITA')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seleccione al cliente:',
              style: TextStyle(fontSize: 13, color: AppColors.textoSecundario),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<Cliente>>(
                future: _clientesFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final clientes = snapshot.data!;
                  return ListView.builder(
                    itemCount: clientes.length,
                    itemBuilder: (context, i) {
                      final cliente = clientes[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Material(
                          color: AppColors.tarjeta,
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AgregarCitaServicioScreen(cliente: cliente),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    cliente.nombre,
                                    style: const TextStyle(fontSize: 13, color: AppColors.texto),
                                  ),
                                  const Icon(Icons.person_outline, size: 18, color: AppColors.textoSecundario),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
