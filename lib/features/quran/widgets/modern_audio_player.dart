import 'package:flutter/material.dart';
import 'package:test_flutter/app/theme.dart';
import 'package:test_flutter/features/quran/services/quran_audio_service.dart';

class ModernAudioPlayer extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onPlayPause;
  final Function(double) onSeek;
  final bool isDownloaded;
  final VoidCallback onDownload;
  final VoidCallback onDelete;
  final String? qariName;
  final String surahName;

  const ModernAudioPlayer({
    super.key,
    required this.isLoading,
    required this.onPlayPause,
    required this.onSeek,
    required this.isDownloaded,
    required this.onDownload,
    required this.onDelete,
    this.qariName,
    required this.surahName,
  });

  @override
  State<ModernAudioPlayer> createState() => _ModernAudioPlayerState();
}

class _ModernAudioPlayerState extends State<ModernAudioPlayer> {
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();

    // Listen to playing state
    QuranAudioService.playingStream.listen((isPlaying) {
      if (mounted) {
        setState(() {
          _isPlaying = isPlaying;
        });
      }
    });

    // Listen to position changes
    QuranAudioService.positionStream.listen((position) {
      if (mounted && !_isDragging) {
        setState(() {
          _currentPosition = position;
        });
      }
    });

    // Listen to duration changes
    QuranAudioService.durationStream.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: QuranAudioService.playingStream,
      builder: (context, playingSnapshot) {
        final isPlaying = playingSnapshot.data ?? false;

        return StreamBuilder<Duration>(
          stream: QuranAudioService.positionStream,
          builder: (context, positionSnapshot) {
            final position = positionSnapshot.data ?? Duration.zero;

            return StreamBuilder<Duration>(
              stream: QuranAudioService.durationStream,
              builder: (context, durationSnapshot) {
                final duration = durationSnapshot.data ?? Duration.zero;

                return SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Qari Info & Surah Name + KONTROL TOMBOL
                        if (widget.isDownloaded && widget.qariName != null) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.primaryBlue.withOpacity(0.1),
                                      AppTheme.accentGreen.withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.person_rounded,
                                  color: AppTheme.primaryBlue,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.surahName,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.onSurface,
                                      ),
                                    ),
                                    Text(
                                      'Recited by ${widget.qariName}',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: AppTheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 16),
                              // Play/Pause Button
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.accentGreen,
                                      AppTheme.accentGreen.withOpacity(0.8),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: widget.isLoading
                                        ? null
                                        : widget.onPlayPause,
                                    borderRadius: BorderRadius.circular(30),
                                    child: Center(
                                      child: widget.isLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            )
                                          : Icon(
                                              isPlaying
                                                  ? Icons.pause_rounded
                                                  : Icons.play_arrow_rounded,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 8),
                              // Delete Button
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: IconButton(
                                  onPressed: () => _confirmDelete(context),
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                  ),
                                  color: Colors.red.shade400,
                                  iconSize: 22,
                                  tooltip: 'Delete Download',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Progress Bar
                        if (duration.inMilliseconds > 0) ...[
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 3,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 7,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 14,
                              ),
                              activeTrackColor: AppTheme.accentGreen,
                              inactiveTrackColor: AppTheme.primaryBlue
                                  .withOpacity(0.1),
                              thumbColor: AppTheme.accentGreen,
                              overlayColor: AppTheme.accentGreen.withOpacity(
                                0.2,
                              ),
                            ),
                            child: Slider(
                              value: duration.inMilliseconds > 0
                                  ? position.inMilliseconds /
                                        duration.inMilliseconds
                                  : 0.0,
                              onChanged: (value) {
                                setState(() => _isDragging = true);
                                widget.onSeek(value);
                              },
                              onChangeEnd: (value) {
                                setState(() => _isDragging = false);
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(position),
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  _formatDuration(duration),
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Tombol Download
                        if (!widget.isDownloaded)
                          ElevatedButton.icon(
                            onPressed: widget.onDownload,
                            icon: const Icon(Icons.download_rounded, size: 20),
                            label: Text(
                              'Download Audio',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: Colors.red.shade400,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Delete Download',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete this downloaded audio?',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: AppTheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.onSurfaceVariant,
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Delete',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
