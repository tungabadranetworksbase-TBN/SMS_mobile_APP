import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';

/// Tungabadra Networks LMS — Download Manager
///
/// Handles background downloading of files (PDFs, Videos) for offline access.
class DownloadManager {
  static final DownloadManager _instance = DownloadManager._internal();
  factory DownloadManager() => _instance;
  DownloadManager._internal();

  final Dio _dio = Dio();
  final Logger _logger = Logger();
  
  // Map to track download progress by URL
  final Map<String, double> _downloadProgress = {};

  double getProgress(String url) => _downloadProgress[url] ?? 0.0;

  /// Download a file to local storage.
  Future<File?> downloadFile(String url, String filename, {Function(double)? onProgress}) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final savePath = '${dir.path}/$filename';
      
      // If file exists, return it immediately (already downloaded)
      final file = File(savePath);
      if (await file.exists()) {
        return file;
      }

      _downloadProgress[url] = 0.0;

      await _dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            _downloadProgress[url] = progress;
            if (onProgress != null) onProgress(progress);
          }
        },
      );

      _downloadProgress.remove(url);
      _logger.i('Successfully downloaded: $filename');
      return File(savePath);
      
    } catch (e) {
      _logger.e('Failed to download $filename: $e');
      _downloadProgress.remove(url);
      return null;
    }
  }

  /// Check if a file is already downloaded
  Future<bool> isDownloaded(String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    return await file.exists();
  }
  
  /// Get a downloaded file
  Future<File?> getLocalFile(String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    return await file.exists() ? file : null;
  }
}
