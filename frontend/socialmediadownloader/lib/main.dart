import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'services/api_service.dart';

void main() {
  runApp(const MediaDownloaderApp());
}

class MediaDownloaderApp extends StatelessWidget {
  const MediaDownloaderApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Media Downloader',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        fontFamily: 'Inter',
        primaryColor: const Color(0xFF6366F1),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          primary: const Color(0xFF6366F1),
          secondary: const Color(0xFFF3F4F6),
        ),
      ),
      home: const MediaDownloaderScreen(),
    );
  }
}

class MediaDownloaderScreen extends StatefulWidget {
  const MediaDownloaderScreen({Key? key}) : super(key: key);

  @override
  State<MediaDownloaderScreen> createState() => _MediaDownloaderScreenState();
}

class _MediaDownloaderScreenState extends State<MediaDownloaderScreen> {
  String _platform = 'youtube';
  String _contentType = 'video';
  String _url = '';
  String _format = 'mp4';
  String _quality = 'highest';
  bool _isLoading = false;
  StatusMessage? _status;
  String? _downloadUrl;

  final TextEditingController _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  List<ContentTypeOption> get _contentTypes {
    if (_platform == 'youtube') {
      return [
        ContentTypeOption(value: 'video', label: 'Video'),
        ContentTypeOption(value: 'playlist', label: 'Playlist'),
      ];
    } else {
      return [
        ContentTypeOption(value: 'post', label: 'Post'),
      ];
    }
  }

  Future<void> _handleDownload() async {
    if (_url.trim().isEmpty) {
      setState(() {
        _status = StatusMessage(
          type: StatusType.error,
          message: 'Please enter a valid URL',
        );
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = null;
      _downloadUrl = null;
    });

    ApiResponse response;

    try {
      if (_platform == 'youtube') {
        final onlyAudio = _format == 'mp3';

        if (_contentType == 'video') {
          response = await ApiService.downloadYoutubeVideo(
            url: _url.trim(),
            quality: _quality,
            onlyAudio: onlyAudio,
          );
        } else {
          response = await ApiService.downloadYoutubePlaylist(
            url: _url.trim(),
            quality: _quality,
            onlyAudio: onlyAudio,
          );
        }
      } else {
        response = await ApiService.downloadInstagramPost(
          url: _url.trim(),
        );
      }

      setState(() {
        _isLoading = false;
        if (response.success) {
          _status = StatusMessage(
            type: StatusType.success,
            message: response.message,
          );

          // If API returns a download URL, store it
          if (response.data is String) {
            _downloadUrl = response.data;
          } else if (response.data is Map && response.data['download_url'] != null) {
            _downloadUrl = response.data['download_url'];
          }
        } else {
          _status = StatusMessage(
            type: StatusType.error,
            message: response.message,
          );
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = StatusMessage(
          type: StatusType.error,
          message: 'An error occurred: ${e.toString()}',
        );
      });
    }
  }

  Future<void> _openDownloadUrl() async {
    if (_downloadUrl != null) {
      final uri = Uri.parse(_downloadUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              children: [
                _buildMainCard(),
                const SizedBox(height: 24),
                _buildFooterText(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildPlatformSelection(),
          const SizedBox(height: 24),
          _buildContentTypeSelection(),
          const SizedBox(height: 24),
          _buildUrlInput(),
          const SizedBox(height: 24),
          if (_platform == 'youtube') ...[
            _buildQualitySelection(),
            const SizedBox(height: 24),
          ],
          _buildFormatSelection(),
          const SizedBox(height: 24),
          _buildDownloadButton(),
          if (_status != null) ...[
            const SizedBox(height: 24),
            _buildStatusMessage(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(
            Icons.download_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Media Downloader',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Download videos and audio from YouTube & Instagram',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF6B7280),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPlatformSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Platform',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPlatformButton(
                platform: 'youtube',
                icon: Icons.play_circle_outline,
                label: 'YouTube',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPlatformButton(
                platform: 'instagram',
                icon: Icons.camera_alt_outlined,
                label: 'Instagram',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlatformButton({
    required String platform,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _platform == platform;

    return InkWell(
      onTap: () {
        setState(() {
          _platform = platform;
          _contentType = platform == 'youtube' ? 'video' : 'post';
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE0E7FF).withOpacity(0.3) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFE5E7EB),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    blurRadius: 0,
                    spreadRadius: 3,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF6B7280),
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isSelected ? const Color(0xFF1F2937) : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Content Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6).withOpacity(0.5),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: _contentTypes.map((type) {
              final isSelected = _contentType == type.value;
              return InkWell(
                onTap: () {
                  setState(() {
                    _contentType = type.value;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    type.label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? const Color(0xFF1F2937) : const Color(0xFF6B7280),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildUrlInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'URL',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6).withOpacity(0.5),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _urlController,
            onChanged: (value) {
              setState(() {
                _url = value;
                _status = null;
              });
            },
            decoration: const InputDecoration(
              hintText: 'Paste your URL here...',
              hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
              prefixIcon: Icon(Icons.link, color: Color(0xFF6B7280)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQualitySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quality',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6).withOpacity(0.5),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _quality,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B7280)),
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.w400,
              ),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _quality = newValue;
                  });
                }
              },
              items: const [
                DropdownMenuItem(value: 'highest', child: Text('Highest Quality')),
                DropdownMenuItem(value: 'high', child: Text('High Quality')),
                DropdownMenuItem(value: 'medium', child: Text('Medium Quality')),
                DropdownMenuItem(value: 'low', child: Text('Low Quality')),
                DropdownMenuItem(value: 'lowest', child: Text('Lowest Quality')),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormatSelection() {
    // Instagram doesn't have format options
    if (_platform == 'instagram') {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Format',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6).withOpacity(0.5),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _format,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B7280)),
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.w400,
              ),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _format = newValue;
                  });
                }
              },
              items: const [
                DropdownMenuItem(value: 'mp4', child: Text('MP4 (Video)')),
                DropdownMenuItem(value: 'mp3', child: Text('MP3 (Audio)')),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleDownload,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          disabledBackgroundColor: const Color(0xFF6366F1).withOpacity(0.6),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
          shadowColor: const Color(0xFF6366F1).withOpacity(0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Processing...',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.download_rounded, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Download',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildStatusMessage() {
    final isSuccess = _status!.type == StatusType.success;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSuccess ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
            border: Border.all(
              color: isSuccess ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _status!.message,
                  style: TextStyle(
                    fontSize: 14,
                    color: isSuccess ? const Color(0xFF166534) : const Color(0xFF991B1B),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isSuccess && _downloadUrl != null) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _openDownloadUrl,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6366F1),
                side: const BorderSide(color: Color(0xFF6366F1), width: 2),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text(
                'Open Download Link',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFooterText() {
    return const Text(
      'Supports YouTube videos, playlists, and Instagram posts',
      style: TextStyle(
        fontSize: 14,
        color: Color(0xFF6B7280),
      ),
      textAlign: TextAlign.center,
    );
  }
}

class ContentTypeOption {
  final String value;
  final String label;

  ContentTypeOption({required this.value, required this.label});
}

class StatusMessage {
  final StatusType type;
  final String message;

  StatusMessage({required this.type, required this.message});
}

enum StatusType { success, error }
