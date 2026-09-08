/// Set from [service_locator] after [AuthRepository] is registered.
Future<void> Function()? capabilitiesRefresh;

Future<void> refreshCapabilitiesSafely() async {
  final fn = capabilitiesRefresh;
  if (fn == null) return;
  try {
    await fn();
  } catch (_) {
    // Resume / gate refresh is best-effort.
  }
}
