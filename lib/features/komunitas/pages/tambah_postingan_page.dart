import 'dart:io' show File;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:test_flutter/app/theme.dart';
import 'package:test_flutter/core/utils/logger.dart';
import 'package:test_flutter/core/utils/responsive_helper.dart';
import 'package:test_flutter/core/widgets/toast.dart';

import 'package:test_flutter/features/komunitas/komunitas_provider.dart';
import 'package:test_flutter/features/komunitas/komunitas_state.dart';

class TambahPostinganPage extends ConsumerStatefulWidget {
  const TambahPostinganPage({super.key});

  @override
  ConsumerState<TambahPostinganPage> createState() =>
      _TambahPostinganPageState();
}

class _TambahPostinganPageState extends ConsumerState<TambahPostinganPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _judulCtrl = TextEditingController();
  final TextEditingController _kontenCtrl = TextEditingController();

  /// kategoriId yang dipilih (WAJIB sesuai backend). Silakan isi mapping sesuai master kategori API-mu.
  /// Contoh dari payload: 1 = Ibadah
  int _selectedKategoriId = 1;

  /// (opsional) nama kategori untuk label UI saja
  String _selectedKategoriNama = 'Ibadah';

  List<XFile> _selectedImages = [];
  final Map<String, Uint8List> _imageBytesCache = {};

  late final AnimationController _anim;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  bool _submitting = false;

  /// Daftar kategori dummy (id->nama). Ganti ini dengan data dari API kalau sudah ada endpoint kategori.
  final List<Map<String, dynamic>> _kategoriList = const [
    {'id': 1, 'nama': 'Ibadah'},
    {'id': 2, 'nama': 'Diskusi'},
    {'id': 3, 'nama': 'Pertanyaan'},
    {'id': 4, 'nama': 'Sharing'},
    {'id': 5, 'nama': 'Event'},
  ];

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, .25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
    _anim.forward();
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _kontenCtrl.dispose();
    _anim.dispose();
    super.dispose();
  }

  // ===== Helpers UI kategori =====
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
      default:
        return Icons.forum_rounded;
    }
  }

  // ===== Gambar =====
  Future<void> _pickImages() async {
    try {
      final picker = ImagePicker();
      final images = await picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (images.isNotEmpty) {
        setState(() => _selectedImages.addAll(images));
        logger.info('[TambahPostingan] picked ${images.length} images');
      }
    } catch (e) {
      logger.warning('[TambahPostingan] pick image error: $e');
      if (mounted) {
        showMessageToast(
          context,
          message: 'Gagal memilih gambar: $e',
          type: ToastType.error,
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  // ===== Submit =====
  Future<void> _submit() async {
    final judul = _judulCtrl.text.trim();
    final konten = _kontenCtrl.text.trim();

    if (judul.isEmpty || konten.isEmpty) {
      showMessageToast(
        context,
        message: 'Judul dan konten tidak boleh kosong.',
        type: ToastType.error,
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      /// Pastikan Notifier punya method ini:
      /// Future<void> createPostingan({
      ///   required int kategoriId,
      ///   required String judul,
      ///   required String konten,
      ///   required List<XFile> gambar, // gambar pertama = cover
      /// })
      await ref
          .read(komunitasProvider.notifier)
          .createPostingan(
            // kategoriId: _selectedKategoriId,
            // judul: judul,
            // konten: konten,
            // gambar: _selectedImages,
          );

      // Refresh list saat kembali (biar aman, list page sudah refresh onPop juga)
      // ignore: use_build_context_synchronously
      showMessageToast(
        context,
        message: 'Postingan berhasil dibuat!',
        type: ToastType.success,
      );
      // ignore: use_build_context_synchronously
      Navigator.pop(context, {'created': true});
    } catch (e, st) {
      logger.severe('[TambahPostingan] submit error: $e', e, st);
      if (mounted) {
        showMessageToast(
          context,
          message: 'Gagal membuat postingan: $e',
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _handleBack() {
    if (!_submitting && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  // ===== Responsive =====
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
    final pad = ResponsiveHelper.getResponsivePadding(context);
    final labelSize = ResponsiveHelper.adaptiveTextSize(context, 18);
    final inputSize = ResponsiveHelper.adaptiveTextSize(context, 15);
    final hintSize = ResponsiveHelper.adaptiveTextSize(context, 14);

    // Bisa dipakai jika mau men-disable saat provider lagi loading list
    final provState = ref.watch(komunitasProvider);
    final listLoading =
        provState.status == KomunitasStatus.loading &&
        provState.postingan.isEmpty;

    final catColor = _getCategoryColor(_selectedKategoriNama);
    final catIcon = _getCategoryIcon(_selectedKategoriNama);

    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryBlue.withValues(alpha: .05),
              AppTheme.accentGreen.withValues(alpha: .03),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Container(
                padding: EdgeInsets.all(pad.left.clamp(12, 20)),
                color: Colors.white,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: _maxWidth(context)),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryBlue.withValues(alpha: .1),
                                AppTheme.accentGreen.withValues(alpha: .1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: _submitting ? null : _handleBack,
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
                                'Buat Postingan',
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.adaptiveTextSize(
                                    context,
                                    20,
                                  ),
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.onSurface,
                                  letterSpacing: -.3,
                                ),
                              ),
                              Text(
                                'Bagikan cerita, pengalaman, atau pertanyaanmu',
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.adaptiveTextSize(
                                    context,
                                    13,
                                  ),
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

              // Body
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
                        opacity: _fade,
                        child: SlideTransition(
                          position: _slide,
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Kategori
                                _CardBlock(
                                  borderColor: catColor.withValues(alpha: .12),
                                  shadowColor: catColor.withValues(alpha: .08),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                            'Kategori',
                                            style: TextStyle(
                                              fontSize: labelSize,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.onSurface,
                                              letterSpacing: -.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: catColor.withValues(
                                            alpha: .05,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: catColor.withValues(
                                              alpha: .2,
                                            ),
                                          ),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<int>(
                                            value: _selectedKategoriId,
                                            isExpanded: true,
                                            icon: Icon(
                                              Icons.arrow_drop_down_rounded,
                                              color: catColor,
                                            ),
                                            style: TextStyle(
                                              color: AppTheme.onSurface,
                                              fontSize: inputSize,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            items: _kategoriList.map((k) {
                                              final nama = k['nama'] as String;
                                              final id = k['id'] as int;
                                              final color = _getCategoryColor(
                                                nama,
                                              );
                                              final icon = _getCategoryIcon(
                                                nama,
                                              );
                                              return DropdownMenuItem<int>(
                                                value: id,
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      icon,
                                                      color: color,
                                                      size: 18,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(nama),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                            onChanged:
                                                (_submitting || listLoading)
                                                ? null
                                                : (val) {
                                                    if (val == null) return;
                                                    final match = _kategoriList
                                                        .firstWhere(
                                                          (e) => e['id'] == val,
                                                        );
                                                    setState(() {
                                                      _selectedKategoriId = val;
                                                      _selectedKategoriNama =
                                                          (match['nama']
                                                              as String?) ??
                                                          'Umum';
                                                    });
                                                  },
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
                                    alpha: .1,
                                  ),
                                  shadowColor: AppTheme.primaryBlue.withValues(
                                    alpha: .08,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                            'Judul',
                                            style: TextStyle(
                                              fontSize: labelSize,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.onSurface,
                                              letterSpacing: -.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      TextFormField(
                                        controller: _judulCtrl,
                                        enabled: !_submitting,
                                        validator: (v) =>
                                            (v == null || v.trim().isEmpty)
                                            ? 'Judul wajib diisi'
                                            : null,
                                        decoration: InputDecoration(
                                          hintText:
                                              'Masukkan judul yang informatif...',
                                          hintStyle: TextStyle(
                                            fontSize: hintSize,
                                            color: AppTheme.onSurfaceVariant
                                                .withValues(alpha: .6),
                                          ),
                                          filled: true,
                                          fillColor: AppTheme.primaryBlue
                                              .withValues(alpha: .05),
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
                                          fontSize: inputSize,
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
                                    alpha: .1,
                                  ),
                                  shadowColor: AppTheme.accentGreen.withValues(
                                    alpha: .08,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                            'Konten',
                                            style: TextStyle(
                                              fontSize: labelSize,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.onSurface,
                                              letterSpacing: -.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        height: _editorHeight(context),
                                        decoration: BoxDecoration(
                                          color: AppTheme.accentGreen
                                              .withValues(alpha: .05),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: AppTheme.accentGreen
                                                .withValues(alpha: .1),
                                          ),
                                        ),
                                        child: TextFormField(
                                          controller: _kontenCtrl,
                                          enabled: !_submitting,
                                          validator: (v) =>
                                              (v == null || v.trim().isEmpty)
                                              ? 'Konten wajib diisi'
                                              : null,
                                          decoration: InputDecoration(
                                            hintText:
                                                'Tulis isi postinganmu di sini…',
                                            hintStyle: TextStyle(
                                              fontSize: hintSize,
                                              color: AppTheme.onSurfaceVariant
                                                  .withValues(alpha: .6),
                                              height: 1.5,
                                            ),
                                            border: InputBorder.none,
                                            contentPadding:
                                                const EdgeInsets.all(16),
                                          ),
                                          maxLines: null,
                                          expands: true,
                                          textAlignVertical:
                                              TextAlignVertical.top,
                                          style: TextStyle(
                                            fontSize: inputSize,
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
                                    alpha: .1,
                                  ),
                                  shadowColor: Colors.orange.withValues(
                                    alpha: .08,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                            'Gambar (opsional)',
                                            style: TextStyle(
                                              fontSize: labelSize,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.onSurface,
                                              letterSpacing: -.3,
                                            ),
                                          ),
                                          const Spacer(),
                                          TextButton.icon(
                                            onPressed: _submitting
                                                ? null
                                                : _pickImages,
                                            icon: const Icon(
                                              Icons.add_photo_alternate,
                                              size: 18,
                                            ),
                                            label: const Text('Pilih Gambar'),
                                            style: TextButton.styleFrom(
                                              foregroundColor:
                                                  Colors.orange.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (_selectedImages.isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          height: 120,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: _selectedImages.length,
                                            itemBuilder: (context, i) {
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
                                                        .withValues(alpha: .2),
                                                  ),
                                                ),
                                                child: Stack(
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      child: _thumb(
                                                        _selectedImages[i],
                                                      ),
                                                    ),
                                                    Positioned(
                                                      top: 4,
                                                      right: 4,
                                                      child: GestureDetector(
                                                        onTap: () =>
                                                            _removeImage(i),
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                4,
                                                              ),
                                                          decoration:
                                                              const BoxDecoration(
                                                                color:
                                                                    Colors.red,
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
                                      if (_selectedImages.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          'Catatan: gambar pertama akan dijadikan cover.',
                                          style: TextStyle(
                                            fontSize:
                                                ResponsiveHelper.adaptiveTextSize(
                                                  context,
                                                  12,
                                                ),
                                            color: AppTheme.onSurfaceVariant,
                                            fontStyle: FontStyle.italic,
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
                                          color: AppTheme.primaryBlue
                                              .withValues(alpha: .3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: (_submitting || listLoading)
                                          ? null
                                          : () {
                                              if (_formKey.currentState
                                                      ?.validate() !=
                                                  true) {
                                                return;
                                              }
                                              _submit();
                                            },
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
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                      child: _submitting
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
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
                                                  'Publikasikan',
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
                              ],
                            ),
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

  // ====== Image thumb (Web/Mobile) ======
  Widget _thumb(XFile file, {double size = 120}) {
    if (!kIsWeb) {
      return Image.file(
        File(file.path),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _thumbError(size),
      );
    }
    final cached = _imageBytesCache[file.path];
    if (cached != null) {
      return Image.memory(
        cached,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _thumbError(size),
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
            errorBuilder: (_, __, ___) => _thumbError(size),
          );
        }
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

  Widget _thumbError(double size) => Container(
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

// ===== Reusable UI =====
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
        color: color.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: size),
    );
  }
}
