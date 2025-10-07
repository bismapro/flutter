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
    final user = authState['profile']['user'] ?? authState['profile'];
    final status = authState['status'];
    final error = authState['error'];

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
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Profile',
                              style: TextStyle(
                                fontSize: _ts(context, 28),
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2D3748),
                              ),
                            ),
                          ),
                        ),

                        // Error
                        if (error != null)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red[200]!),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error, color: Colors.red),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    error,
                                    style: TextStyle(color: Colors.red[700]),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => ref
                                      .read(profileProvider.notifier)
                                      .clearError(),
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
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
                              status == ProfileState.loading
                                  ? _buildLoadingProfile(context)
                                  : _buildProfileContent(context, user),
                            ],
                          ),
                        ),

                        SizedBox(height: _px(context, 28)),

                        // Menu Items
                        _buildMenuItem(
                          context: context,
                          icon: Icons.person_outline,
                          title: 'Edit Profile',
                          subtitle: 'Ubah informasi profil Anda',
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
                          onTap: () => _showHelp(context),
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.info_outline,
                          title: 'Tentang Aplikasi',
                          subtitle: 'Versi dan informasi aplikasi',
                          onTap: () => _showAbout(context),
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

  Widget _buildProfileContent(
    BuildContext context,
    Map<String, dynamic>? user,
  ) {
    final name = user?['name'] ?? 'User';
    final email = user?['email'] ?? 'email@example.com';

    return Column(
      children: [
        // Avatar
        Container(
          width: _px(context, 88),
          height: _px(context, 88),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFF1E88E5), Color(0xFF26A69A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(
            Icons.person,
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
            color: const Color(0xFF2D3748),
          ),
        ),
        SizedBox(height: _px(context, 6)),

        // Email
        Text(
          email,
          style: TextStyle(
            fontSize: _ts(context, 14),
            color: const Color(0xFF4A5568),
          ),
        ),
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
  }) {
    final iconSize = _px(context, 26);
    final titleFontSize = _ts(context, 16);
    final subtitleFontSize = _ts(context, 13);
    final vPad = _px(context, 14);
    final hPad = _px(context, 16);

    return Container(
      margin: EdgeInsets.only(bottom: _px(context, 14)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
        leading: Container(
          padding: EdgeInsets.all(_px(context, 10)),
          decoration: BoxDecoration(
            color: const Color(0xFF1E88E5).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF1E88E5), size: iconSize),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3748),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: subtitleFontSize,
            color: const Color(0xFF4A5568),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: _px(context, 16),
          color: const Color(0xFF4A5568),
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
