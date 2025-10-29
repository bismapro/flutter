import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_flutter/core/utils/responsive_helper.dart';
import 'package:test_flutter/core/widgets/toast.dart';
import 'package:test_flutter/features/auth/auth_provider.dart';
import 'package:test_flutter/features/profile/profile_provider.dart';
import 'package:test_flutter/features/profile/profile_state.dart';
import 'edit_profile_page.dart';
import 'change_password_page.dart';
import 'manage_family_page.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  String selectedLanguage = 'Indonesia';

  // --- Helpers berbasis ResponsiveHelper ---
  double _scale(BuildContext c) {
    if (ResponsiveHelper.isSmallScreen(c)) return .9;
    if (ResponsiveHelper.isMediumScreen(c)) return 1.0;
    if (ResponsiveHelper.isLargeScreen(c)) return 1.1;
    return 1.2;
  }

  double _px(BuildContext c, double base) => base * _scale(c);
  double _ts(BuildContext c, double base) =>
      ResponsiveHelper.adaptiveTextSize(c, base);

  double _contentMaxWidth(BuildContext c) {
    if (ResponsiveHelper.isExtraLargeScreen(c)) return 720;
    if (ResponsiveHelper.isLargeScreen(c)) return 640;
    return double.infinity;
  }

  EdgeInsets _pageHPad(BuildContext c) => EdgeInsets.symmetric(
    horizontal: ResponsiveHelper.getResponsivePadding(c).left,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check auth status first
      final authState = ref.read(authProvider);
      if (authState['status'] == AuthState.authenticated) {
        ref.read(profileProvider.notifier).loadUser();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth state
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState['status'] == AuthState.authenticated;

    // Watch profile state
    final profileState = ref.watch(profileProvider);
    final user = profileState.profile;
    final status = profileState.status;
    final message = profileState.message;

    // Create guest user if not authenticated
    final displayUser = isAuthenticated
        ? user
        : {
            'user': {
              'name': 'Guest User',
              'email': 'guest@shollover.com',
              'phone': null,
            },
          };

    // Listen to state changes for showing messages
    ref.listen<ProfileState>(profileProvider, (previous, next) {
      if (next.status == ProfileStatus.error && next.message != null) {
        showMessageToast(
          context,
          message: next.message!,
          type: ToastType.error,
        );
        ref.read(profileProvider.notifier).clearMessage();
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ===== Content =====
            Expanded(
              child: SingleChildScrollView(
                padding: _pageHPad(context),
                physics: const BouncingScrollPhysics(),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: _contentMaxWidth(context),
                    ),
                    child: Column(
                      children: [
                        // Header
                        Container(
                          width: double.infinity,
                          color: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: _px(context, 20),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Back button (left)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(context, '/home');
                                  },
                                  icon: const Icon(Icons.arrow_back_rounded),
                                  color: const Color(0xFF2D3748),
                                  tooltip: 'Kembali',
                                ),
                              ),
                              // Title (center)
                              Text(
                                'Profile',
                                style: TextStyle(
                                  fontSize: _ts(context, 28),
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2D3748),
                                ),
                              ),
                              // Refresh button (right) - only for authenticated users
                              if (isAuthenticated &&
                                  status != ProfileStatus.loading)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF1E88E5,
                                      ).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: IconButton(
                                      onPressed: () {
                                        ref
                                            .read(profileProvider.notifier)
                                            .loadUser();
                                      },
                                      icon: const Icon(Icons.refresh_rounded),
                                      color: const Color(0xFF1E88E5),
                                      tooltip: 'Refresh',
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Profile Card
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(_px(context, 20)),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.1),
                                blurRadius: 10,
                                spreadRadius: 1,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Show loading only if authenticated and loading
                              if (isAuthenticated &&
                                  status == ProfileStatus.loading)
                                _buildLoadingProfile(context)
                              // Show error only if authenticated and error
                              else if (isAuthenticated &&
                                  status == ProfileStatus.error)
                                _buildErrorProfile(context, message)
                              // Show profile (real or guest)
                              else
                                _buildProfileContent(
                                  context,
                                  displayUser,
                                  isGuest: !isAuthenticated,
                                ),
                            ],
                          ),
                        ),

                        SizedBox(height: _px(context, 28)),

                        // Show login prompt for guest users
                        if (!isAuthenticated) ...[
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(_px(context, 20)),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1E88E5), Color(0xFF26A69A)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF1E88E5,
                                  ).withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.lock_outline_rounded,
                                  size: _px(context, 48),
                                  color: Colors.white,
                                ),
                                SizedBox(height: _px(context, 12)),
                                Text(
                                  'Masuk untuk Mengakses Fitur',
                                  style: TextStyle(
                                    fontSize: _ts(context, 18),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: _px(context, 8)),
                                Text(
                                  'Login untuk mengelola profil, keluarga, dan mengakses fitur lengkap',
                                  style: TextStyle(
                                    fontSize: _ts(context, 14),
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: _px(context, 16)),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/welcome',
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF1E88E5),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: _px(context, 32),
                                      vertical: _px(context, 14),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Masuk Sekarang',
                                    style: TextStyle(
                                      fontSize: _ts(context, 16),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: _px(context, 28)),
                        ],

                        // Menu Items (disabled for guest)
                        _buildMenuItem(
                          context: context,
                          icon: Icons.person_outline,
                          title: 'Edit Profile',
                          subtitle: isAuthenticated
                              ? 'Ubah informasi profil Anda'
                              : 'Login untuk mengedit profil',
                          enabled: isAuthenticated && displayUser != null,
                          onTap: () async {
                            final result = await Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfilePage(),
                              ),
                              (route) => false,
                            );
                            // Refresh if profile was updated
                            if (result == true) {
                              ref.read(profileProvider.notifier).loadUser();
                            }
                          },
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.security,
                          title: 'Ubah Password',
                          subtitle: isAuthenticated
                              ? 'Ubah password untuk keamanan akun'
                              : 'Login untuk mengubah password',
                          enabled: isAuthenticated && displayUser != null,
                          onTap: () => Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChangePasswordPage(),
                            ),
                            (route) => false,
                          ),
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.family_restroom,
                          title: 'Kelola Keluarga',
                          subtitle: isAuthenticated
                              ? 'Tambah atau edit anggota keluarga'
                              : 'Login untuk mengelola keluarga',
                          enabled: isAuthenticated && displayUser != null,
                          onTap: () => Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ManageFamilyPage(),
                            ),
                            (route) => false,
                          ),
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.help_outline,
                          title: 'Bantuan',
                          subtitle: 'FAQ dan dukungan pelanggan',
                          enabled: true,
                          onTap: () => _showHelp(context),
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.info_outline,
                          title: 'Tentang Aplikasi',
                          subtitle: 'Versi dan informasi aplikasi',
                          enabled: true,
                          onTap: () => _showAbout(context),
                        ),

                        SizedBox(height: _px(context, 16)),

                        // Logout (only for authenticated users)
                        if (isAuthenticated)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              vertical: _px(context, 16),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red[200]!),
                            ),
                            child: InkWell(
                              onTap: () => _showLogoutDialog(context),
                              borderRadius: BorderRadius.circular(12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.logout,
                                    color: Colors.red,
                                    size: _px(context, 22),
                                  ),
                                  SizedBox(width: _px(context, 10)),
                                  Text(
                                    'Keluar',
                                    style: TextStyle(
                                      fontSize: _ts(context, 16),
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        SizedBox(
                          height: ResponsiveHelper.getResponsivePadding(
                            context,
                          ).bottom,
                        ),
                      ],
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

  // ================== Widgets ==================

  Widget _buildLoadingProfile(BuildContext context) {
    return Column(
      children: [
        // Avatar loading
        Container(
          width: _px(context, 88),
          height: _px(context, 88),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[300],
          ),
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E88E5)),
            ),
          ),
        ),
        SizedBox(height: _px(context, 18)),

        // Name skeleton
        Container(
          width: 150,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(height: _px(context, 6)),

        // Email skeleton
        Container(
          width: 200,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(height: _px(context, 22)),
      ],
    );
  }

  Widget _buildErrorProfile(BuildContext context, String? errorMessage) {
    return Column(
      children: [
        Icon(Icons.error_outline, size: _px(context, 64), color: Colors.red),
        SizedBox(height: _px(context, 16)),
        Text(
          'Gagal memuat profil',
          style: TextStyle(
            fontSize: _ts(context, 18),
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ),
        SizedBox(height: _px(context, 8)),
        if (errorMessage != null)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: _px(context, 20)),
            child: Text(
              errorMessage,
              style: TextStyle(
                fontSize: _ts(context, 14),
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          )
        else
          Text(
            'Silakan coba lagi',
            style: TextStyle(
              fontSize: _ts(context, 14),
              color: Colors.grey[600],
            ),
          ),
        SizedBox(height: _px(context, 16)),
        ElevatedButton.icon(
          onPressed: () {
            ref.read(profileProvider.notifier).loadUser();
          },
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Coba Lagi'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E88E5),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: _px(context, 20),
              vertical: _px(context, 12),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        SizedBox(height: _px(context, 22)),
      ],
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    user, {
    bool isGuest = false,
  }) {
    // Handle case when user is null
    final name = user != null ? (user['name'] ?? '-') : '-';
    final email = user != null ? (user['email'] ?? '-') : '-';
    final phone = user != null ? (user['phone'] ?? '-') : '-';
    final isDataAvailable = user != null;

    return Column(
      children: [
        // Avatar
        Container(
          width: _px(context, 88),
          height: _px(context, 88),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: isGuest
                  ? [Colors.grey.shade400, Colors.grey.shade500]
                  : isDataAvailable
                  ? [const Color(0xFF1E88E5), const Color(0xFF26A69A)]
                  : [Colors.grey.shade400, Colors.grey.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(
            isGuest
                ? Icons.person_off_outlined
                : isDataAvailable
                ? Icons.person
                : Icons.person_off,
            size: _px(context, 44),
            color: Colors.white,
          ),
        ),
        SizedBox(height: _px(context, 18)),

        // Name
        Text(
          name,
          style: TextStyle(
            fontSize: _ts(context, 22),
            fontWeight: FontWeight.bold,
            color: isGuest || !isDataAvailable
                ? Colors.grey.shade600
                : const Color(0xFF2D3748),
          ),
        ),
        SizedBox(height: _px(context, 6)),

        // Email
        Text(
          email,
          style: TextStyle(
            fontSize: _ts(context, 14),
            color: isGuest || !isDataAvailable
                ? Colors.grey.shade500
                : const Color(0xFF4A5568),
          ),
        ),

        // Phone (if available and not guest)
        if (!isGuest && phone != null && phone.isNotEmpty) ...[
          SizedBox(height: _px(context, 4)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.phone,
                size: _px(context, 14),
                color: const Color(0xFF4A5568),
              ),
              SizedBox(width: _px(context, 4)),
              Text(
                phone,
                style: TextStyle(
                  fontSize: _ts(context, 13),
                  color: const Color(0xFF4A5568),
                ),
              ),
            ],
          ),
        ],

        // Guest indicator
        if (isGuest) ...[
          SizedBox(height: _px(context, 8)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: _px(context, 12),
              vertical: _px(context, 4),
            ),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: _px(context, 14),
                  color: Colors.grey.shade600,
                ),
                SizedBox(width: _px(context, 6)),
                Text(
                  'Mode Guest',
                  style: TextStyle(
                    fontSize: _ts(context, 12),
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],

        // Unavailable indicator (only for authenticated users with no data)
        if (!isGuest && !isDataAvailable) ...[
          SizedBox(height: _px(context, 8)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: _px(context, 12),
              vertical: _px(context, 4),
            ),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Text(
              'Data tidak tersedia',
              style: TextStyle(
                fontSize: _ts(context, 12),
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],

        SizedBox(height: _px(context, 22)),
      ],
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    final iconSize = _px(context, 26);
    final titleFontSize = _ts(context, 16);
    final subtitleFontSize = _ts(context, 13);
    final vPad = _px(context, 14);
    final hPad = _px(context, 16);

    return Container(
      margin: EdgeInsets.only(bottom: _px(context, 14)),
      decoration: BoxDecoration(
        color: enabled ? Colors.white : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.08),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ListTile(
        onTap: enabled ? onTap : null,
        contentPadding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
        leading: Container(
          padding: EdgeInsets.all(_px(context, 10)),
          decoration: BoxDecoration(
            color: (enabled ? const Color(0xFF1E88E5) : Colors.grey).withValues(
              alpha: 0.1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: enabled ? const Color(0xFF1E88E5) : Colors.grey,
            size: iconSize,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.w600,
            color: enabled ? const Color(0xFF2D3748) : Colors.grey,
          ),
        ),
        subtitle: Text(
          enabled ? subtitle : 'Tidak tersedia',
          style: TextStyle(
            fontSize: subtitleFontSize,
            color: enabled ? const Color(0xFF4A5568) : Colors.grey,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: _px(context, 16),
          color: enabled ? const Color(0xFF4A5568) : Colors.grey,
        ),
      ),
    );
  }

  // ================== Dialogs & Actions ==================

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
              showMessageToast(
                context,
                message: 'Anda telah keluar dari aplikasi',
                type: ToastType.success,
              );
              Navigator.pushReplacementNamed(context, '/welcome');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bantuan'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🌐 Website: www.shollover.com'),
            SizedBox(height: 8),
            Text('📧 Email: support@shollover.com'),
            SizedBox(height: 8),
            Text('📱 WhatsApp: +62 xxx xxxx xxxx'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              foregroundColor: Colors.white,
            ),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tentang Aplikasi'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shollover',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('📱 Versi: 1.0.0'),
            SizedBox(height: 8),
            Text('🔨 Build: 100'),
            SizedBox(height: 8),
            Text('👨‍💻 Developer: Tim Shollover'),
            SizedBox(height: 16),
            Text(
              'Aplikasi untuk membantu keluarga Muslim dalam menjalankan ibadah dan monitoring aktivitas keagamaan.',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
