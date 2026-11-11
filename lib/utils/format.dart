String formatPrice(Object amount) {
  final v = double.tryParse(amount.toString());
  if (v == null) return amount.toString();
  return v
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ' ');
}

String formatDate(Object value) {
  final d = DateTime.tryParse(value.toString())?.toLocal();
  if (d == null) return value.toString();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}.${two(d.month)}.${d.year} ${two(d.hour)}:${two(d.minute)}';
}
