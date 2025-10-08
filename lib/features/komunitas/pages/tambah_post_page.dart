import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test_flutter/core/utils/responsive_helper.dart';
import 'package:test_flutter/core/utils/logger.dart';
import 'package:test_flutter/core/widgets/toast.dart';
import 'package:test_flutter/features/komunitas/komunitas_provider.dart';
import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../app/theme.dart';

class TambahPostPage extends ConsumerStatefulWidget {
  const TambahPostPage({super.key});

  @override
  ConsumerState<TambahPostPage> createState() => _TambahPostPageState();
}

class _TambahPostPageState extends ConsumerState<TambahPostPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _selectedCategory = 'Diskusi';
  List<XFile> _selectedImages = [];
  final Map<String, Uint8List> _imageBytesCache = {};

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

    // Listen to provider state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(komunitasProvider, (previous, next) {
        final status = next['status'] as KomunitasArtikelState;
        final error = next['error'];

        if (status == KomunitasArtikelState.success) {
          // Success - navigate back and show success message
          Navigator.pop(context);
          showMessageToast(
            context,
            message: 'Artikel berhasil dibuat',
            type: ToastType.success,
            duration: const Duration(seconds: 3),
          );
        } else if (status == KomunitasArtikelState.error && error != null) {
          // Error - show error message
          showMessageToast(
            context,
            message: 'Gagal menambahkan artikel',
            type: ToastType.error,
            duration: const Duration(seconds: 4),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      default:
        return AppTheme.primaryBlue;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      default:
        return Icons.forum_rounded;
    }
  }

  Future<void> _pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images); // <— append
        });
        logger.info('TambahPostPage: Selected ${images.length} images');
      }
    } catch (e) {
      logger.fine('TambahPostPage: Error picking images', e);
      if (mounted) {
        showMessageToast(
          context,
          message: 'Gagal memilih gambar: ${e.toString()}',
          type: ToastType.error,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
    // logger.info('TambahPostPage: Removed image at index $index');
  }

  Future<void> _handleSubmit() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      showMessageToast(
        context,
        message: 'Judul dan konten tidak boleh kosong',
        type: ToastType.error,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    try {
      await ref
          .read(komunitasProvider.notifier)
          .createArtikel(
            kategori: _selectedCategory,
            judul: title,
            isi: content,
            gambar: _selectedImages,
          );

      showMessageToast(
        context,
        message: 'Artikel berhasil dibuat!',
        type: ToastType.success,
        duration: const Duration(seconds: 3),
      );

      // Optional: reset form setelah sukses
      _formKey.currentState!.reset();
      _titleController.clear();
      _contentController.clear();
      setState(() => _selectedImages = []);
    } catch (e) {
      showMessageToast(
        context,
        message: 'Gagal membuat artikel: ${e.toString()}',
        type: ToastType.error,
        duration: const Duration(seconds: 4),
      );
    }
  }

  void _handleBackButton() {
    logger.info('TambahPostPage: Back button pressed');

    // Use Future.microtask to ensure we're not in the middle of a build cycle
    Future.microtask(() {
      if (mounted && Navigator.canPop(context)) {
        // Use Navigator.pop instead of Navigator.pushNamed
        Navigator.pop(context);
      }
    });
  }

  // ===== Responsiveness helpers =====
  double _maxWidth(BuildContext context) {
    if (ResponsiveHelper.isExtraLargeScreen(context)) return 900;
    if (ResponsiveHelper.isLargeScreen(context)) return 820;
    if (ResponsiveHelper.isMediumScreen(context)) return 680;
    return double.infinity;
  }

  double _editorHeight(BuildContext context) {
    if (ResponsiveHelper.isExtraLargeScreen(context)) return 280;
    if (ResponsiveHelper.isLargeScreen(context)) return 260;
    if (ResponsiveHelper.isMediumScreen(context)) return 240;
    return 200;
  }

  @override
  Widget build(BuildContext context) {
    // Watch provider state
    final komunitasState = ref.watch(komunitasProvider);
    final isLoading = komunitasState['status'] == KomunitasArtikelState.loading;
    final error = komunitasState['error'];

    logger.info(
      'TambahPostPage: build called, isLoading: $isLoading, error: $error',
    );

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
                            onPressed: isLoading ? null : _handleBackButton,
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
                                'Buat Artikel Baru',
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
                      ],
                    ),
                  ),
                ),
              ),

              // Error display (if any)
              if (error != null)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          error.toString(),
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // logger.info(
                          //   'TambahPostPage: Clear error button pressed',
                          // );
                          ref.read(komunitasProvider.notifier).clearError();
                        },
                        icon: const Icon(
                          Icons.close,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ],
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
                                          'Kategori Artikel',
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
                                          onChanged: isLoading
                                              ? null
                                              : (value) => setState(
                                                  () => _selectedCategory =
                                                      value!,
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
                                          'Judul Artikel',
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
                                      enabled: !isLoading,
                                      decoration: InputDecoration(
                                        hintText:
                                            'Masukkan judul artikel yang menarik...',
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
                                          'Konten Artikel',
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
                                        enabled: !isLoading,
                                        decoration: InputDecoration(
                                          hintText:
                                              'Tulis konten artikel Anda di sini...\n\nBerbagi pengalaman, ajukan pertanyaan, atau bagikan informasi menarik lainnya.',
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

                              const SizedBox(height: 16),

                              // Gambar
                              _CardBlock(
                                borderColor: Colors.orange.withValues(
                                  alpha: 0.1,
                                ),
                                shadowColor: Colors.orange.withValues(
                                  alpha: 0.08,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        _IconBadge(
                                          color: Colors.orange.shade600,
                                          icon: Icons.image_rounded,
                                          size:
                                              ResponsiveHelper.adaptiveTextSize(
                                                context,
                                                22,
                                              ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Gambar (Opsional)',
                                          style: TextStyle(
                                            fontSize: labelSize,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.onSurface,
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                        const Spacer(),
                                        TextButton.icon(
                                          onPressed: isLoading
                                              ? null
                                              : _pickImages,
                                          icon: const Icon(
                                            Icons.add_photo_alternate,
                                            size: 18,
                                          ),
                                          label: const Text('Pilih Gambar'),
                                          style: TextButton.styleFrom(
                                            foregroundColor:
                                                Colors.orange.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (_selectedImages.isNotEmpty) ...[
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        height: 120,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: _selectedImages.length,
                                          itemBuilder: (context, index) {
                                            return Container(
                                              margin: const EdgeInsets.only(
                                                right: 12,
                                              ),
                                              width: 120,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Colors.orange
                                                      .withValues(alpha: 0.2),
                                                ),
                                              ),
                                              child: Stack(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    child: _buildImageThumb(
                                                      _selectedImages[index],
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 4,
                                                    right: 4,
                                                    child: GestureDetector(
                                                      onTap: () =>
                                                          _removeImage(index),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              4,
                                                            ),
                                                        decoration:
                                                            const BoxDecoration(
                                                              color: Colors.red,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                        child: const Icon(
                                                          Icons.close,
                                                          color: Colors.white,
                                                          size: 16,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
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
                                    onPressed: isLoading ? null : _handleSubmit,
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
                                    child: isLoading
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
                                                'Publikasikan Artikel',
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

  Widget _buildImageThumb(XFile file, {double size = 120}) {
    if (!kIsWeb) {
      // iOS/Android/Desktop: aman pakai path file
      return Image.file(
        File(file.path),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _errorThumb(size),
      );
    }

    // Web: path tidak bisa langsung dipakai → baca bytes
    final cached = _imageBytesCache[file.path];
    if (cached != null) {
      return Image.memory(
        cached,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _errorThumb(size),
      );
    }

    return FutureBuilder<Uint8List>(
      future: file.readAsBytes().then((b) {
        _imageBytesCache[file.path] = b;
        return b;
      }),
      builder: (context, snap) {
        if (snap.hasData) {
          return Image.memory(
            snap.data!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _errorThumb(size),
          );
        }
        // loading placeholder sederhana
        return Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }

  Widget _errorThumb(double size) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(Icons.broken_image, color: Colors.grey.shade400),
  );
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
