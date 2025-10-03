import 'package:flutter/material.dart';
import 'package:test_flutter/core/utils/responsive_helper.dart';
import '../../../app/theme.dart';

class TambahPostPage extends StatefulWidget {
  const TambahPostPage({super.key});

  @override
  State<TambahPostPage> createState() => _TambahPostPageState();
}

class _TambahPostPageState extends State<TambahPostPage>
    with TickerProviderStateMixin {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _selectedCategory = 'Diskusi';
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> _categories = [
    'Diskusi',
    'Pertanyaan',
    'Sharing',
    'Event',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _animationController.forward();
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

  Future<void> _handleSubmit() async {
    if (_titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Judul dan konten tidak boleh kosong'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1500));

    final newPost = {
      'id': 'post_${DateTime.now().millisecondsSinceEpoch}',
      'title': _titleController.text.trim(),
      'content': _contentController.text.trim(),
      'category': _selectedCategory,
      'authorId': 'user_123',
      'authorName': 'Muhammad Ahmad',
      'date': 'Baru saja',
      'likes': 0,
      'likedBy': [],
      'comments': [],
      'imageUrl': null,
    };

    setState(() => _isLoading = false);
    Navigator.pop(context, newPost);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Post berhasil dibuat!'),
        backgroundColor: AppTheme.accentGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ===== Responsiveness helpers =====
  double _maxWidth(BuildContext context) {
    if (ResponsiveHelper.isExtraLargeScreen(context)) return 900;
    if (ResponsiveHelper.isLargeScreen(context)) return 820;
    if (ResponsiveHelper.isMediumScreen(context)) return 680;
    return double.infinity; // mobile full width
  }

  double _editorHeight(BuildContext context) {
    if (ResponsiveHelper.isExtraLargeScreen(context)) return 280;
    if (ResponsiveHelper.isLargeScreen(context)) return 260;
    if (ResponsiveHelper.isMediumScreen(context)) return 240;
    return 200;
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _getCategoryColor(_selectedCategory);
    final catIcon = _getCategoryIcon(_selectedCategory);

    final pad = ResponsiveHelper.getResponsivePadding(context);
    final titleSize = ResponsiveHelper.adaptiveTextSize(context, 20);
    final subSize = ResponsiveHelper.adaptiveTextSize(context, 13);
    final labelSize = ResponsiveHelper.adaptiveTextSize(context, 18);
    final bodySize = ResponsiveHelper.adaptiveTextSize(context, 15);
    final inputHintSize = ResponsiveHelper.adaptiveTextSize(context, 14);

    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
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
              // AppBar
              Container(
                padding: EdgeInsets.all(pad.left.clamp(12, 20)),
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
                            iconSize: ResponsiveHelper.adaptiveTextSize(
                              context,
                              22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Buat Post Baru',
                                style: TextStyle(
                                  fontSize: titleSize,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.onSurface,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              Text(
                                'Berbagi cerita dan pengalaman',
                                style: TextStyle(
                                  fontSize: subSize,
                                  color: AppTheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                catColor.withValues(alpha: 0.1),
                                catColor.withValues(alpha: 0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: _handleSubmit,
                            icon: _isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        catColor,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.check_rounded),
                            color: catColor,
                            iconSize: ResponsiveHelper.adaptiveTextSize(
                              context,
                              22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: _maxWidth(context)),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.isSmallScreen(context)
                            ? 16
                            : 20,
                        vertical: ResponsiveHelper.isSmallScreen(context)
                            ? 16
                            : 20,
                      ),
                      physics: const BouncingScrollPhysics(),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Kategori
                              _CardBlock(
                                borderColor: catColor.withValues(alpha: 0.1),
                                shadowColor: catColor.withValues(alpha: 0.08),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        _IconBadge(
                                          color: catColor,
                                          icon: catIcon,
                                          size:
                                              ResponsiveHelper.adaptiveTextSize(
                                                context,
                                                22,
                                              ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Kategori Post',
                                          style: TextStyle(
                                            fontSize: labelSize,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.onSurface,
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: catColor.withValues(alpha: 0.05),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: catColor.withValues(
                                            alpha: 0.2,
                                          ),
                                        ),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _selectedCategory,
                                          isExpanded: true,
                                          icon: Icon(
                                            Icons.arrow_drop_down_rounded,
                                            color: catColor,
                                          ),
                                          style: TextStyle(
                                            color: AppTheme.onSurface,
                                            fontSize: bodySize,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          items: _categories.map((category) {
                                            final color = _getCategoryColor(
                                              category,
                                            );
                                            final icon = _getCategoryIcon(
                                              category,
                                            );
                                            return DropdownMenuItem(
                                              value: category,
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    icon,
                                                    color: color,
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(category),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (value) => setState(
                                            () => _selectedCategory = value!,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Judul
                              _CardBlock(
                                borderColor: AppTheme.primaryBlue.withValues(
                                  alpha: 0.1,
                                ),
                                shadowColor: AppTheme.primaryBlue.withValues(
                                  alpha: 0.08,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        _IconBadge(
                                          color: AppTheme.primaryBlue,
                                          icon: Icons.title_rounded,
                                          size:
                                              ResponsiveHelper.adaptiveTextSize(
                                                context,
                                                22,
                                              ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Judul Post',
                                          style: TextStyle(
                                            fontSize: labelSize,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.onSurface,
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: _titleController,
                                      decoration: InputDecoration(
                                        hintText:
                                            'Masukkan judul post yang menarik...',
                                        hintStyle: TextStyle(
                                          fontSize: inputHintSize,
                                          color: AppTheme.onSurfaceVariant
                                              .withValues(alpha: 0.6),
                                        ),
                                        filled: true,
                                        fillColor: AppTheme.primaryBlue
                                            .withValues(alpha: 0.05),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppTheme.primaryBlue,
                                            width: 2,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.all(
                                          16,
                                        ),
                                      ),
                                      maxLines: 2,
                                      style: TextStyle(
                                        fontSize: bodySize,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Konten
                              _CardBlock(
                                borderColor: AppTheme.accentGreen.withValues(
                                  alpha: 0.1,
                                ),
                                shadowColor: AppTheme.accentGreen.withValues(
                                  alpha: 0.08,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        _IconBadge(
                                          color: AppTheme.accentGreen,
                                          icon: Icons.article_rounded,
                                          size:
                                              ResponsiveHelper.adaptiveTextSize(
                                                context,
                                                22,
                                              ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Konten Post',
                                          style: TextStyle(
                                            fontSize: labelSize,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.onSurface,
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      height: _editorHeight(context),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentGreen.withValues(
                                          alpha: 0.05,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppTheme.accentGreen
                                              .withValues(alpha: 0.1),
                                        ),
                                      ),
                                      child: TextField(
                                        controller: _contentController,
                                        decoration: InputDecoration(
                                          hintText:
                                              'Tulis konten post Anda di sini...\n\nBerbagi pengalaman, ajukan pertanyaan, atau bagikan informasi menarik lainnya.',
                                          hintStyle: TextStyle(
                                            fontSize: inputHintSize,
                                            color: AppTheme.onSurfaceVariant
                                                .withValues(alpha: 0.6),
                                            height: 1.5,
                                          ),
                                          border: InputBorder.none,
                                          contentPadding: const EdgeInsets.all(
                                            16,
                                          ),
                                        ),
                                        maxLines: null,
                                        expands: true,
                                        textAlignVertical:
                                            TextAlignVertical.top,
                                        style: TextStyle(
                                          fontSize: bodySize,
                                          height: 1.6,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 22),

                              // Submit
                              SizedBox(
                                width: double.infinity,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppTheme.primaryBlue,
                                        AppTheme.accentGreen,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryBlue.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _isLoading
                                        ? null
                                        : _handleSubmit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: EdgeInsets.symmetric(
                                        vertical:
                                            ResponsiveHelper.isSmallScreen(
                                              context,
                                            )
                                            ? 14
                                            : 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.publish_rounded,
                                                color: Colors.white,
                                                size:
                                                    ResponsiveHelper.adaptiveTextSize(
                                                      context,
                                                      22,
                                                    ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Publikasikan Post',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      ResponsiveHelper.adaptiveTextSize(
                                                        context,
                                                        16,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}

// ====== Small reusable widgets ======

class _CardBlock extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final Color shadowColor;
  const _CardBlock({
    required this.child,
    required this.borderColor,
    required this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(
        ResponsiveHelper.isSmallScreen(context) ? 16 : 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: -5,
          ),
        ],
      ),
      child: child,
    );
  }
}

class _IconBadge extends StatelessWidget {
  final Color color;
  final IconData icon;
  final double size;
  const _IconBadge({
    required this.color,
    required this.icon,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.isSmallScreen(context) ? 8 : 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: size),
    );
  }
}
