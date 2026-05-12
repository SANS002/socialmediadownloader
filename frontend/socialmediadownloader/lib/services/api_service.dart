import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../config/app_config.dart';

class ApiService {
  static const String baseUrl = AppConfig.apiBaseUrl;

  /// Download YouTube video — saves file to device, opens it
  static Future<ApiResponse> downloadYoutubeVideo({
    required String url,
    required String quality,
    required bool onlyAudio,
  }) async {
    return _downloadFile(
      endpoint: '/youtube/video',
      body: {'url': url, 'quality': quality, 'only_audio': onlyAudio},
      fallbackFileName: onlyAudio ? 'audio.mp3' : 'video.mp4',
    );
  }

  /// Download YouTube playlist — saves zip to device
  static Future<ApiResponse> downloadYoutubePlaylist({
    required String url,
    required String quality,
    required bool onlyAudio,
  }) async {
    return _downloadFile(
      endpoint: '/youtube/playlist',
      body: {'url': url, 'quality': quality, 'only_audio': onlyAudio},
      fallbackFileName: 'playlist.zip',
    );
  }

  /// Download Instagram post — saves file to device
  static Future<ApiResponse> downloadInstagramPost({
    required String url,
  }) async {
    return _downloadFile(
      endpoint: '/instagram/post',
      body: {'url': url},
      fallbackFileName: 'instagram_post.mp4',
    );
  }

  /// Core download handler — streams binary response and saves to device
  static Future<ApiResponse> _downloadFile({
    required String endpoint,
    required Map<String, dynamic> body,
    required String fallbackFileName,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        // Extract filename from Content-Disposition header if present
        final fileName = _extractFileName(response.headers, fallbackFileName);

        // Save bytes to device Downloads/Documents folder
        final savedPath = await _saveFile(response.bodyBytes, fileName);

        // Open the file automatically
        await OpenFilex.open(savedPath);

        return ApiResponse(
          success: true,
          message: 'Downloaded and saved to:\n$savedPath',
          data: savedPath,
        );
      } else if (response.statusCode == 422) {
        final error = jsonDecode(response.body);
        return ApiResponse(
          success: false,
          message: 'Validation error: ${error['detail']}',
        );
      } else {
        // Try to parse error detail from JSON body
        String detail = 'Status ${response.statusCode}';
        try {
          final error = jsonDecode(response.body);
          detail = error['detail'] ?? detail;
        } catch (_) {}
        return ApiResponse(success: false, message: 'Failed: $detail');
      }
    } on SocketException {
      return ApiResponse(
        success: false,
        message: 'No internet connection.',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  /// Extract filename from Content-Disposition header
  static String _extractFileName(Map<String, String> headers, String fallback) {
    final disposition = headers['content-disposition'] ?? '';
    final match = RegExp(r'filename="?([^"]+)"?').firstMatch(disposition);
    return match?.group(1) ?? fallback;
  }

  /// Save bytes to the device's downloads/documents directory
  static Future<String> _saveFile(Uint8List bytes, String fileName) async {
    Directory? dir;

    if (Platform.isAndroid) {
      // Save to /storage/emulated/0/Download on Android
      dir = Directory('/storage/emulated/0/Download');
      if (!await dir.exists()) {
        dir = await getExternalStorageDirectory();
      }
    } else if (Platform.isIOS) {
      dir = await getApplicationDocumentsDirectory();
    } else {
      dir = await getDownloadsDirectory();
    }

    final filePath = '${dir!.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return filePath;
  }

  /// Health check
  static Future<bool> checkApiHealth() async {
    try {
      final response = await http
          .get(Uri.parse(baseUrl))
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

class ApiResponse {
  final bool success;
  final dynamic data;
  final String message;

  ApiResponse({required this.success, this.data, required this.message});
}
