import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/loading/shimmer_loading.dart';
import '../../../../shared/widgets/error_states/error_state_view.dart';
import '../../controllers/learning_controller.dart';
import '../../data/models/lesson_dto.dart';

class CourseDetailsScreen extends ConsumerWidget {
  final String courseId;

  const CourseDetailsScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modulesState = ref.watch(courseModulesProvider(courseId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Course Modules'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: modulesState.when(
        data: (modules) => _buildContent(context, modules),
        loading: () => _buildLoading(),
        error: (error, _) => ErrorStateView(
          message: error.toString(),
          onRetry: () => ref.refresh(courseModulesProvider(courseId)),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<ModuleDto> modules) {
    if (modules.isEmpty) {
      return Center(
        child: Text(
          'No content available for this course yet.',
          style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final module = modules[index];
        return _ModuleExpansionTile(module: module);
      },
    );
  }

  Widget _buildLoading() {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, __) => const ShimmerBox(width: double.infinity, height: 60),
    );
  }
}

class _ModuleExpansionTile extends StatelessWidget {
  final ModuleDto module;

  const _ModuleExpansionTile({required this.module});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardSurface,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        title: Text(
          module.title,
          style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary),
        ),
        subtitle: Text(
          '${module.lessons.length} Lessons',
          style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
        ),
        collapsedIconColor: AppColors.textMuted,
        iconColor: AppColors.primary,
        children: module.lessons.map((lesson) => _LessonListTile(lesson: lesson)).toList(),
      ),
    );
  }
}

class _LessonListTile extends StatelessWidget {
  final LessonDto lesson;

  const _LessonListTile({required this.lesson});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    if (lesson.type == 'video') {
      icon = Icons.play_circle_fill_rounded;
    } else if (lesson.type == 'pdf') {
      icon = Icons.picture_as_pdf_rounded;
    } else {
      icon = Icons.quiz_rounded;
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: lesson.isCompleted ? AppColors.success.withValues(alpha: 0.1) : AppColors.surfaceContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(
          lesson.isCompleted ? Icons.check_circle_rounded : icon,
          color: lesson.isCompleted ? AppColors.success : AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        lesson.title,
        style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
      ),
      subtitle: Text(
        '${lesson.durationMinutes} mins',
        style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
      onTap: () {
        // Quizzes are addressed by id, so only media lessons need a URL.
        final needsUrl = lesson.type == 'video' || lesson.type == 'pdf';
        if (needsUrl && lesson.url == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No media URL provided for this lesson.')),
          );
          return;
        }

        if (lesson.type == 'video') {
          context.pushNamed(
            RouteNames.videoPlayer,
            extra: {'title': lesson.title, 'url': lesson.url},
          );
        } else if (lesson.type == 'pdf') {
          context.pushNamed(
            RouteNames.pdfViewer,
            extra: {'title': lesson.title, 'url': lesson.url},
          );
        } else {
          context.pushNamed(
            RouteNames.quizPlayer,
            pathParameters: {'id': lesson.id},
            extra: {'title': lesson.title},
          );
        }
      },
    );
  }
}
