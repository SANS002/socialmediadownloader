/// Application configuration
class AppConfig {
  // API Configuration
  static const String apiBaseUrl =
      'https://socialmediadownloader-3gvp.onrender.com';

  // API Endpoints
  static const String youtubeVideoEndpoint = '/youtube/video';
  static const String youtubePlaylistEndpoint = '/youtube/playlist';
  static const String instagramPostEndpoint = '/instagram/post';

  // Quality Options for YouTube
  static const List<QualityOption> qualityOptions = [
    QualityOption(value: 'highest', label: 'Highest Quality'),
    QualityOption(value: 'high', label: 'High Quality'),
    QualityOption(value: 'medium', label: 'Medium Quality'),
    QualityOption(value: 'low', label: 'Low Quality'),
    QualityOption(value: 'lowest', label: 'Lowest Quality'),
  ];

  // Format Options
  static const List<FormatOption> formatOptions = [
    FormatOption(value: 'mp4', label: 'MP4 (Video)', isAudio: false),
    FormatOption(value: 'mp3', label: 'MP3 (Audio)', isAudio: true),
  ];

  // Timeout Durations
  static const Duration apiTimeout = Duration(minutes: 3);
  static const Duration healthCheckTimeout = Duration(seconds: 15);

  // App Info
  static const String appName = 'Media Downloader';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Download videos and audio from YouTube & Instagram';
}

class QualityOption {
  final String value;
  final String label;

  const QualityOption({
    required this.value,
    required this.label,
  });
}

class FormatOption {
  final String value;
  final String label;
  final bool isAudio;

  const FormatOption({
    required this.value,
    required this.label,
    required this.isAudio,
  });
}