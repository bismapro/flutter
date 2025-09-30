import 'package:flutter/material.dart';
import 'package:test_flutter/app/theme.dart';
import 'package:test_flutter/data/models/surah.dart';
import 'package:test_flutter/data/services/quran_service.dart';
import 'package:test_flutter/data/services/audio_player_service.dart';

class SurahDetailPage extends StatefulWidget {
  final Surah surah;

  const SurahDetailPage({super.key, required this.surah});

  @override
  State<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage> {
  Map<String, dynamic>? _surahData;
  bool _isLoading = true;

  bool _isLoadingAudio = false;
  Duration _duration = Duration.zero;
  String _selectedReciter = '01';

  @override
  void initState() {
    super.initState();
    _loadSurahData();
    _setupAudioService();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _setupAudioService() {
    // For now, let's use a simpler approach
    // We'll listen to the service state in the UI methods directly
  }

  Future<void> _playPause() async {
    try {
      // Check current playing state from audio service
      final isCurrentlyPlaying = QuranAudioService.isPlaying;

      if (isCurrentlyPlaying) {
        await QuranAudioService.pause();
      } else {
        final audioUrl = widget.surah.audioFull[_selectedReciter];
        if (audioUrl != null) {
          setState(() {
            _isLoadingAudio = true;
          });

          // Get reciter name
          final reciter = QuranService.getReciters().firstWhere(
            (r) => r['id'] == _selectedReciter,
            orElse: () => {'name': 'Unknown Reciter'},
          );

          await QuranAudioService.playFromUrl(
            audioUrl,
            widget.surah.namaLatin,
            reciter['name']!,
            widget.surah.nama,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing audio: $e'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAudio = false;
        });
      }
    }
  }

  Future<void> _stop() async {
    await QuranAudioService.stop();
  }

  Future<void> _seekTo(double value) async {
    final position = Duration(
      milliseconds: (value * _duration.inMilliseconds).round(),
    );
    await QuranAudioService.seek(position);
  }

  void _changeReciter(String reciterId) async {
    await _stop();
    setState(() {
      _selectedReciter = reciterId;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }

  Future<void> _loadSurahData() async {
    try {
      final data = await QuranService.getSurahWithAyahs(widget.surah.nomor);
      if (mounted) {
        setState(() {
          _surahData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading surah: $e'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryBlue.withValues(alpha: 0.03),
              AppTheme.backgroundWhite,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryBlue.withValues(alpha: 0.1),
                            AppTheme.accentGreen.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.surah.namaLatin,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.onSurface,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            '${widget.surah.jumlahAyat} Ayat • ${widget.surah.tempatTurun == 'Mekah' ? 'Makkiyah' : 'Madaniyyah'}',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      widget.surah.nama,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                        fontFamily: 'Arabic',
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryBlue,
                        ),
                      )
                    : Column(
                        children: [
                          // Bismillah (except for At-Taubah)
                          if (widget.surah.nomor != 9 &&
                              widget.surah.nomor != 1)
                            _buildBismillah(),

                          // Ayahs List
                          Expanded(child: _buildAyahsList()),
                        ],
                      ),
              ),

              // Audio Controls - moved to bottom
              _buildCompactAudioControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactAudioControls() {
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
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.12),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                        spreadRadius: -5,
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Progress Slider (only show when playing)
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
                              ),
                              child: Slider(
                                value: duration.inMilliseconds > 0
                                    ? position.inMilliseconds /
                                          duration.inMilliseconds
                                    : 0.0,
                                onChanged: _seekTo,
                                activeColor: AppTheme.primaryBlue,
                                inactiveColor: AppTheme.primaryBlue.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(position),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    _formatDuration(duration),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],

                          // Main control row
                          Row(
                            children: [
                              // Reciter Selection
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryBlue.withValues(
                                      alpha: 0.05,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppTheme.primaryBlue.withValues(
                                        alpha: 0.1,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.person_rounded,
                                        size: 18,
                                        color: AppTheme.primaryBlue,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: _selectedReciter,
                                            isDense: true,
                                            isExpanded: true,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: AppTheme.onSurface,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            icon: Icon(
                                              Icons.arrow_drop_down_rounded,
                                              color: AppTheme.primaryBlue,
                                            ),
                                            items: QuranService.getReciters()
                                                .map((reciter) {
                                                  return DropdownMenuItem<
                                                    String
                                                  >(
                                                    value: reciter['id']!,
                                                    child: Text(
                                                      reciter['name']!,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  );
                                                })
                                                .toList(),
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                _changeReciter(newValue);
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(width: 16),

                              // Control Buttons
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryBlue.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: IconButton(
                                      onPressed: _stop,
                                      icon: const Icon(Icons.stop_rounded),
                                      iconSize: 22,
                                      color: AppTheme.primaryBlue,
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppTheme.primaryBlue,
                                          AppTheme.accentGreen,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.primaryBlue
                                              .withValues(alpha: 0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      onPressed: _isLoadingAudio
                                          ? null
                                          : _playPause,
                                      icon: _isLoadingAudio
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
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
                                              size: 32,
                                            ),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentGreen.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: IconButton(
                                      onPressed: () {
                                        // Future: Add next/previous surah functionality
                                      },
                                      icon: const Icon(Icons.skip_next_rounded),
                                      iconSize: 22,
                                      color: AppTheme.accentGreen,
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
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

  Widget _buildBismillah() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue.withValues(alpha: 0.1),
            AppTheme.accentGreen.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.2)),
      ),
      child: const Text(
        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryBlue,
          letterSpacing: 0.5,
          height: 1.8,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAyahsList() {
    if (_surahData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryBlue.withValues(alpha: 0.1),
                    AppTheme.accentGreen.withValues(alpha: 0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.menu_book_rounded,
                size: 64,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tidak ada data tersedia',
              style: TextStyle(
                fontSize: 18,
                color: AppTheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    final ayahs = _surahData!['ayat'] as List<dynamic>;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      physics: const BouncingScrollPhysics(),
      itemCount: ayahs.length,
      itemBuilder: (context, index) {
        final ayah = ayahs[index];
        return _buildAyahCard(ayah);
      },
    );
  }

  Widget _buildAyahCard(Map<String, dynamic> ayah) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ayah number badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryBlue.withValues(alpha: 0.15),
                      AppTheme.accentGreen.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 8, color: AppTheme.primaryBlue),
                    const SizedBox(width: 8),
                    Text(
                      'Ayat ${ayah['ayat']}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Arabic Text
          Text(
            ayah['teksArab'],
            style: const TextStyle(
              fontSize: 26,
              height: 2.0,
              color: AppTheme.onSurface,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          ),

          const SizedBox(height: 16),

          // Divider
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryBlue.withValues(alpha: 0.0),
                  AppTheme.primaryBlue.withValues(alpha: 0.2),
                  AppTheme.primaryBlue.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Latin transliteration
          Text(
            ayah['teksLatin'],
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: AppTheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.left,
          ),

          const SizedBox(height: 12),

          // Indonesian translation
          Text(
            ayah['teksIndonesia'],
            style: TextStyle(
              fontSize: 15,
              height: 1.7,
              color: AppTheme.onSurface.withValues(alpha: 0.9),
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.left,
          ),

          const SizedBox(height: 16),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Bookmark button
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.accentGreen.withValues(alpha: 0.2),
                  ),
                ),
                child: IconButton(
                  onPressed: () {
                    // Add bookmark functionality
                  },
                  icon: const Icon(Icons.bookmark_border_rounded, size: 20),
                  color: AppTheme.accentGreen,
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(width: 10),
              // Share button
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                  ),
                ),
                child: IconButton(
                  onPressed: () {
                    // Add share functionality
                  },
                  icon: const Icon(Icons.share_outlined, size: 20),
                  color: AppTheme.primaryBlue,
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
