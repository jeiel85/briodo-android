import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../providers/app_settings_provider.dart';

class ModelDownloadState {
  final double progress; // 0.0 to 1.0
  final bool isDownloading;
  final String? error;
  final int downloadedBytes;
  final int totalBytes;
  final double downloadSpeedBytesPerSec;

  ModelDownloadState({
    this.progress = 0.0,
    this.isDownloading = false,
    this.error,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
    this.downloadSpeedBytesPerSec = 0.0,
  });

  ModelDownloadState copyWith({
    double? progress,
    bool? isDownloading,
    String? error,
    int? downloadedBytes,
    int? totalBytes,
    double? downloadSpeedBytesPerSec,
  }) =>
      ModelDownloadState(
        progress: progress ?? this.progress,
        isDownloading: isDownloading ?? this.isDownloading,
        error: error ?? this.error,
        downloadedBytes: downloadedBytes ?? this.downloadedBytes,
        totalBytes: totalBytes ?? this.totalBytes,
        downloadSpeedBytesPerSec: downloadSpeedBytesPerSec ?? this.downloadSpeedBytesPerSec,
      );
}

class ModelDownloadNotifier extends Notifier<ModelDownloadState> {
  http.Client? _client;
  File? _downloadingFile;

  @override
  ModelDownloadState build() {
    return ModelDownloadState();
  }

  Future<void> startDownload() async {
    print("ModelDownloadNotifier: startDownload called");
    final settings = ref.read(appSettingsProvider);
    final urlStr = settings.onDeviceModelUrl;
    print("ModelDownloadNotifier: urlStr = '$urlStr'");
    if (urlStr.isEmpty) {
      state = state.copyWith(error: "다운로드 URL이 비어 있습니다.");
      return;
    }

    state = ModelDownloadState(isDownloading: true);
    _client = http.Client();

    try {
      print("ModelDownloadNotifier: getting application documents directory");
      final docDir = await getApplicationDocumentsDirectory();
      if (!docDir.existsSync()) {
        docDir.createSync(recursive: true);
      }
      
      final fileName = "gemma-2b-it-cpu-int4.bin";
      final file = File("${docDir.path}/$fileName");
      _downloadingFile = file;

      final request = http.Request('GET', Uri.parse(urlStr));
      final response = await _client!.send(request);

      if (response.statusCode != 200) {
        throw Exception("서버 응답 오류 (HTTP ${response.statusCode})");
      }

      final totalBytes = response.contentLength ?? 0;
      int downloadedBytes = 0;
      
      IOSink? ioSink;
      try {
        ioSink = file.openWrite();
        final stopwatch = Stopwatch()..start();
        
        await for (final chunk in response.stream) {
          if (!state.isDownloading) {
            break;
          }

          ioSink.add(chunk);
          downloadedBytes += chunk.length;

          final elapsedSecs = stopwatch.elapsedMilliseconds / 1000.0;
          final speed = elapsedSecs > 0 ? downloadedBytes / elapsedSecs : 0.0;
          final progress = totalBytes > 0 ? downloadedBytes / totalBytes : 0.0;

          state = state.copyWith(
            progress: progress,
            downloadedBytes: downloadedBytes,
            totalBytes: totalBytes,
            downloadSpeedBytesPerSec: speed,
          );
        }

        await ioSink.close();
        ioSink = null;
        stopwatch.stop();

        if (!state.isDownloading) {
          if (file.existsSync()) {
            file.deleteSync();
          }
          return;
        }

        // 다운로드 완료 시 설정에 로컬 파일 경로 바인딩
        await ref.read(appSettingsProvider.notifier).setOnDeviceModelPath(file.path);
        state = state.copyWith(isDownloading: false, progress: 1.0);
      } catch (e) {
        if (ioSink != null) {
          try {
            await ioSink.close();
          } catch (_) {}
        }
        rethrow;
      }
    } catch (e, stackTrace) {
      print("ModelDownloadNotifier error: $e\n$stackTrace");
      state = state.copyWith(isDownloading: false, error: e.toString());
      if (_downloadingFile != null && _downloadingFile!.existsSync()) {
        try {
          _downloadingFile!.deleteSync();
        } catch (_) {}
      }
    } finally {
      _client?.close();
      _client = null;
      _downloadingFile = null;
    }
  }

  void cancelDownload() {
    if (state.isDownloading) {
      state = state.copyWith(isDownloading: false);
      _client?.close();
      _client = null;
    }
  }

  Future<void> deleteModel() async {
    final settings = ref.read(appSettingsProvider);
    final path = settings.onDeviceModelPath;
    if (path.isNotEmpty) {
      final file = File(path);
      if (file.existsSync()) {
        try {
          file.deleteSync();
        } catch (_) {}
      }
      await ref.read(appSettingsProvider.notifier).setOnDeviceModelPath('');
      state = ModelDownloadState();
    }
  }

  Future<bool> checkModelExists() async {
    final settings = ref.read(appSettingsProvider);
    final path = settings.onDeviceModelPath;
    if (path.isEmpty) return false;
    final file = File(path);
    final exists = file.existsSync();
    if (!exists) {
      await ref.read(appSettingsProvider.notifier).setOnDeviceModelPath('');
    }
    return exists;
  }
}

final modelDownloadProvider = NotifierProvider<ModelDownloadNotifier, ModelDownloadState>(
  ModelDownloadNotifier.new,
);
