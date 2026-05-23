import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_theme.dart';
import '../../models/tarea_model.dart';
import '../../providers/tareas_provider.dart';
import '../../widgets/shimmer_card.dart';
import '../../widgets/empty_state.dart';

class TareasCompletadasScreen extends StatefulWidget {
  const TareasCompletadasScreen({super.key});

  @override
  State<TareasCompletadasScreen> createState() => _TareasCompletadasScreenState();
}

class _TareasCompletadasScreenState extends State<TareasCompletadasScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TareasProvider>().loadTareasCompletadas();
    });
  }

  Future<void> _actualizarEstado(TareaModel tarea, String estado) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(estado == 'APROBADA' ? 'Aprobar tarea' : 'Rechazar tarea'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Voluntario: ${tarea.voluntarioNombre}',
                style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Text(tarea.descripcion, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: estado == 'APROBADA' ? Colors.green : Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(estado == 'APROBADA' ? 'Aprobar' : 'Rechazar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final ok = await context.read<TareasProvider>().actualizarEstado(tarea.id, estado);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ok ? 'Tarea ${estado.toLowerCase()} correctamente' : 'Error al actualizar'),
          backgroundColor: ok ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tareasProv = context.watch<TareasProvider>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        flexibleSpace: Container(decoration: BoxDecoration(gradient: AppTheme.primaryGradient)),
        title: Row(
          children: [
            const Text('Revisar Completadas'),
            if (tareasProv.tareasCompletadas.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                child: Text('${tareasProv.tareasCompletadas.length}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryTeal,
        onRefresh: () => context.read<TareasProvider>().loadTareasCompletadas(),
        child: tareasProv.isLoading
            ? const Padding(
                padding: EdgeInsets.all(16),
                child: ShimmerList(count: 3, itemHeight: 130),
              )
            : tareasProv.tareasCompletadas.isEmpty
                ? EmptyState(
                    icon: Icons.task_alt,
                    title: 'Sin tareas por revisar',
                    subtitle: 'Cuando un voluntario complete una tarea, aparecerá aquí.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: tareasProv.tareasCompletadas.length,
                    itemBuilder: (context, index) {
                      final tarea = tareasProv.tareasCompletadas[index];
                      return _ReviewCard(
                        tarea: tarea,
                        onAprobar: () => _actualizarEstado(tarea, 'APROBADA'),
                        onRechazar: () => _actualizarEstado(tarea, 'RECHAZADA'),
                      );
                    },
                  ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final TareaModel tarea;
  final VoidCallback onAprobar;
  final VoidCallback onRechazar;

  const _ReviewCard({required this.tarea, required this.onAprobar, required this.onRechazar});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.statusCompletada.withOpacity(0.15),
                  child: Text(
                    tarea.voluntarioNombre[0].toUpperCase(),
                    style: const TextStyle(color: AppTheme.statusCompletada, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tarea.voluntarioNombre,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      Text(tarea.programaNombre,
                          style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.statusCompletada.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outline, size: 12, color: AppTheme.statusCompletada),
                      SizedBox(width: 3),
                      Text('Completada',
                          style: TextStyle(color: AppTheme.statusCompletada, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Text(tarea.descripcion,
                style: const TextStyle(fontSize: 14, color: Colors.black87)),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text('Límite: ${tarea.fechaLimite.split('T').first}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Rechazar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: onRechazar,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Aprobar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: onAprobar,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
