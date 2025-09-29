import 'package:flutter/material.dart';
import 'edit_profile_page.dart';
import 'change_password_page.dart';
import 'manage_family_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String selectedLanguage = 'Indonesia'; // Default language

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isLargeScreen = screenWidth > 800;

    // Responsive padding and sizes
    final horizontalPadding = isLargeScreen ? 40.0 : (isTablet ? 32.0 : 20.0);
    final verticalPadding = isTablet ? 24.0 : 20.0;
    final cardPadding = isTablet ? 24.0 : 20.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  children: [
                    Container(
                      width: isLargeScreen ? 600 : double.infinity,
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: verticalPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profile',
                            style: TextStyle(
                              fontSize: isLargeScreen
                                  ? 32
                                  : (isTablet ? 30 : 28),
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2D3748),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Profile Card
                    Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        maxWidth: isLargeScreen ? 600 : double.infinity,
                      ),
                      padding: EdgeInsets.all(cardPadding),
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
                          // Avatar
                          Container(
                            width: isLargeScreen ? 100 : (isTablet ? 90 : 80),
                            height: isLargeScreen ? 100 : (isTablet ? 90 : 80),
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
                              size: isLargeScreen ? 50 : (isTablet ? 45 : 40),
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: isTablet ? 20 : 16),

                          // Name
                          Text(
                            'Ahmad Fauzan',
                            style: TextStyle(
                              fontSize: isTablet ? 24 : 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2D3748),
                            ),
                          ),
                          SizedBox(height: isTablet ? 6 : 4),

                          // Email
                          Text(
                            'ahmad.fauzan@email.com',
                            style: TextStyle(
                              fontSize: isTablet ? 16 : 14,
                              color: const Color(0xFF4A5568),
                            ),
                          ),
                          SizedBox(height: isTablet ? 24 : 16),

                          // Stats Row
                          _buildStatsRow(isTablet, isLargeScreen),
                        ],
                      ),
                    ),

                    SizedBox(height: isTablet ? 32 : 24),

                    // Menu Items Container
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: isLargeScreen ? 600 : double.infinity,
                      ),
                      child: Column(
                        children: [
                          _buildMenuItem(
                            icon: Icons.person_outline,
                            title: 'Edit Profile',
                            subtitle: 'Ubah informasi profil Anda',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfilePage(),
                              ),
                            ),
                            isTablet: isTablet,
                          ),

                          SizedBox(height: isTablet ? 24 : 20),

                          _buildMenuItem(
                            icon: Icons.security,
                            title: 'Ubah Password',
                            subtitle: 'Ubah password untuk keamanan akun',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ChangePasswordPage(),
                              ),
                            ),
                            isTablet: isTablet,
                          ),

                          _buildMenuItem(
                            icon: Icons.family_restroom,
                            title: 'Kelola Keluarga',
                            subtitle: 'Tambah atau edit anggota keluarga',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ManageFamilyPage(),
                              ),
                            ),
                            isTablet: isTablet,
                          ),

                          // _buildMenuItem(
                          //   icon: Icons.language,
                          //   title: 'Bahasa',
                          //   subtitle: 'Saat ini: $selectedLanguage',
                          //   onTap: () => _showLanguageDialog(context),
                          //   isTablet: isTablet,
                          // ),

                          _buildMenuItem(
                            icon: Icons.help_outline,
                            title: 'Bantuan',
                            subtitle: 'FAQ dan dukungan pelanggan',
                            onTap: () => _showHelp(context),
                            isTablet: isTablet,
                          ),

                          _buildMenuItem(
                            icon: Icons.info_outline,
                            title: 'Tentang Aplikasi',
                            subtitle: 'Versi dan informasi aplikasi',
                            onTap: () => _showAbout(context),
                            isTablet: isTablet,
                          ),

                          // Logout Button
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              vertical: isTablet ? 20 : 16,
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
                                    size: isTablet ? 24 : 20,
                                  ),
                                  SizedBox(width: isTablet ? 12 : 8),
                                  Text(
                                    'Keluar',
                                    style: TextStyle(
                                      fontSize: isTablet ? 18 : 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: verticalPadding),
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

  Widget _buildStatsRow(bool isTablet, bool isLargeScreen) {
    final fontSize = isTablet ? 20.0 : 18.0;
    final labelFontSize = isTablet ? 14.0 : 12.0;
    final separatorHeight = isTablet ? 36.0 : 30.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(
          '15',
          'Hari Streak',
          Colors.orange,
          fontSize,
          labelFontSize,
        ),
        Container(width: 1, height: separatorHeight, color: Colors.grey[300]),
        _buildStatItem(
          '85%',
          'Target Tercapai',
          Colors.green,
          fontSize,
          labelFontSize,
        ),
        Container(width: 1, height: separatorHeight, color: Colors.grey[300]),
        _buildStatItem(
          '24',
          'Total Badge',
          Colors.blue,
          fontSize,
          labelFontSize,
        ),
      ],
    );
  }

  Widget _buildStatItem(
    String value,
    String label,
    Color color,
    double fontSize,
    double labelFontSize,
  ) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: labelFontSize,
              color: const Color(0xFF4A5568),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isTablet,
  }) {
    final iconSize = isTablet ? 28.0 : 24.0;
    final titleFontSize = isTablet ? 18.0 : 16.0;
    final subtitleFontSize = isTablet ? 15.0 : 13.0;
    final verticalPadding = isTablet ? 16.0 : 12.0;
    final horizontalPadding = isTablet ? 20.0 : 16.0;

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
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
        contentPadding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        leading: Container(
          padding: EdgeInsets.all(isTablet ? 12 : 8),
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
          size: isTablet ? 18 : 16,
          color: const Color(0xFF4A5568),
        ),
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
          children: [
            // Text('📖 Frequently Asked Questions (FAQ)'),
            // SizedBox(height: 8),
            // Text('💬 Live Chat dengan Admin'),
            // SizedBox(height: 8),
            // Text('📞 Hubungi Customer Service'),
            // SizedBox(height: 8),
            // Text('📧 Email: support@islamicapp.com'),
            // SizedBox(height: 8),
            Text('🌐 Website: www.shollover.com'),
          ],
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Anda telah keluar dari aplikasi'),
                  backgroundColor: Colors.orange,
                ),
              );
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

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF1E88E5), Color(0xFF26A69A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.language, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Pilih Bahasa',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Language Options
              _buildLanguageOption(
                flag: '🇮🇩',
                language: 'Indonesia',
                subtitle: 'Bahasa Indonesia',
                isSelected: selectedLanguage == 'Indonesia',
                onTap: () {
                  setState(() {
                    selectedLanguage = 'Indonesia';
                  });
                  Navigator.pop(context);
                  _showLanguageChangeSuccess('Indonesia');
                },
              ),

              const SizedBox(height: 16),

              _buildLanguageOption(
                flag: '🇺🇸',
                language: 'English',
                subtitle: 'English Language',
                isSelected: selectedLanguage == 'English',
                onTap: () {
                  setState(() {
                    selectedLanguage = 'English';
                  });
                  Navigator.pop(context);
                  _showLanguageChangeSuccess('English');
                },
              ),

              const SizedBox(height: 24),

              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1E88E5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Tutup',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required String flag,
    required String language,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: Colors.white, width: 2)
              : Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
        ),
        child: Row(
          children: [
            Text(flag, style: TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }

  void _showLanguageChangeSuccess(String language) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          language == 'Indonesia'
              ? 'Bahasa berhasil diubah ke Bahasa Indonesia'
              : 'Language successfully changed to English',
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
