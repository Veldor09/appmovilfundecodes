import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import 'crear_usuario_screen.dart';
import 'crear_programa_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final _api = ApiService();

  List<dynamic> _usuarios = [];
  List<dynamic> _programas = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([_api.adminGetUsuarios(), _api.adminGetProgramas()]);
      setState(() {
        _usuarios = results[0];
        _programas = results[1];
      });
    } catch (_) {
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro que deseas salir?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Salir')),
        ],
      ),
    );
    if (confirm == true && mounted) context.read<AuthProvider>().logout();
  }

  void _irCrearUsuario() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const CrearUsuarioScreen()))
        .then((_) => _load());
  }

  void _irCrearPrograma() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const CrearProgramaScreen()))
        .then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final encargados = _usuarios.where((u) => u['rol'] == 'ENCARGADO').length;
    final voluntarios = _usuarios.where((u) => u['rol'] == 'VOLUNTARIO').length;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        flexibleSpace: Container(decoration: BoxDecoration(gradient: AppTheme.primaryGradient)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hola, ${auth.user?.nombre.split(' ').first ?? ''}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text('Administrador', style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.logout), tooltip: 'Cerrar sesión', onPressed: _logout),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryTeal,
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Stats banner
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryTeal.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(label: 'Usuarios', value: '${_usuarios.length}', icon: Icons.people),
                        _StatItem(label: 'Encargados', value: '$encargados', icon: Icons.manage_accounts),
                        _StatItem(label: 'Voluntarios', value: '$voluntarios', icon: Icons.volunteer_activism),
                        _StatItem(label: 'Programas', value: '${_programas.length}', icon: Icons.folder_special),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text('Acciones', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _AdminAction(
                          icon: Icons.person_add,
                          label: 'Crear\nUsuario',
                          color: AppTheme.primaryTeal,
                          onTap: _irCrearUsuario,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _AdminAction(
                          icon: Icons.create_new_folder,
                          label: 'Crear\nPrograma',
                          color: AppTheme.primaryBlue,
                          onTap: _irCrearPrograma,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Usuarios list
                  Row(
                    children: [
                      const Text('Usuarios', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryTeal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('${_usuarios.length}',
                            style: const TextStyle(
                                color: AppTheme.primaryTeal, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._usuarios.map((u) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _rolColor(u['rol']).withOpacity(0.15),
                            child: Text(
                              (u['nombre'] as String? ?? '?')[0].toUpperCase(),
                              style: TextStyle(color: _rolColor(u['rol']), fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(u['nombre'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          subtitle: Text(u['email'] ?? '', style: const TextStyle(fontSize: 12)),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _rolColor(u['rol']).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(u['rol'] ?? '',
                                style: TextStyle(
                                    color: _rolColor(u['rol']), fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      )),
                  const SizedBox(height: 24),

                  // Programas list
                  Row(
                    children: [
                      const Text('Programas', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('${_programas.length}',
                            style: const TextStyle(
                                color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._programas.map((p) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.folder_special, color: AppTheme.primaryBlue, size: 20),
                          ),
                          title: Text(p['nombre'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          subtitle: Text(
                            'Encargado: ${p['encargado']?['nombre'] ?? 'Sin encargado'}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('${p['_count']?['voluntarios'] ?? 0}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const Text('voluntarios', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
      ),
    );
  }

  Color _rolColor(String? rol) {
    switch (rol) {
      case 'ADMIN':
        return Colors.deepPurple;
      case 'ENCARGADO':
        return AppTheme.primaryBlue;
      default:
        return AppTheme.primaryTeal;
    }
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

class _AdminAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AdminAction(
      {required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 34),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
