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

  // 🆕 Show Terms of Service Modal
  void _showTermsOfService() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPolicyModal(
        title: 'Ketentuan Layanan',
        content: _getTermsOfServiceContent(),
        icon: Icons.gavel_rounded,
        iconColor: AppTheme.primaryBlue,
      ),
    );
  }

  // 🆕 Show Privacy Policy Modal
  void _showPrivacyPolicy() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPolicyModal(
        title: 'Kebijakan Privasi',
        content: _getPrivacyPolicyContent(),
        icon: Icons.privacy_tip_rounded,
        iconColor: AppTheme.accentGreen,
      ),
    );
  }

  // 🆕 Build Policy Modal Widget
  Widget _buildPolicyModal({
    required String title,
    required String content,
    required IconData icon,
    required Color iconColor,
  }) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: iconColor, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    content,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border(
                    top: BorderSide(color: Colors.grey[200]!, width: 1),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: iconColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Mengerti',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 🆕 Terms of Service Content
  String _getTermsOfServiceContent() {
    return '''
KETENTUAN LAYANAN

Terakhir diperbarui: ${DateTime.now().day} ${_getMonthName(DateTime.now().month)} ${DateTime.now().year}

1. PENERIMAAN KETENTUAN

Dengan mengakses dan menggunakan aplikasi ini, Anda menyetujui untuk terikat dengan Ketentuan Layanan ini. Jika Anda tidak setuju dengan ketentuan ini, mohon tidak menggunakan layanan kami.

2. DESKRIPSI LAYANAN

Aplikasi kami menyediakan konten Islami, termasuk namun tidak terbatas pada:
• Al-Qur'an digital dengan terjemahan
• Jadwal waktu sholat
• Kumpulan doa dan dzikir
• Artikel dan konten edukatif Islami
• Fitur pencarian kiblat

3. AKUN PENGGUNA

3.1 Pendaftaran Akun
• Anda harus berusia minimal 13 tahun untuk membuat akun
• Informasi yang Anda berikan harus akurat dan lengkap
• Anda bertanggung jawab menjaga kerahasiaan password
• Anda bertanggung jawab atas semua aktivitas yang terjadi di akun Anda

3.2 Keamanan Akun
• Segera beritahu kami jika terjadi penggunaan tidak sah pada akun Anda
• Kami tidak bertanggung jawab atas kerugian akibat kelalaian Anda menjaga keamanan akun

4. PENGGUNAAN LAYANAN

Anda setuju untuk TIDAK:
• Menggunakan layanan untuk tujuan ilegal
• Mengunggah konten yang melanggar hukum atau hak orang lain
• Mengirimkan spam atau konten berbahaya
• Mencoba mengakses sistem tanpa otorisasi
• Mengganggu atau merusak infrastruktur layanan

5. HAK KEKAYAAN INTELEKTUAL

5.1 Konten Kami
• Semua konten dalam aplikasi dilindungi hak cipta
• Anda dapat menggunakan konten untuk keperluan pribadi non-komersial
• Dilarang mendistribusikan atau memodifikasi konten tanpa izin

5.2 Konten Pengguna
• Anda mempertahankan hak atas konten yang Anda buat
• Dengan mengunggah konten, Anda memberikan kami lisensi untuk menggunakannya dalam layanan

6. PEMBATASAN TANGGUNG JAWAB

• Layanan disediakan "sebagaimana adanya"
• Kami tidak menjamin layanan bebas dari error atau gangguan
• Kami tidak bertanggung jawab atas kerugian yang timbul dari penggunaan layanan
• Tanggung jawab kami terbatas pada jumlah yang Anda bayarkan (jika ada)

7. PERUBAHAN LAYANAN

Kami berhak:
• Memodifikasi atau menghentikan layanan kapan saja
• Mengubah fitur atau konten
• Membatasi akses untuk pemeliharaan

8. PEMUTUSAN

Kami dapat menutup akun Anda jika:
• Anda melanggar Ketentuan Layanan ini
• Kami diwajibkan oleh hukum
• Layanan dihentikan

9. HUKUM YANG BERLAKU

Ketentuan ini diatur oleh hukum Republik Indonesia. Setiap perselisihan akan diselesaikan di pengadilan yang berwenang di Indonesia.

10. KONTAK

Jika Anda memiliki pertanyaan tentang Ketentuan Layanan ini, hubungi kami di:
Email: support@islamicapp.com
Telepon: +62 XXX XXXX XXXX

11. PERUBAHAN KETENTUAN

Kami dapat memperbarui Ketentuan Layanan ini dari waktu ke waktu. Perubahan akan berlaku setelah dipublikasikan di aplikasi. Penggunaan berkelanjutan berarti Anda menerima perubahan tersebut.

DENGAN MENDAFTAR, ANDA MENYATAKAN TELAH MEMBACA, MEMAHAMI, DAN MENYETUJUI KETENTUAN LAYANAN INI.
''';
  }

  // 🆕 Privacy Policy Content
  String _getPrivacyPolicyContent() {
    return '''
KEBIJAKAN PRIVASI

Terakhir diperbarui: ${DateTime.now().day} ${_getMonthName(DateTime.now().month)} ${DateTime.now().year}

1. PENDAHULUAN

Kami menghargai privasi Anda dan berkomitmen melindungi data pribadi Anda. Kebijakan Privasi ini menjelaskan bagaimana kami mengumpulkan, menggunakan, dan melindungi informasi Anda.

2. INFORMASI YANG KAMI KUMPULKAN

2.1 Informasi yang Anda Berikan
• Nama lengkap
• Alamat email
• Nomor telepon (opsional)
• Foto profil (opsional)
• Preferensi dan pengaturan aplikasi

2.2 Informasi yang Dikumpulkan Otomatis
• Informasi perangkat (model, sistem operasi, ID unik)
• Data penggunaan aplikasi
• Lokasi geografis (untuk fitur waktu sholat dan kiblat)
• Log aktivitas

2.3 Informasi dari Pihak Ketiga
• Data dari Google Sign-In (jika Anda login dengan Google)
• Informasi dari layanan analitik

3. BAGAIMANA KAMI MENGGUNAKAN INFORMASI

Kami menggunakan informasi Anda untuk:
• Menyediakan dan meningkatkan layanan
• Mengirim notifikasi waktu sholat
• Personalisasi pengalaman pengguna
• Analisis penggunaan aplikasi
• Komunikasi terkait layanan
• Keamanan dan pencegahan fraud
• Mematuhi kewajiban hukum

4. BERBAGI INFORMASI

Kami TIDAK menjual data pribadi Anda. Kami dapat berbagi informasi dengan:

4.1 Penyedia Layanan
• Hosting dan penyimpanan data
• Layanan analitik (Google Analytics, Firebase)
• Layanan notifikasi push
• Penyedia layanan pembayaran (jika ada)

4.2 Kewajiban Hukum
• Jika diwajibkan oleh hukum
• Untuk melindungi hak dan keamanan kami
• Dalam proses hukum atau investigasi

4.3 Dengan Persetujuan Anda
• Dengan izin eksplisit Anda untuk tujuan tertentu

5. PENYIMPANAN DATA

• Data disimpan di server yang aman
• Kami menggunakan enkripsi untuk melindungi data sensitif
• Data disimpan selama akun aktif atau sesuai kebutuhan hukum
• Anda dapat meminta penghapusan data kapan saja

6. LOKASI PENYIMPANAN DATA

Data Anda dapat disimpan dan diproses di:
• Server di Indonesia
• Server penyedia layanan cloud (AWS, Google Cloud)
• Lokasi lain sesuai penyedia layanan kami

7. HAK ANDA

Anda memiliki hak untuk:
• Mengakses data pribadi Anda
• Memperbaiki data yang tidak akurat
• Menghapus data Anda
• Membatasi pemrosesan data
• Portabilitas data
• Menarik persetujuan
• Mengajukan keberatan

Untuk menggunakan hak-hak ini, hubungi kami di privacy@islamicapp.com

8. KEAMANAN

Kami menerapkan langkah-langkah keamanan:
• Enkripsi data saat transmisi (SSL/TLS)
• Enkripsi data sensitif saat penyimpanan
• Kontrol akses yang ketat
• Audit keamanan berkala
• Pelatihan karyawan tentang privasi

Namun, tidak ada sistem yang 100% aman. Kami tidak dapat menjamin keamanan absolut.

9. COOKIES DAN TEKNOLOGI PELACAKAN

Kami menggunakan:
• Cookies untuk menyimpan preferensi
• Analytics tools untuk memahami penggunaan
• Teknologi fingerprinting perangkat

Anda dapat mengatur preferensi cookies di pengaturan aplikasi.

10. PRIVASI ANAK-ANAK

• Layanan tidak ditujukan untuk anak di bawah 13 tahun
• Kami tidak dengan sengaja mengumpulkan data anak di bawah 13 tahun
• Jika kami menemukan data anak, akan segera dihapus
• Orang tua dapat menghubungi kami untuk menghapus data anak

11. PERUBAHAN KEBIJAKAN

• Kami dapat memperbarui Kebijakan Privasi ini
• Perubahan material akan diberitahukan melalui email atau notifikasi
• Penggunaan berkelanjutan berarti persetujuan terhadap perubahan

12. TRANSFER DATA INTERNASIONAL

Jika data Anda ditransfer ke luar Indonesia:
• Kami memastikan perlindungan yang memadai
• Sesuai dengan standar internasional
• Dengan mekanisme perlindungan yang sesuai

13. KONTAK

Untuk pertanyaan tentang privasi:
• Email: privacy@islamicapp.com
• Alamat: [Alamat Kantor]
• Telepon: +62 XXX XXXX XXXX

Data Protection Officer:
• Email: dpo@islamicapp.com

14. KELUHAN

Jika tidak puas dengan penanganan data Anda, Anda dapat:
• Mengajukan keluhan kepada kami
• Menghubungi otoritas perlindungan data

DENGAN MENGGUNAKAN LAYANAN INI, ANDA MENYETUJUI PENGUMPULAN DAN PENGGUNAAN INFORMASI SESUAI KEBIJAKAN INI.
''';
  }

  // 🆕 Helper: Get Month Name in Indonesian
  String _getMonthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return months[month - 1];
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_agreeTerms) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showMessageToast(
            context,
            message:
                'Anda harus menyetujui Ketentuan Layanan dan Kebijakan Privasi',
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

  final isLoadingGoogle = false;

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
              authState['message']?.toString() ??
              'Pendaftaran berhasil! Selamat bergabung.',
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
                  'Buat Akun',
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
                'Bergabunglah dengan komunitas Islami kami hari ini',
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
                        labelText: 'Nama Lengkap',
                        hintText: 'Masukkan nama lengkap Anda',
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
                          return 'Silakan masukkan nama Anda';
                        }
                        if (value.length < 3) {
                          return 'Nama harus memiliki setidaknya 3 karakter';
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
                        labelText: 'Email',
                        hintText: 'Masukkan email Anda',
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
                          return 'Silakan masukkan email Anda';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Silakan masukkan email yang valid';
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
                        labelText: 'Kata Sandi',
                        hintText: 'Buat kata sandi',
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
                          return 'Silakan masukkan kata sandi';
                        }
                        if (value.length < 6) {
                          return 'Kata sandi harus memiliki setidaknya 6 karakter';
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
                        labelText: 'Konfirmasi Kata Sandi',
                        hintText: 'Masukkan ulang kata sandi',
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
                          return 'Silakan konfirmasi kata sandi Anda';
                        }
                        if (value != _passwordController.text) {
                          return 'Kata sandi tidak cocok';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: _gapMedium(context) - 4),

                    // Terms - 🆕 UPDATED WITH CLICKABLE LINKS
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
                                  const TextSpan(text: 'Saya setuju dengan '),
                                  WidgetSpan(
                                    child: GestureDetector(
                                      onTap: _showTermsOfService,
                                      child: Text(
                                        'Ketentuan Layanan',
                                        style: TextStyle(
                                          color: AppTheme.primaryBlue,
                                          fontWeight: FontWeight.w600,
                                          fontSize:
                                              ResponsiveHelper.adaptiveTextSize(
                                                context,
                                                13,
                                              ),
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const TextSpan(text: ' dan '),
                                  WidgetSpan(
                                    child: GestureDetector(
                                      onTap: _showPrivacyPolicy,
                                      child: Text(
                                        'Kebijakan Privasi',
                                        style: TextStyle(
                                          color: AppTheme.primaryBlue,
                                          fontWeight: FontWeight.w600,
                                          fontSize:
                                              ResponsiveHelper.adaptiveTextSize(
                                                context,
                                                13,
                                              ),
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
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
                                    'Daftar',
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
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Atau daftar dengan',
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
                  onPressed: isLoading
                      ? null
                      : () async {
                          try {
                            await ref
                                .read(authProvider.notifier)
                                .loginWithGoogle();
                          } catch (e) {
                            if (mounted) {
                              showMessageToast(
                                context,
                                message: e.toString().replaceFirst(
                                  'Exception: ',
                                  '',
                                ),
                                type: ToastType.error,
                              );
                            }
                          }
                        },
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
                        'Lanjutkan dengan Google',
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
                    'Sudah punya akun?',
                    style: TextStyle(
                      color: AppTheme.onSurfaceVariant,
                      fontSize: ResponsiveHelper.adaptiveTextSize(context, 14),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/login'),
                    child: Text(
                      ' Masuk',
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
                          'Mulai Perjalananmu',
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
                          'Buat akun untuk mengakses konten dan fitur Islami pilihan.',
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
