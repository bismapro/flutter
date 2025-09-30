import 'package:flutter/material.dart';
import '../../../app/theme.dart';

class NgajiOnlinePage extends StatefulWidget {
  const NgajiOnlinePage({super.key});

  @override
  State<NgajiOnlinePage> createState() => _NgajiOnlinePageState();
}

class _NgajiOnlinePageState extends State<NgajiOnlinePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'Semua';

  final List<String> _categories = [
    'Semua',
    'Live Streaming',
    'Tafsir Al-Quran',
    'Hadits',
    'Fiqih',
    'Akhlak',
    'Sejarah Islam',
  ];

  final List<Map<String, dynamic>> _liveStreams = [
    {
      'id': 'live_1',
      'title': 'Kajian Tafsir Al-Quran - Surah Al-Baqarah',
      'ustadz': 'Ustadz Ahmad Fauzi',
      'category': 'Tafsir Al-Quran',
      'viewers': 3600,
      'isLive': true,
      'duration': 'Live',
      'description':
          'Kajian mendalam tentang surah Al-Baqarah ayat 1-10 dengan pendekatan kontemporer',
      'imageUrl': 'https://picsum.photos/400/250?random=1',
      'schedule': 'Setiap Senin & Kamis, 20:00 WIB',
    },
    {
      'id': 'live_2',
      'title': 'Belajar Hadits Sahih Bukhari',
      'ustadz': 'Ustadz Muhammad Ridwan',
      'category': 'Hadits',
      'viewers': 2400,
      'isLive': true,
      'duration': 'Live',
      'description':
          'Memahami hadits-hadits sahih dari Imam Bukhari dengan penjelasan yang mudah dipahami',
      'imageUrl': 'https://picsum.photos/400/250?random=2',
      'schedule': 'Setiap Selasa & Jumat, 19:30 WIB',
    },
    {
      'id': 'live_3',
      'title': 'Fiqih Kontemporer: Hukum dalam Kehidupan Modern',
      'ustadz': 'Ustadz Abdul Hakim',
      'category': 'Fiqih',
      'viewers': 1800,
      'isLive': false,
      'duration': '45 min',
      'description':
          'Membahas hukum-hukum Islam yang relevan dengan kehidupan modern',
      'imageUrl': 'https://picsum.photos/400/250?random=3',
      'schedule': 'Setiap Rabu, 20:30 WIB',
    },
  ];

  final List<Map<String, dynamic>> _videoLibrary = [
    {
      'id': 'video_1',
      'title': 'Keutamaan Sholat Tahajud',
      'ustadz': 'Ustadz Khalil Ridwan',
      'category': 'Akhlak',
      'duration': '15:30',
      'views': 125000,
      'uploadDate': '3 hari yang lalu',
      'description':
          'Membahas keutamaan dan tata cara sholat tahajud yang benar',
      'imageUrl': 'https://picsum.photos/320/180?random=4',
      'tags': ['Sholat', 'Tahajud', 'Ibadah'],
    },
    {
      'id': 'video_2',
      'title': 'Sejarah Perang Badr dan Hikmahnya',
      'ustadz': 'Ustadz Ahmad Syafi\'i',
      'category': 'Sejarah Islam',
      'duration': '22:45',
      'views': 89000,
      'uploadDate': '1 minggu yang lalu',
      'description':
          'Mempelajari sejarah perang Badr dan hikmah yang dapat diambil',
      'imageUrl': 'https://picsum.photos/320/180?random=5',
      'tags': ['Sejarah', 'Perang Badr', 'Hikmah'],
    },
    {
      'id': 'video_3',
      'title': 'Adab Berinteraksi dengan Orang Tua',
      'ustadz': 'Ustadzah Fatimah Zahra',
      'category': 'Akhlak',
      'duration': '18:20',
      'views': 67000,
      'uploadDate': '2 minggu yang lalu',
      'description':
          'Bagaimana Islam mengajarkan adab berinteraksi dengan kedua orang tua',
      'imageUrl': 'https://picsum.photos/320/180?random=6',
      'tags': ['Akhlak', 'Orang Tua', 'Adab'],
    },
    {
      'id': 'video_4',
      'title': 'Mukjizat Al-Quran dalam Sains Modern',
      'ustadz': 'Dr. Abdullah Mahmud',
      'category': 'Tafsir Al-Quran',
      'duration': '35:15',
      'views': 156000,
      'uploadDate': '3 minggu yang lalu',
      'description':
          'Mengungkap mukjizat Al-Quran yang terbukti dalam sains modern',
      'imageUrl': 'https://picsum.photos/320/180?random=7',
      'tags': ['Al-Quran', 'Sains', 'Mukjizat'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredContent {
    if (_selectedCategory == 'Semua') {
      return [..._liveStreams, ..._videoLibrary];
    } else if (_selectedCategory == 'Live Streaming') {
      return _liveStreams.where((item) => item['isLive'] == true).toList();
    } else {
      return [
        ..._liveStreams,
        ..._videoLibrary,
      ].where((item) => item['category'] == _selectedCategory).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: CustomScrollView(
        slivers: [
          // Enhanced App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppTheme.accentGreen,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Ngaji Online',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.accentGreen, AppTheme.primaryBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 60,
                      right: -50,
                      child: Icon(
                        Icons.play_circle_rounded,
                        size: 200,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    const Positioned(
                      bottom: 50,
                      left: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Belajar Islam',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Kapan Saja, Di Mana Saja',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search_rounded, color: Colors.white),
                onPressed: () => _showSearchDialog(),
              ),
              IconButton(
                icon: const Icon(
                  Icons.notifications_rounded,
                  color: Colors.white,
                ),
                onPressed: () => _showNotificationDialog(),
              ),
            ],
          ),

          // Tab Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: AppTheme.primaryBlue,
                unselectedLabelColor: AppTheme.onSurfaceVariant,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(width: 3, color: AppTheme.primaryBlue),
                ),
                tabs: const [
                  Tab(icon: Icon(Icons.live_tv_rounded), text: 'Live & Video'),
                  Tab(icon: Icon(Icons.schedule_rounded), text: 'Jadwal'),
                ],
              ),
            ),
          ),

          // Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [_buildMainContent(), _buildScheduleContent()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        // Category Filter
        Container(
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = category == _selectedCategory;

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  backgroundColor: Colors.white,
                  selectedColor: AppTheme.accentGreen.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? AppTheme.accentGreen
                        : AppTheme.onSurfaceVariant,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? AppTheme.accentGreen
                        : Colors.grey.shade300,
                  ),
                ),
              );
            },
          ),
        ),

        // Live Streams Header
        if (_liveStreams.any((stream) => stream['isLive'] == true)) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.live_tv_rounded, color: Colors.red),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Sedang Live',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Content List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filteredContent.length,
            itemBuilder: (context, index) {
              final content = _filteredContent[index];
              final isLiveStream = content.containsKey('isLive');

              return isLiveStream
                  ? _buildLiveStreamCard(content)
                  : _buildVideoCard(content);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLiveStreamCard(Map<String, dynamic> stream) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentGreen.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail with live indicator
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.network(
                  stream['imageUrl'],
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              // Live badge
              if (stream['isLive'])
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
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
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
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
                ),
              // Viewers count
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.remove_red_eye_rounded,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatViewers(stream['viewers']),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Play button
              Center(
                child: GestureDetector(
                  onTap: () => _playLiveStream(stream),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.red,
                      size: 36,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Content info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stream['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.person_rounded,
                      size: 16,
                      color: AppTheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      stream['ustadz'],
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  stream['description'],
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        stream['category'],
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.accentGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => _showStreamDetails(stream),
                      icon: Icon(
                        Icons.info_outline_rounded,
                        color: AppTheme.onSurfaceVariant,
                      ),
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

  Widget _buildVideoCard(Map<String, dynamic> video) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: -4,
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _playVideo(video),
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            // Thumbnail
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: Image.network(
                    video['imageUrl'],
                    width: 120,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),
                // Duration
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      video['duration'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // Play icon
                const Center(
                  child: Icon(
                    Icons.play_circle_filled_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
            // Video info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video['title'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      video['ustadz'],
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.remove_red_eye_rounded,
                          size: 12,
                          color: AppTheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatViews(video['views']),
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(color: AppTheme.onSurfaceVariant),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          video['uploadDate'],
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Jadwal Kajian Rutin',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        ..._liveStreams.map((stream) => _buildScheduleCard(stream)).toList(),
      ],
    );
  }

  Widget _buildScheduleCard(Map<String, dynamic> stream) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentGreen.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentGreen.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.accentGreen, AppTheme.primaryBlue],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.schedule_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stream['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  stream['ustadz'],
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: AppTheme.accentGreen,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      stream['schedule'],
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.accentGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _setReminder(stream),
            icon: Icon(
              Icons.notifications_outlined,
              color: AppTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  void _playLiveStream(Map<String, dynamic> stream) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'LIVE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('Tonton Live Stream', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stream['title'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Oleh: ${stream['ustadz']}',
              style: TextStyle(color: AppTheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Text(
              stream['description'],
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Memulai live stream...'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Tonton Sekarang'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _playVideo(Map<String, dynamic> video) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Putar Video'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              video['title'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Oleh: ${video['ustadz']}',
              style: TextStyle(color: AppTheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Text(
              'Durasi: ${video['duration']}',
              style: TextStyle(color: AppTheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Text(
              video['description'],
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Memulai video: ${video['title']}'),
                  backgroundColor: AppTheme.accentGreen,
                ),
              );
            },
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Putar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showStreamDetails(Map<String, dynamic> stream) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Detail Live Stream'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stream['title'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Ustadz', stream['ustadz']),
              _buildDetailRow('Kategori', stream['category']),
              _buildDetailRow('Jadwal', stream['schedule']),
              _buildDetailRow('Penonton', '${stream['viewers']} orang'),
              const SizedBox(height: 16),
              const Text(
                'Deskripsi:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                stream['description'],
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppTheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Pencarian'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Cari kajian atau ustadz...',
            prefixIcon: Icon(Icons.search_rounded),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur pencarian akan segera hadir!'),
                ),
              );
            },
            child: const Text('Cari'),
          ),
        ],
      ),
    );
  }

  void _showNotificationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Notifikasi'),
        content: const Text('Belum ada notifikasi terbaru.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _setReminder(Map<String, dynamic> stream) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pengingat diatur untuk: ${stream['title']}'),
        backgroundColor: AppTheme.accentGreen,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  String _formatViewers(int viewers) {
    if (viewers >= 1000) {
      return '${(viewers / 1000).toStringAsFixed(1)}K';
    }
    return viewers.toString();
  }

  String _formatViews(int views) {
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M';
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K';
    }
    return views.toString();
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: AppTheme.backgroundWhite, child: tabBar);
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
