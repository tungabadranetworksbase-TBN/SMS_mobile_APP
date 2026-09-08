import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/managers/download_manager.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/error_states/error_state_view.dart';

class PdfViewerScreen extends StatefulWidget {
  final String title;
  final String url;

  const PdfViewerScreen({super.key, required this.title, required this.url});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  String? _localPath;
  bool _isLoading = true;
  String? _error;

  int _totalPages = 0;
  int _currentPage = 0;
  PDFViewController? _pdfViewController;

  @override
  void initState() {
    super.initState();
    _downloadAndSavePdf();
  }

  Future<void> _downloadAndSavePdf() async {
    // DownloadManager already caches by filename in the documents directory
    // and returns the existing file rather than refetching it.
    final filename = widget.url.split('/').last.split('?').first;
    final file = await locator<DownloadManager>().downloadFile(
      widget.url,
      filename,
    );
    if (!mounted) return;
    setState(() {
      if (file == null) {
        _error = 'Failed to load PDF document.';
      } else {
        _localPath = file.path;
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: _buildBody(),
      bottomNavigationBar: _localPath != null ? _buildPageIndicator() : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: AppSpacing.md),
            Text('Downloading document...', style: AppTypography.bodyMedium),
          ],
        ),
      );
    }

    if (_error != null) {
      return ErrorStateView(
        message: _error!,
        onRetry: () {
          setState(() {
            _isLoading = true;
            _error = null;
          });
          _downloadAndSavePdf();
        },
      );
    }

    if (_localPath != null) {
      return PDFView(
        filePath: _localPath,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: false,
        pageFling: true,
        pageSnap: true,
        defaultPage: _currentPage,
        fitPolicy: FitPolicy.BOTH,
        preventLinkNavigation: false,
        onRender: (pages) {
          setState(() {
            _totalPages = pages!;
          });
        },
        onError: (error) {
          setState(() {
            _error = error.toString();
          });
        },
        onPageError: (page, error) {
          // Non-fatal, handled internally by PDFView usually
        },
        onViewCreated: (PDFViewController pdfViewController) {
          _pdfViewController = pdfViewController;
        },
        onPageChanged: (int? page, int? total) {
          if (page != null) {
            setState(() {
              _currentPage = page;
            });
          }
        },
      );
    }

    return const SizedBox();
  }

  Widget _buildPageIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      color: AppColors.surfaceContainer,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: _currentPage > 0
                ? () => _pdfViewController?.setPage(_currentPage - 1)
                : null,
          ),
          Text(
            'Page ${_currentPage + 1} of $_totalPages',
            style: AppTypography.labelLarge,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: _currentPage < _totalPages - 1
                ? () => _pdfViewController?.setPage(_currentPage + 1)
                : null,
          ),
        ],
      ),
    );
  }
}
