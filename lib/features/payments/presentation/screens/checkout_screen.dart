import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/open_url.dart';
import '../../../../shared/widgets/buttons/gradient_button.dart';
import '../../controllers/checkout_controller.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final String courseId;
  final String courseTitle;
  final double price;

  const CheckoutScreen({
    super.key,
    required this.courseId,
    required this.courseTitle,
    required this.price,
  });

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  CheckoutOutcome? _manual;
  final _referenceCtrl = TextEditingController();
  bool _submittingProof = false;

  @override
  void dispose() {
    _referenceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    try {
      final outcome = await ref
          .read(checkoutControllerProvider.notifier)
          .startCheckout(courseId: widget.courseId);
      final url = outcome.url;
      if (url != null && url.isNotEmpty) {
        final launched = await openExternalUrl(url);
        if (!launched) {
          throw const ApiException(message: 'Could not open checkout.');
        }
        return;
      }
      if (!mounted) return;
      setState(() => _manual = outcome);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _submitProof() async {
    final order = _manual;
    if (order == null) return;
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;
    setState(() => _submittingProof = true);
    try {
      final amount = order.total > 0 ? order.total : widget.price;
      await ref
          .read(checkoutControllerProvider.notifier)
          .submitManualPayment(
            orderId: order.orderId,
            receiptPath: file.path,
            amount: amount,
            reference: _referenceCtrl.text.trim(),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Payment proof submitted. Staff will verify it shortly.',
          ),
        ),
      );
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _submittingProof = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(checkoutControllerProvider, (_, state) {
      state.whenOrNull(
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              backgroundColor: AppColors.error,
            ),
          );
        },
      );
    });

    final checkoutState = ref.watch(checkoutControllerProvider);
    final currencyFormat = NumberFormat.simpleCurrency(name: 'INR');
    final manual = _manual;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AppColors.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Summary',
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.courseTitle,
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Text(
                        currencyFormat.format(widget.price),
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Payable',
                        style: AppTypography.headlineSmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        currencyFormat.format(
                          manual != null && manual.total > 0
                              ? manual.total
                              : widget.price,
                        ),
                        style: AppTypography.headlineSmall.copyWith(
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (manual != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Expanded(child: _ManualPayPanel(outcome: manual)),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _referenceCtrl,
                decoration: const InputDecoration(
                  labelText: 'UPI / transaction reference (optional)',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              GradientButton(
                text: 'Upload payment screenshot',
                isLoading: _submittingProof || checkoutState.isLoading,
                onPressed: _submitProof,
              ),
            ] else ...[
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.security,
                    color: AppColors.success,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Secure payment',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              GradientButton(
                text: 'Pay ${currencyFormat.format(widget.price)}',
                isLoading: checkoutState.isLoading,
                onPressed: _pay,
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _ManualPayPanel extends StatelessWidget {
  final CheckoutOutcome outcome;

  const _ManualPayPanel({required this.outcome});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Text(
          'Pay via UPI / QR',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Transfer the amount, then upload a screenshot of the payment.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        if (outcome.upi.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            'UPI IDs',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final u in outcome.upi)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(u.label),
              subtitle: Text(u.id),
              trailing: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: u.id));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Copied ${u.id}')),
                  );
                },
              ),
            ),
        ],
        if (outcome.qrs.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Scan QR',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final qr in outcome.qrs) ...[
            Text(
              qr.label,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: CachedNetworkImage(
                imageUrl: qr.imageUrl,
                height: 220,
                fit: BoxFit.contain,
                placeholder: (_, _) => const SizedBox(
                  height: 220,
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, _, _) => const Icon(Icons.broken_image),
              ),
            ),
            if (qr.instructions != null && qr.instructions!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                qr.instructions!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
          ],
        ],
        if (outcome.upi.isEmpty && outcome.qrs.isEmpty)
          Text(
            'Order created. Ask the team for UPI / QR details if they do not appear here.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
      ],
    );
  }
}
