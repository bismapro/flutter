import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:test_flutter/app/theme.dart';
import 'package:test_flutter/core/utils/format_helper.dart';
import 'package:test_flutter/core/utils/logger.dart';
import 'package:test_flutter/core/utils/responsive_helper.dart';

import 'package:test_flutter/data/models/komunitas/komunitas.dart';
import 'package:test_flutter/features/auth/auth_provider.dart';
import 'package:test_flutter/features/komunitas/komunitas_provider.dart';
import 'package:test_flutter/features/komunitas/komunitas_state.dart';

class DetailPostinganPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> post; // datang dari list (mapped)

  const DetailPostinganPage({super.key, required this.post});

  @override
  ConsumerState<DetailPostinganPage> createState() =>
      _DetailPostinganPageState();
}

class _DetailPostinganPageState extends ConsumerState<DetailPostinganPage> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isAnonymous = false;

  // ===== Responsive helpers =====
  double _maxWidth(BuildContext context) {
    if (ResponsiveHelper.isExtraLargeScreen(context)) return 900;
    if (ResponsiveHelper.isLargeScreen(context)) return 800;
    if (ResponsiveHelper.isMediumScreen(context)) return 680;
    return double.infinity;
  }

  EdgeInsets _pagePadding(BuildContext context, {double extraBottom = 0}) {
    final base = ResponsiveHelper.getResponsivePadding(context);
    return EdgeInsets.fromLTRB(
      base.left,
      base.top,
      base.right,
      base.bottom + extraBottom,
    );
  }

  double _gap(BuildContext context) =>
      ResponsiveHelper.isSmallScreen(context) ? 16 : 20;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    final id = widget.post['id'].toString();
    logger.fine('Loading postingan detail for ID: $id');

    // Fetch detail postingan menggunakan provider (includes comments)
    await ref.read(komunitasProvider.notifier).fetchPostinganById(id);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Baru saja';
    if (difference.inMinutes < 60) return '${difference.inMinutes} menit lalu';
    if (difference.inHours < 24) return '${difference.inHours} jam lalu';
    if (difference.inDays < 7) return '${difference.inDays} hari lalu';
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final komunitasState = ref.read(komunitasProvider);
    final postingan = komunitasState.postingan;
    if (postingan == null) return;

    // Check if already submitting
    if (komunitasState.status == KomunitasStatus.loading) return;

    try {
      logger.fine('Adding comment to postingan ${postingan.id}');

      // Menggunakan provider untuk add comment
      await ref
          .read(komunitasProvider.notifier)
          .addComment(
            postinganId: postingan.id.toString(),
            komentar: _commentController.text.trim(),
            isAnonymous: _isAnonymous,
          );

      // Check if success
      final newState = ref.read(komunitasProvider);
      if (newState.status == KomunitasStatus.success) {
        _commentController.clear();
        setState(() => _isAnonymous = false);

        // Reload detail postingan untuk update comments
        await ref
            .read(komunitasProvider.notifier)
            .fetchPostinganById(postingan.id.toString());

        // Scroll to bottom after comment added
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Komentar berhasil ditambahkan'),
              backgroundColor: AppTheme.accentGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    } catch (e, st) {
      logger.warning('Error adding comment: $e', e, st);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menambahkan komentar: $e'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  Future<void> _toggleLike() async {
    final komunitasState = ref.read(komunitasProvider);
    final postingan = komunitasState.postingan;
    if (postingan == null) return;

    // Check if already toggling
    if (komunitasState.status == KomunitasStatus.loading) return;

    try {
      logger.fine('Toggling like for postingan ${postingan.id}');

      // Menggunakan provider untuk toggle like
      await ref
          .read(komunitasProvider.notifier)
          .toggleLike(postingan.id.toString());

      // Reload detail postingan untuk update status like
      await ref
          .read(komunitasProvider.notifier)
          .fetchPostinganById(postingan.id.toString());
    } catch (e, st) {
      logger.warning('Error toggling like: $e', e, st);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengubah like: $e'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  // Kategori warna/icon menggunakan nama kategori
  Color _getCategoryColor(String nama) {
    switch (nama.toLowerCase()) {
      case 'ibadah':
        return const Color(0xFF3B82F6);
      case 'doa':
        return const Color(0xFF8B5CF6);
      case 'event':
        return const Color(0xFFF97316);
      case 'sharing':
        return const Color(0xFF10B981);
      case 'pertanyaan':
        return const Color(0xFFEF4444);
      case 'diskusi':
        return Colors.purple.shade400;
      default:
        return AppTheme.primaryBlue;
    }
  }

  IconData _getCategoryIcon(String nama) {
    switch (nama.toLowerCase()) {
      case 'ibadah':
        return Icons.auto_awesome_rounded;
      case 'doa':
        return Icons.spa_rounded;
      case 'event':
        return Icons.event_rounded;
      case 'sharing':
        return Icons.share_rounded;
      case 'pertanyaan':
        return Icons.help_outline_rounded;
      case 'diskusi':
        return Icons.forum_rounded;
      default:
        return Icons.forum_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState['status'] == AuthState.authenticated;

    final komunitasState = ref.watch(komunitasProvider);
    final postingan = komunitasState.postingan;

    final appbarTitleSize = ResponsiveHelper.adaptiveTextSize(context, 20);
    final appbarSubSize = ResponsiveHelper.adaptiveTextSize(context, 13);
    final iconSize = ResponsiveHelper.adaptiveTextSize(context, 22);
    final appbarPad = ResponsiveHelper.isSmallScreen(context) ? 14.0 : 16.0;

    final totalComments = postingan?.komentars?.length ?? 0;
    final isSubmitting = komunitasState.status == KomunitasStatus.loading;

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
                padding: EdgeInsets.all(appbarPad),
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
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: _maxWidth(context)),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryBlue.withValues(alpha: 0.1),
                                AppTheme.accentGreen.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: () => Navigator.pop(context, true),
                            icon: const Icon(Icons.arrow_back_rounded),
                            color: AppTheme.primaryBlue,
                            iconSize: iconSize,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Detail Postingan',
                                style: TextStyle(
                                  fontSize: appbarTitleSize,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.onSurface,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              Text(
                                '$totalComments komentar',
                                style: TextStyle(
                                  fontSize: appbarSubSize,
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
              ),

              // Content
              Expanded(child: _buildContent(isLoggedIn, komunitasState)),
            ],
          ),
        ),
      ),

      // Comment Input (Only show if logged in)
      bottomSheet: isLoggedIn && postingan != null
          ? _buildCommentInput(isSubmitting)
          : null,
    );
  }

  Widget _buildContent(bool isLoggedIn, KomunitasState state) {
    // Loading state
    if (state.status == KomunitasStatus.loading && state.postingan == null) {
      return _buildLoadingState();
    }

    // Error state
    if (state.status == KomunitasStatus.error && state.postingan == null) {
      return _buildErrorState(message: state.message);
    }

    // Empty state
    if (state.postingan == null) {
      return _buildErrorState(message: 'Postingan tidak ditemukan');
    }

    final extraBottom = isLoggedIn
        ? (ResponsiveHelper.isSmallScreen(context) ? 100 : 120)
        : 20;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: _maxWidth(context)),
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: _pagePadding(context, extraBottom: extraBottom.toDouble()),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPostCard(state.postingan!),
              SizedBox(height: _gap(context) + 4),
              _buildCommentsSection(state.postingan!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    final titleSize = ResponsiveHelper.adaptiveTextSize(context, 16);
    final subSize = ResponsiveHelper.adaptiveTextSize(context, 14);

    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: EdgeInsets.all(_gap(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: ResponsiveHelper.isSmallScreen(context) ? 36 : 40,
              height: ResponsiveHelper.isSmallScreen(context) ? 36 : 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Memuat postingan...',
              style: TextStyle(
                color: AppTheme.onSurface,
                fontSize: titleSize,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mohon tunggu sebentar',
              style: TextStyle(
                color: AppTheme.onSurfaceVariant,
                fontSize: subSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState({String? message}) {
    final titleSize = ResponsiveHelper.adaptiveTextSize(context, 18);
    final subSize = ResponsiveHelper.adaptiveTextSize(context, 14);
    final iconSz = ResponsiveHelper.adaptiveTextSize(context, 48);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: _maxWidth(context)),
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: EdgeInsets.all(_gap(context) + 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
                spreadRadius: -5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(
                  ResponsiveHelper.isSmallScreen(context) ? 12 : 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: iconSz,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Gagal Memuat Data',
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message ?? 'Terjadi kesalahan. Coba lagi nanti.',
                style: TextStyle(color: Colors.red.shade600, fontSize: subSize),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_back_rounded, size: 20),
                      label: const Text('Kembali'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _loadDetail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 20),
                      label: const Text('Coba Lagi'),
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

  Widget _buildPostCard(KomunitasPostingan post) {
    final kategoriNama = post.kategori.nama;
    final categoryColor = _getCategoryColor(kategoriNama);
    final categoryIcon = _getCategoryIcon(kategoriNama);

    final titleSize = ResponsiveHelper.adaptiveTextSize(context, 22);
    final bodySize = ResponsiveHelper.adaptiveTextSize(context, 15);
    final chipSize = ResponsiveHelper.adaptiveTextSize(context, 13);
    final iconSz = ResponsiveHelper.adaptiveTextSize(context, 20);

    final coverUrl = post.cover;
    final gallery = post.daftarGambar;
    final liked = post.liked ?? false;

    final komunitasState = ref.watch(komunitasProvider);
    final isTogglingLike = komunitasState.status == KomunitasStatus.loading;

    return Container(
      padding: EdgeInsets.all(_gap(context) + 4),
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
          // Author + kategori chip
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
                  radius: ResponsiveHelper.isSmallScreen(context) ? 22 : 24,
                  backgroundColor: Colors.white,
                  child: Text(
                    (post.penulis.isNotEmpty ? post.penulis[0] : 'G')
                        .toUpperCase(),
                    style: TextStyle(
                      color: categoryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveHelper.adaptiveTextSize(context, 18),
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
                      post.penulis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: ResponsiveHelper.adaptiveTextSize(
                          context,
                          16,
                        ),
                        color: AppTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: ResponsiveHelper.adaptiveTextSize(context, 14),
                          color: AppTheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          FormatHelper.getFormattedDate(post.createdAt),
                          style: TextStyle(
                            color: AppTheme.onSurfaceVariant,
                            fontSize: ResponsiveHelper.adaptiveTextSize(
                              context,
                              13,
                            ),
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
                  color: categoryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(categoryIcon, size: 16, color: categoryColor),
                    const SizedBox(width: 6),
                    Text(
                      kategoriNama,
                      style: TextStyle(
                        color: categoryColor,
                        fontSize: chipSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Cover image (jika ada)
          if (coverUrl.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  coverUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    alignment: Alignment.center,
                    color: categoryColor.withValues(alpha: 0.08),
                    child: Icon(
                      Icons.broken_image_rounded,
                      color: categoryColor.withValues(alpha: 0.4),
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Judul
          Text(
            post.judul,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
              height: 1.3,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),

          // Konten (pakai isi jika ada; fallback excerpt)
          Text(
            (post.isi?.isNotEmpty == true) ? post.isi! : post.excerpt,
            style: TextStyle(
              fontSize: bodySize,
              color: AppTheme.onSurface.withValues(alpha: 0.9),
              height: 1.6,
            ),
          ),

          // Galeri
          if (gallery.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: gallery.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final url = gallery[i];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 1.4,
                      child: Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: categoryColor.withValues(alpha: 0.08),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.broken_image_rounded,
                            color: categoryColor.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Action Buttons
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              GestureDetector(
                onTap: isTogglingLike ? null : _toggleLike,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.isSmallScreen(context)
                        ? 14
                        : 16,
                    vertical: ResponsiveHelper.isSmallScreen(context) ? 8 : 10,
                  ),
                  decoration: BoxDecoration(
                    color: liked
                        ? Colors.red.withValues(alpha: 0.1)
                        : AppTheme.primaryBlue.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: liked
                          ? Colors.red.withValues(alpha: 0.2)
                          : AppTheme.primaryBlue.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isTogglingLike)
                        SizedBox(
                          width: iconSz,
                          height: iconSz,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryBlue,
                            ),
                          ),
                        )
                      else
                        Icon(
                          liked ? Icons.favorite : Icons.favorite_border,
                          color: liked ? Colors.red : AppTheme.onSurfaceVariant,
                          size: iconSz,
                        ),
                      const SizedBox(width: 8),
                      Text(
                        '${post.totalLikes}',
                        style: TextStyle(
                          color: liked ? Colors.red : AppTheme.onSurfaceVariant,
                          fontSize: ResponsiveHelper.adaptiveTextSize(
                            context,
                            14,
                          ),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.isSmallScreen(context) ? 14 : 16,
                  vertical: ResponsiveHelper.isSmallScreen(context) ? 8 : 10,
                ),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: categoryColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      color: categoryColor,
                      size: iconSz,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${post.totalKomentar}',
                      style: TextStyle(
                        color: categoryColor,
                        fontSize: ResponsiveHelper.adaptiveTextSize(
                          context,
                          14,
                        ),
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
    );
  }

  Widget _buildCommentsSection(KomunitasPostingan post) {
    final titleSize = ResponsiveHelper.adaptiveTextSize(context, 18);
    final iconSz = ResponsiveHelper.adaptiveTextSize(context, 22);

    final comments = post.komentars ?? [];

    return Container(
      padding: EdgeInsets.all(_gap(context) + 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.08),
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
                padding: EdgeInsets.all(
                  ResponsiveHelper.isSmallScreen(context) ? 8 : 10,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryBlue.withValues(alpha: 0.1),
                      AppTheme.accentGreen.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.forum_rounded,
                  color: AppTheme.primaryBlue,
                  size: iconSz,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Komentar (${comments.length})',
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (comments.isEmpty)
            _buildEmptyCommentsState()
          else
            ...comments.map((comment) => _buildCommentItem(comment, post)),
        ],
      ),
    );
  }

  Widget _buildEmptyCommentsState() {
    final titleSize = ResponsiveHelper.adaptiveTextSize(context, 16);
    final subSize = ResponsiveHelper.adaptiveTextSize(context, 14);
    final iconSz = ResponsiveHelper.adaptiveTextSize(context, 48);

    final isLoggedIn =
        ref.watch(authProvider)['status'] == AuthState.authenticated;

    return Center(
      child: Container(
        padding: EdgeInsets.all(_gap(context) * 2),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(
                ResponsiveHelper.isSmallScreen(context) ? 16 : 20,
              ),
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
                Icons.chat_bubble_outline,
                size: iconSz,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada komentar',
              style: TextStyle(
                fontSize: titleSize,
                color: AppTheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isLoggedIn
                  ? 'Jadilah yang pertama berkomentar'
                  : 'Masuk untuk berkomentar',
              style: TextStyle(
                fontSize: subSize,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentItem(Komentar comment, KomunitasPostingan post) {
    final isAnonymous = comment.isAnonymous ?? false;
    final kategoriNama = post.kategori.nama;
    final categoryColor = _getCategoryColor(kategoriNama);

    final nameSize = ResponsiveHelper.adaptiveTextSize(context, 14);
    final timeSize = ResponsiveHelper.adaptiveTextSize(context, 12);
    final contentSize = ResponsiveHelper.adaptiveTextSize(context, 14);
    final avatarSide = ResponsiveHelper.isSmallScreen(context) ? 34.0 : 36.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(
        ResponsiveHelper.isSmallScreen(context) ? 14 : 16,
      ),
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
                width: avatarSide,
                height: avatarSide,
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
                      ? Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: nameSize,
                        )
                      : Text(
                          (comment.penulis.isNotEmpty
                                  ? comment.penulis[0]
                                  : 'U')
                              .toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: ResponsiveHelper.adaptiveTextSize(
                              context,
                              14,
                            ),
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
                        Flexible(
                          child: Text(
                            comment.penulis,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: nameSize,
                              color: isAnonymous
                                  ? AppTheme.onSurfaceVariant
                                  : AppTheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
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
                                fontSize: ResponsiveHelper.adaptiveTextSize(
                                  context,
                                  10,
                                ),
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
                          size: timeSize,
                          color: AppTheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(comment.createdAt),
                          style: TextStyle(
                            fontSize: timeSize,
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
            comment.komentar,
            style: TextStyle(
              fontSize: contentSize,
              color: AppTheme.onSurface.withValues(alpha: 0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(bool isSubmitting) {
    final authState = ref.watch(authProvider);
    final currentUserName = authState['user']?['name'] ?? 'User';

    final padH = ResponsiveHelper.isSmallScreen(context) ? 14.0 : 16.0;
    final padV = ResponsiveHelper.isSmallScreen(context) ? 12.0 : 16.0;
    final sendIconSize = ResponsiveHelper.adaptiveTextSize(context, 22);
    final nameSize = ResponsiveHelper.adaptiveTextSize(context, 14);
    final toggleSize = ResponsiveHelper.adaptiveTextSize(context, 12);

    return Container(
      padding: EdgeInsets.only(
        left: padH,
        right: padH,
        top: padV,
        bottom: MediaQuery.of(context).viewInsets.bottom + padV,
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
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: _maxWidth(context)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Anonymous Toggle
              Row(
                children: [
                  Icon(
                    _isAnonymous
                        ? Icons.visibility_off_rounded
                        : Icons.person_rounded,
                    size: ResponsiveHelper.adaptiveTextSize(context, 18),
                    color: AppTheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isAnonymous ? 'Anonim' : currentUserName,
                    style: TextStyle(
                      fontSize: nameSize,
                      color: AppTheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: isSubmitting
                        ? null
                        : () => setState(() => _isAnonymous = !_isAnonymous),
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
                        _isAnonymous ? 'Pakai Nama' : 'Kirim Anonim',
                        style: TextStyle(
                          fontSize: toggleSize,
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
                        enabled: !isSubmitting,
                        decoration: InputDecoration(
                          hintText: _isAnonymous
                              ? 'Tulis komentar sebagai anonim...'
                              : 'Tulis komentar...',
                          hintStyle: TextStyle(
                            color: AppTheme.onSurfaceVariant.withValues(
                              alpha: 0.6,
                            ),
                            fontSize: ResponsiveHelper.adaptiveTextSize(
                              context,
                              14,
                            ),
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
                      onPressed: isSubmitting ? null : _addComment,
                      icon: isSubmitting
                          ? SizedBox(
                              width: sendIconSize,
                              height: sendIconSize,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.send_rounded, color: Colors.white),
                      iconSize: sendIconSize,
                      style: IconButton.styleFrom(
                        padding: EdgeInsets.all(
                          ResponsiveHelper.isSmallScreen(context) ? 10 : 12,
                        ),
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

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
