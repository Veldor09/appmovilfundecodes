import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_theme.dart';
import '../../models/tarea_model.dart';
import '../../providers/tareas_provider.dart';

class TareaDetailScreen extends StatelessWidget {
  final TareaModel tarea;
  const TareaDetailScreen({super.key, required this.tarea});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(decoration: BoxDecoration(gradient: AppTheme.primaryGradient)),
        title: const Text('Detalle de Tarea'),
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(label: 'Programa', value: tarea.programaNombre, icon: Icons.groups),
                _InfoRow(label: 'Descripción', value: tarea.descripcion, icon: Icons.task),
                _InfoRow(label: 'Fecha límite', value: tarea.fechaLimite, icon: Icons.calendar_today),
                _InfoRow(
                  label: 'Estado',
                  value: tarea.estado,
                  icon: Icons.info_outline,
                  valueColor: AppTheme.statusColor(tarea.estado),
                ),
              ],
            ),
          ),
          if (tarea.estado == 'APROBADA' || tarea.estado == 'RECHAZADA')
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber.shade700),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Esta tarea fue ${tarea.estado.toLowerCase()} por el encargado.',
                      style: TextStyle(color: Colors.amber.shade900, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          if (tarea.estado == 'PENDIENTE')
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Marcar como Completada'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.statusCompletada,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Confirmar'),
                      content: const Text('¿Marcar esta tarea como completada?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                        ElevatedButton(
                            onPressed: () => Navigator.pop(context, true), child: const Text('Confirmar')),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    final ok = await context.read<TareasProvider>().marcarCompletada(tarea.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(ok ? 'Tarea marcada como completada' : 'Error al actualizar'),
                        backgroundColor: ok ? Colors.green : Colors.red,
                      ));
                      if (ok) Navigator.pop(context);
                    }
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, required this.icon, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryTeal),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value,
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500, color: valueColor ?? Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
