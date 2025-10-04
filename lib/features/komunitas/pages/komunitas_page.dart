import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_flutter/core/utils/date_helper.dart';
import 'package:test_flutter/core/utils/logger.dart';
import 'package:test_flutter/core/utils/responsive_helper.dart';
import 'package:test_flutter/data/models/komunitas/komunitas.dart';
import 'package:test_flutter/features/auth/auth_provider.dart';
import 'package:test_flutter/features/komunitas/komunitas_provider.dart';
import '../../../app/theme.dart';
import 'detail_komunitas_page.dart';
import 'tambah_post_page.dart';

class KomunitasPage extends ConsumerStatefulWidget {
  const KomunitasPage({super.key});

  @override
  ConsumerState<KomunitasPage> createState() => _KomunitasPageState();
}

class _KomunitasPageState extends ConsumerState<KomunitasPage>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final String _selectedCategory = 'Semua';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _init();
    _setupScrollListener();
  }

  void _init() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(komunitasProvider.notifier).loadArtikel();
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreIfPossible();
      }
    });
  }

  void _loadMoreIfPossible() {
    final komunitasState = ref.read(komunitasProvider);
    final currentPage = komunitasState['currentPage'] as int;
    final lastPage = komunitasState['lastPage'] as int;
    final status = komunitasState['status'];

    // Only load more if not already loading and there are more pages
    if (status != KomunitasArtikelState.loading &&
        status != KomunitasArtikelState.loadingMore &&
        currentPage < lastPage) {
      ref.read(komunitasProvider.notifier).loadArtikel(loadMore: true);
    }
  }

  // Handle pull to refresh
  Future<void> _handleRefresh() async {
    logger.fine('Pull to refresh triggered');
    await ref.read(komunitasProvider.notifier).refresh();
  }

  List<Map<String, dynamic>> get _filteredPosts {
    final artikel =
        ref.read(komunitasProvider)['artikel'] as List<KomunitasArtikel>? ?? [];

    return artikel
        .where((item) {
          final matchesCategory =
              _selectedCategory == 'Semua' ||
              item.kategori == _selectedCategory;
          final matchesSearch =
              _searchQuery.isEmpty ||
              item.judul.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              item.excerpt.toLowerCase().contains(_searchQuery.toLowerCase());
          return matchesCategory && matchesSearch;
        })
        .map(
          (item) => {
            'id': item.id.toString(),
            'title': item.judul,
            'content': item.excerpt,
            'category': item.kategori,
            'authorId': item.userId.toString(),
            'authorName': 'guest',
            'date': DateHelper.getFormattedDate(item.createdAt),
            'likes': item.jumlahLike,
            'likedBy': [],
            'comments': item.jumlahKomentar,
            'imageUrl': (item.gambar.isNotEmpty)
                ? ("${dotenv.env['STORAGE_URL']}/${item.gambar[0]}")
                : null,
          },
        )
        .toList();
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
      // Refresh the list after adding new post
      ref.read(komunitasProvider.notifier).loadArtikel();
    }
  }

  void _toggleLike(String postId) {
    // TODO: Implement API call to toggle like
    logger.fine('Toggle like for post: $postId');
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
            const Text('Delete Post'),
          ],
        ),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement API call to delete post
              Navigator.pop(context);
              // Refresh list after deletion
              ref.read(komunitasProvider.notifier).loadArtikel();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete'),
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
      // Optionally refresh the list if needed
      ref.read(komunitasProvider.notifier).loadArtikel();
    }
  }

  // ===== Responsiveness helpers =====
  double _maxWidth(BuildContext context) {
    if (ResponsiveHelper.isExtraLargeScreen(context)) return 1100;
    if (ResponsiveHelper.isLargeScreen(context)) return 980;
    if (ResponsiveHelper.isMediumScreen(context)) return 760;
    return double.infinity;
  }

  int _gridColumns(BuildContext context) {
    if (ResponsiveHelper.isExtraLargeScreen(context)) return 3; // ≥1200
    if (ResponsiveHelper.isLargeScreen(context)) return 2; // 900–1199
    return 1; // mobile & tablet kecil pakai list 1 kolom
  }

  double _cardImageHeight(BuildContext context) {
    if (ResponsiveHelper.isExtraLargeScreen(context)) return 220;
    if (ResponsiveHelper.isLargeScreen(context)) return 200;
    if (ResponsiveHelper.isMediumScreen(context)) return 190;
    return 180;
  }

  @override
  Widget build(BuildContext context) {
    final pagePad = ResponsiveHelper.getResponsivePadding(context);
    final titleSize = ResponsiveHelper.adaptiveTextSize(context, 28);
    final subtitleSize = ResponsiveHelper.adaptiveTextSize(context, 15);
    final useGrid = _gridColumns(context) > 1;

    // Watch komunitas state
    final komunitasState = ref.watch(komunitasProvider);
    final currentPage = komunitasState['currentPage'] as int;
    final lastPage = komunitasState['lastPage'] as int;

    // Watch auth state to check if user is logged in
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState['status'] == AuthState.authenticated;

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
              // Header + Search (Fixed at top)
              Padding(
                padding: EdgeInsets.all(pagePad.horizontal / 2),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: _maxWidth(context)),
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
                                size: ResponsiveHelper.adaptiveTextSize(
                                  context,
                                  26,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Community',
                                  style: TextStyle(
                                    fontSize: titleSize,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.onSurface,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                Text(
                                  'Share and discuss with others',
                                  style: TextStyle(
                                    fontSize: subtitleSize,
                                    color: AppTheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.primaryBlue.withValues(
                                alpha: 0.1,
                              ),
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
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) =>
                                setState(() => _searchQuery = value),
                            style: TextStyle(
                              fontSize: ResponsiveHelper.adaptiveTextSize(
                                context,
                                14,
                              ),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search discussions...',
                              hintStyle: TextStyle(
                                color: AppTheme.onSurfaceVariant.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: AppTheme.primaryBlue,
                                size: ResponsiveHelper.adaptiveTextSize(
                                  context,
                                  22,
                                ),
                              ),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.clear_rounded,
                                        color: AppTheme.onSurfaceVariant,
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _searchQuery = '');
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Content with RefreshIndicator
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: _maxWidth(context)),
                    child: _buildContentArea(
                      komunitasState,
                      currentPage,
                      lastPage,
                      useGrid,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // Only show FAB if user is logged in
      floatingActionButton: isLoggedIn ? _buildFloatingActionButton() : null,
    );
  }

  Widget _buildContentArea(
    Map<String, dynamic> komunitasState,
    int currentPage,
    int lastPage,
    bool useGrid,
  ) {
    final status = komunitasState['status'];
    final isOffline = komunitasState['isOffline'] as bool;

    // Show initial loading in content area
    if (status == KomunitasArtikelState.loading && currentPage == 1) {
      return _buildLoadingState();
    }

    // Show error state in content area (only if no cached data)
    if (status == KomunitasArtikelState.error && _filteredPosts.isEmpty) {
      return _buildErrorState(komunitasState['error']);
    }

    // Show content with refresh indicator
    if (_filteredPosts.isEmpty && status != KomunitasArtikelState.loading) {
      return RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppTheme.primaryBlue,
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: _emptyState(),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Offline indicator - UNCOMMENT INI
        if (isOffline) ...[_buildOfflineIndicator(), SizedBox(height: 8)],

        // Content
        Expanded(
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            color: AppTheme.primaryBlue,
            backgroundColor: Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.isSmallScreen(context) ? 12 : 20,
              ),
              child: useGrid
                  ? GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(bottom: 100),
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _gridColumns(context),
                        mainAxisSpacing: 18,
                        crossAxisSpacing: 18,
                        childAspectRatio:
                            ResponsiveHelper.isExtraLargeScreen(context)
                            ? 0.78
                            : ResponsiveHelper.isLargeScreen(context)
                            ? 0.8
                            : 0.85,
                      ),
                      itemCount:
                          _filteredPosts.length +
                          (currentPage < lastPage && !isOffline ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= _filteredPosts.length) {
                          return _buildLoadMoreIndicator();
                        }
                        final post = _filteredPosts[index];
                        return _buildEnhancedPostCard(
                          post,
                          imageHeight: _cardImageHeight(context),
                        );
                      },
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(bottom: 100),
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      itemCount:
                          _filteredPosts.length +
                          (currentPage < lastPage && !isOffline ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= _filteredPosts.length) {
                          return _buildLoadMoreIndicator();
                        }
                        final post = _filteredPosts[index];
                        return _buildEnhancedPostCard(
                          post,
                          imageHeight: _cardImageHeight(context),
                        );
                      },
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOfflineIndicator() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded, color: Colors.orange.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'You are offline. Some features may be unavailable.',
              style: TextStyle(
                color: Colors.orange.shade700,
                fontSize: ResponsiveHelper.adaptiveTextSize(context, 14),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: _handleRefresh,
            child: Text(
              'Retry',
              style: TextStyle(
                color: Colors.orange.shade700,
                fontSize: ResponsiveHelper.adaptiveTextSize(context, 12),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // New loading state widget for content area
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Load article...',
                  style: TextStyle(
                    color: AppTheme.onSurface,
                    fontSize: ResponsiveHelper.adaptiveTextSize(context, 16),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please wait a moment...',
                  style: TextStyle(
                    color: AppTheme.onSurfaceVariant,
                    fontSize: ResponsiveHelper.adaptiveTextSize(context, 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // New error state widget for content area
  Widget _buildErrorState(String? errorMessage) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 48,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Failed to Load Data',
              style: TextStyle(
                fontSize: ResponsiveHelper.adaptiveTextSize(context, 18),
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'An error occurred while loading the article',
              style: TextStyle(
                color: Colors.red.shade600,
                fontSize: ResponsiveHelper.adaptiveTextSize(context, 14),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ref.read(komunitasProvider.notifier).loadArtikel();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: Text(
                  'Try Again',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.adaptiveTextSize(context, 16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
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
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: ResponsiveHelper.adaptiveTextSize(context, 30),
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Loading more...',
              style: TextStyle(
                color: AppTheme.onSurfaceVariant,
                fontSize: ResponsiveHelper.adaptiveTextSize(context, 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== UI pieces =====
  Widget _emptyState() {
    return Column(
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
            size: ResponsiveHelper.adaptiveTextSize(context, 64),
            color: AppTheme.primaryBlue,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'No Discussions Yet',
          style: TextStyle(
            fontSize: ResponsiveHelper.adaptiveTextSize(context, 18),
            color: AppTheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          ref.watch(authProvider)['status'] == AuthState.authenticated
              ? 'Start a new discussion by pressing the + button'
              : 'Login to start a new discussion',
          style: TextStyle(
            fontSize: ResponsiveHelper.adaptiveTextSize(context, 14),
            color: AppTheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Pull down to refresh',
          style: TextStyle(
            fontSize: ResponsiveHelper.adaptiveTextSize(context, 12),
            color: AppTheme.onSurfaceVariant.withValues(alpha: 0.7),
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEnhancedPostCard(
    Map<String, dynamic> post, {
    required double imageHeight,
  }) {
    final isLiked = false; // TODO: Check from user's liked posts
    final authState = ref.watch(authProvider);
    final currentUser = authState['user'];
    final isMyPost =
        currentUser != null && post['authorId'] == currentUser['id'].toString();
    final categoryColor = _getCategoryColor(post['category']);
    final categoryIcon = _getCategoryIcon(post['category']);

    return GestureDetector(
      onTap: () => _navigateToDetail(post),
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
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
            // Header author
            Padding(
              padding: const EdgeInsets.all(16),
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
                      radius: 20,
                      backgroundColor: Colors.white,
                      child: Text(
                        post['authorName'][0].toUpperCase(),
                        style: TextStyle(
                          color: categoryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: ResponsiveHelper.adaptiveTextSize(
                            context,
                            16,
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
                        Text(
                          post['authorName'],
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: ResponsiveHelper.adaptiveTextSize(
                              context,
                              15,
                            ),
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
                                fontSize: ResponsiveHelper.adaptiveTextSize(
                                  context,
                                  12,
                                ),
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
                                const Text('Delete Post'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Category chip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
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
                        fontSize: ResponsiveHelper.adaptiveTextSize(
                          context,
                          12.5,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Title + content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post['title'],
                    style: TextStyle(
                      fontSize: ResponsiveHelper.adaptiveTextSize(context, 17),
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                      height: 1.3,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post['content'],
                    style: TextStyle(
                      fontSize: ResponsiveHelper.adaptiveTextSize(context, 14),
                      color: AppTheme.onSurface.withValues(alpha: 0.8),
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Image
            if (post['imageUrl'] != null) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      // Blur placeholder
                      Container(
                        width: double.infinity,
                        height: imageHeight,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              categoryColor.withValues(alpha: 0.1),
                              categoryColor.withValues(alpha: 0.05),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.image_rounded,
                            size: ResponsiveHelper.adaptiveTextSize(
                              context,
                              44,
                            ),
                            color: categoryColor.withValues(alpha: 0.3),
                          ),
                        ),
                      ),

                      // Network image
                      Image.network(
                        post['imageUrl'],
                        width: double.infinity,
                        height: imageHeight,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return ImageFiltered(
                            imageFilter: ImageFilter.blur(
                              sigmaX: 12,
                              sigmaY: 12,
                            ),
                            child: child,
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: imageHeight,
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
                              Icons.broken_image_rounded,
                              size: ResponsiveHelper.adaptiveTextSize(
                                context,
                                44,
                              ),
                              color: categoryColor.withValues(alpha: 0.4),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Actions
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
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
                            fontSize: ResponsiveHelper.adaptiveTextSize(
                              context,
                              13.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 22),
                  Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        color: AppTheme.onSurfaceVariant,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post['comments']}',
                        style: TextStyle(
                          color: AppTheme.onSurfaceVariant,
                          fontSize: ResponsiveHelper.adaptiveTextSize(
                            context,
                            13.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Icon(
                  //   Icons.share_outlined,
                  //   color: AppTheme.onSurfaceVariant,
                  //   size: 20,
                  // ),
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
    _scrollController.dispose();
    super.dispose();
  }
}
