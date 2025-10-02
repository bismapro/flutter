import 'package:flutter/material.dart';
import 'package:test_flutter/core/constants/app_config.dart';
import 'package:test_flutter/core/utils/responsive_helper.dart';
import '../../../app/theme.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  // double _gapSmall(BuildContext context) =>
  //     ResponsiveHelper.isSmallScreen(context) ? 12 : 16;
  double _gapMedium(BuildContext context) =>
      ResponsiveHelper.isSmallScreen(context) ? 20 : 28;
  double _fieldHeight(BuildContext context) =>
      ResponsiveHelper.isSmallScreen(context) ? 52 : 56;

  @override
  Widget build(BuildContext context) {
    final isSmall = ResponsiveHelper.isSmallScreen(context);
    final isMedium = ResponsiveHelper.isMediumScreen(context);
    final isLarge = ResponsiveHelper.isLargeScreen(context);
    final isXL = ResponsiveHelper.isExtraLargeScreen(context);

    final pagePadding = ResponsiveHelper.getResponsivePadding(context);
    final useTwoColumns =
        MediaQuery.of(context).size.width >= ResponsiveHelper.largeScreenSize;

    // Sizing adaptif
    final logoSize = isSmall
        ? 90.0
        : isMedium
        ? 110.0
        : 120.0;
    final appNameSize = ResponsiveHelper.adaptiveTextSize(
      context,
      isSmall ? 32 : 38,
    );
    final cardRadius = isXL ? 36.0 : 32.0;
    final cardPadding = isSmall
        ? 28.0
        : isMedium
        ? 36.0
        : 40.0;
    final maxContentWidth = isXL
        ? 700.0
        : isLarge
        ? 640.0
        : 600.0;
    final maxHeroWidth = isXL
        ? 520.0
        : isLarge
        ? 460.0
        : 420.0;

    // HEADER (logo + nama app)
    final header = Column(
      children: [
        SizedBox(height: isSmall ? 40 : 60),
        FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: logoSize,
              height: logoSize,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                    spreadRadius: -5,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(AppConfig.appLogo, fit: BoxFit.cover),
              ),
            ),
          ),
        ),
        SizedBox(height: isSmall ? 20 : 28),
        FadeTransition(
          opacity: _fadeAnimation,
          child: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [AppTheme.primaryBlue, AppTheme.accentGreen],
            ).createShader(bounds),
            child: Text(
              AppConfig.appName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: appNameSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -1.2,
              ),
            ),
          ),
        ),
        SizedBox(height: isSmall ? 20 : 40),
      ],
    );

    // KONTEN UTAMA (card fitur)
    final mainCard = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(cardPadding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(cardRadius),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                    blurRadius: 40,
                    offset: const Offset(0, 10),
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxHeroWidth),
                    child: Column(
                      children: [
                        Text(
                          'Stay Connected to\nYour Faith',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.adaptiveTextSize(
                              context,
                              24,
                            ),
                            fontWeight: FontWeight.bold,
                            color: AppTheme.onSurface,
                            height: 1.3,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: isSmall ? 12 : 16),
                        Text(
                          'Prayer times, Qibla direction, Islamic calendar\nand community - all in one place',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.adaptiveTextSize(
                              context,
                              15,
                            ),
                            color: AppTheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isSmall ? 20 : 24),

                  // Fitur: otomatis jadi 2 kolom pada layar besar
                  LayoutBuilder(
                    builder: (context, c) {
                      final twoCol = c.maxWidth >= 520;
                      if (twoCol) {
                        return Wrap(
                          spacing: 16,
                          runSpacing: 12,
                          children: const [
                            _FeatureChip(text: 'Accurate prayer times'),
                            _FeatureChip(text: 'Find nearest mosques'),
                            _FeatureChip(text: 'Read Al-Quran & Hadith'),
                          ],
                        );
                      }
                      return Column(
                        children: const [
                          _FeatureRow(text: 'Accurate prayer times'),
                          SizedBox(height: 12),
                          _FeatureRow(text: 'Find nearest mosques'),
                          SizedBox(height: 12),
                          _FeatureRow(text: 'Read Al-Quran & Hadith'),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // TOMBOL BAWAH
    final bottomButtons = SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: _slideController,
              curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
            ),
          ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: _fieldHeight(context),
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  shadowColor: AppTheme.primaryBlue.withValues(alpha: 0.3),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.adaptiveTextSize(
                          context,
                          16,
                        ),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: _fieldHeight(context),
              child: OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/home'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Continue as Guest',
                  style: TextStyle(
                    color: AppTheme.primaryBlue,
                    fontSize: ResponsiveHelper.adaptiveTextSize(context, 16),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            SizedBox(height: _gapMedium(context)),
          ],
        ),
      ),
    );

    // PANEL KIRI (hiasan) khusus layar besar
    final leftPane = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      padding: EdgeInsets.all(isXL ? 32 : 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mosque_rounded,
            size: isXL ? 120 : 96,
            color: AppTheme.accentGreen.withValues(alpha: 0.9),
          ),
          const SizedBox(height: 16),
          Text(
            'All-in-One Muslim Companion',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ResponsiveHelper.adaptiveTextSize(context, 22),
              fontWeight: FontWeight.w700,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Prayer times, Qibla, Quran, and community features to support your daily worship.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ResponsiveHelper.adaptiveTextSize(context, 14),
              color: AppTheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );

    // ================== SCAFFOLD ==================
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryBlue.withValues(alpha: 0.05),
              AppTheme.accentGreen.withValues(alpha: 0.03),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: pagePadding,
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (useTwoColumns) {
                  // Layar besar: 2 kolom
                  return Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: pagePadding.right / 2,
                          ),
                          child: leftPane,
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                padding: EdgeInsets.symmetric(
                                  horizontal: pagePadding.horizontal / 2,
                                ),
                                child: Column(children: [header, mainCard]),
                              ),
                            ),
                            bottomButtons,
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  // Mobile / tablet kecil: 1 kolom
                  return Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(children: [header, mainCard]),
                        ),
                      ),
                      bottomButtons,
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ===== Komponen kecil responsif =====

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.check_circle_rounded, color: AppTheme.accentGreen, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: ResponsiveHelper.adaptiveTextSize(context, 14),
              color: AppTheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.accentGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.accentGreen.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: ResponsiveHelper.adaptiveTextSize(context, 14),
                color: AppTheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
