import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_theme.dart';
import '../../providers/programa_provider.dart';
import '../../services/api_service.dart';

class GestionarVoluntariosScreen extends StatefulWidget {
  const GestionarVoluntariosScreen({super.key});

  @override
  State<GestionarVoluntariosScreen> createState() => _GestionarVoluntariosScreenState();
}

class _GestionarVoluntariosScreenState extends State<GestionarVoluntariosScreen>
    with SingleTickerProviderStateMixin {
  final _api = ApiService();
  late TabController _tabs;

  List<dynamic> _disponibles = [];
  bool _loadingDisponibles = true;
  bool _working = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgramaProvider>().loadVoluntarios();
      _loadDisponibles();
    });
  }

  Future<void> _loadDisponibles() async {
    setState(() => _loadingDisponibles = true);
    try {
      final data = await _api.getVoluntariosDisponibles();
      setState(() => _disponibles = data);
    } catch (_) {
    } finally {
      setState(() => _loadingDisponibles = false);
    }
  }

  Future<void> _agregar(int voluntarioId, String nombre) async {
    setState(() => _working = true);
    try {
      await _api.agregarVoluntarioAPrograma(voluntarioId);
      if (mounted) {
        context.read<ProgramaProvider>().loadVoluntarios();
        await _loadDisponibles();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$nombre agregado al programa'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _quitar(int voluntarioId, String nombre) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Quitar voluntario'),
        content: Text('¿Quitar a $nombre del programa?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Quitar'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _working = true);
    try {
      await _api.quitarVoluntarioDePrograma(voluntarioId);
      if (mounted) {
        context.read<ProgramaProvider>().loadVoluntarios();
        await _loadDisponibles();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$nombre removido del programa'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final programaProv = context.watch<ProgramaProvider>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        flexibleSpace: Container(decoration: BoxDecoration(gradient: AppTheme.primaryGradient)),
        title: const Text('Gestionar Voluntarios'),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(text: 'En mi programa (${programaProv.voluntarios.length})'),
            Tab(text: 'Disponibles (${_disponibles.length})'),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabs,
            children: [
              // Tab 1: voluntarios asignados al programa
              RefreshIndicator(
                color: AppTheme.primaryTeal,
                onRefresh: () => programaProv.loadVoluntarios(),
                child: programaProv.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : programaProv.voluntarios.isEmpty
                        ? const Center(
                            child: Text('No hay voluntarios en tu programa',
                                style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: programaProv.voluntarios.length,
                            itemBuilder: (_, i) {
                              final v = programaProv.voluntarios[i];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                elevation: 1,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: AppTheme.primaryTeal.withOpacity(0.12),
                                    child: Text(
                                      (v['nombre'] as String? ?? '?')[0].toUpperCase(),
                                      style: const TextStyle(
                                          color: AppTheme.primaryTeal, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  title: Text(v['nombre'] ?? '',
                                      style: const TextStyle(fontWeight: FontWeight.w600)),
                                  subtitle: Text(v['email'] ?? '',
                                      style: const TextStyle(fontSize: 12)),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.person_remove, color: Colors.red),
                                    tooltip: 'Quitar del programa',
                                    onPressed: _working
                                        ? null
                                        : () => _quitar(v['id'] as int, v['nombre'] ?? ''),
                                  ),
                                ),
                              );
                            },
                          ),
              ),

              // Tab 2: voluntarios disponibles (sin programa o con otro)
              RefreshIndicator(
                color: AppTheme.primaryTeal,
                onRefresh: _loadDisponibles,
                child: _loadingDisponibles
                    ? const Center(child: CircularProgressIndicator())
                    : _disponibles.isEmpty
                        ? const Center(
                            child: Text('No hay voluntarios disponibles',
                                style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _disponibles.length,
                            itemBuilder: (_, i) {
                              final v = _disponibles[i];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                elevation: 1,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.grey.withOpacity(0.12),
                                    child: Text(
                                      (v['nombre'] as String? ?? '?')[0].toUpperCase(),
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  title: Text(v['nombre'] ?? '',
                                      style: const TextStyle(fontWeight: FontWeight.w600)),
                                  subtitle: Text(v['email'] ?? '',
                                      style: const TextStyle(fontSize: 12)),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.person_add, color: AppTheme.primaryTeal),
                                    tooltip: 'Agregar al programa',
                                    onPressed: _working
                                        ? null
                                        : () => _agregar(v['id'] as int, v['nombre'] ?? ''),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
          if (_working)
            const ColoredBox(
              color: Colors.black26,
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
