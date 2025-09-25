import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';

class ArtikelSection extends StatefulWidget {
  const ArtikelSection({super.key});

  @override
  State<ArtikelSection> createState() => _ArtikelSectionState();
}

class _ArtikelSectionState extends State<ArtikelSection> {
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
      'category': 'Ramadhan',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Artikel Islami',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pelajari Islam lebih dalam',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
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
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppTheme.textSecondary,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: AppTheme.textSecondary,
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
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Category Filter
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = category == _selectedCategory;

                        return Padding(
                          padding: EdgeInsets.only(
                            right: index == _categories.length - 1 ? 0 : 12,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primaryBlue
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primaryBlue
                                      : AppTheme.borderColor,
                                ),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.textPrimary,
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
                          Icon(
                            Icons.article_outlined,
                            size: 64,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada artikel ditemukan',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Coba ubah kata kunci atau kategori',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _filteredArticles.length,
                      itemBuilder: (context, index) {
                        final article = _filteredArticles[index];
                        return _buildArticleCard(article);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleCard(Map<String, dynamic> article) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.articleDetail,
          arguments: article,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Image.network(
                article['imageUrl'],
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 180,
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.image,
                      size: 48,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),

            // Article Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      article['category'],
                      style: const TextStyle(
                        color: AppTheme.primaryBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    article['title'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Summary
                  Text(
                    article['summary'],
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Meta Info
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        article['readTime'],
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        article['date'],
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.bookmark_border,
                        size: 20,
                        color: AppTheme.textSecondary,
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
