import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_theme.dart';
import '../../models/tarea_model.dart';
import '../../providers/tareas_provider.dart';
import '../../utils/date_helper.dart';
import '../../widgets/shimmer_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';

class TodasTareasScreen extends StatefulWidget {
  const TodasTareasScreen({super.key});

  @override
  State<TodasTareasScreen> createState() => _TodasTareasScreenState();
}

class _TodasTareasScreenState extends State<TodasTareasScreen> {
  String _filtro = 'TODOS';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TareasProvider>().loadTareasDelPrograma();
    });
  }

  List<TareaModel> _filtrar(List<TareaModel> tareas) {
    if (_filtro == 'TODOS') return tareas;
    return tareas.where((t) => t.estado == _filtro).toList();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<TareasProvider>();
    final filtradas = _filtrar(prov.tareasDelPrograma);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        flexibleSpace: Container(decoration: BoxDecoration(gradient: AppTheme.primaryGradient)),
        title: Row(
          children: [
            const Text('Todas las Tareas'),
            if (prov.tareasDelPrograma.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                child: Text('${prov.tareasDelPrograma.length}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryTeal,
        onRefresh: () => context.read<TareasProvider>().loadTareasDelPrograma(),
        child: Column(
          children: [
            // Resumen de conteos por estado
            if (!prov.isLoading && prov.tareasDelPrograma.isNotEmpty)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    for (final entry in [
                      ('PENDIENTE', 'Pendientes'),
                      ('COMPLETADA', 'En revisión'),
                      ('APROBADA', 'Aprobadas'),
                      ('RECHAZADA', 'Rechazadas'),
                    ])
                      Expanded(
                        child: _StatChip(
                          count: prov.tareasDelPrograma.where((t) => t.estado == entry.$1).length,
                          label: entry.$2,
                          color: AppTheme.statusColor(entry.$1),
                        ),
                      ),
                  ],
                ),
              ),

            // Filtros
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: ['TODOS', 'PENDIENTE', 'COMPLETADA', 'APROBADA', 'RECHAZADA']
                    .map((f) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(f == 'TODOS' ? 'Todos' : f[0] + f.substring(1).toLowerCase(),
                                style: const TextStyle(fontSize: 11)),
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

            // Lista
            Expanded(
              child: prov.isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: ShimmerList(count: 4, itemHeight: 100),
                    )
                  : filtradas.isEmpty
                      ? EmptyState(
                          icon: Icons.assignment_outlined,
                          title: 'Sin tareas',
                          subtitle: _filtro == 'TODOS'
                              ? 'No hay tareas creadas aún.'
                              : 'No hay tareas con estado "${_filtro.toLowerCase()}".',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filtradas.length,
                          itemBuilder: (_, i) => _TareaEncargadoCard(tarea: filtradas[i]),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  const _StatChip({required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$count', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey), overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

class _TareaEncargadoCard extends StatelessWidget {
  final TareaModel tarea;
  const _TareaEncargadoCard({required this.tarea});

  @override
  Widget build(BuildContext context) {
    final statusColor = AppTheme.statusColor(tarea.estado);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppTheme.primaryTeal.withOpacity(0.1),
                  child: Text(
                    tarea.voluntarioNombre[0].toUpperCase(),
                    style: const TextStyle(color: AppTheme.primaryTeal, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(tarea.voluntarioNombre,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
                StatusBadge(estado: tarea.estado),
              ],
            ),
            const SizedBox(height: 8),
            Text(tarea.descripcion,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.calendar_today, size: 11, color: Colors.grey),
              const SizedBox(width: 4),
              Text('Límite: ${formatFecha(tarea.fechaLimite)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ]),
          ],
        ),
      ),
    );
  }
}
