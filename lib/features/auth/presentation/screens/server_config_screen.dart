import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/capabilities.dart';
import '../../../../core/auth/capabilities_store.dart';
import '../../../../core/auth/destinations.dart';
import '../../../../core/config/app_constants.dart';
import '../../../../core/demo/demo_data.dart';
import '../../../../core/demo/demo_mode.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/managers/session_manager.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/storage/preference_manager.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/buttons/gradient_button.dart';
import '../../controllers/auth_controller.dart';

class ServerConfigScreen extends ConsumerStatefulWidget {
  const ServerConfigScreen({super.key});

  @override
  ConsumerState<ServerConfigScreen> createState() => _ServerConfigScreenState();
}

class _ServerConfigScreenState extends ConsumerState<ServerConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill if already exists
    final savedUrl = locator<PreferenceManager>().getServerUrl();
    if (savedUrl != null) {
      _urlController.text = savedUrl;
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _validateAndSaveUrl() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Clean URL
    String url = _urlController.text.trim();
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    if (!url.startsWith('http')) {
      url = 'https://$url';
    }

    // Temporarily update ApiClient to test the new URL
    locator<ApiClient>().updateBaseUrl(url);

    // Ping Health Check
    final isHealthy = await ref
        .read(authControllerProvider.notifier)
        .checkServerHealth();

    if (!mounted) return;

    if (isHealthy) {
      // Deactivate demo if active
      DemoMode().deactivate();
      await locator<PreferenceManager>().remove(AppConstants.keyDemoRole);

      // Save valid URL globally
      await locator<PreferenceManager>().setServerUrl(url);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Server connected successfully!'),
          backgroundColor: AppColors.success,
        ),
      );

      // Navigate to login
      context.goNamed(RouteNames.login);
    } else {
      // Revert if failed
      final previousUrl = locator<PreferenceManager>().getServerUrl();
      if (previousUrl != null) {
        locator<ApiClient>().updateBaseUrl(previousUrl);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to connect to server. Please check the URL.'),
          backgroundColor: AppColors.error,
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  void _startDemo(String role) async {
    // 1. Activate demo mode
    DemoMode().activate(role: role);
    await locator<PreferenceManager>().setString(
      AppConstants.keyDemoRole,
      role,
    );

    // 2. Set dummy server URL so router doesn't block access
    await locator<PreferenceManager>().setServerUrl(
      'https://demo.tungabadranetworks.com',
    );
    locator<ApiClient>().updateBaseUrl('https://demo.tungabadranetworks.com');

    // 3. Save dummy session
    final profile = DemoData.getProfile(role);
    locator<CapabilitiesStore>().set(Capabilities.demo(role));
    await locator<SessionManager>().saveSession(
      token: 'demo-token',
      refreshToken: 'demo-refresh-token',
      userId: profile.id,
      userName: profile.name,
      userEmail: profile.email,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logged in as ${role.toUpperCase()} (Demo Mode)'),
        backgroundColor: AppColors.success,
      ),
    );

    context.go(homeRouteFor(Capabilities.demo(role)));
  }

  void _showDemoRoleSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDim,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Choose Demo Role',
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                ListTile(
                  leading: const Icon(
                    Icons.school_rounded,
                    color: AppColors.primary,
                  ),
                  title: const Text(
                    'Student Dashboard',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  subtitle: const Text(
                    'View courses, modules, videos, assignments',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _startDemo('student');
                  },
                ),
                const Divider(color: AppColors.outlineVariant),
                ListTile(
                  leading: const Icon(
                    Icons.badge_rounded,
                    color: AppColors.primary,
                  ),
                  title: const Text(
                    'SMR (Staff) Dashboard',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  subtitle: const Text(
                    'Monitor student progress, attendance, support tickets',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _startDemo('smr');
                  },
                ),
                const Divider(color: AppColors.outlineVariant),
                ListTile(
                  leading: const Icon(
                    Icons.admin_panel_settings_rounded,
                    color: AppColors.primary,
                  ),
                  title: const Text(
                    'Admin Dashboard',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  subtitle: const Text(
                    'Analytics, revenue data, server status',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _startDemo('admin');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.dns_rounded,
                    size: 64,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Workspace Configuration',
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Enter your organization\'s LMS server URL to continue.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  TextFormField(
                    controller: _urlController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Server URL',
                      hintText: 'e.g., https://lms.company.com',
                      prefixIcon: const Icon(Icons.link_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a server URL';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  GradientButton(
                    text: 'Connect',
                    onPressed: _validateAndSaveUrl,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: _showDemoRoleSelector,
                    child: Text(
                      'Explore App Demo (Offline)',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
