import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_flutter/core/utils/logger.dart';
import 'package:test_flutter/core/utils/responsive_helper.dart';
import 'package:test_flutter/core/widgets/toast.dart';
import 'package:test_flutter/data/models/komunitas/komunitas.dart';
import 'package:test_flutter/features/auth/auth_provider.dart';
import 'package:test_flutter/features/komunitas/services/komunitas_service.dart';
import '../../../app/theme.dart';

class DetailKomunitasPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> post;

  const DetailKomunitasPage({super.key, required this.post});

  @override
  ConsumerState<DetailKomunitasPage> createState() =>
      _DetailKomunitasPageState();
}

class _DetailKomunitasPageState extends ConsumerState<DetailKomunitasPage> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isAnonymous = false;
  bool _isLoading = true;
  bool _isLoadingComments = false;
  bool _isSubmittingComment = false;
  bool _isTogglingLike = false;
  String? _error;

  KomunitasArtikel? _artikel;
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
    _loadArtikelDetail();
  }

  Future<void> _loadArtikelDetail() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      logger.fine('Loading artikel detail for ID: ${widget.post['id']}');

      final response = await KomunitasService.getArtikelById(widget.post['id']);

      setState(() {
        _artikel = KomunitasArtikel.fromJson(response['data']);
        _isLoading = false;
      });

      await _loadComments();
    } catch (e) {
      logger.warning('Error loading artikel detail: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadComments({bool loadMore = false}) async {
    if (_isLoadingComments) return;

    try {
      setState(() => _isLoadingComments = true);

      final page = loadMore ? _currentCommentPage + 1 : 1;

      logger.fine('Loading comments for artikel ${_artikel?.id}, page: $page');

      final response = await KomunitasService.getComments(
        artikelId: _artikel!.id,
        page: page,
      );

      final commentsData = response['data'] as List;
      final newComments = commentsData
          .map(
            (comment) => {
              'id': comment['id'].toString(),
              'authorName': comment['is_anonymous'] == true
                  ? 'Anonim'
                  : comment['user']?['name'] ?? 'User',
              'content': comment['content'],
              'date': _formatDate(DateTime.parse(comment['created_at'])),
              'isAnonymous': comment['is_anonymous'] ?? false,
              'authorId': comment['user_id']?.toString() ?? 'anonymous',
            },
          )
          .toList();

      setState(() {
        if (loadMore) {
          _comments.addAll(newComments);
          _currentCommentPage = response['current_page'];
        } else {
          _comments = newComments;
          _currentCommentPage = response['current_page'];
        }
        _lastCommentPage = response['last_page'];
        _isLoadingComments = false;
      });
    } catch (e) {
      logger.warning('Error loading comments: $e');
      setState(() => _isLoadingComments = false);

      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showMessageToast(
            context,
            message: 'Gagal memuat komentar: ${e.toString()}',
            type: ToastType.error,
            duration: const Duration(seconds: 4),
          );
          ref.read(authProvider.notifier).clearError();
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty || _isSubmittingComment) return;

    try {
      setState(() => _isSubmittingComment = true);

      logger.fine('Adding comment to artikel ${_artikel?.id}');

      await KomunitasService.addComment(
        artikelId: _artikel!.id,
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
    } catch (e) {
      logger.warning('Error adding comment: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menambah komentar: ${e.toString()}'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      setState(() => _isSubmittingComment = false);
    }
  }

  Future<void> _toggleLike() async {
    if (_isTogglingLike || _artikel == null) return;

    try {
      setState(() => _isTogglingLike = true);

      logger.fine('Toggling like for artikel ${_artikel?.id}');

      await KomunitasService.toggleLike(_artikel!.id);

      await _loadArtikelDetail();
    } catch (e) {
      logger.warning('Error toggling like: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal toggle like: ${e.toString()}'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      setState(() => _isTogglingLike = false);
    }
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState['status'] == AuthState.authenticated;

    final appbarTitleSize = ResponsiveHelper.adaptiveTextSize(context, 20);
    final appbarSubSize = ResponsiveHelper.adaptiveTextSize(context, 13);
    final iconSize = ResponsiveHelper.adaptiveTextSize(context, 22);
    final appbarPad = ResponsiveHelper.isSmallScreen(context) ? 14.0 : 16.0;

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
                                'Detail Diskusi',
                                style: TextStyle(
                                  fontSize: appbarTitleSize,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.onSurface,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              Text(
                                '${_artikel?.jumlahKomentar ?? 0} komentar',
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
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),

      // Comment Input (Only show if logged in)
      bottomSheet: isLoggedIn ? _buildCommentInput() : null,
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_artikel == null) {
      return _buildErrorState(message: 'Artikel tidak ditemukan');
    }

    final extraBottom =
        ref.watch(authProvider)['status'] == AuthState.authenticated
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
            _buildArtikelCard(),
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
              'Memuat detail artikel...',
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
                'Failed to Load Data',
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message ??
                    _error ??
                    'Terjadi kesalahan saat memuat detail artikel',
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
                      label: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _loadArtikelDetail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 20),
                      label: const Text('Try Again'),
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

  Widget _buildArtikelCard() {
    final categoryColor = _getCategoryColor(_artikel!.kategori);
    final categoryIcon = _getCategoryIcon(_artikel!.kategori);
    final isLiked = false; // TODO: map dari API

    final titleSize = ResponsiveHelper.adaptiveTextSize(context, 22);
    final bodySize = ResponsiveHelper.adaptiveTextSize(context, 15);
    final chipSize = ResponsiveHelper.adaptiveTextSize(context, 13);
    final iconSz = ResponsiveHelper.adaptiveTextSize(context, 20);

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
                  radius: ResponsiveHelper.isSmallScreen(context) ? 22 : 24,
                  backgroundColor: Colors.white,
                  child: Text(
                    'G',
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
                      'Guest',
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
                          _artikel!.formattedDate,
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
                      _artikel!.kategori,
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
          const SizedBox(height: 20),

          // Post Title
          Text(
            _artikel!.judul,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
              height: 1.3,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),

          // Post Content
          Text(
            _artikel!.isi ?? _artikel!.excerpt,
            style: TextStyle(
              fontSize: bodySize,
              color: AppTheme.onSurface.withValues(alpha: 0.9),
              height: 1.6,
            ),
          ),

          const SizedBox(height: 20),

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
                    color: isLiked
                        ? Colors.red.withValues(alpha: 0.1)
                        : AppTheme.primaryBlue.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isLiked
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
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked
                              ? Colors.red
                              : AppTheme.onSurfaceVariant,
                          size: iconSz,
                        ),
                      const SizedBox(width: 8),
                      Text(
                        '${_artikel!.jumlahLike}',
                        style: TextStyle(
                          color: isLiked
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
                  color: _getCategoryColor(
                    _artikel!.kategori,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getCategoryColor(
                      _artikel!.kategori,
                    ).withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      color: _getCategoryColor(_artikel!.kategori),
                      size: iconSz,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_comments.length}',
                      style: TextStyle(
                        color: _getCategoryColor(_artikel!.kategori),
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
                      _isLoadingComments
                          ? 'Memuat...'
                          : 'Muat Komentar Lainnya',
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
              ref.watch(authProvider)['status'] == AuthState.authenticated
                  ? 'Jadilah yang pertama berkomentar'
                  : 'Login untuk berkomentar',
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
    final categoryColor = _getCategoryColor(_artikel!.kategori);

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
                          comment['authorName'][0].toUpperCase(),
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
                        _isAnonymous ? 'Gunakan Nama' : 'Kirim Anonim',
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
                              : 'Tulis komentar Anda...',
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
