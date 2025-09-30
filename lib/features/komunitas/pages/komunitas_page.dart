import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import 'detail_komunitas_page.dart';
import 'tambah_post_page.dart';

class KomunitasPage extends StatefulWidget {
  const KomunitasPage({super.key});

  @override
  State<KomunitasPage> createState() => _KomunitasPageState();
}

class _KomunitasPageState extends State<KomunitasPage> {
  final TextEditingController _searchController = TextEditingController();
  final String _selectedCategory = 'Semua';
  String _searchQuery = '';

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

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Sharing':
        return AppTheme.accentGreen;
      case 'Pertanyaan':
        return AppTheme.primaryBlue;
      case 'Event':
        return Colors.orange.shade600;
      case 'Diskusi':
        return Colors.purple.shade400;
      default:
        return AppTheme.primaryBlue;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Sharing':
        return Icons.people_rounded;
      case 'Pertanyaan':
        return Icons.help_outline_rounded;
      case 'Event':
        return Icons.event_rounded;
      case 'Diskusi':
        return Icons.forum_rounded;
      default:
        return Icons.forum_rounded;
    }
  }

  void _navigateToAddPost() async {
    final newPost = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => const TambahPostPage()),
    );

    if (newPost != null) {
      setState(() {
        _communityPosts.insert(0, newPost);
      });
    }
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red.shade400),
            const SizedBox(width: 12),
            const Text('Hapus Post'),
          ],
        ),
        content: const Text('Apakah Anda yakin ingin menghapus post ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: TextStyle(color: AppTheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _communityPosts.removeWhere((post) => post['id'] == postId);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(Map<String, dynamic> post) async {
    final updatedPost = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => DetailKomunitasPage(post: post)),
    );

    if (updatedPost != null) {
      setState(() {
        final postIndex = _communityPosts.indexWhere(
          (p) => p['id'] == updatedPost['id'],
        );
        if (postIndex != -1) {
          _communityPosts[postIndex] = updatedPost;
        }
      });
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
              AppTheme.primaryBlue.withValues(alpha: 0.05),
              AppTheme.accentGreen.withValues(alpha: 0.03),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
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
                                AppTheme.primaryBlue.withValues(alpha: 0.1),
                                AppTheme.accentGreen.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.people_rounded,
                            color: AppTheme.primaryBlue,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Komunitas',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.onSurface,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              'Berbagi dan berdiskusi bersama',
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

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.08),
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
                          hintText: 'Cari diskusi...',
                          hintStyle: TextStyle(
                            color: AppTheme.onSurfaceVariant.withValues(
                              alpha: 0.6,
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: AppTheme.primaryBlue,
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
                  ],
                ),
              ),

              Expanded(
                child: _filteredPosts.isEmpty
                    ? Center(
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
                                Icons.forum_outlined,
                                size: 64,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Tidak ada diskusi ditemukan',
                              style: TextStyle(
                                fontSize: 18,
                                color: AppTheme.onSurface,
                                fontWeight: FontWeight.w600,
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
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final post = _filteredPosts[index];
                          return _buildEnhancedPostCard(post);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryBlue, AppTheme.accentGreen],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _navigateToAddPost,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
    );
  }

  Widget _buildEnhancedPostCard(Map<String, dynamic> post) {
    final isLiked = (post['likedBy'] as List).contains(_currentUserId);
    final isMyPost = post['authorId'] == _currentUserId;
    final categoryColor = _getCategoryColor(post['category']);
    final categoryIcon = _getCategoryIcon(post['category']);

    return GestureDetector(
      onTap: () => _navigateToDetail(post),
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
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          categoryColor.withValues(alpha: 0.2),
                          categoryColor.withValues(alpha: 0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white,
                      child: Text(
                        post['authorName'][0].toUpperCase(),
                        style: TextStyle(
                          color: categoryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
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
                          post['authorName'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: AppTheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              post['date'],
                              style: TextStyle(
                                color: AppTheme.onSurfaceVariant,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isMyPost)
                    Container(
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: PopupMenuButton(
                        icon: Icon(
                          Icons.more_vert_rounded,
                          color: categoryColor,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            onTap: () => _deletePost(post['id']),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_rounded,
                                  color: Colors.red.shade400,
                                ),
                                const SizedBox(width: 12),
                                const Text('Hapus Post'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(categoryIcon, size: 16, color: categoryColor),
                    const SizedBox(width: 6),
                    Text(
                      post['category'],
                      style: TextStyle(
                        color: categoryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
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
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    post['content'],
                    style: TextStyle(
                      fontSize: 15,
                      color: AppTheme.onSurface.withValues(alpha: 0.8),
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            if (post['imageUrl'] != null) ...[
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    post['imageUrl'],
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
                              categoryColor.withValues(alpha: 0.1),
                              categoryColor.withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.image_rounded,
                          size: 48,
                          color: categoryColor.withValues(alpha: 0.4),
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
                          color: isLiked
                              ? Colors.red
                              : AppTheme.onSurfaceVariant,
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
                    // onTap: () => _showCommentsDialog(post),
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
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
