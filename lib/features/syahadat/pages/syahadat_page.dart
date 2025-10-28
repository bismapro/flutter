import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:test_flutter/app/theme.dart';
import 'package:test_flutter/core/utils/responsive_helper.dart';

class SyahadatPage extends StatefulWidget {
  const SyahadatPage({super.key});

  @override
  State<SyahadatPage> createState() => _SyahadatPageState();
}

class _SyahadatPageState extends State<SyahadatPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;

  double _scaleFactor(BuildContext context) {
    if (ResponsiveHelper.isSmallScreen(context)) return .9;
    if (ResponsiveHelper.isMediumScreen(context)) return 1.0;
    if (ResponsiveHelper.isLargeScreen(context)) return 1.1;
    return 1.2;
  }

  double _t(BuildContext c, double base) =>
      ResponsiveHelper.adaptiveTextSize(c, base);

  double _px(BuildContext c, double base) => base * _scaleFactor(c);

  double _hpad(BuildContext c) {
    if (ResponsiveHelper.isExtraLargeScreen(c)) return 48;
    if (ResponsiveHelper.isLargeScreen(c)) return 32;
    return ResponsiveHelper.getScreenWidth(c) * 0.04;
  }

  EdgeInsets _pagePadding(BuildContext context) =>
      ResponsiveHelper.getResponsivePadding(context);

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
          _isLoading = false;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleAudio() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        setState(() => _isLoading = true);
        await _audioPlayer.play(AssetSource('audio/syahadat.mp3'));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memutar audio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pagePad = _pagePadding(context);
    final titleSize = ResponsiveHelper.adaptiveTextSize(context, 28);
    final subtitleSize = ResponsiveHelper.adaptiveTextSize(context, 15);

    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
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
              // Header
              Container(
                padding: EdgeInsets.only(
                  left: pagePad.left,
                  right: pagePad.right,
                  top: 8,
                  bottom: 16,
                ),
                child: Row(
                  children: [
                    // Back button
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: AppTheme.onSurface,
                      tooltip: 'Kembali',
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.accentGreen.withValues(alpha: 0.15),
                            AppTheme.primaryBlue.withValues(alpha: 0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        FlutterIslamicIcons.solidKaaba,
                        color: AppTheme.accentGreen,
                        size: ResponsiveHelper.adaptiveTextSize(context, 26),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Syahadat',
                            style: TextStyle(
                              fontSize: titleSize,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.onSurface,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Rukun Islam Pertama',
                            style: TextStyle(
                              fontSize: subtitleSize,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: _hpad(context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Audio Control Button
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(_px(context, 16)),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryBlue.withValues(alpha: 0.1),
                              AppTheme.accentGreen.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.accentGreen.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.volume_up_rounded,
                              color: AppTheme.accentGreen,
                              size: _px(context, 24),
                            ),
                            SizedBox(width: _px(context, 12)),
                            Expanded(
                              child: Text(
                                _isPlaying
                                    ? 'Memutar Audio Syahadat...'
                                    : 'Dengarkan Bacaan Syahadat',
                                style: TextStyle(
                                  fontSize: _t(context, 14),
                                  color: AppTheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(width: _px(context, 12)),
                            InkWell(
                              onTap: _isLoading ? null : _toggleAudio,
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                padding: EdgeInsets.all(_px(context, 12)),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.accentGreen,
                                      AppTheme.accentGreen.withValues(
                                        alpha: 0.8,
                                      ),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.accentGreen.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: _isLoading
                                    ? SizedBox(
                                        width: _px(context, 24),
                                        height: _px(context, 24),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : Icon(
                                        _isPlaying
                                            ? Icons.pause_rounded
                                            : Icons.play_arrow_rounded,
                                        color: Colors.white,
                                        size: _px(context, 24),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: _px(context, 24)),

                      // Syahadat Container
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.accentGreen.withValues(alpha: 0.05),
                              AppTheme.primaryBlue.withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.accentGreen.withValues(alpha: 0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentGreen.withValues(
                                alpha: 0.08,
                              ),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                              spreadRadius: -3,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Syahadat Content
                            _buildSyahadatContent(context),
                          ],
                        ),
                      ),

                      SizedBox(height: _px(context, 24)),

                      // Info footer
                      Container(
                        padding: EdgeInsets.all(_px(context, 16)),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGreen.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.accentGreen.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: AppTheme.accentGreen,
                              size: _px(context, 20),
                            ),
                            SizedBox(width: _px(context, 12)),
                            Expanded(
                              child: Text(
                                'Syahadat adalah pernyataan iman seorang Muslim yang menjadi rukun Islam pertama. Dengan mengucapkan dua kalimat syahadat, seseorang telah menyatakan keimanannya kepada Allah SWT dan Rasul-Nya.',
                                style: TextStyle(
                                  fontSize: _t(context, 13),
                                  color: AppTheme.onSurfaceVariant,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: _px(context, 24)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSyahadatContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(_px(context, 24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: _px(context, 20),
                vertical: _px(context, 10),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accentGreen,
                    AppTheme.accentGreen.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentGreen.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'Dua Kalimat Syahadat',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: _t(context, 16),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          SizedBox(height: _px(context, 24)),

          // Arabic text - Combined
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(_px(context, 20)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'أَشْهَدُ أَنْ لاَ إِلَهَ إِلاَّ اللهُ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: _t(context, 26),
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentGreen,
                    height: 2.0,
                    fontFamily: 'Arabic',
                  ),
                ),
                SizedBox(height: _px(context, 8)),
                Text(
                  'وَأَشْهَدُ أَنَّ مُحَمَّدًا رَسُوْلُ اللهُ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: _t(context, 26),
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentGreen,
                    height: 2.0,
                    fontFamily: 'Arabic',
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: _px(context, 16)),

          // Transliteration
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(_px(context, 16)),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.translate_rounded,
                      size: _px(context, 18),
                      color: AppTheme.primaryBlue,
                    ),
                    SizedBox(width: _px(context, 8)),
                    Text(
                      'Bacaan:',
                      style: TextStyle(
                        fontSize: _t(context, 14),
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: _px(context, 8)),
                Text(
                  'Asyhadu an laa ilaaha illallah, wa asyhadu anna Muhammadar Rasulullah',
                  style: TextStyle(
                    fontSize: _t(context, 15),
                    fontStyle: FontStyle.italic,
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: _px(context, 12)),

          // Translation
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(_px(context, 16)),
            decoration: BoxDecoration(
              color: AppTheme.accentGreen.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: _px(context, 18),
                      color: AppTheme.accentGreen,
                    ),
                    SizedBox(width: _px(context, 8)),
                    Text(
                      'Artinya:',
                      style: TextStyle(
                        fontSize: _t(context, 14),
                        color: AppTheme.accentGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: _px(context, 8)),
                Text(
                  'Aku bersaksi bahwa tidak ada Tuhan selain Allah, dan aku bersaksi bahwa Muhammad adalah utusan Allah',
                  style: TextStyle(
                    fontSize: _t(context, 14),
                    color: AppTheme.onSurface,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
