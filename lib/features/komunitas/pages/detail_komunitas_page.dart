import 'package:flutter/material.dart';
import '../../../app/theme.dart';

class DetailKomunitasPage extends StatefulWidget {
  final Map<String, dynamic> post;

  const DetailKomunitasPage({super.key, required this.post});

  @override
  State<DetailKomunitasPage> createState() => _DetailKomunitasPageState();
}

class _DetailKomunitasPageState extends State<DetailKomunitasPage> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Simulated current user
  final String _currentUserId = 'user_123';
  final String _currentUserName = 'Muhammad Ahmad';

  bool _isAnonymous = false;
  late Map<String, dynamic> _post;

  @override
  void initState() {
    super.initState();
    _post = Map<String, dynamic>.from(widget.post);
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

  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      final newComment = {
        'id': 'comment_${DateTime.now().millisecondsSinceEpoch}',
        'authorName': _isAnonymous ? 'Anonim' : _currentUserName,
        'content': _commentController.text.trim(),
        'date': 'Baru saja',
        'isAnonymous': _isAnonymous,
        'authorId': _isAnonymous ? 'anonymous' : _currentUserId,
      };

      (_post['comments'] as List).add(newComment);
    });

    _commentController.clear();
    _isAnonymous = false;

    // Scroll to bottom to show new comment
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Show success snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Komentar berhasil ditambahkan'),
        backgroundColor: AppTheme.accentGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _toggleLike() {
    setState(() {
      final likedBy = List<String>.from(_post['likedBy']);

      if (likedBy.contains(_currentUserId)) {
        likedBy.remove(_currentUserId);
        _post['likes']--;
      } else {
        likedBy.add(_currentUserId);
        _post['likes']++;
      }

      _post['likedBy'] = likedBy;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLiked = (_post['likedBy'] as List).contains(_currentUserId);
    final comments = _post['comments'] as List;
    final categoryColor = _getCategoryColor(_post['category']);
    final categoryIcon = _getCategoryIcon(_post['category']);

    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      resizeToAvoidBottomInset: true,
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
              // Custom App Bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Container(
                    //   decoration: BoxDecoration(
                    //     gradient: LinearGradient(
                    //       colors: [
                    //         AppTheme.primaryBlue.withValues(alpha: 0.1),
                    //         AppTheme.accentGreen.withValues(alpha: 0.1),
                    //       ],
                    //     ),
                    //     borderRadius: BorderRadius.circular(12),
                    //   ),
                    //   child: IconButton(
                    //     onPressed: () => Navigator.pop(context, _post),
                    //     icon: const Icon(Icons.arrow_back_rounded),
                    //     color: AppTheme.primaryBlue,
                    //   ),
                    // ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Detail Diskusi',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.onSurface,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            '${comments.length} komentar',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Container(
                    //   decoration: BoxDecoration(
                    //     gradient: LinearGradient(
                    //       colors: [
                    //         AppTheme.accentGreen.withValues(alpha: 0.1),
                    //         AppTheme.primaryBlue.withValues(alpha: 0.1),
                    //       ],
                    //     ),
                    //     borderRadius: BorderRadius.circular(12),
                    //   ),
                    //   child: IconButton(
                    //     onPressed: () {
                    //       ScaffoldMessenger.of(context).showSnackBar(
                    //         SnackBar(
                    //           content: const Text(
                    //             'Fitur berbagi akan segera hadir',
                    //           ),
                    //           backgroundColor: AppTheme.primaryBlue,
                    //           behavior: SnackBarBehavior.floating,
                    //           shape: RoundedRectangleBorder(
                    //             borderRadius: BorderRadius.circular(12),
                    //           ),
                    //           margin: const EdgeInsets.all(16),
                    //         ),
                    //       );
                    //     },
                    //     icon: const Icon(Icons.share_outlined),
                    //     color: AppTheme.accentGreen,
                    //   ),
                    // ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Post Detail Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: categoryColor.withValues(alpha: 0.1),
                          ),
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
                            // Author Info
                            Row(
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
                                    radius: 24,
                                    backgroundColor: Colors.white,
                                    child: Text(
                                      _post['authorName'][0].toUpperCase(),
                                      style: TextStyle(
                                        color: categoryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _post['authorName'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: AppTheme.onSurface,
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
                                            _post['date'],
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
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: categoryColor.withValues(
                                      alpha: 0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        categoryIcon,
                                        size: 16,
                                        color: categoryColor,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _post['category'],
                                        style: TextStyle(
                                          color: categoryColor,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Post Title
                            Text(
                              _post['title'],
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.onSurface,
                                height: 1.3,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Post Content
                            Text(
                              _post['content'],
                              style: TextStyle(
                                fontSize: 15,
                                color: AppTheme.onSurface.withValues(
                                  alpha: 0.9,
                                ),
                                height: 1.6,
                              ),
                            ),

                            // Post Image
                            if (_post['imageUrl'] != null) ...[
                              const SizedBox(height: 16),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  _post['imageUrl'],
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
                                            categoryColor.withValues(
                                              alpha: 0.1,
                                            ),
                                            categoryColor.withValues(
                                              alpha: 0.05,
                                            ),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Icon(
                                        Icons.image_rounded,
                                        size: 48,
                                        color: categoryColor.withValues(
                                          alpha: 0.4,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],

                            const SizedBox(height: 20),

                            // Action Buttons
                            Row(
                              children: [
                                // Like Button
                                GestureDetector(
                                  onTap: _toggleLike,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isLiked
                                          ? Colors.red.withValues(alpha: 0.1)
                                          : AppTheme.primaryBlue.withValues(
                                              alpha: 0.05,
                                            ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isLiked
                                            ? Colors.red.withValues(alpha: 0.2)
                                            : AppTheme.primaryBlue.withValues(
                                                alpha: 0.1,
                                              ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isLiked
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: isLiked
                                              ? Colors.red
                                              : AppTheme.onSurfaceVariant,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${_post['likes']}',
                                          style: TextStyle(
                                            color: isLiked
                                                ? Colors.red
                                                : AppTheme.onSurfaceVariant,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Comment Count
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: categoryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: categoryColor.withValues(
                                        alpha: 0.2,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.chat_bubble_outline,
                                        color: categoryColor,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${comments.length}',
                                        style: TextStyle(
                                          color: categoryColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Comments Section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withValues(
                                alpha: 0.08,
                              ),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                              spreadRadius: -5,
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
                                        AppTheme.primaryBlue.withValues(
                                          alpha: 0.1,
                                        ),
                                        AppTheme.accentGreen.withValues(
                                          alpha: 0.1,
                                        ),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.forum_rounded,
                                    color: AppTheme.primaryBlue,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Komentar (${comments.length})',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.onSurface,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            if (comments.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(40),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppTheme.primaryBlue.withValues(
                                              alpha: 0.1,
                                            ),
                                            AppTheme.accentGreen.withValues(
                                              alpha: 0.1,
                                            ),
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.chat_bubble_outline,
                                        size: 48,
                                        color: AppTheme.primaryBlue,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Belum ada komentar',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: AppTheme.onSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Jadilah yang pertama berkomentar',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              ...comments.map(
                                (comment) => _buildCommentItem(comment),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 120), // Space for bottom input
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Comment Input (Bottom Sheet Style)
      bottomSheet: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, -4),
              spreadRadius: -5,
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Anonymous Toggle - Simplified
              Row(
                children: [
                  Icon(
                    _isAnonymous
                        ? Icons.visibility_off_rounded
                        : Icons.person_rounded,
                    size: 18,
                    color: AppTheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isAnonymous ? 'Anonim' : _currentUserName,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _isAnonymous = !_isAnonymous),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _isAnonymous
                            ? AppTheme.accentGreen.withValues(alpha: 0.1)
                            : AppTheme.primaryBlue.withValues(alpha: 0.1),
                        border: Border.all(
                          color: _isAnonymous
                              ? AppTheme.accentGreen
                              : AppTheme.primaryBlue,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _isAnonymous ? 'Gunakan Nama' : 'Kirim Anonim',
                        style: TextStyle(
                          fontSize: 12,
                          color: _isAnonymous
                              ? AppTheme.accentGreen
                              : AppTheme.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Comment Input
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                        ),
                      ),
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: _isAnonymous
                              ? 'Tulis komentar sebagai anonim...'
                              : 'Tulis komentar Anda...',
                          hintStyle: TextStyle(
                            color: AppTheme.onSurfaceVariant.withValues(
                              alpha: 0.6,
                            ),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                        ),
                        maxLines: 4,
                        minLines: 1,
                        textInputAction: TextInputAction.newline,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryBlue, AppTheme.accentGreen],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: _addComment,
                      icon: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    final isAnonymous = comment['isAnonymous'] ?? false;
    final categoryColor = _getCategoryColor(_post['category']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: isAnonymous
                      ? LinearGradient(
                          colors: [Colors.grey.shade400, Colors.grey.shade500],
                        )
                      : LinearGradient(
                          colors: [
                            categoryColor.withValues(alpha: 0.7),
                            categoryColor.withValues(alpha: 0.5),
                          ],
                        ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: isAnonymous
                      ? const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 18,
                        )
                      : Text(
                          comment['authorName'][0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          comment['authorName'],
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: isAnonymous
                                ? AppTheme.onSurfaceVariant
                                : AppTheme.onSurface,
                          ),
                        ),
                        if (isAnonymous) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Anonim',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: AppTheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          comment['date'],
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
            ],
          ),
          const SizedBox(height: 10),
          Text(
            comment['content'],
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.onSurface.withValues(alpha: 0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
