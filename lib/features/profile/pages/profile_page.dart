import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_flutter/core/utils/responsive_helper.dart';
import 'package:test_flutter/core/widgets/toast.dart';
import 'package:test_flutter/features/auth/auth_provider.dart';
import 'package:test_flutter/features/profile/profile_provider.dart';
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
      ref.read(profileProvider.notifier).loadUser();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(profileProvider);
    final profileData = authState['profile'];
    final user = profileData is Map<String, dynamic>
        ? (profileData['user'] ?? profileData)
        : null;
    final status = authState['status'] as ProfileState?;
    final error = authState['error'];
    final isOffline = authState['isOffline'] as bool? ?? false;

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
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Profile',
                                  style: TextStyle(
                                    fontSize: _ts(context, 28),
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2D3748),
                                  ),
                                ),
                              ),
                              // Offline indicator
                              if (isOffline)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: _px(context, 12),
                                    vertical: _px(context, 6),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.orange.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.wifi_off_rounded,
                                        size: _px(context, 16),
                                        color: Colors.orange,
                                      ),
                                      SizedBox(width: _px(context, 6)),
                                      Text(
                                        'Offline',
                                        style: TextStyle(
                                          fontSize: _ts(context, 12),
                                          fontWeight: FontWeight.w600,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Error
                        // if (error != null)
                        //   Container(
                        //     width: double.infinity,
                        //     margin: const EdgeInsets.only(bottom: 16),
                        //     padding: const EdgeInsets.all(16),
                        //     decoration: BoxDecoration(
                        //       color: Colors.red[50],
                        //       borderRadius: BorderRadius.circular(8),
                        //       border: Border.all(color: Colors.red[200]!),
                        //     ),
                        //     child: Row(
                        //       children: [
                        //         const Icon(Icons.error, color: Colors.red),
                        //         const SizedBox(width: 8),
                        //         Expanded(
                        //           child: Text(
                        //             error,
                        //             style: TextStyle(color: Colors.red[700]),
                        //           ),
                        //         ),
                        //         IconButton(
                        //           onPressed: () => ref
                        //               .read(profileProvider.notifier)
                        //               .clearError(),
                        //           icon: const Icon(
                        //             Icons.close,
                        //             color: Colors.red,
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),

                        // Offline Notice (when user data is null but we're offline)
                        if (isOffline && user == null)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange[200]!),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.wifi_off,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Data profil tidak tersedia dalam mode offline. Silakan sambungkan ke internet untuk memuat data terbaru.',
                                    style: TextStyle(color: Colors.orange[700]),
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
                              if (status == ProfileState.loading)
                                _buildLoadingProfile(context)
                              else if (status == ProfileState.error &&
                                  !isOffline)
                                _buildErrorProfile(context)
                              else
                                _buildProfileContent(context, user),
                            ],
                          ),
                        ),

                        SizedBox(height: _px(context, 28)),

                        // Menu Items - disable when offline and no user data
                        _buildMenuItem(
                          context: context,
                          icon: Icons.person_outline,
                          title: 'Edit Profile',
                          subtitle: 'Ubah informasi profil Anda',
                          enabled: user != null && user['name'] != null,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfilePage(),
                            ),
                          ),
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.security,
                          title: 'Ubah Password',
                          subtitle: 'Ubah password untuk keamanan akun',
                          enabled: !isOffline,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChangePasswordPage(),
                            ),
                          ),
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.family_restroom,
                          title: 'Kelola Keluarga',
                          subtitle: 'Tambah atau edit anggota keluarga',
                          enabled: !isOffline,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ManageFamilyPage(),
                            ),
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

                        // Refresh button when offline or no data
                        if (isOffline || (user == null || user['name'] == null))
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(bottom: _px(context, 16)),
                            padding: EdgeInsets.symmetric(
                              vertical: _px(context, 16),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: InkWell(
                              onTap: () {
                                ref.read(profileProvider.notifier).loadUser();
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.refresh,
                                    color: Colors.blue,
                                    size: _px(context, 22),
                                  ),
                                  SizedBox(width: _px(context, 10)),
                                  Text(
                                    isOffline
                                        ? 'Coba Sambungkan Lagi'
                                        : 'Muat Ulang Profil',
                                    style: TextStyle(
                                      fontSize: _ts(context, 16),
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Logout
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

  Widget _buildErrorProfile(BuildContext context) {
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
        Text(
          'Silakan coba lagi',
          style: TextStyle(fontSize: _ts(context, 14), color: Colors.grey[600]),
        ),
        SizedBox(height: _px(context, 16)),
        ElevatedButton(
          onPressed: () {
            ref.read(profileProvider.notifier).loadUser();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E88E5),
            foregroundColor: Colors.white,
          ),
          child: const Text('Coba Lagi'),
        ),
        SizedBox(height: _px(context, 22)),
      ],
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    Map<String, dynamic>? user,
  ) {
    // Handle offline/unauthenticated state with fallback data
    final name = user?['name']?.toString() ?? '-';
    final email = user?['email']?.toString() ?? '-';
    final isDataAvailable =
        user != null && user['name'] != null && user['email'] != null;

    return Column(
      children: [
        // Avatar
        Container(
          width: _px(context, 88),
          height: _px(context, 88),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: isDataAvailable
                  ? [const Color(0xFF1E88E5), const Color(0xFF26A69A)]
                  : [Colors.grey.shade400, Colors.grey.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(
            isDataAvailable ? Icons.person : Icons.person_off,
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
            color: isDataAvailable
                ? const Color(0xFF2D3748)
                : Colors.grey.shade600,
          ),
        ),
        SizedBox(height: _px(context, 6)),

        // Email
        Text(
          email,
          style: TextStyle(
            fontSize: _ts(context, 14),
            color: isDataAvailable
                ? const Color(0xFF4A5568)
                : Colors.grey.shade500,
          ),
        ),

        // Offline/Unavailable indicator
        if (!isDataAvailable) ...[
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
          enabled ? subtitle : 'Tidak tersedia saat offline',
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
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text('🌐 Website: www.shollover.com')],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
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
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Shollover'),
            SizedBox(height: 8),
            Text('📱 Versi: 1.0.0'),
            SizedBox(height: 8),
            Text('🔨 Build: 100'),
            SizedBox(height: 8),
            Text('👨‍💻 Developer: Tim Shollover'),
            SizedBox(height: 16),
            Text(
              'Aplikasi untuk membantu keluarga Muslim dalam menjalankan ibadah dan monitoring aktivitas keagamaan.',
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
