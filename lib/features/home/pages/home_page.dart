import 'package:flutter/material.dart';
import '../../../app/theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeTabContent(),
    const PremiumTabContent(),
    const ArtikelTabContent(),
    const KomunitasTabContent(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: _pages[_currentIndex],
      floatingActionButton: SizedBox(
        // Tentukan ukuran container/area total yang Anda inginkan
        width: 80.0, // Contoh lebar
        height: 80.0, // Contoh tinggi
        child: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/qibla-compass');
          },
          // Pastikan `AppTheme.primaryBlue` sudah didefinisikan
          backgroundColor: AppTheme.primaryBlue,
          child: const Icon(
            Icons.explore,
            color: Colors.white,
            size:
                42.0, // Icon ini sudah besar, sehingga membutuhkan FAB yang besar juga
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        elevation: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', 0),
              _buildNavItem(Icons.star, 'Premium', 1),
              const SizedBox(width: 40), // Space for FAB
              _buildNavItem(Icons.article, 'Artikel', 2),
              _buildNavItem(Icons.group, 'Komunitas', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected
                ? AppTheme.primaryBlue
                : AppTheme.onSurfaceVariant,
            size: 32,
          ),
          const SizedBox(height: 4),
          // Text(
          //   label,
          //   style: TextStyle(
          //     color: isSelected ? AppTheme.primaryBlue : AppTheme.onSurfaceVariant,
          //     fontSize: 12,
          //     fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          //   ),
          // ),
        ],
      ),
    );
  }
}

class HomeTabContent extends StatelessWidget {
  const HomeTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppTheme.accentGreen),
      child: SafeArea(
        child: Stack(
          children: [
            // Banner Section (Fixed Background)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 80.0),
                child: Column(
                  children: [
                    // Date and Location
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '9 Ramadhan 1444 H',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Jakarta, Indonesia',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Next Prayer Time
                    const Text(
                      '04:41',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 64,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const Text(
                      'Fajr 3 hour 9 min left',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 32),

                    // Prayer Times Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildPrayerTimeWidget(
                          'Fajr',
                          '04:41',
                          Icons.nightlight_round,
                          true,
                        ),
                        _buildPrayerTimeWidget(
                          'Dzuhr',
                          '12:00',
                          Icons.wb_sunny,
                          false,
                        ),
                        _buildPrayerTimeWidget(
                          'Asr',
                          '15:14',
                          Icons.wb_sunny_outlined,
                          false,
                        ),
                        _buildPrayerTimeWidget(
                          'Maghrib',
                          '18:02',
                          Icons.brightness_3,
                          false,
                        ),
                        _buildPrayerTimeWidget(
                          'Isha',
                          '19:11',
                          Icons.nights_stay,
                          false,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Scrollable White Section
            DraggableScrollableSheet(
              initialChildSize: 0.45, // Start at 45% of screen height
              minChildSize: 0.45, // Minimum 45%
              maxChildSize: 0.85, // Maximum 85%
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Handle bar
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // All Features
                          const Text(
                            'All Features',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Features Grid - Scrollable
                          SizedBox(
                            height: 120,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                _buildFeatureCard(
                                  Icons.menu_book,
                                  'Al-Quran',
                                  const Color(0xFF4DD0E1),
                                  onTap: () {
                                    Navigator.pushNamed(context, '/quran');
                                  },
                                ),
                                const SizedBox(width: 12),
                                _buildFeatureCard(
                                  Icons.mosque,
                                  'Sholat',
                                  const Color(0xFF4DD0E1),
                                  onTap: () {
                                    Navigator.pushNamed(context, '/sholat');
                                  },
                                ),
                                const SizedBox(width: 12),
                                _buildFeatureCard(
                                  Icons.nightlight_round,
                                  'Puasa',
                                  const Color(0xFF4DD0E1),
                                  onTap: () {
                                    Navigator.pushNamed(context, '/puasa');
                                  },
                                ),
                                const SizedBox(width: 12),
                                _buildFeatureCard(
                                  Icons.volunteer_activism,
                                  'Sedekah',
                                  const Color(0xFF4DD0E1),
                                  onTap: () {
                                    Navigator.pushNamed(context, '/zakat');
                                  },
                                ),
                                const SizedBox(width: 12),
                                _buildFeatureCard(
                                  Icons.explore,
                                  'Qibla',
                                  const Color(0xFF4DD0E1),
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/qibla-compass',
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Ngaji Online Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Ngaji Online',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: const Text(
                                  'See All',
                                  style: TextStyle(
                                    color: Color(0xFF4DD0E1),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Live Stream Card
                          Container(
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: const DecorationImage(
                                image: NetworkImage(
                                  'https://picsum.photos/400/200?random=1',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Stack(
                              children: [
                                // Gradient overlay
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withOpacity(0.3),
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.7),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                                // Viewers count
                                Positioned(
                                  bottom: 12,
                                  left: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      '3.6K viewers',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Latest Articles Section
                          const Text(
                            'Artikel Terbaru',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Articles List
                          ...List.generate(
                            3,
                            (index) => _buildArticleCard(
                              title: _getArticleTitle(index),
                              summary: _getArticleSummary(index),
                              imageUrl:
                                  'https://picsum.photos/80/80?random=${index + 2}',
                              date: _getArticleDate(index),
                              context: context,
                            ),
                          ),

                          // Extra spacing for bottom navigation
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerTimeWidget(
    String name,
    String time,
    IconData icon,
    bool isActive,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive
                ? Colors.white.withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white70,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          time,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    IconData icon,
    String title,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleCard({
    required String title,
    required String summary,
    required String imageUrl,
    required String date,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/article-detail',
          arguments: {
            'title': title,
            'summary': summary,
            'imageUrl': imageUrl,
            'date': date,
            'content': _getFullArticleContent(title),
            'author': 'Tim Editorial Islamic App',
            'readTime': '5 min',
            'category': 'Ibadah',
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
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
                imageUrl,
                width: 120,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 120,
                    height: 100,
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.image,
                      color: Colors.grey,
                      size: 40,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    summary,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    date,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFullArticleContent(String title) {
    // Mock content berdasarkan title
    switch (title) {
      case 'Keutamaan Membaca Al-Quran di Bulan Ramadhan':
        return '''Bulan Ramadhan adalah bulan yang penuh berkah dan rahmat. Dalam bulan ini, Allah SWT memberikan keutamaan yang luar biasa bagi umat Islam yang menjalankan ibadah dengan khusyuk.

Membaca Al-Quran di bulan Ramadhan memiliki pahala yang berlipat ganda dibandingkan dengan bulan-bulan lainnya. Rasulullah SAW bersabda dalam sebuah hadits yang diriwayatkan oleh Ibnu Majah:

"من قرأ حرفا من كتاب الله فله به حسنة، والحسنة بعشر أمثالها"

Artinya: "Barangsiapa membaca satu huruf dari kitab Allah, maka baginya satu kebaikan, dan satu kebaikan dibalas dengan sepuluh kali lipatnya."

Di bulan Ramadhan, pahala ini menjadi berlipat ganda karena kemuliaan bulan tersebut. Para ulama menyarankan untuk:

1. Membaca Al-Quran dengan tartil (perlahan dan jelas)
2. Merenungkan makna ayat-ayat yang dibaca
3. Mengamalkan isi kandungan Al-Quran dalam kehidupan sehari-hari
4. Membaca Al-Quran secara rutin setiap hari

Semoga dengan membaca Al-Quran di bulan Ramadhan, kita dapat meraih ridha Allah SWT dan menjadi pribadi yang lebih baik.''';

      case 'Doa-Doa yang Dianjurkan Dibaca Setelah Sholat':
        return '''Setelah menyelesaikan sholat, dianjurkan untuk membaca doa-doa tertentu sebagai bentuk dzikir dan memohon keberkahan kepada Allah SWT.

Berikut adalah beberapa doa yang dianjurkan:

1. ISTIGHFAR (3x)
أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ
"Astaghfirullaahal 'adhiim"
Artinya: "Aku memohon ampun kepada Allah Yang Maha Agung"

2. DOA SETELAH SHOLAT
اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ
"Allahumma a'innii 'alaa dzikrika wa syukrika wa husni 'ibaadatika"
Artinya: "Ya Allah, tolonglah aku dalam berdzikir kepada-Mu, bersyukur kepada-Mu, dan beribadah dengan baik kepada-Mu"

3. TASBIH, TAHMID, dan TAKBIR
- Subhanallah (33x)
- Alhamdulillah (33x)  
- Allahu Akbar (34x)

Doa-doa ini memiliki keutamaan yang besar dan dapat menjadi penutup yang baik setelah melaksanakan sholat.''';

      default:
        return '''Lailatul Qadr adalah malam yang sangat mulia dalam Islam. Malam ini disebutkan dalam Al-Quran sebagai malam yang lebih baik dari seribu bulan.

Beberapa amalan yang dianjurkan di malam Lailatul Qadr:

1. Sholat Tahajjud
Melaksanakan sholat malam dengan khusyuk dan penuh harapan.

2. Membaca Al-Quran
Memperbanyak tilawah Al-Quran, terutama surah-surah pendek.

3. Berdzikir dan Bertasbih
Memperbanyak dzikir dengan mengucap tasbih, tahmid, dan takbir.

4. Berdoa
Memohon kepada Allah dengan doa-doa yang tulus dari hati.

5. Istighfar
Memohon ampun kepada Allah atas segala dosa dan kesalahan.

Doa yang dianjurkan di malam Lailatul Qadr:
اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي

"Allahumma innaka 'afuwwun tuhibbul 'afwa fa'fu 'anni"

Artinya: "Ya Allah, sesungguhnya Engkau Maha Pemaaf dan menyukai maaf, maka maafkanlah aku."

Semoga kita dapat memanfaatkan malam Lailatul Qadr dengan sebaik-baiknya.''';
    }
  }

  String _getArticleTitle(int index) {
    const titles = [
      'Keutamaan Membaca Al-Quran di Bulan Ramadhan',
      'Doa-Doa yang Dianjurkan Dibaca Setelah Sholat',
      'Amalan-Amalan Sunnah di Malam Lailatul Qadr',
    ];
    return titles[index % titles.length];
  }

  String _getArticleSummary(int index) {
    const summaries = [
      'Membaca Al-Quran di bulan Ramadhan memiliki pahala yang berlipat ganda. Simak penjelasan lengkapnya...',
      'Setelah sholat, dianjurkan untuk membaca doa-doa tertentu untuk mendapatkan keberkahan...',
      'Lailatul Qadr adalah malam yang lebih baik dari seribu bulan. Berikut amalan yang dianjurkan...',
    ];
    return summaries[index % summaries.length];
  }

  String _getArticleDate(int index) {
    const dates = [
      '2 hari yang lalu',
      '5 hari yang lalu',
      '1 minggu yang lalu',
    ];
    return dates[index % dates.length];
  }
}

class PremiumTabContent extends StatelessWidget {
  const PremiumTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Premium Content',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class ArtikelTabContent extends StatefulWidget {
  const ArtikelTabContent({super.key});

  @override
  State<ArtikelTabContent> createState() => _ArtikelTabContentState();
}

class _ArtikelTabContentState extends State<ArtikelTabContent> {
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
      backgroundColor: AppTheme.backgroundWhite,
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
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pelajari Islam lebih dalam',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.onSurfaceVariant,
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
                          color: AppTheme.onSurfaceVariant,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
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
                          Icon(
                            Icons.article_outlined,
                            size: 64,
                            color: AppTheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada artikel ditemukan',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppTheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
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
    return Container(
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
                  child: const Icon(Icons.image, size: 48, color: Colors.grey),
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
                    color: AppTheme.onSurface,
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
                    color: AppTheme.onSurfaceVariant,
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
                      color: AppTheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      article['readTime'],
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppTheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      article['date'],
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.bookmark_border,
                      size: 20,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class KomunitasTabContent extends StatefulWidget {
  const KomunitasTabContent({super.key});

  @override
  State<KomunitasTabContent> createState() => _KomunitasTabContentState();
}

class _KomunitasTabContentState extends State<KomunitasTabContent> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Semua';
  String _searchQuery = '';

  // Simulated current user
  final String _currentUserId = 'user_123';
  final String _currentUserName = 'Muhammad Ahmad';

  List<Map<String, dynamic>> _communityPosts = [];

  @override
  void initState() {
    super.initState();
    _initializePosts();
  }

  void _initializePosts() {
    _communityPosts = [
      {
        'id': 'post_1',
        'title': 'Pengalaman Pertama Umrah di Bulan Ramadhan',
        'content':
            'Alhamdulillah, saya baru saja pulang dari umrah. Subhanallah, betapa berbedanya suasana Masjidil Haram di bulan Ramadhan.\n\n"Dan berikan kabar gembira kepada orang-orang yang berbuat baik" - QS. Al-Baqarah: 155\n\nBeberapa tips untuk teman-teman yang ingin umrah:\n• Persiapkan fisik dan mental jauh-jauh hari\n• Pelajari doa-doa dan manasik umrah\n• Bawa obat-obatan pribadi\n• Siapkan mental untuk antrian yang panjang\n\nSemoga bermanfaat!',
        'category': 'Sharing',
        'authorId': 'user_456',
        'authorName': 'Siti Aminah',
        'date': '2 jam yang lalu',
        'likes': 24,
        'likedBy': [],
        'comments': [
          {
            'id': 'comment_1',
            'authorName': 'Ahmad Fauzi',
            'content':
                'Masya Allah, pengalaman yang luar biasa. Semoga Allah mudahkan saya juga bisa kesana.',
            'date': '1 jam yang lalu',
          },
          {
            'id': 'comment_2',
            'authorName': 'Fatimah',
            'content':
                'Barakallahu fiik atas sharingnya. Bisa cerita lebih detail tentang persiapannya?',
            'date': '45 menit yang lalu',
          },
        ],
        'imageUrl': 'https://picsum.photos/400/250?random=1',
      },
      {
        'id': 'post_2',
        'title': 'Bagaimana Cara Khusyuk dalam Sholat?',
        'content':
            'Assalamualaikum, saya ingin bertanya kepada teman-teman. Bagaimana cara agar bisa lebih khusyuk dalam sholat? Sering kali pikiran saya kemana-mana saat sholat.\n\nMohon sharing pengalaman dari teman-teman 🙏',
        'category': 'Pertanyaan',
        'authorId': 'user_789',
        'authorName': 'Abdullah',
        'date': '5 jam yang lalu',
        'likes': 18,
        'likedBy': ['user_123'],
        'comments': [
          {
            'id': 'comment_3',
            'authorName': 'Ustadz Mahmud',
            'content':
                'Wa alaykumus salam. Salah satu caranya adalah dengan memahami makna bacaan sholat dan fokus pada dzikir.',
            'date': '4 jam yang lalu',
          },
        ],
        'imageUrl': null,
      },
      {
        'id': 'post_3',
        'title': 'Event Kajian Rutin Masjid Al-Barokah',
        'content':
            'Bismillah, kami mengundang teman-teman untuk menghadiri kajian rutin setiap Jumat malam di Masjid Al-Barokah.\n\nTema kali ini: "Menggali Hikmah dari Surah Al-Kahf"\n\nDetail Acara:\n• Waktu: Setiap Jumat, 20:00 - 21:30 WIB\n• Tempat: Masjid Al-Barokah, Jl. Raya No. 123\n• Pemateri: Ustadz Ahmad Hidayat\n• Free untuk umum\n\n"Dan bacakanlah apa yang diwahyukan kepadamu yaitu Kitab Tuhanmu" - QS. Al-Kahf: 27\n\nJazakumullahu khairan',
        'category': 'Event',
        'authorId': _currentUserId,
        'authorName': _currentUserName,
        'date': '1 hari yang lalu',
        'likes': 32,
        'likedBy': ['user_456', 'user_789'],
        'comments': [],
        'imageUrl': 'https://picsum.photos/400/250?random=3',
      },
    ];
  }

  List<Map<String, dynamic>> get _filteredPosts {
    return _communityPosts.where((post) {
      final matchesCategory =
          _selectedCategory == 'Semua' || post['category'] == _selectedCategory;
      final matchesSearch =
          _searchQuery.isEmpty ||
          post['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          post['content'].toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _showAddPostDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buat Post Baru'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  hintText: 'Masukkan judul post...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              Expanded(
                child: TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Konten',
                    hintText: 'Tulis konten post Anda di sini...',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: null,
                  minLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  contentController.text.isNotEmpty) {
                setState(() {
                  _communityPosts.insert(0, {
                    'id': 'post_${DateTime.now().millisecondsSinceEpoch}',
                    'title': titleController.text,
                    'content': contentController.text,
                    'category': 'Diskusi',
                    'authorId': _currentUserId,
                    'authorName': _currentUserName,
                    'date': 'Baru saja',
                    'likes': 0,
                    'likedBy': [],
                    'comments': [],
                    'imageUrl': null,
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  void _toggleLike(String postId) {
    setState(() {
      final postIndex = _communityPosts.indexWhere(
        (post) => post['id'] == postId,
      );
      if (postIndex != -1) {
        final post = _communityPosts[postIndex];
        final likedBy = List<String>.from(post['likedBy']);

        if (likedBy.contains(_currentUserId)) {
          likedBy.remove(_currentUserId);
          post['likes']--;
        } else {
          likedBy.add(_currentUserId);
          post['likes']++;
        }

        post['likedBy'] = likedBy;
      }
    });
  }

  void _deletePost(String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Post'),
        content: const Text('Apakah Anda yakin ingin menghapus post ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _communityPosts.removeWhere((post) => post['id'] == postId);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showCommentsDialog(Map<String, dynamic> post) {
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Komentar',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),

                // Comments List
                Expanded(
                  child: post['comments'].isEmpty
                      ? const Center(child: Text('Belum ada komentar'))
                      : ListView.builder(
                          itemCount: post['comments'].length,
                          itemBuilder: (context, index) {
                            final comment = post['comments'][index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        comment['authorName'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        comment['date'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    comment['content'],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),

                const Divider(),

                // Add Comment
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration: const InputDecoration(
                          hintText: 'Tulis komentar...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (commentController.text.isNotEmpty) {
                          setDialogState(() {
                            post['comments'].add({
                              'id':
                                  'comment_${DateTime.now().millisecondsSinceEpoch}',
                              'authorName': _currentUserName,
                              'content': commentController.text,
                              'date': 'Baru saja',
                            });
                          });
                          setState(() {}); // Update main state
                          commentController.clear();
                        }
                      },
                      child: const Text('Kirim'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
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
                    'Komunitas',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Berbagi dan berdiskusi bersama',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.onSurfaceVariant,
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
                        hintText: 'Cari diskusi...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppTheme.onSurfaceVariant,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
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
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Posts List
            Expanded(
              child: _filteredPosts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.forum_outlined,
                            size: 64,
                            color: AppTheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada diskusi ditemukan',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppTheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Mulai diskusi baru dengan menekan tombol +',
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
                      itemCount: _filteredPosts.length,
                      itemBuilder: (context, index) {
                        final post = _filteredPosts[index];
                        return _buildPostCard(post);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPostDialog,
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final isLiked = (post['likedBy'] as List).contains(_currentUserId);
    final isMyPost = post['authorId'] == _currentUserId;

    return Container(
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
          // Post Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                  child: Text(
                    post['authorName'][0].toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['authorName'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        post['date'],
                        style: TextStyle(
                          color: AppTheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isMyPost)
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        onTap: () => _deletePost(post['id']),
                        child: const Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Hapus'),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Category Badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                post['category'],
                style: const TextStyle(
                  color: AppTheme.primaryBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Post Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post['title'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  child: Text(
                    post['content'],
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.onSurface,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Post Image
          if (post['imageUrl'] != null) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  post['imageUrl'],
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 200,
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
            ),
          ],

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Like Button
                GestureDetector(
                  onTap: () => _toggleLike(post['id']),
                  child: Row(
                    children: [
                      Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : AppTheme.onSurfaceVariant,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post['likes']}',
                        style: TextStyle(
                          color: AppTheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),

                // Comment Button
                GestureDetector(
                  onTap: () => _showCommentsDialog(post),
                  child: Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        color: AppTheme.onSurfaceVariant,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post['comments'].length}',
                        style: TextStyle(
                          color: AppTheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Share Button
                Icon(
                  Icons.share_outlined,
                  color: AppTheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
