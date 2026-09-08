import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/router/route_names.dart';
import '../../controllers/auth_controller.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String email;
  final String? password;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    this.password,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  var _sentOnOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureOtpSent());
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _ensureOtpSent() async {
    if (_sentOnOpen) return;
    _sentOnOpen = true;
    if (widget.password != null) {
      try {
        await ref
            .read(authControllerProvider.notifier)
            .sendEmailVerificationOtp(widget.email);
      } catch (_) {
        // Signup already sent one; a second send is best-effort.
      }
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final notifier = ref.read(authControllerProvider.notifier);
    try {
      await notifier.verifyEmailOtp(
        widget.email,
        _otpController.text.trim(),
      );
      if (widget.password != null && widget.password!.isNotEmpty) {
        await notifier.login(widget.email, widget.password!);
        return;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email verified. Please log in.'),
          backgroundColor: AppColors.success,
        ),
      );
      context.goNamed(RouteNames.login);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.mark_email_read_outlined,
                  size: 64,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Verify your email',
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Enter the code sent to ${widget.email}.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  style: AppTypography.bodyLarge,
                  decoration: const InputDecoration(
                    labelText: 'Verification code',
                    prefixIcon: Icon(Icons.pin_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter the code';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Verify'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
