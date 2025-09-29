import 'package:flutter/material.dart';
import '../../../app/theme.dart';

class ArticleDetailPage extends StatelessWidget {
  final Map<String, dynamic> article;

  const ArticleDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar dengan gambar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppTheme.primaryBlue,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Article Image
                  Image.network(
                    article['imageUrl'] ??
                        'https://picsum.photos/400/300?random=1',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.image,
                          size: 64,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: .7),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.bookmark_border),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Artikel disimpan'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Artikel dibagikan'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      article['category'] ?? 'Artikel',
                      style: const TextStyle(
                        color: AppTheme.primaryBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    article['title'] ?? 'Judul Artikel',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Meta Info
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 18,
                        color: AppTheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        article['readTime'] ?? '5 min',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: AppTheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        article['date'] ?? 'Hari ini',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Summary
                  if (article['summary'] != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primaryBlue.withValues(alpha: .2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        article['summary'],
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.onSurface,
                          height: 1.5,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Article Content
                  Text(
                    _getFullArticleContent(article),
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.onSurface,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Tags
                  if (article['tags'] != null) ...[
                    const Text(
                      'Tags',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (article['tags'] as List<String>).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '#$tag',
                            style: const TextStyle(
                              color: AppTheme.primaryBlue,
                              fontSize: 14,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Related Articles Section
                  const Text(
                    'Artikel Terkait',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Related Articles List
                  ...List.generate(
                    2,
                    (index) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: .1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              'https://picsum.photos/60/60?random=${index + 10}',
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getRelatedArticleTitle(index),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.onSurface,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${index + 3} hari yang lalu',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom spacing
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getFullArticleContent(Map<String, dynamic> article) {
    // Simulated full article content based on the category
    final category = article['category'] ?? 'Artikel';
    final title = article['title'] ?? 'Judul Artikel';

    String baseContent =
        '''
Bismillah, dalam artikel ini kita akan membahas tentang "${title.toLowerCase()}".

**Pendahuluan**

Islam mengajarkan kita untuk selalu belajar dan mencari ilmu. Sebagaimana firman Allah SWT dalam Al-Quran:

"Dan katakanlah: 'Ya Tuhanku, tambahkanlah kepadaku ilmu pengetahuan.'" (QS. Taha: 114)

**Pembahasan**

${article['summary'] ?? 'Konten artikel akan dijelaskan secara detail di sini.'}

Dalam konteks $category, penting bagi kita untuk memahami bahwa setiap amal ibadah yang kita lakukan haruslah berdasarkan tuntunan Al-Quran dan As-Sunnah.

**Dalil-dalil Pendukung**

Rasulullah SAW bersabda:
"Barangsiapa yang menunjuki kepada kebaikan, maka baginya pahala seperti pahala orang yang mengerjakannya." (HR. Muslim)

**Hikmah dan Pelajaran**

Dari pembahasan di atas, kita dapat mengambil beberapa hikmah penting:

1. Pentingnya konsistensi dalam beramal
2. Memahami ilmu sebelum mengamalkan
3. Selalu mengikuti tuntunan yang benar
4. Menjadikan ibadah sebagai kebutuhan bukan beban

**Kesimpulan**

Semoga artikel ini dapat memberikan manfaat bagi kita semua. Mari kita terus belajar dan mengamalkan ajaran Islam dengan sebaik-baiknya.

Wallahu a'lam bishawab.

**Referensi:**
- Al-Quran dan Terjemahannya
- Shahih Bukhari
- Shahih Muslim
- Tafsir Ibnu Katsir

---

*"Dan mereka yang telah diberi ilmu berkata: 'Kecelakaan yang besarlah bagi kamu, pahala Allah adalah lebih baik bagi orang-orang yang beriman dan beramal saleh, dan tidak diperoleh pahala itu, kecuali oleh orang-orang yang sabar.'" (QS. Al-Qashash: 80)*
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
}
