String formatFecha(String isoDate) {
  try {
    final dt = DateTime.parse(isoDate);
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  } catch (_) {
    return isoDate.split('T').first;
  }
}
