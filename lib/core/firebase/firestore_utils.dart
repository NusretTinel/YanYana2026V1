import 'package:cloud_firestore/cloud_firestore.dart';

DateTime parseFirestoreDate(dynamic value, {DateTime? fallback}) {
  final base = fallback ?? DateTime.now();
  if (value == null) return base;
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.tryParse(value) ?? base;
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  // Pending server timestamp in local cache right after a write.
  if (value is FieldValue) return base;
  return base;
}

/// Sort newest first. Avoids Firestore [orderBy] excluding docs without the field.
void sortByNewest<T>(List<T> items, DateTime Function(T item) readDate) {
  items.sort((a, b) => readDate(b).compareTo(readDate(a)));
}
