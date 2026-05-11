import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ApiService {
  static const String baseUrl = AppConfig.apiBaseUrl;

  /// Download YouTube video
  static Future<ApiResponse> downloadYoutubeVideo({
    required String url,
    required String quality,
    required bool onlyAudio,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/youtube/video'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'url': url,
              'quality': quality,
              'only_audio': onlyAudio,
            }),
          )
          .timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse(
          success: true,
          data: data,
          message: 'Video download ready!',
        );
      } else if (response.statusCode == 422) {
        final error = jsonDecode(response.body);
        return ApiResponse(
          success: false,
          message: 'Validation error: ${error['detail']}',
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Failed to download video. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  /// Download YouTube playlist
  static Future<ApiResponse> downloadYoutubePlaylist({
    required String url,
    required String quality,
    required bool onlyAudio,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/youtube/playlist'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'url': url,
              'quality': quality,
              'only_audio': onlyAudio,
            }),
          )
          .timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse(
          success: true,
          data: data,
          message: 'Playlist download ready!',
        );
      } else if (response.statusCode == 422) {
        final error = jsonDecode(response.body);
        return ApiResponse(
          success: false,
          message: 'Validation error: ${error['detail']}',
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Failed to download playlist. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  /// Download Instagram post
  static Future<ApiResponse> downloadInstagramPost({
    required String url,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/instagram/post'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'url': url,
            }),
          )
          .timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse(
          success: true,
          data: data,
          message: 'Instagram post download ready!',
        );
      } else if (response.statusCode == 422) {
        final error = jsonDecode(response.body);
        return ApiResponse(
          success: false,
          message: 'Validation error: ${error['detail']}',
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Failed to download post. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  /// Check API health
  static Future<bool> checkApiHealth() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

class ApiResponse {
  final bool success;
  final dynamic data;
  final String message;

  ApiResponse({
    required this.success,
    this.data,
    required this.message,
  });
}
