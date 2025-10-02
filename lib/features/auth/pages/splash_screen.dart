import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_flutter/core/constants/app_config.dart';
import 'package:test_flutter/core/utils/logger.dart';
import 'package:test_flutter/core/utils/responsive_helper.dart';
import 'package:test_flutter/features/auth/auth_provider.dart';
import 'package:test_flutter/features/auth/pages/welcome_page.dart';
import 'package:test_flutter/features/home/pages/home_page.dart';
import '../../../app/theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  late AnimationController _pulseController;

  late Animation<double> _logoScale;
  late Animation<double> _textFade;
  late Animation<double> _progress;
  late Animation<double> _pulse;

  // ignore: unused_field
  ProviderSubscription<Map<String, dynamic>>? _authSub;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    // (1) Trigger cek status auth
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).checkAuthStatus();
    });

    // (2) LISTEN menggunakan listenManual (boleh di initState)
    _authSub = ref.listenManual<Map<String, dynamic>>(authProvider, (
      prev,
      next,
    ) async {
      if (_navigated) return; // guard

      final status = next['status'] as AuthState?;
      logger.fine('Splash listen: $status');

      Future<void> navigate(Widget page) async {
        if (mounted && !_navigated) {
          _navigated = true;
          // beri jeda dikit biar animasi kebaca
          await Future<void>.delayed(const Duration(milliseconds: 350));
          if (!mounted) return;
          Navigator.of(
            context,
          ).pushReplacement(MaterialPageRoute(builder: (_) => page));
        }
      }

      switch (status) {
        case AuthState.authenticated:
          await navigate(const HomePage());
          break;
        case AuthState.unauthenticated:
        case AuthState.isRegistered:
        case AuthState.error:
          await navigate(const WelcomePage());
          break;
        case AuthState.initial:
        case AuthState.loading:
        default:
          // tetap di splash
          break;
      }
    });

    // --- INISIALISASI ANIMASI (tanpa auto-navigate di akhir!) ---
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );
    _progress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    _pulse = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _progressController.forward();

    // ⚠️ HAPUS auto-navigate default berikut supaya tidak bentrok:
    // await Future.delayed(const Duration(milliseconds: 2500));
    // if (mounted) {
    //   Navigator.of(context).pushReplacementNamed('/welcome');
    // }

    // (Opsional) Fallback kalau 5 detik belum ada keputusan dari auth:
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && !_navigated) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WelcomePage()),
        );
        _navigated = true;
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // ==== Helper jarak/ukuran responsif ====
  double _gapSmall(BuildContext context) =>
      ResponsiveHelper.isSmallScreen(context) ? 12 : 16;
  double _gapMedium(BuildContext context) =>
      ResponsiveHelper.isSmallScreen(context) ? 20 : 28;
  double _logoSize(BuildContext context) {
    if (ResponsiveHelper.isSmallScreen(context)) return 100;
    if (ResponsiveHelper.isMediumScreen(context)) return 130;
    if (ResponsiveHelper.isLargeScreen(context)) return 150;
    return 168; // XL
  }

  double _progressWidth(BuildContext context) {
    final w = ResponsiveHelper.getScreenWidth(context);
    // max 320, min 200, proporsional terhadap lebar layar
    final target = w * 0.4;
    return target.clamp(200, 320);
  }

  double _bgCircleBig(BuildContext context) {
    final w = ResponsiveHelper.getScreenWidth(context);
    if (w >= ResponsiveHelper.extraLargeScreenSize) return 520;
    if (w >= ResponsiveHelper.largeScreenSize) return 440;
    if (w >= ResponsiveHelper.mediumScreenSize) return 360;
    return 300;
  }

  double _bgCircleSmall(BuildContext context) {
    final w = ResponsiveHelper.getScreenWidth(context);
    if (w >= ResponsiveHelper.extraLargeScreenSize) return 360;
    if (w >= ResponsiveHelper.largeScreenSize) return 300;
    if (w >= ResponsiveHelper.mediumScreenSize) return 260;
    return 220;
  }

  @override
  Widget build(BuildContext context) {
    // Status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    final pagePadding = ResponsiveHelper.getResponsivePadding(context);
    final logoSize = _logoSize(context);
    final titleSize = ResponsiveHelper.adaptiveTextSize(
      context,
      44, // base
    );
    final subtitleSize = ResponsiveHelper.adaptiveTextSize(context, 17);
    final iconSize = ResponsiveHelper.isSmallScreen(context) ? 20.0 : 22.0;
    final featureSpacing = ResponsiveHelper.isSmallScreen(context)
        ? 18.0
        : 24.0;

    final big = _bgCircleBig(context);
    final small = _bgCircleSmall(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryBlue,
              AppTheme.primaryBlue.withValues(alpha: 0.9),
              AppTheme.accentGreen.withValues(alpha: 0.7),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated background circles (ukuran & posisi responsif)
            Positioned(
              top: -small / 3,
              right: -small / 3,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulse.value,
                    child: Container(
                      width: small,
                      height: small,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: -big / 3,
              left: -big / 3.5,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.2 - (_pulse.value - 1.0),
                    child: Container(
                      width: big,
                      height: big,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.03),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Main content
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: pagePadding.horizontal / 2,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo
                          AnimatedBuilder(
                            animation: _logoScale,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _logoScale.value,
                                child: Container(
                                  width: logoSize,
                                  height: logoSize,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(32),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 40,
                                        spreadRadius: 10,
                                      ),
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.2,
                                        ),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: Image.asset(
                                      AppConfig.appLogo,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          SizedBox(height: _gapMedium(context) + 12),

                          // Title + Subtitle
                          AnimatedBuilder(
                            animation: _textFade,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _textFade.value,
                                child: Column(
                                  children: [
                                    ShaderMask(
                                      shaderCallback: (bounds) =>
                                          LinearGradient(
                                            colors: [
                                              Colors.white,
                                              Colors.white.withValues(
                                                alpha: 0.9,
                                              ),
                                            ],
                                          ).createShader(bounds),
                                      child: Text(
                                        AppConfig.appName,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: titleSize,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: -1.5,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: _gapSmall(context)),
                                    Text(
                                      'Your prayer partners',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: subtitleSize,
                                        color: Colors.white.withValues(
                                          alpha: 0.85,
                                        ),
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          SizedBox(height: _gapMedium(context)),

                          // Feature icons (wrap untuk layar sempit)
                          AnimatedBuilder(
                            animation: _textFade,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _textFade.value * 0.8,
                                child: LayoutBuilder(
                                  builder: (context, c) {
                                    final canWrap = c.maxWidth < 360;
                                    final children = [
                                      _buildFeatureIcon(
                                        Icons.access_time_rounded,
                                        iconSize,
                                      ),
                                      SizedBox(
                                        width: featureSpacing,
                                        height: featureSpacing,
                                      ),
                                      _buildFeatureIcon(
                                        Icons.menu_book_rounded,
                                        iconSize,
                                      ),
                                      SizedBox(
                                        width: featureSpacing,
                                        height: featureSpacing,
                                      ),
                                      _buildFeatureIcon(
                                        Icons.explore_outlined,
                                        iconSize,
                                      ),
                                      SizedBox(
                                        width: featureSpacing,
                                        height: featureSpacing,
                                      ),
                                      _buildFeatureIcon(
                                        Icons.people_rounded,
                                        iconSize,
                                      ),
                                    ];

                                    if (canWrap) {
                                      return Wrap(
                                        alignment: WrapAlignment.center,
                                        runSpacing: 12,
                                        children: children,
                                      );
                                    }
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: children,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Progress
                    Padding(
                      padding: EdgeInsets.all(
                        ResponsiveHelper.isSmallScreen(context) ? 28 : 40,
                      ),
                      child: Column(
                        children: [
                          AnimatedBuilder(
                            animation: _progress,
                            builder: (context, child) {
                              final barWidth = _progressWidth(context);
                              return Container(
                                width: barWidth,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        width: barWidth * _progress.value,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.white,
                                              Colors.white.withValues(
                                                alpha: 0.85,
                                              ),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            3,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.white.withValues(
                                                alpha: 0.45,
                                              ),
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          SizedBox(height: _gapSmall(context) + 4),
                          AnimatedBuilder(
                            animation: _textFade,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _textFade.value,
                                child: Text(
                                  'Loading...',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: ResponsiveHelper.adaptiveTextSize(
                                      context,
                                      15,
                                    ),
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureIcon(IconData icon, double size) {
    final box = size + 24; // container sedikit lebih besar dari icon
    return Container(
      width: box,
      height: box,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Icon(icon, color: Colors.white, size: size),
    );
  }
}
