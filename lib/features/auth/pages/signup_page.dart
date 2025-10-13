import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_flutter/core/constants/app_config.dart';
import 'package:test_flutter/core/utils/responsive_helper.dart';
import 'package:test_flutter/core/widgets/toast.dart';
import 'package:test_flutter/features/auth/auth_provider.dart';
import '../../../app/theme.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeTerms = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_agreeTerms) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showMessageToast(
            context,
            message: tr('signup.terms_required'),
            type: ToastType.error,
            duration: const Duration(seconds: 4),
          );
        });
        return;
      }

      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final confirmationPassword = _confirmPasswordController.text.trim();

      ref
          .read(authProvider.notifier)
          .register(name, email, password, confirmationPassword);
    }
  }

  double _gapSmall(BuildContext context) =>
      ResponsiveHelper.isSmallScreen(context) ? 12 : 16;
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

    // Watch auth state
    final authState = ref.watch(authProvider);
    final isLoading = authState['status'] == AuthState.loading;
    final error = authState['error'];

    if (authState['status'] == AuthState.error && error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showMessageToast(
          context,
          message: error.toString(),
          type: ToastType.error,
          duration: const Duration(seconds: 4),
        );
        ref.read(authProvider.notifier).clearError();
      });
    }

    if (authState['status'] == AuthState.isRegistered) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showMessageToast(
          context,
          message:
              authState['message']?.toString() ?? tr('signup.toast_success'),
          type: ToastType.success,
          duration: const Duration(seconds: 3),
        );
        Navigator.of(context).pushReplacementNamed('/home');
      });
    }

    final pagePadding = ResponsiveHelper.getResponsivePadding(context);
    final useTwoColumns =
        MediaQuery.of(context).size.width >= ResponsiveHelper.largeScreenSize;

    final logoSize = isSmall
        ? 70.0
        : isMedium
        ? 85.0
        : 95.0;
    final cardRadius = isXL ? 32.0 : 28.0;
    const fieldRadius = 16.0;

    final maxFormWidth = isXL
        ? 520.0
        : isLarge
        ? 480.0
        : 440.0;

    final appBar = Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back_rounded, color: AppTheme.onSurface),
            ),
          ),
        ],
      ),
    );

    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: isSmall ? 6 : 10),
        // Logo
        FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            width: logoSize,
            height: logoSize,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                  blurRadius: 25,
                  offset: const Offset(0, 8),
                  spreadRadius: -5,
                ),
              ],
            ),
            padding: const EdgeInsets.all(6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(AppConfig.appLogo, fit: BoxFit.cover),
            ),
          ),
        ),
        SizedBox(height: _gapMedium(context) - 4),

        // Title & subtitle
        FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [AppTheme.primaryBlue, AppTheme.accentGreen],
                ).createShader(bounds),
                child: Text(
                  tr('signup.title'),
                  style: TextStyle(
                    fontSize: ResponsiveHelper.adaptiveTextSize(context, 30),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              SizedBox(height: isSmall ? 6 : 8),
              Text(
                tr('signup.subtitle'),
                style: TextStyle(
                  fontSize: ResponsiveHelper.adaptiveTextSize(context, 15),
                  color: AppTheme.onSurfaceVariant,
                  height: 1.35,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        SizedBox(height: _gapMedium(context)),
      ],
    );

    final formCard = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: useTwoColumns ? maxFormWidth : 600,
        ),
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              padding: EdgeInsets.all(
                isSmall
                    ? 20
                    : isMedium
                    ? 24
                    : 28,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(cardRadius),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Name
                    TextFormField(
                      controller: _nameController,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.adaptiveTextSize(
                          context,
                          15,
                        ),
                      ),
                      decoration: InputDecoration(
                        labelText: tr('signup.name_label'),
                        hintText: tr('signup.name_hint'),
                        prefixIcon: Icon(
                          Icons.person_outlined,
                          color: AppTheme.primaryBlue,
                        ),
                        filled: true,
                        fillColor: AppTheme.primaryBlue.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(fieldRadius),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(fieldRadius),
                          borderSide: BorderSide(
                            color: AppTheme.primaryBlue,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return tr('signup.name_validation_null');
                        }

                        if (value.length < 3) {
                          return tr('signup.name_validation_short');
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: _gapSmall(context) + 4),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.adaptiveTextSize(
                          context,
                          15,
                        ),
                      ),
                      decoration: InputDecoration(
                        labelText: tr('signup.email_label'),
                        hintText: tr('signup.email_hint'),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: AppTheme.accentGreen,
                        ),
                        filled: true,
                        fillColor: AppTheme.accentGreen.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(fieldRadius),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(fieldRadius),
                          borderSide: BorderSide(
                            color: AppTheme.accentGreen,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return tr('signup.email_validation_null');
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return tr('signup.email_validation_invalid');
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: _gapSmall(context) + 4),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.adaptiveTextSize(
                          context,
                          15,
                        ),
                      ),
                      decoration: InputDecoration(
                        labelText: tr('signup.password_label'),
                        hintText: tr('signup.password_hint'),
                        prefixIcon: Icon(
                          Icons.lock_outlined,
                          color: AppTheme.primaryBlue,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                        filled: true,
                        fillColor: AppTheme.primaryBlue.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(fieldRadius),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(fieldRadius),
                          borderSide: BorderSide(
                            color: AppTheme.primaryBlue,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return tr('signup.password_validation_null');
                        }
                        if (value.length < 6) {
                          return tr('signup.password_validation_short');
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: _gapSmall(context) + 4),

                    // Confirm Password
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.adaptiveTextSize(
                          context,
                          15,
                        ),
                      ),
                      decoration: InputDecoration(
                        labelText: tr('signup.confirm_password_label'),
                        hintText: tr('signup.confirm_password_hint'),
                        prefixIcon: Icon(
                          Icons.lock_outlined,
                          color: AppTheme.accentGreen,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible;
                            });
                          },
                          icon: Icon(
                            _isConfirmPasswordVisible
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                        filled: true,
                        fillColor: AppTheme.accentGreen.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(fieldRadius),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(fieldRadius),
                          borderSide: BorderSide(
                            color: AppTheme.accentGreen,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return tr('signup.confirm_password_validation_null');
                        }
                        if (value != _passwordController.text) {
                          return tr(
                            'signup.confirm_password_validation_mismatch',
                          );
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: _gapMedium(context) - 4),

                    // Terms
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _agreeTerms,
                            onChanged: (value) {
                              setState(() => _agreeTerms = value ?? false);
                            },
                            activeColor: AppTheme.primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.adaptiveTextSize(
                                    context,
                                    13,
                                  ),
                                  color: AppTheme.onSurfaceVariant,
                                ),
                                children: [
                                  TextSpan(text: tr('signup.terms_text')),
                                  TextSpan(
                                    text: tr('signup.terms_service'),
                                    style: TextStyle(
                                      color: AppTheme.primaryBlue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(text: tr('signup.terms_and')),
                                  TextSpan(
                                    text: tr('signup.privacy_policy'),
                                    style: TextStyle(
                                      color: AppTheme.primaryBlue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: _gapMedium(context) - 4),

                    // Button
                    SizedBox(
                      width: double.infinity,
                      height: _fieldHeight(context),
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleSignup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(fieldRadius),
                          ),
                          elevation: 0,
                          disabledBackgroundColor: AppTheme.accentGreen
                              .withValues(alpha: 0.6),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    tr('signup.button_signup'),
                                    style: TextStyle(
                                      fontSize:
                                          ResponsiveHelper.adaptiveTextSize(
                                            context,
                                            16,
                                          ),
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 20,
                                  ),
                                ],
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
    );

    final social = FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: useTwoColumns ? maxFormWidth : 600,
          ),
          child: Column(
            children: [
              SizedBox(height: _gapMedium(context)),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300])),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      tr('signup.divider_text'),
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300])),
                ],
              ),
              SizedBox(height: _gapSmall(context) + 8),
              SizedBox(
                width: double.infinity,
                height: _fieldHeight(context),
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[300]!, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(fieldRadius),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.g_mobiledata_rounded,
                        size: isSmall ? 26 : 28,
                        color: AppTheme.onSurface,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        tr('signup.button_google'),
                        style: TextStyle(
                          fontSize: ResponsiveHelper.adaptiveTextSize(
                            context,
                            16,
                          ),
                          fontWeight: FontWeight.w600,
                          color: AppTheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final signupLink = Padding(
      padding: EdgeInsets.only(
        top: _gapMedium(context),
        left: 4,
        right: 4,
        bottom: isSmall ? 8 : 0,
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: useTwoColumns ? maxFormWidth : 600,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.accentGreen.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    tr('signup.already_account'),
                    style: TextStyle(
                      color: AppTheme.onSurfaceVariant,
                      fontSize: ResponsiveHelper.adaptiveTextSize(context, 14),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/login'),
                    child: Text(
                      ' ${tr('signup.login')}',
                      style: TextStyle(
                        color: AppTheme.accentGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveHelper.adaptiveTextSize(
                          context,
                          14,
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
    );

    // ===== Scaffold body =====
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
                          Icons.favorite_rounded,
                          size: isXL ? 120 : 96,
                          color: AppTheme.accentGreen.withValues(alpha: 0.9),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          tr('signup.left_panel_title'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.adaptiveTextSize(
                              context,
                              22,
                            ),
                            fontWeight: FontWeight.w700,
                            color: AppTheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tr('signup.left_panel_description'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.adaptiveTextSize(
                              context,
                              14,
                            ),
                            color: AppTheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      appBar,
                      Expanded(
                        child: Row(
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
                              child: SingleChildScrollView(
                                padding: EdgeInsets.symmetric(
                                  horizontal: pagePadding.horizontal / 2,
                                  vertical: 12,
                                ),
                                child: Column(
                                  children: [
                                    header,
                                    formCard,
                                    social,
                                    signupLink,
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  // mobile / tablet kecil
                  return Column(
                    children: [
                      appBar,
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [header, formCard, social, signupLink],
                          ),
                        ),
                      ),
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
