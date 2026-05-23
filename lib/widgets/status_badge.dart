import 'package:flutter/material.dart';
import '../app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String estado;

  const StatusBadge({super.key, required this.estado});

  IconData get _icon {
    switch (estado.toUpperCase()) {
      case 'PENDIENTE':   return Icons.schedule;
      case 'COMPLETADA':  return Icons.check_circle_outline;
      case 'APROBADA':    return Icons.verified;
      case 'RECHAZADA':   return Icons.cancel_outlined;
      default:            return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.statusColor(estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            estado,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
