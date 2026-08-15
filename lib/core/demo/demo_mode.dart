/// Tungabadra Networks LMS — Demo Mode Manager
///
/// Lightweight singleton that tells the app whether to use mock data
/// instead of real API calls. Activated from the Server Config screen.
class DemoMode {
  static final DemoMode _instance = DemoMode._internal();
  factory DemoMode() => _instance;
  DemoMode._internal();

  bool _isActive = false;
  String _selectedRole = 'student';

  bool get isActive => _isActive;
  String get selectedRole => _selectedRole;

  void activate({String role = 'student'}) {
    _isActive = true;
    _selectedRole = role;
  }

  void deactivate() {
    _isActive = false;
    _selectedRole = 'student';
  }
}
