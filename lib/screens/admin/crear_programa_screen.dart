import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../services/api_service.dart';

class CrearProgramaScreen extends StatefulWidget {
  const CrearProgramaScreen({super.key});

  @override
  State<CrearProgramaScreen> createState() => _CrearProgramaScreenState();
}

class _CrearProgramaScreenState extends State<CrearProgramaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();

  final _nombreCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  List<dynamic> _encargados = [];
  int? _encargadoId;
  bool _loading = false;
  bool _loadingEncargados = true;

  @override
  void initState() {
    super.initState();
    _loadEncargados();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadEncargados() async {
    try {
      final data = await _api.adminGetEncargados();
      setState(() => _encargados = data);
    } catch (_) {
    } finally {
      setState(() => _loadingEncargados = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_encargadoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Selecciona un encargado'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setState(() => _loading = true);
    try {
      await _api.adminCrearPrograma(
        nombre: _nombreCtrl.text.trim(),
        descripcion: _descripcionCtrl.text.trim().isEmpty ? null : _descripcionCtrl.text.trim(),
        encargadoId: _encargadoId!,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Programa creado exitosamente'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        flexibleSpace: Container(decoration: BoxDecoration(gradient: AppTheme.primaryGradient)),
        title: const Text('Crear Programa'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nombreCtrl,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: _inputDeco('Nombre del programa', Icons.folder_special_outlined),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descripcionCtrl,
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: _inputDeco('Descripción (opcional)', Icons.description_outlined),
                      ),
                      const SizedBox(height: 16),
                      _loadingEncargados
                          ? const Center(child: CircularProgressIndicator())
                          : _encargados.isEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.warning_amber, color: Colors.orange),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'No hay encargados disponibles. Crea primero un usuario con rol Encargado.',
                                          style: TextStyle(color: Colors.orange, fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : DropdownButtonFormField<int>(
                                  value: _encargadoId,
                                  decoration: _inputDeco('Encargado', Icons.manage_accounts_outlined),
                                  hint: const Text('Selecciona un encargado'),
                                  items: _encargados
                                      .map((e) => DropdownMenuItem<int>(
                                            value: e['id'] as int,
                                            child: Text('${e['nombre']} (${e['email']})'),
                                          ))
                                      .toList(),
                                  onChanged: (v) => setState(() => _encargadoId = v),
                                ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading || _encargados.isEmpty ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: AppTheme.primaryBlue,
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Crear Programa',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      );
}
