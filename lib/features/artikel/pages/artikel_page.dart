import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../app/router.dart';

class ArtikelPage extends StatefulWidget {
  const ArtikelPage({super.key});

  @override
  State<ArtikelPage> createState() => _ArtikelPageState();
}

class _ArtikelPageState extends State<ArtikelPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Semua';
  String _searchQuery = '';

  final List<String> _categories = [
    'Semua',
    'Ibadah',
    'Akhlak',
    'Sejarah',
    'Ramadhan',
    'Doa',
    'Al-Quran',
  ];

  final List<Map<String, dynamic>> _allArticles = [
    {
      'title': 'Keutamaan Membaca Al-Quran di Bulan Ramadhan',
      'summary':
          'Membaca Al-Quran di bulan Ramadhan memiliki pahala yang berlipat ganda. Simak penjelasan lengkapnya dalam artikel ini.',
      'category': 'Haji',
      'date': '2 hari yang lalu',
      'readTime': '5 min',
      'imageUrl': 'https://picsum.photos/300/200?random=1',
    },
    {
      'title': 'Doa-Doa yang Dianjurkan Dibaca Setelah Sholat',
      'summary':
          'Setelah sholat, dianjurkan untuk membaca doa-doa tertentu untuk mendapatkan keberkahan dan perlindungan Allah SWT.',
      'category': 'Doa',
      'date': '3 hari yang lalu',
      'readTime': '7 min',
      'imageUrl': 'https://picsum.photos/300/200?random=2',
    },
    {
      'title': 'Amalan-Amalan Sunnah di Malam Lailatul Qadr',
      'summary':
          'Lailatul Qadr adalah malam yang lebih baik dari seribu bulan. Berikut amalan yang dianjurkan dilakukan.',
      'category': 'Ibadah',
      'date': '5 hari yang lalu',
      'readTime': '6 min',
      'imageUrl': 'https://picsum.photos/300/200?random=3',
    },
    {
      'title': 'Sejarah Turunnya Ayat Pertama Al-Quran',
      'summary':
          'Kisah turunnya wahyu pertama kepada Nabi Muhammad SAW di Gua Hira yang mengubah sejarah umat manusia.',
      'category': 'Sejarah',
      'date': '1 minggu yang lalu',
      'readTime': '8 min',
      'imageUrl': 'https://picsum.photos/300/200?random=4',
    },
    {
      'title': 'Pentingnya Menjaga Akhlak dalam Kehidupan Sehari-hari',
      'summary':
          'Akhlak yang baik adalah cerminan keimanan seseorang. Pelajari cara menjaga akhlak dalam berinteraksi.',
      'category': 'Akhlak',
      'date': '1 minggu yang lalu',
      'readTime': '4 min',
      'imageUrl': 'https://picsum.photos/300/200?random=5',
    },
    {
      'title': 'Makna dan Hikmah Surah Al-Fatihah',
      'summary':
          'Surah Al-Fatihah adalah induk dari Al-Quran. Pelajari makna dan hikmah yang terkandung di dalamnya.',
      'category': 'Al-Quran',
      'date': '2 minggu yang lalu',
      'readTime': '10 min',
      'imageUrl': 'https://picsum.photos/300/200?random=6',
    },
    {
      'title': 'Adab Masuk dan Keluar Masjid',
      'summary':
          'Islam mengajarkan adab yang baik dalam setiap aspek kehidupan, termasuk ketika masuk dan keluar masjid.',
      'category': 'Ibadah',
      'date': '2 minggu yang lalu',
      'readTime': '3 min',
      'imageUrl': 'https://picsum.photos/300/200?random=7',
    },
    {
      'title': 'Doa Berbuka Puasa dan Adabnya',
      'summary':
          'Ketika berbuka puasa, ada doa khusus yang dianjurkan untuk dibaca beserta adab-adab yang perlu diperhatikan.',
      'category': 'Ramadhan',
      'date': '3 minggu yang lalu',
      'readTime': '5 min',
      'imageUrl': 'https://picsum.photos/300/200?random=8',
    },
  ];

  List<Map<String, dynamic>> get _filteredArticles {
    return _allArticles.where((article) {
      final matchesCategory =
          _selectedCategory == 'Semua' ||
          article['category'] == _selectedCategory;
      final matchesSearch =
          _searchQuery.isEmpty ||
          article['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          article['summary'].toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

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
      default:
        return Icons.article_rounded;
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
              AppTheme.accentGreen.withValues(alpha: 0.03),
              AppTheme.backgroundWhite,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Enhanced Header
              Container(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
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
                            Icons.article_rounded,
                            color: AppTheme.accentGreen,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Artikel Islami',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.onSurface,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              'Pelajari Islam lebih dalam',
                              style: TextStyle(
                                fontSize: 15,
                                color: AppTheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Enhanced Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.accentGreen.withValues(alpha: 0.1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentGreen.withValues(alpha: 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                            spreadRadius: -5,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Cari artikel...',
                          hintStyle: TextStyle(
                            color: AppTheme.onSurfaceVariant.withValues(
                              alpha: 0.6,
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: AppTheme.accentGreen,
                            size: 24,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear_rounded,
                                    color: AppTheme.onSurfaceVariant,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Enhanced Category Filter
                    SizedBox(
                      height: 44,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final isSelected = category == _selectedCategory;

                          return Padding(
                            padding: EdgeInsets.only(
                              right: index == _categories.length - 1 ? 0 : 10,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? LinearGradient(
                                          colors: [
                                            AppTheme.accentGreen,
                                            AppTheme.accentGreen.withValues(
                                              alpha: 0.8,
                                            ),
                                          ],
                                        )
                                      : null,
                                  color: isSelected ? null : Colors.white,
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.accentGreen
                                        : AppTheme.accentGreen.withValues(
                                            alpha: 0.2,
                                          ),
                                    width: isSelected ? 0 : 1.5,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: AppTheme.accentGreen
                                                .withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppTheme.onSurface,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Articles List
              Expanded(
                child: _filteredArticles.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.accentGreen.withValues(alpha: 0.1),
                                    AppTheme.primaryBlue.withValues(alpha: 0.1),
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.article_outlined,
                                size: 64,
                                color: AppTheme.accentGreen,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Tidak ada artikel ditemukan',
                              style: TextStyle(
                                fontSize: 18,
                                color: AppTheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Coba ubah kata kunci atau kategori',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _filteredArticles.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final article = _filteredArticles[index];
                          return _buildEnhancedArticleCard(article);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedArticleCard(Map<String, dynamic> article) {
    final categoryColor = _getCategoryColor(article['category']);
    final categoryIcon = _getCategoryIcon(article['category']);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.articleDetail,
          arguments: article,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: categoryColor.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: categoryColor.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
              spreadRadius: -5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article Image with Overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: Image.network(
                    article['imageUrl'],
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              categoryColor.withValues(alpha: 0.2),
                              categoryColor.withValues(alpha: 0.1),
                            ],
                          ),
                        ),
                        child: Icon(
                          Icons.image_rounded,
                          size: 64,
                          color: categoryColor.withValues(alpha: 0.4),
                        ),
                      );
                    },
                  ),
                ),
                // Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                  ),
                ),
                // Category Badge on Image
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: categoryColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: categoryColor.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(categoryIcon, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          article['category'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Bookmark Icon
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.bookmark_border_rounded,
                      color: categoryColor,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),

            // Article Content
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    article['title'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                      height: 1.3,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),

                  // Summary
                  Text(
                    article['summary'],
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.onSurface.withValues(alpha: 0.7),
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),

                  // Divider
                  Divider(
                    color: categoryColor.withValues(alpha: 0.1),
                    height: 1,
                  ),
                  const SizedBox(height: 12),

                  // Meta Info
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 16,
                              color: AppTheme.primaryBlue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              article['readTime'],
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.primaryBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.circle,
                        size: 4,
                        color: AppTheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        article['date'],
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: categoryColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
