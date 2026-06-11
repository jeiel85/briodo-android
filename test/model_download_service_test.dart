// ignore_for_file: depend_on_referenced_packages, avoid_print
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:briodo/services/model_download_service.dart';
import 'package:briodo/providers/todos_provider.dart';

class FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async => './test_temp';

  @override
  Future<String?> getApplicationDocumentsPath() async => './test_docs';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory docsDir;

  setUpAll(() {
    HttpOverrides.global = null; // Allow real HTTP requests in tests
    PathProviderPlatform.instance = FakePathProviderPlatform();
    docsDir = Directory('./test_docs');
    if (!docsDir.existsSync()) {
      docsDir.createSync(recursive: true);
    }
  });

  tearDownAll(() {
    if (docsDir.existsSync()) {
      try {
        docsDir.deleteSync(recursive: true);
      } catch (_) {}
    }
    final tempDir = Directory('./test_temp');
    if (tempDir.existsSync()) {
      try {
        tempDir.deleteSync(recursive: true);
      } catch (_) {}
    }
  });

  test('Gemma Model Download Service - Start, Track Progress, Cancel', () async {
    SharedPreferences.setMockInitialValues({});
    final sharedPrefs = await SharedPreferences.getInstance();

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
      ],
    );

    addTearDown(() => container.dispose());

    final notifier = container.read(modelDownloadProvider.notifier);

    // 1. Initial State
    var state = container.read(modelDownloadProvider);
    expect(state.isDownloading, isFalse);
    expect(state.progress, 0.0);
    expect(state.error, isNull);

    // 2. Start Download
    final downloadFuture = notifier.startDownload();

    // Wait a brief moment to let the request connect and start receiving chunks
    await Future.delayed(const Duration(milliseconds: 3000));

    state = container.read(modelDownloadProvider);
    print('Current download progress: ${state.progress}');
    print('Current download speed: ${(state.downloadSpeedBytesPerSec / (1024 * 1024)).toStringAsFixed(2)} MB/s');
    print('Is downloading: ${state.isDownloading}');
    print('Error: ${state.error}');

    // Expect that download has started, is active, and no error occurred
    expect(state.error, isNull);
    expect(state.isDownloading, isTrue);

    // 3. Cancel Download
    notifier.cancelDownload();
    await downloadFuture;

    state = container.read(modelDownloadProvider);
    print('State after cancel downloadFuture completed:');
    print('  isDownloading: ${state.isDownloading}');
    print('  progress: ${state.progress}');
    print('  error: ${state.error}');
    expect(state.isDownloading, isFalse);

    // Verify cleanup: downloading file should have been deleted
    final file = File('./test_docs/gemma-2b-it-cpu-int4.bin');
    expect(file.existsSync(), isFalse);
  });
}
