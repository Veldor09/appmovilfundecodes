import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_theme.dart';
import '../../models/tarea_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/programa_provider.dart';
import '../../providers/tareas_provider.dart';
import '../../utils/date_helper.dart';
import '../../widgets/shimmer_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';
import 'tarea_detail_screen.dart';

class VoluntarioHomeScreen extends StatefulWidget {
  const VoluntarioHomeScreen({super.key});

  @override
  State<VoluntarioHomeScreen> createState() => _VoluntarioHomeScreenState();
}

class _VoluntarioHomeScreenState extends State<VoluntarioHomeScreen> {
  String _filtro = 'TODOS';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TareasProvider>().loadMisTareas();
      context.read<ProgramaProvider>().loadPrograma();
    });
  }

  List<TareaModel> _filtrarTareas(List<TareaModel> tareas) {
    if (_filtro == 'TODOS') return tareas;
    return tareas.where((t) => t.estado == _filtro).toList();
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
    final tareasProv = context.watch<TareasProvider>();
    final programaProv = context.watch<ProgramaProvider>();
    final tareasFiltradas = _filtrarTareas(tareasProv.misTareas);
    final pendientes = tareasProv.misTareas.where((t) => t.estado == 'PENDIENTE').length;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        flexibleSpace: Container(decoration: BoxDecoration(gradient: AppTheme.primaryGradient)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hola, ${auth.user?.nombre.split(' ').first ?? ''}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text('Voluntario', style: TextStyle(fontSize: 12, color: Colors.white70)),
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
            context.read<TareasProvider>().loadMisTareas(),
            context.read<ProgramaProvider>().loadPrograma(),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Tarjeta del programa
            if (programaProv.isLoading)
              const ShimmerCard(height: 90)
            else if (programaProv.programa != null)
              _ProgramaCard(
                nombre: programaProv.programa!.nombre,
                encargado: programaProv.programa!.encargadoNombre,
              ),
            const SizedBox(height: 16),

            // Resumen de tareas
            if (!tareasProv.isLoading && tareasProv.misTareas.isNotEmpty)
              _ResumenRow(tareas: tareasProv.misTareas),
            const SizedBox(height: 16),

            // Header + filtros
            Row(
              children: [
                const Text('Mis Tareas',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                const Spacer(),
                if (pendientes > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.statusPendiente,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('$pendientes pendiente${pendientes > 1 ? 's' : ''}',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['TODOS', 'PENDIENTE', 'COMPLETADA', 'APROBADA', 'RECHAZADA']
                    .map((f) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(f, style: const TextStyle(fontSize: 11)),
                            selected: _filtro == f,
                            onSelected: (_) => setState(() => _filtro = f),
                            selectedColor: AppTheme.primaryTeal.withOpacity(0.15),
                            checkmarkColor: AppTheme.primaryTeal,
                            side: BorderSide(
                              color: _filtro == f ? AppTheme.primaryTeal : Colors.grey.shade300,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Lista
            if (tareasProv.isLoading)
              const ShimmerList(count: 3, itemHeight: 90)
            else if (tareasProv.error != null)
              EmptyState(
                icon: Icons.wifi_off,
                title: 'Sin conexión',
                subtitle: tareasProv.error!,
                action: ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                  onPressed: () => context.read<TareasProvider>().loadMisTareas(),
                ),
              )
            else if (tareasFiltradas.isEmpty)
              EmptyState(
                icon: Icons.task_alt,
                title: 'Sin tareas',
                subtitle: _filtro == 'TODOS'
                    ? 'No tienes tareas asignadas aún.'
                    : 'No hay tareas con estado "$_filtro".',
              )
            else
              ...tareasFiltradas.map((t) => _TareaCard(tarea: t)),
          ],
        ),
      ),
    );
  }
}

// ─── Tarjeta del programa ──────────────────────────────────────
class _ProgramaCard extends StatelessWidget {
  final String nombre;
  final String encargado;
  const _ProgramaCard({required this.nombre, required this.encargado});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppTheme.primaryTeal.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.groups, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nombre, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.person, color: Colors.white60, size: 13),
                  const SizedBox(width: 4),
                  Expanded(child: Text('Encargado: $encargado',
                      style: const TextStyle(color: Colors.white70, fontSize: 12), overflow: TextOverflow.ellipsis)),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Fila de resumen ──────────────────────────────────────────
class _ResumenRow extends StatelessWidget {
  final List<TareaModel> tareas;
  const _ResumenRow({required this.tareas});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('PENDIENTE', 'Pendiente'),
      ('COMPLETADA', 'Completada'),
      ('APROBADA', 'Aprobada'),
      ('RECHAZADA', 'Rechazada'),
    ];
    return Row(
      children: items.asMap().entries.map((entry) {
        final i = entry.key;
        final estado = entry.value.$1;
        final label = entry.value.$2;
        final count = tareas.where((t) => t.estado == estado).length;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
            ),
            child: Column(children: [
              Text('$count',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                      color: AppTheme.statusColor(estado))),
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey),
                  overflow: TextOverflow.ellipsis),
            ]),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Tarjeta de tarea ──────────────────────────────────────────
class _TareaCard extends StatelessWidget {
  final TareaModel tarea;
  const _TareaCard({required this.tarea});

  @override
  Widget build(BuildContext context) {
    final statusColor = AppTheme.statusColor(tarea.estado);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TareaDetailScreen(tarea: tarea))),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: statusColor, width: 4)),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(tarea.descripcion,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(estado: tarea.estado),
                ],
              ),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text('Límite: ${formatFecha(tarea.fechaLimite)}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const Spacer(),
                const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
