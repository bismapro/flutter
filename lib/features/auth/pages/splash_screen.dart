import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_flutter/core/constants/app_config.dart';
import 'package:test_flutter/core/utils/responsive_helper.dart';
import 'package:test_flutter/features/auth/auth_provider.dart';
import 'package:test_flutter/features/auth/pages/welcome_page.dart';
import 'package:test_flutter/features/home/pages/home_page.dart';
import '../../../app/theme.dart';

// Target hasil keputusan auth
enum _Target { unknown, home, welcome }

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  ProviderSubscription<Map<String, dynamic>>? _authSub;
  bool _animationsDone = false;
  bool _navigated = false;
  _Target _target = _Target.unknown;

  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  late AnimationController _pulseController;

  late Animation<double> _logoScale;
  late Animation<double> _textFade;
  late Animation<double> _progress;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    // 1) Trigger cek status auth
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).checkAuthStatus();
    });

    // 2) Listen auth → tentukan TARGET SAJA (tidak navigate di sini)
    _authSub = ref.listenManual<Map<String, dynamic>>(authProvider, (
      prev,
      next,
    ) {
      final status = next['status'] as AuthState?;
      switch (status) {
        case AuthState.authenticated:
          _target = _Target.home;
          break;
        case AuthState.unauthenticated:
        case AuthState.isRegistered:
        case AuthState.error:
          _target = _Target.welcome;
          break;
        case AuthState.initial:
        case AuthState.loading:
        default:
          _target = _Target.unknown;
      }
      _maybeNavigate(); // cek apakah animasi sudah selesai
    });

    // 3) Init animasi
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

  // Jalankan animasi berurut dan tandai selesai
  Future<void> _startAnimations() async {
    await _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    await _textController.forward();
    await _progressController.forward(); // selesai progress bar

    _animationsDone = true;
    _maybeNavigate();
  }

  // Navigate hanya kalau KEDUA syarat terpenuhi: animasi selesai & target jelas
  void _maybeNavigate() {
    if (!mounted || _navigated) return;
    if (!_animationsDone) return;
    if (_target == _Target.unknown) return;

    _navigated = true;
    final page = (_target == _Target.home)
        ? const HomePage()
        : const WelcomePage();
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => page));
  }

  @override
  void dispose() {
    _authSub?.close();
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

  double _bgCircleBig(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= ResponsiveHelper.extraLargeScreenSize) return 520;
    if (w >= ResponsiveHelper.largeScreenSize) return 440;
    if (w >= ResponsiveHelper.mediumScreenSize) return 360;
    return 300;
  }

  double _bgCircleSmall(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
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

    final screenW = MediaQuery.sizeOf(context).width;
    final isNarrow = screenW <= 360; // penting: 360 ikut kategori sempit
    final horizontalPad = isNarrow ? 16.0 : (screenW < 600 ? 24.0 : 32.0);
    final logoSize = _logoSize(context);
    final titleSize = ResponsiveHelper.adaptiveTextSize(context, 44);
    final subtitleSize = ResponsiveHelper.adaptiveTextSize(context, 17);
    final iconSize = isNarrow ? 20.0 : 22.0;
    final featureSpacing = isNarrow ? 18.0 : 24.0;

    final big = _bgCircleBig(context);
    final small = _bgCircleSmall(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
            // Animated background circles
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

            // Main content (selalu center + lebar dibatasi)
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPad),
                    child: LayoutBuilder(
                      builder: (context, inner) {
                        final innerW =
                            inner.maxWidth; // lebar konten yang sesungguhnya
                        final barWidth = math.max(
                          200.0,
                          math.min(innerW * 0.7, 320.0),
                        );
                        final canWrap = innerW <= 360; // penting: 360 ikut wrap

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
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
                                            borderRadius: BorderRadius.circular(
                                              32,
                                            ),
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
                                            borderRadius: BorderRadius.circular(
                                              24,
                                            ),
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
                                            SizedBox(
                                              height: _gapSmall(context),
                                            ),
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

                                  // Feature icons : wrap pada ≤ 360 agar tetap center
                                  AnimatedBuilder(
                                    animation: _textFade,
                                    builder: (context, child) {
                                      return Opacity(
                                        opacity: _textFade.value * 0.8,
                                        child: canWrap
                                            ? Wrap(
                                                alignment: WrapAlignment.center,
                                                runSpacing: 12,
                                                spacing: featureSpacing,
                                                children: [
                                                  _buildFeatureIcon(
                                                    Icons.access_time_rounded,
                                                    iconSize,
                                                  ),
                                                  _buildFeatureIcon(
                                                    Icons.menu_book_rounded,
                                                    iconSize,
                                                  ),
                                                  _buildFeatureIcon(
                                                    Icons.explore_outlined,
                                                    iconSize,
                                                  ),
                                                  _buildFeatureIcon(
                                                    Icons.people_rounded,
                                                    iconSize,
                                                  ),
                                                ],
                                              )
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  _buildFeatureIcon(
                                                    Icons.access_time_rounded,
                                                    iconSize,
                                                  ),
                                                  SizedBox(
                                                    width: featureSpacing,
                                                  ),
                                                  _buildFeatureIcon(
                                                    Icons.menu_book_rounded,
                                                    iconSize,
                                                  ),
                                                  SizedBox(
                                                    width: featureSpacing,
                                                  ),
                                                  _buildFeatureIcon(
                                                    Icons.explore_outlined,
                                                    iconSize,
                                                  ),
                                                  SizedBox(
                                                    width: featureSpacing,
                                                  ),
                                                  _buildFeatureIcon(
                                                    Icons.people_rounded,
                                                    iconSize,
                                                  ),
                                                ],
                                              ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),

                            // Progress
                            Padding(
                              padding: EdgeInsets.all(isNarrow ? 28 : 40),
                              child: Column(
                                children: [
                                  AnimatedBuilder(
                                    animation: _progress,
                                    builder: (context, child) {
                                      return Container(
                                        width: barWidth,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            3,
                                          ),
                                        ),
                                        child: Stack(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Container(
                                                width:
                                                    barWidth * _progress.value,
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
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.white
                                                          .withValues(
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
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.9,
                                            ),
                                            fontSize:
                                                ResponsiveHelper.adaptiveTextSize(
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
                        );
                      },
                    ),
                  ),
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
