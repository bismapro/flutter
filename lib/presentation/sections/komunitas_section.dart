import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class KomunitasSection extends StatefulWidget {
  const KomunitasSection({super.key});

  @override
  State<KomunitasSection> createState() => _KomunitasSectionState();
}

class _KomunitasSectionState extends State<KomunitasSection> {
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
                    'Komunitas',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Berbagi dan berdiskusi bersama',
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
                        hintText: 'Cari diskusi...',
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
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada diskusi ditemukan',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Mulai diskusi baru dengan menekan tombol +',
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
                          color: AppTheme.textSecondary,
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
                    color: AppTheme.textPrimary,
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
                      color: AppTheme.textPrimary,
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
                        color: isLiked ? Colors.red : AppTheme.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post['likes']}',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
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
                        color: AppTheme.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post['comments'].length}',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
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
                  color: AppTheme.textSecondary,
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
