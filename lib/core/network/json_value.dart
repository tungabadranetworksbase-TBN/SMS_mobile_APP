Map<String, dynamic> jsonMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return {};
}

List<dynamic> jsonList(dynamic value) {
  if (value is List) return value;
  return const [];
}

String jsonStr(dynamic value, [String fallback = '']) {
  if (value == null) return fallback;
  return value.toString();
}

DateTime? jsonDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

int jsonInt(dynamic value, [int fallback = 0]) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

double jsonDouble(dynamic value, [double fallback = 0]) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}
