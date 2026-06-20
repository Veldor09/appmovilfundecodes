import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_theme.dart';
import '../../models/tarea_model.dart';
import '../../providers/tareas_provider.dart';
import '../../utils/date_helper.dart';

class TareaDetailScreen extends StatelessWidget {
  final TareaModel tarea;
  const TareaDetailScreen({super.key, required this.tarea});

  @override
  Widget build(BuildContext context) {
    final bool aprobada = tarea.estado == 'APROBADA';
    final bool rechazada = tarea.estado == 'RECHAZADA';
    final bool resuelta = aprobada || rechazada;

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
                _InfoRow(label: 'Título', value: tarea.tituloDisplay, icon: Icons.title),
                _InfoRow(label: 'Descripción', value: tarea.descripcion, icon: Icons.notes),
                _InfoRow(
                  label: 'Fecha límite',
                  value: formatFecha(tarea.fechaLimite),
                  icon: Icons.calendar_today,
                ),
                _InfoRow(
                  label: 'Estado',
                  value: tarea.estado[0] + tarea.estado.substring(1).toLowerCase(),
                  icon: Icons.info_outline,
                  valueColor: AppTheme.statusColor(tarea.estado),
                ),
              ],
            ),
          ),

          if (resuelta)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: aprobada ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: aprobada ? Colors.green.shade300 : Colors.red.shade300),
              ),
              child: Row(
                children: [
                  Icon(
                    aprobada ? Icons.check_circle_outline : Icons.cancel_outlined,
                    color: aprobada ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          aprobada
                              ? 'Esta tarea fue aprobada por el encargado.'
                              : 'Esta tarea fue rechazada por el encargado.',
                          style: TextStyle(
                            color: aprobada ? Colors.green.shade900 : Colors.red.shade900,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (!aprobada && tarea.comentario != null && tarea.comentario!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Motivo: ${tarea.comentario}',
                            style: TextStyle(color: Colors.red.shade800, fontSize: 13),
                          ),
                        ],
                      ],
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: const Text('Confirmar'),
                      content: const Text('¿Marcar esta tarea como completada?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancelar')),
                        ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Confirmar')),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    final ok = await context.read<TareasProvider>().marcarCompletada(tarea.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(ok ? 'Tarea marcada como completada' : 'Error al actualizar'),
                        backgroundColor: ok ? Colors.green : Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
