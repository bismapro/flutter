import 'package:flutter/material.dart';
import 'package:test_flutter/app/theme.dart';
import 'package:test_flutter/data/models/sheikh.dart';
import 'package:test_flutter/data/services/audio_download_service.dart';

class JuzDetailPage extends StatefulWidget {
  final int juzNumber;
  final Map<String, String> juzData;

  const JuzDetailPage({
    super.key,
    required this.juzNumber,
    required this.juzData,
  });

  @override
  State<JuzDetailPage> createState() => _JuzDetailPageState();
}

class _JuzDetailPageState extends State<JuzDetailPage> {
  final Map<String, AudioDownload> _downloadProgress = {};
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Custom App Bar with gradient
          SliverAppBar(
            expandedHeight: 250,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.accentGreen,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Juz ${widget.juzNumber}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxGradient(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.accentGreen,
                      AppTheme.accentGreen.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: Image.asset(
                          'assets/images/logo/islamic-pattern.png',
                          repeat: ImageRepeat.repeat,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(); // Fallback if image not found
                          },
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Arabic name
                          Text(
                            widget.juzData['arabic'] ?? '',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Arabic',
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Juz info
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.juzData['range'] ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Actions
                  _buildQuickActions(),

                  const SizedBox(height: 24),

                  // Audio Downloads Section
                  _buildAudioSection(),

                  const SizedBox(height: 24),

                  // Juz Content Preview
                  _buildJuzContent(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aksi Cepat',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.play_arrow,
                  label: 'Dengarkan',
                  color: AppTheme.accentGreen,
                  onTap: () => _playJuz(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.bookmark_outline,
                  label: 'Bookmark',
                  color: AppTheme.primaryBlue,
                  onTap: () => _bookmarkJuz(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.share,
                  label: 'Bagikan',
                  color: Colors.orange,
                  onTap: () => _shareJuz(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioSection() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.audiotrack, color: AppTheme.accentGreen, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Download Audio Juz',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Pilih qari favorit Anda untuk mendengarkan Juz ${widget.juzNumber}',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),

          // Popular Sheikhs
          const Text(
            'Qari Populer',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),

          ...AudioDownloadService.getPopularSheikhs().map(
            (sheikh) => _buildJuzSheikhCard(sheikh, isPopular: true),
          ),

          const SizedBox(height: 20),

          // Other Sheikhs
          const Text(
            'Qari Lainnya',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),

          ...AudioDownloadService.getAllSheikhs()
              .where((sheikh) => !sheikh.isPopular)
              .map((sheikh) => _buildJuzSheikhCard(sheikh)),
        ],
      ),
    );
  }

  Widget _buildJuzSheikhCard(Sheikh sheikh, {bool isPopular = false}) {
    final downloadKey = '${widget.juzNumber}_${sheikh.id}_juz';
    final downloadData = _downloadProgress[downloadKey];
    final isDownloading = downloadData != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: isPopular
            ? Border.all(
                color: AppTheme.accentGreen.withValues(alpha: 0.3),
                width: 2,
              )
            : Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          // Sheikh info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        sheikh.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.onSurface,
                        ),
                      ),
                    ),
                    if (isPopular) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          'POPULER',
                          style: TextStyle(
                            color: Colors.amber.shade700,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (sheikh.arabicName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    sheikh.arabicName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Download button
          if (isDownloading &&
              downloadData.status == DownloadStatus.downloading)
            SizedBox(
              width: 100,
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: downloadData.progress,
                    backgroundColor: AppTheme.accentGreen.withValues(
                      alpha: 0.3,
                    ),
                    valueColor: AlwaysStoppedAnimation(AppTheme.accentGreen),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(downloadData.progress * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentGreen,
                    ),
                  ),
                ],
              ),
            )
          else if (isDownloading &&
              downloadData.status == DownloadStatus.completed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.accentGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppTheme.accentGreen,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Selesai',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentGreen,
                    ),
                  ),
                ],
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: () => _startJuzDownload(sheikh),
              icon: const Icon(Icons.download, size: 16),
              label: const Text(
                'Download',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildJuzContent() {
    // Mock content untuk preview
    final surahs = _getJuzSurahs(widget.juzNumber);

    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.book, color: AppTheme.primaryBlue, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Isi Juz',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ...surahs.map(
            (surahInfo) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.backgroundWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        surahInfo['number']!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          surahInfo['name']!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.onSurface,
                          ),
                        ),
                        Text(
                          surahInfo['range']!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    surahInfo['arabic']!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                      fontFamily: 'Arabic',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, String>> _getJuzSurahs(int juzNumber) {
    // Mock data - dalam aplikasi nyata, ini akan diambil dari API
    switch (juzNumber) {
      case 1:
        return [
          {
            'number': '1',
            'name': 'Al-Fatihah',
            'range': 'Ayat 1-7',
            'arabic': 'الفاتحة',
          },
          {
            'number': '2',
            'name': 'Al-Baqarah',
            'range': 'Ayat 1-141',
            'arabic': 'البقرة',
          },
        ];
      case 2:
        return [
          {
            'number': '2',
            'name': 'Al-Baqarah',
            'range': 'Ayat 142-252',
            'arabic': 'البقرة',
          },
        ];
      default:
        return [
          {
            'number': '${juzNumber}',
            'name': 'Berbagai Surah',
            'range': 'Ayat bervariasi',
            'arabic': 'متنوعة',
          },
        ];
    }
  }

  void _playJuz() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Memainkan Juz ${widget.juzNumber}'),
        backgroundColor: AppTheme.accentGreen,
      ),
    );
  }

  void _bookmarkJuz() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Juz ${widget.juzNumber} ditambahkan ke bookmark'),
        backgroundColor: AppTheme.primaryBlue,
      ),
    );
  }

  void _shareJuz() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Membagikan Juz ${widget.juzNumber}'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _startJuzDownload(Sheikh sheikh) {
    final downloadKey = '${widget.juzNumber}_${sheikh.id}_juz';

    // Mock download untuk Juz
    setState(() {
      _downloadProgress[downloadKey] = AudioDownload(
        surahId: widget.juzNumber.toString(),
        sheikhId: sheikh.id,
        fileName: 'juz_${widget.juzNumber}_${sheikh.id}.mp3',
        filePath: '',
        fileSize: 0,
        downloadDate: DateTime.now(),
        progress: 0.0,
        status: DownloadStatus.downloading,
      );
    });

    // Simulate download progress
    _simulateJuzDownload(sheikh, downloadKey);
  }

  void _simulateJuzDownload(Sheikh sheikh, String downloadKey) async {
    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        setState(() {
          _downloadProgress[downloadKey] = _downloadProgress[downloadKey]!
              .copyWith(
                progress: i / 100.0,
                status: i == 100
                    ? DownloadStatus.completed
                    : DownloadStatus.downloading,
                fileSize: i == 100
                    ? 1024 * 1024 * 25
                    : 0, // 25MB when completed
              );
        });
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Download Selesai!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Juz ${widget.juzNumber} - ${sheikh.name}'),
              const Text('Ukuran: 25.0MB'),
            ],
          ),
          backgroundColor: AppTheme.accentGreen,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}

class BoxGradient extends BoxDecoration {
  const BoxGradient({required Gradient gradient}) : super(gradient: gradient);
}
