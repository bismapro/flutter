import 'package:flutter/material.dart';
import '../../../app/theme.dart';

class ArtikelDetailPage extends StatefulWidget {
  final Map<String, dynamic> article;

  const ArtikelDetailPage({super.key, required this.article});

  @override
  State<ArtikelDetailPage> createState() => _ArtikelDetailPageState();
}

class _ArtikelDetailPageState extends State<ArtikelDetailPage> {
  bool _isBookmarked = false;

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Ramadhan':
        return AppTheme.accentGreen;
      case 'Doa':
        return AppTheme.primaryBlue;
      case 'Ibadah':
        return Colors.purple.shade400;
      case 'Sejarah':
        return Colors.orange.shade600;
      case 'Akhlak':
        return Colors.teal.shade500;
      case 'Al-Quran':
        return AppTheme.primaryBlue;
      case 'Haji':
        return Colors.amber.shade700;
      default:
        return AppTheme.primaryBlue;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Ramadhan':
        return Icons.nightlight_round;
      case 'Doa':
        return Icons.favorite_rounded;
      case 'Ibadah':
        return Icons.mosque_rounded;
      case 'Sejarah':
        return Icons.history_edu_rounded;
      case 'Akhlak':
        return Icons.people_rounded;
      case 'Al-Quran':
        return Icons.menu_book_rounded;
      case 'Haji':
        return Icons.location_on_rounded;
      default:
        return Icons.article_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(
      widget.article['category'] ?? 'Artikel',
    );
    final categoryIcon = _getCategoryIcon(
      widget.article['category'] ?? 'Artikel',
    );

    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: CustomScrollView(
        slivers: [
          // Enhanced App Bar dengan gambar
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: categoryColor,
            iconTheme: const IconThemeData(color: Colors.white),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: categoryColor),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Article Image
                  Image.network(
                    widget.article['imageUrl'] ??
                        'https://picsum.photos/400/300?random=1',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              categoryColor.withValues(alpha: 0.3),
                              categoryColor.withValues(alpha: 0.1),
                            ],
                          ),
                        ),
                        child: Icon(
                          Icons.image_rounded,
                          size: 80,
                          color: categoryColor.withValues(alpha: 0.5),
                        ),
                      );
                    },
                  ),
                  // Enhanced Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.5),
                          Colors.black.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),
                  // Category Badge at bottom
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: categoryColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: categoryColor.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(categoryIcon, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            widget.article['category'] ?? 'Artikel',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    _isBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: categoryColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _isBookmarked = !_isBookmarked;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _isBookmarked
                              ? 'Artikel disimpan'
                              : 'Artikel dihapus dari bookmark',
                        ),
                        duration: const Duration(seconds: 2),
                        backgroundColor: categoryColor,
                      ),
                    );
                  },
                  padding: EdgeInsets.zero,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.share_rounded, color: categoryColor),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Artikel dibagikan'),
                        duration: const Duration(seconds: 2),
                        backgroundColor: AppTheme.accentGreen,
                      ),
                    );
                  },
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    categoryColor.withValues(alpha: 0.02),
                    AppTheme.backgroundWhite,
                  ],
                  stops: const [0.0, 0.3],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      widget.article['title'] ?? 'Judul Artikel',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSurface,
                        height: 1.3,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Enhanced Meta Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            categoryColor.withValues(alpha: 0.08),
                            categoryColor.withValues(alpha: 0.04),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: categoryColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.access_time_rounded,
                              size: 20,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            widget.article['readTime'] ?? '5 min',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppTheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Container(
                            width: 1,
                            height: 24,
                            color: categoryColor.withValues(alpha: 0.3),
                          ),
                          const SizedBox(width: 20),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.accentGreen.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.calendar_today_rounded,
                              size: 20,
                              color: AppTheme.accentGreen,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.article['date'] ?? 'Hari ini',
                              style: TextStyle(
                                fontSize: 15,
                                color: AppTheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Enhanced Summary
                    if (widget.article['summary'] != null) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              categoryColor.withValues(alpha: 0.1),
                              categoryColor.withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: categoryColor.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: categoryColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.format_quote_rounded,
                                color: categoryColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                widget.article['summary'],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.onSurface,
                                  height: 1.6,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],

                    // Article Content with better styling
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: categoryColor.withValues(alpha: 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                            spreadRadius: -5,
                          ),
                        ],
                      ),
                      child: Text(
                        _getFullArticleContent(widget.article),
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppTheme.onSurface,
                          height: 1.8,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Special Haji Section
                    if (widget.article['category'] == 'Haji') ...[
                      _buildHajiSpecialSection(categoryColor),
                      const SizedBox(height: 32),
                    ],

                    // Tags
                    if (widget.article['tags'] != null) ...[
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: categoryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.local_offer_rounded,
                              color: categoryColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Tags',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: (widget.article['tags'] as List<String>).map((
                          tag,
                        ) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  categoryColor.withValues(alpha: 0.15),
                                  categoryColor.withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: categoryColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              '#$tag',
                              style: TextStyle(
                                color: categoryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Divider
                    Divider(
                      color: categoryColor.withValues(alpha: 0.2),
                      thickness: 2,
                    ),
                    const SizedBox(height: 32),

                    // Related Articles Section
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryBlue.withValues(alpha: 0.15),
                                AppTheme.accentGreen.withValues(alpha: 0.15),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.auto_stories_rounded,
                            color: AppTheme.primaryBlue,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Artikel Terkait',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.onSurface,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Related Articles List
                    ...List.generate(
                      2,
                      (index) => Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: categoryColor.withValues(alpha: 0.1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: categoryColor.withValues(alpha: 0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 3),
                              spreadRadius: -3,
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () {},
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    'https://picsum.photos/80/80?random=${index + 10}',
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _getRelatedArticleTitle(index),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.onSurface,
                                          height: 1.3,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time_rounded,
                                            size: 14,
                                            color: AppTheme.onSurfaceVariant,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${index + 3} hari yang lalu',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 16,
                                  color: categoryColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Bottom spacing
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getFullArticleContent(Map<String, dynamic> article) {
    final category = article['category'] ?? 'Artikel';
    final title = article['title'] ?? 'Judul Artikel';

    String baseContent =
        '''
Bismillah, dalam artikel ini kita akan membahas tentang "${title.toLowerCase()}".

PENDAHULUAN

Islam mengajarkan kita untuk selalu belajar dan mencari ilmu. Sebagaimana firman Allah SWT dalam Al-Quran:

"Dan katakanlah: 'Ya Tuhanku, tambahkanlah kepadaku ilmu pengetahuan.'" (QS. Taha: 114)

PEMBAHASAN

${article['summary'] ?? 'Konten artikel akan dijelaskan secara detail di sini.'}

Dalam konteks $category, penting bagi kita untuk memahami bahwa setiap amal ibadah yang kita lakukan haruslah berdasarkan tuntunan Al-Quran dan As-Sunnah.

DALIL-DALIL PENDUKUNG

Rasulullah SAW bersabda:
"Barangsiapa yang menunjuki kepada kebaikan, maka baginya pahala seperti pahala orang yang mengerjakannya." (HR. Muslim)

HIKMAH DAN PELAJARAN

Dari pembahasan di atas, kita dapat mengambil beberapa hikmah penting:

• Pentingnya konsistensi dalam beramal
• Memahami ilmu sebelum mengamalkan
• Selalu mengikuti tuntunan yang benar
• Menjadikan ibadah sebagai kebutuhan bukan beban

KESIMPULAN

Semoga artikel ini dapat memberikan manfaat bagi kita semua. Mari kita terus belajar dan mengamalkan ajaran Islam dengan sebaik-baiknya.

Wallahu a'lam bishawab.

REFERENSI:
• Al-Quran dan Terjemahannya
• Shahih Bukhari
• Shahih Muslim
• Tafsir Ibnu Katsir

---

"Dan mereka yang telah diberi ilmu berkata: 'Kecelakaan yang besarlah bagi kamu, pahala Allah adalah lebih baik bagi orang-orang yang beriman dan beramal saleh, dan tidak diperoleh pahala itu, kecuali oleh orang-orang yang sabar.'" (QS. Al-Qashash: 80)
''';

    return baseContent;
  }

  String _getRelatedArticleTitle(int index) {
    const titles = [
      'Adab-adab dalam Menuntut Ilmu',
      'Keutamaan Membaca Al-Quran',
      'Pentingnya Akhlakul Karimah',
    ];
    return titles[index % titles.length];
  }

  Widget _buildHajiSpecialSection(Color categoryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                categoryColor.withValues(alpha: 0.1),
                categoryColor.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: categoryColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.place_rounded,
                  color: categoryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Konten Khusus Haji',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    Text(
                      'Video live dan panduan lengkap ibadah haji',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Makkah Live HD Section
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: categoryColor.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: categoryColor.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
                spreadRadius: -4,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.red.withValues(alpha: 0.2),
                          Colors.red.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.live_tv_rounded,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Makkah Live HD',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.onSurface,
                          ),
                        ),
                        Text(
                          'Streaming langsung dari Masjidil Haram',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        categoryColor.withValues(alpha: 0.3),
                        categoryColor.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Placeholder untuk video thumbnail
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                              'https://picsum.photos/400/200?random=makkah',
                            ),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {},
                          ),
                        ),
                      ),
                      // Play button overlay
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showMakkahLiveDialog();
                  },
                  icon: Icon(Icons.play_circle_filled_rounded),
                  label: Text('Tonton Makkah Live HD'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Haji Guide Quick Access
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: categoryColor.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: categoryColor.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
                spreadRadius: -4,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      color: categoryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Panduan Haji Lengkap',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...List.generate(
                3,
                (index) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      _showHajiGuideDialog(_getHajiGuideTitle(index));
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: categoryColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: categoryColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getHajiGuideIcon(index),
                              color: categoryColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getHajiGuideTitle(index),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.onSurface,
                                  ),
                                ),
                                Text(
                                  _getHajiGuideSubtitle(index),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: categoryColor,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showMakkahLiveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.live_tv_rounded, color: Colors.red),
            const SizedBox(width: 8),
            Text('Makkah Live HD'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pilih sumber streaming Makkah Live:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildLiveStreamOption(
              'Haramain Live',
              'Stream resmi dari Haramain',
              Icons.mosque_rounded,
            ),
            const SizedBox(height: 8),
            _buildLiveStreamOption(
              'YouTube Live',
              'Streaming melalui YouTube',
              Icons.play_circle_rounded,
            ),
            const SizedBox(height: 8),
            _buildLiveStreamOption(
              'Website Resmi',
              'Kunjungi website haramain.gov.sa',
              Icons.web_rounded,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveStreamOption(String title, String subtitle, IconData icon) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Membuka $title...'),
            backgroundColor: Colors.red,
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHajiGuideDialog(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title),
        content: Text(
          'Panduan lengkap tentang $title akan ditampilkan di sini. '
          'Termasuk langkah-langkah detail, doa-doa, dan tips praktis.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Membuka panduan $title...'),
                  backgroundColor: AppTheme.accentGreen,
                ),
              );
            },
            child: Text('Baca Lengkap'),
          ),
        ],
      ),
    );
  }

  String _getHajiGuideTitle(int index) {
    const titles = [
      'Rukun dan Wajib Haji',
      'Tata Cara Thawaf',
      'Panduan Sa\'i',
    ];
    return titles[index];
  }

  String _getHajiGuideSubtitle(int index) {
    const subtitles = [
      'Pelajari rukun dan wajib haji',
      'Langkah-langkah thawaf yang benar',
      'Panduan lengkap sa\'i antara Shafa dan Marwah',
    ];
    return subtitles[index];
  }

  IconData _getHajiGuideIcon(int index) {
    const icons = [
      Icons.checklist_rounded,
      Icons.refresh_rounded,
      Icons.directions_walk_rounded,
    ];
    return icons[index];
  }
}
