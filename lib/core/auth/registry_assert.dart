import 'destinations.dart';

/// Asserts every `anyOf` key in [destinations] appears in a
/// `GET /staff/registry` payload (`{ modules: [{ key, label, permissions[] }] }`).
///
/// Throws [StateError] naming the first missing key — silent invisible tabs
/// are worse than a loud CI failure (spec §4.2.1).
void assertDestinationsInRegistry(
  List<Map<String, dynamic>> modules, {
  List<Destination> destinations = kStaffDestinations,
}) {
  final keys = <String>{};
  for (final m in modules) {
    final perms = m['permissions'];
    if (perms is! List) continue;
    for (final p in perms) {
      keys.add(p.toString());
    }
  }
  for (final d in destinations) {
    for (final key in d.anyOf) {
      if (!keys.contains(key)) {
        throw StateError(
          'Destination "${d.label}" references unknown permission "$key"',
        );
      }
    }
  }
}
