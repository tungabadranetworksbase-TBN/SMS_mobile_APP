import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/open_url.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../controllers/auth_controller.dart';
import '../../data/models/registration_status_dto.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  RegistrationStatusDto? _status;
  String? _error;
  bool _loadingStatus = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadStatus());
  }

  Future<void> _loadStatus() async {
    try {
      final status = await ref
          .read(authControllerProvider.notifier)
          .registrationStatus();
      if (!mounted) return;
      setState(() {
        _status = status;
        _error = null;
        _loadingStatus = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loadingStatus = false;
      });
    }
  }

  Future<void> _pickAndSubmit() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;
    try {
      await ref
          .read(authControllerProvider.notifier)
          .submitRegistrationReceipt(file.path);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Receipt submitted. Staff will verify it shortly.'),
        ),
      );
      await _loadStatus();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _payOnline() async {
    try {
      final url = await ref
          .read(authControllerProvider.notifier)
          .startRegistrationCheckout();
      if (url == null || url.isEmpty) {
        throw const ApiException(message: 'No payment URL returned.');
      }
      if (!await openExternalUrl(url)) {
        throw ApiException(message: 'Could not open $url');
      }
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
    final status = _status;
    final feeLabel = status == null || status.feeAmount == 0
        ? ''
        : NumberFormat.simpleCurrency(
            name: status.feeCurrency,
          ).format(status.feeAmount);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xxl),
              const Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Registration fee',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _loadingStatus
                    ? 'Checking your registration status…'
                    : (_error ??
                          status?.message ??
                          (status?.paid == true
                              ? 'Your registration fee is verified.'
                              : 'Pay the fee to unlock courses.')),
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (feeLabel.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  feeLabel,
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (status != null && status.status.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  status.status,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const Spacer(),
              if (_error != null)
                TextButton(
                  onPressed: _loadingStatus
                      ? null
                      : () {
                          setState(() => _loadingStatus = true);
                          _loadStatus();
                        },
                  child: const Text('Try again'),
                ),
              if (status?.onlinePayment == true && status?.paid != true)
                ElevatedButton(
                  onPressed: isLoading ? null : _payOnline,
                  child: const Text('Pay online'),
                ),
              if (status?.paid != true) ...[
                const SizedBox(height: AppSpacing.md),
                OutlinedButton(
                  onPressed: isLoading ? null : _pickAndSubmit,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Upload receipt photo'),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
