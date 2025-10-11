import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:test_flutter/app/theme.dart';
import 'package:test_flutter/core/utils/format_helper.dart';
import 'package:test_flutter/core/utils/logger.dart';
import 'package:test_flutter/core/utils/responsive_helper.dart';
import 'package:test_flutter/core/widgets/toast.dart';

import 'package:test_flutter/data/models/komunitas/komunitas.dart'; // pastikan berisi KomunitasPostingan
import 'package:test_flutter/features/auth/auth_provider.dart';
import 'package:test_flutter/features/komunitas/services/komunitas_service.dart';

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
  bool _isLoading = true;
  bool _isLoadingComments = false;
  bool _isSubmittingComment = false;
  bool _isTogglingLike = false;
  bool _liked = false; // isi dari API kalau tersedia

  String? _error;

  KomunitasPostingan? _post; // MODEL BARU
  List<Map<String, dynamic>> _comments = [];
  int _currentCommentPage = 1;
  int _lastCommentPage = 1;

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
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final id =
          int.tryParse(widget.post['id'].toString()) ??
          widget.post['id'] as int;
      logger.fine('Loading postingan detail for ID: $id');

      final response = await KomunitasService.getPostinganById(id as String);
      // response diharapkan: { "data": { ...postingan... , "liked": bool? } }
      final data = response['data'];
      final liked = (data?['liked'] == true); // optional

      setState(() {
        _post = KomunitasPostingan.fromJson(data);
        _liked = liked;
        _isLoading = false;
      });

      await _loadComments();
    } catch (e, st) {
      logger.warning('Error loading postingan detail: $e', e, st);
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadComments({bool loadMore = false}) async {
    if (_isLoadingComments || _post == null) return;

    try {
      setState(() => _isLoadingComments = true);

      final page = loadMore ? _currentCommentPage + 1 : 1;

      logger.fine('Loading comments for postingan ${_post!.id}, page: $page');

      final response = await KomunitasService.getComments(
        artikelId: _post!.id as String, // endpoint sama, param bernama artikelId
        page: page,
      );

      final commentsData = (response['data'] as List?) ?? const [];
      final newComments = commentsData
          .map(
            (comment) => {
              'id': comment['id'].toString(),
              'authorName': comment['is_anonymous'] == true
                  ? 'Anonim'
                  : (comment['user']?['name'] ?? 'User'),
              'content': comment['content'] ?? '',
              'date': _formatDate(DateTime.parse(comment['created_at'])),
              'isAnonymous': comment['is_anonymous'] ?? false,
              'authorId': comment['user_id']?.toString() ?? 'anonymous',
            },
          )
          .toList();

      setState(() {
        if (loadMore) {
          _comments.addAll(newComments);
        } else {
          _comments = newComments;
        }
        _currentCommentPage = response['current_page'] ?? page;
        _lastCommentPage = response['last_page'] ?? page;
        _isLoadingComments = false;
      });
    } catch (e, st) {
      logger.warning('Error loading comments: $e', e, st);
      setState(() => _isLoadingComments = false);

      if (mounted) {
        showMessageToast(
          context,
          message: 'Gagal memuat komentar: $e',
          type: ToastType.error,
          duration: const Duration(seconds: 4),
        );
      }
    }
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
    if (_commentController.text.trim().isEmpty || _isSubmittingComment) return;

    try {
      setState(() => _isSubmittingComment = true);

      logger.fine('Adding comment to postingan ${_post?.id}');

      await KomunitasService.addComment(
        artikelId: _post!.id as String, // param nama masih artikelId di service
        content: _commentController.text.trim(),
        isAnonymous: _isAnonymous,
      );

      _commentController.clear();
      setState(() => _isAnonymous = false);

      await _loadComments();

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
    } finally {
      setState(() => _isSubmittingComment = false);
    }
  }

  Future<void> _toggleLike() async {
    if (_isTogglingLike || _post == null) return;

    try {
      setState(() => _isTogglingLike = true);

      logger.fine('Toggling like for postingan ${_post?.id}');

      await KomunitasService.toggleLike(_post!.id as String);

      // Optimistic update (kalau API tidak kembalikan detail liked)
      setState(() {
        _liked = !_liked;
        // final current = _post!.totalLikes;
        // _post = _post!.copyWith(totalLikes: _liked ? current + 1 : current - 1);
      });

      // kalau mau strict dari server:
      // await _loadDetail();
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
    } finally {
      setState(() => _isTogglingLike = false);
    }
  }

  // Kategori warna/icon menggunakan nama kategori
  Color _getCategoryColor(String nama) {
    switch (nama.toLowerCase()) {
      case 'ibadah':
        return const Color(0xFF3B82F6);
      case 'event':
        return const Color(0xFFF97316);
      case 'sharing':
        return const Color(0xFF10B981);
      case 'pertanyaan':
        return const Color(0xFF8B5CF6);
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

    final appbarTitleSize = ResponsiveHelper.adaptiveTextSize(context, 20);
    final appbarSubSize = ResponsiveHelper.adaptiveTextSize(context, 13);
    final iconSize = ResponsiveHelper.adaptiveTextSize(context, 22);
    final appbarPad = ResponsiveHelper.isSmallScreen(context) ? 14.0 : 16.0;

    final totalComments = _post?.totalKomentar ?? _comments.length;

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
                            onPressed: () => Navigator.pop(context),
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
              Expanded(child: _buildContent(isLoggedIn)),
            ],
          ),
        ),
      ),

      // Comment Input (Only show if logged in)
      bottomSheet: isLoggedIn ? _buildCommentInput() : null,
    );
  }

  Widget _buildContent(bool isLoggedIn) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_post == null) {
      return _buildErrorState(message: 'Postingan tidak ditemukan');
    }

    final extraBottom = isLoggedIn
        ? (ResponsiveHelper.isSmallScreen(context) ? 100 : 120)
        : 20;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: _maxWidth(context)),
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: _pagePadding(context, extraBottom: extraBottom.toDouble()),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPostCard(),
            SizedBox(height: _gap(context) + 4),
            _buildCommentsSection(),
          ],
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
                message ?? _error ?? 'Terjadi kesalahan. Coba lagi nanti.',
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

  Widget _buildPostCard() {
    final kategoriNama = _post!.kategori.nama;
    final categoryColor = _getCategoryColor(kategoriNama);
    final categoryIcon = _getCategoryIcon(kategoriNama);

    final titleSize = ResponsiveHelper.adaptiveTextSize(context, 22);
    final bodySize = ResponsiveHelper.adaptiveTextSize(context, 15);
    final chipSize = ResponsiveHelper.adaptiveTextSize(context, 13);
    final iconSz = ResponsiveHelper.adaptiveTextSize(context, 20);

    final coverUrl = _post!
        .cover; // string path (udah absolute di model?), kalau masih relatif, format di model
    final gallery = _post!.daftarGambar; // List<String>

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
                    (_post!.penulis.isNotEmpty ? _post!.penulis[0] : 'G')
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
                      _post!.penulis,
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
                          FormatHelper.getFormattedDate(_post!.createdAt),
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
            _post!.judul,
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
            (_post!.isi?.isNotEmpty == true) ? _post!.isi! : _post!.excerpt,
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
                onTap: _isTogglingLike ? null : _toggleLike,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.isSmallScreen(context)
                        ? 14
                        : 16,
                    vertical: ResponsiveHelper.isSmallScreen(context) ? 8 : 10,
                  ),
                  decoration: BoxDecoration(
                    color: _liked
                        ? Colors.red.withValues(alpha: 0.1)
                        : AppTheme.primaryBlue.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _liked
                          ? Colors.red.withValues(alpha: 0.2)
                          : AppTheme.primaryBlue.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isTogglingLike)
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
                          _liked ? Icons.favorite : Icons.favorite_border,
                          color: _liked
                              ? Colors.red
                              : AppTheme.onSurfaceVariant,
                          size: iconSz,
                        ),
                      const SizedBox(width: 8),
                      Text(
                        '${_post!.totalLikes}',
                        style: TextStyle(
                          color: _liked
                              ? Colors.red
                              : AppTheme.onSurfaceVariant,
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
                  color: _getCategoryColor(kategoriNama).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getCategoryColor(
                      kategoriNama,
                    ).withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      color: _getCategoryColor(kategoriNama),
                      size: iconSz,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_post!.totalKomentar}',
                      style: TextStyle(
                        color: _getCategoryColor(kategoriNama),
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

  Widget _buildCommentsSection() {
    final titleSize = ResponsiveHelper.adaptiveTextSize(context, 18);
    final iconSz = ResponsiveHelper.adaptiveTextSize(context, 22);

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
                  'Komentar (${_comments.length})',
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              if (_isLoadingComments)
                SizedBox(
                  width: ResponsiveHelper.isSmallScreen(context) ? 16 : 20,
                  height: ResponsiveHelper.isSmallScreen(context) ? 16 : 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryBlue,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          if (_comments.isEmpty && !_isLoadingComments)
            _buildEmptyCommentsState()
          else ...[
            ..._comments.map((comment) => _buildCommentItem(comment)),
            if (_currentCommentPage < _lastCommentPage)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Center(
                  child: ElevatedButton(
                    onPressed: _isLoadingComments
                        ? null
                        : () => _loadComments(loadMore: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue.withValues(
                        alpha: 0.1,
                      ),
                      foregroundColor: AppTheme.primaryBlue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _isLoadingComments ? 'Memuat...' : 'Muat Komentar Lain',
                    ),
                  ),
                ),
              ),
          ],
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

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    final isAnonymous = comment['isAnonymous'] ?? false;
    final kategoriNama = _post!.kategori.nama;
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
                          (comment['authorName'] ?? 'U')[0].toUpperCase(),
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
                        Text(
                          comment['authorName'],
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: nameSize,
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
                          comment['date'],
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
            comment['content'],
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

  Widget _buildCommentInput() {
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
                        enabled: !_isSubmittingComment,
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
                      onPressed: _isSubmittingComment ? null : _addComment,
                      icon: _isSubmittingComment
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
