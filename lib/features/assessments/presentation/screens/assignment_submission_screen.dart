import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/buttons/gradient_button.dart';
import '../../controllers/assessment_controller.dart';

class AssignmentSubmissionScreen extends ConsumerStatefulWidget {
  final String assignmentId;
  final String title;

  const AssignmentSubmissionScreen({
    super.key,
    required this.assignmentId,
    required this.title,
  });

  @override
  ConsumerState<AssignmentSubmissionScreen> createState() => _AssignmentSubmissionScreenState();
}

class _AssignmentSubmissionScreenState extends ConsumerState<AssignmentSubmissionScreen> {
  String? _selectedFilePath;
  String? _selectedFileName;

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'zip'],
    );

    if (result != null) {
      setState(() {
        _selectedFilePath = result.files.single.path;
        _selectedFileName = result.files.single.name;
      });
    }
  }

  Future<void> _submitAssignment() async {
    if (_selectedFilePath == null) return;

    final success = await ref
        .read(assessmentControllerProvider.notifier)
        .submitAssignment(widget.assignmentId, _selectedFilePath!);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Assignment submitted successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } else {
      final state = ref.read(assessmentControllerProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error?.toString() ?? 'Failed to submit assignment.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controllerState = ref.watch(assessmentControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.upload_file_rounded,
              size: 80,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Upload Submission',
              style: AppTypography.headlineSmall.copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Supported formats: PDF, DOCX, ZIP',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxxl),

            // File Selector
            InkWell(
              onTap: _pickFile,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _selectedFilePath != null ? AppColors.primary : AppColors.border,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  color: AppColors.surface,
                ),
                child: Column(
                  children: [
                    Icon(
                      _selectedFilePath != null ? Icons.check_circle_outline : Icons.add_circle_outline,
                      size: 40,
                      color: _selectedFilePath != null ? AppColors.primaryLight : AppColors.textSecondary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _selectedFileName ?? 'Tap to select a file',
                      style: AppTypography.bodyLarge.copyWith(
                        color: _selectedFilePath != null ? AppColors.textPrimary : AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            GradientButton(
              text: 'Submit Assignment',
              onPressed: _selectedFilePath != null ? _submitAssignment : null,
              isLoading: controllerState.isLoading,
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
