import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_theme.dart';
import '../../providers/programa_provider.dart';
import '../../services/api_service.dart';

class CrearTareaScreen extends StatefulWidget {
  const CrearTareaScreen({super.key});

  @override
  State<CrearTareaScreen> createState() => _CrearTareaScreenState();
}

class _CrearTareaScreenState extends State<CrearTareaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  DateTime? _fechaLimite;
  int? _voluntarioSeleccionado;
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgramaProvider>().loadVoluntarios();
    });
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (fecha != null) setState(() => _fechaLimite = fecha);
  }

  Future<void> _guardarTarea() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fechaLimite == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Selecciona una fecha límite')));
      return;
    }
    if (_voluntarioSeleccionado == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Selecciona un voluntario')));
      return;
    }

    setState(() => _cargando = true);
    try {
      final programa = context.read<ProgramaProvider>().programa;
      await ApiService().crearTarea(
        descripcion: _descCtrl.text.trim(),
        fechaLimite: _fechaLimite!.toIso8601String(),
        voluntarioId: _voluntarioSeleccionado!,
        programaId: programa!.id,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Tarea creada exitosamente'),
          backgroundColor: Colors.green,
        ));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final voluntarios = context.watch<ProgramaProvider>().voluntarios;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(decoration: BoxDecoration(gradient: AppTheme.primaryGradient)),
        title: const Text('Crear Tarea'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _descCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Descripción de la tarea',
                      prefixIcon: Icon(Icons.task),
                    ),
                    maxLines: 3,
                    validator: (v) => v!.trim().isEmpty ? 'Ingresa una descripción' : null,
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _seleccionarFecha,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Fecha límite',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _fechaLimite == null
                            ? 'Seleccionar fecha'
                            : '${_fechaLimite!.day}/${_fechaLimite!.month}/${_fechaLimite!.year}',
                        style: TextStyle(
                            color: _fechaLimite == null ? Colors.grey.shade600 : Colors.black87),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _voluntarioSeleccionado,
                    decoration: const InputDecoration(
                      labelText: 'Asignar a voluntario',
                      prefixIcon: Icon(Icons.person),
                    ),
                    items: voluntarios
                        .map<DropdownMenuItem<int>>(
                            (v) => DropdownMenuItem<int>(value: v['id'], child: Text(v['nombre'] ?? '')))
                        .toList(),
                    onChanged: (v) => setState(() => _voluntarioSeleccionado = v),
                    validator: (v) => v == null ? 'Selecciona un voluntario' : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _cargando ? null : _guardarTarea,
                    icon: _cargando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.save),
                    label: Text(_cargando ? 'Guardando...' : 'Guardar Tarea'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryTeal,
                      minimumSize: const Size.fromHeight(50),
                    ),
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
