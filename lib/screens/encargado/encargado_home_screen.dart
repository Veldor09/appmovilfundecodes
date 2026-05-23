import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/programa_provider.dart';
import '../../providers/tareas_provider.dart';
import '../../widgets/shimmer_card.dart';
import '../../widgets/empty_state.dart';
import 'crear_tarea_screen.dart';
import 'tareas_completadas_screen.dart';

class EncargadoHomeScreen extends StatefulWidget {
  const EncargadoHomeScreen({super.key});

  @override
  State<EncargadoHomeScreen> createState() => _EncargadoHomeScreenState();
}

class _EncargadoHomeScreenState extends State<EncargadoHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgramaProvider>().loadPrograma();
      context.read<ProgramaProvider>().loadVoluntarios();
      context.read<TareasProvider>().loadTareasCompletadas();
    });
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

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final programaProv = context.watch<ProgramaProvider>();
    final tareasProv = context.watch<TareasProvider>();
    final pendientesRevision = tareasProv.tareasCompletadas.length;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        flexibleSpace: Container(decoration: BoxDecoration(gradient: AppTheme.primaryGradient)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hola, ${auth.user?.nombre.split(' ').first ?? ''}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text('Encargado', style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.logout), tooltip: 'Cerrar sesión', onPressed: _logout),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryTeal,
        onRefresh: () async {
          await Future.wait([
            context.read<ProgramaProvider>().loadPrograma(),
            context.read<ProgramaProvider>().loadVoluntarios(),
            context.read<TareasProvider>().loadTareasCompletadas(),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Banner del programa
            if (programaProv.isLoading)
              const ShimmerCard(height: 100)
            else if (programaProv.programa != null)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(
                    color: AppTheme.primaryTeal.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.supervisor_account, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(programaProv.programa!.nombre,
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('${programaProv.voluntarios.length} voluntarios asignados',
                              style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            // Acciones rápidas
            const Text('Acciones', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.add_task,
                    label: 'Crear Tarea',
                    color: AppTheme.primaryTeal,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CrearTareaScreen()),
                    ).then((_) => context.read<TareasProvider>().loadTareasCompletadas()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.done_all,
                    label: 'Revisar\nCompletadas',
                    color: AppTheme.statusCompletada,
                    badge: pendientesRevision,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TareasCompletadasScreen()),
                    ).then((_) => context.read<TareasProvider>().loadTareasCompletadas()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Lista de voluntarios
            Row(
              children: [
                const Text('Voluntarios', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                const Spacer(),
                if (programaProv.voluntarios.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('${programaProv.voluntarios.length}',
                        style: const TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (programaProv.isLoading)
              const ShimmerList(count: 3, itemHeight: 64)
            else if (programaProv.voluntarios.isEmpty)
              EmptyState(
                icon: Icons.group_off,
                title: 'Sin voluntarios',
                subtitle: 'No hay voluntarios asignados a tu programa.',
              )
            else
              ...programaProv.voluntarios.map(
                (v) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 1,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryTeal.withOpacity(0.12),
                      child: Text(
                        (v['nombre'] as String? ?? '?')[0].toUpperCase(),
                        style: const TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(v['nombre'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                    subtitle: Text(v['email'] ?? '', style: const TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final int badge;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 34),
                const SizedBox(height: 8),
                Text(label,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
            if (badge > 0)
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: Text('$badge',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
