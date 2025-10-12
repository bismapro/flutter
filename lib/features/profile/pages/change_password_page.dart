import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_flutter/core/widgets/toast.dart';
import 'package:test_flutter/features/profile/profile_provider.dart';
import 'package:test_flutter/features/profile/profile_state.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      final currentPassword = _currentPasswordController.text.trim();
      final newPassword = _newPasswordController.text.trim();
      final confirmPassword = _confirmPasswordController.text.trim();

      await ref
          .read(profileProvider.notifier)
          .editPassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
            confirmPassword: confirmPassword,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    // Watch profile state
    final profileState = ref.watch(profileProvider);
    final isLoading = profileState.status == ProfileStatus.loading;

    // Listen to state changes for showing messages
    ref.listen<ProfileState>(profileProvider, (previous, next) {
      if (next.status == ProfileStatus.success && next.message != null) {
        showMessageToast(
          context,
          message: next.message!,
          type: ToastType.success,
          duration: const Duration(seconds: 3),
        );
        ref.read(profileProvider.notifier).clearMessage();
        ref.read(profileProvider.notifier).resetStatus();

        // Clear form fields
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        // Navigate back after successful password change
        Navigator.pop(context, true);
      } else if (next.status == ProfileStatus.error && next.message != null) {
        showMessageToast(
          context,
          message: next.message!,
          type: ToastType.error,
          duration: const Duration(seconds: 4),
        );
        ref.read(profileProvider.notifier).clearMessage();
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Ubah Password',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2D3748),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: isLoading ? null : () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isTablet ? 32.0 : 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Info
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isTablet ? 24 : 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E88E5).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF1E88E5).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.security,
                            color: const Color(0xFF1E88E5),
                            size: isTablet ? 28 : 24,
                          ),
                          SizedBox(width: isTablet ? 16 : 12),
                          Expanded(
                            child: Text(
                              'Keamanan Password',
                              style: TextStyle(
                                fontSize: isTablet ? 20 : 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E88E5),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isTablet ? 12 : 8),
                      Text(
                        'Pastikan password baru Anda kuat dan tidak mudah ditebak. Gunakan kombinasi huruf besar, huruf kecil, angka, dan simbol.',
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          color: const Color(0xFF4A5568),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: isTablet ? 32 : 24),

                // Current Password
                _buildPasswordField(
                  controller: _currentPasswordController,
                  label: 'Password Saat Ini',
                  icon: Icons.lock_outline,
                  isVisible: _showCurrentPassword,
                  enabled: !isLoading,
                  onVisibilityToggle: () {
                    setState(() {
                      _showCurrentPassword = !_showCurrentPassword;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password saat ini harus diisi';
                    }
                    if (value.length < 6) {
                      return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                  isTablet: isTablet,
                ),

                SizedBox(height: isTablet ? 20 : 16),

                // New Password
                _buildPasswordField(
                  controller: _newPasswordController,
                  label: 'Password Baru',
                  icon: Icons.lock,
                  isVisible: _showNewPassword,
                  enabled: !isLoading,
                  onVisibilityToggle: () {
                    setState(() {
                      _showNewPassword = !_showNewPassword;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password baru harus diisi';
                    }
                    if (value.length < 8) {
                      return 'Password baru minimal 8 karakter';
                    }
                    if (!RegExp(
                      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)',
                    ).hasMatch(value)) {
                      return 'Password harus mengandung huruf besar, kecil, dan angka';
                    }
                    if (value == _currentPasswordController.text) {
                      return 'Password baru harus berbeda dari password lama';
                    }
                    return null;
                  },
                  isTablet: isTablet,
                ),

                SizedBox(height: isTablet ? 20 : 16),

                // Confirm Password
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  label: 'Konfirmasi Password Baru',
                  icon: Icons.lock_reset,
                  isVisible: _showConfirmPassword,
                  enabled: !isLoading,
                  onVisibilityToggle: () {
                    setState(() {
                      _showConfirmPassword = !_showConfirmPassword;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Konfirmasi password harus diisi';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Password tidak cocok';
                    }
                    return null;
                  },
                  isTablet: isTablet,
                ),

                SizedBox(height: isTablet ? 32 : 24),

                // Password Strength Indicator
                Container(
                  padding: EdgeInsets.all(isTablet ? 20 : 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tips Password Kuat:',
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2D3748),
                        ),
                      ),
                      SizedBox(height: isTablet ? 12 : 8),
                      _buildPasswordTip('✓ Minimal 8 karakter', isTablet),
                      _buildPasswordTip(
                        '✓ Mengandung huruf besar dan kecil',
                        isTablet,
                      ),
                      _buildPasswordTip('✓ Mengandung angka', isTablet),
                      _buildPasswordTip(
                        '✓ Mengandung simbol (!@#\$%^&*)',
                        isTablet,
                      ),
                      _buildPasswordTip(
                        '✓ Berbeda dari password sebelumnya',
                        isTablet,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: isTablet ? 40 : 32),

                // Change Password Button
                SizedBox(
                  width: double.infinity,
                  height: isTablet ? 56 : 48,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _changePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      disabledForegroundColor: Colors.grey[500],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: isLoading ? 0 : 2,
                    ),
                    child: isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: isTablet ? 20 : 18,
                                height: isTablet ? 20 : 18,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: isTablet ? 12 : 10),
                              Text(
                                'Mengubah Password...',
                                style: TextStyle(
                                  fontSize: isTablet ? 18 : 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.lock_reset, size: isTablet ? 22 : 20),
                              SizedBox(width: isTablet ? 10 : 8),
                              Text(
                                'Ubah Password',
                                style: TextStyle(
                                  fontSize: isTablet ? 18 : 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                SizedBox(height: isTablet ? 20 : 16),

                // Cancel Button
                SizedBox(
                  width: double.infinity,
                  height: isTablet ? 56 : 48,
                  child: OutlinedButton(
                    onPressed: isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1E88E5),
                      side: BorderSide(
                        color: isLoading
                            ? Colors.grey[300]!
                            : const Color(0xFF1E88E5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Batal',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isVisible,
    required VoidCallback onVisibilityToggle,
    String? Function(String?)? validator,
    required bool isTablet,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      validator: validator,
      enabled: enabled,
      style: TextStyle(
        fontSize: isTablet ? 18 : 16,
        color: enabled ? const Color(0xFF2D3748) : Colors.grey[600],
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: enabled ? const Color(0xFF1E88E5) : Colors.grey[400],
          size: isTablet ? 24 : 20,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: enabled ? const Color(0xFF4A5568) : Colors.grey[400],
            size: isTablet ? 24 : 20,
          ),
          onPressed: enabled ? onVisibilityToggle : null,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: enabled ? Colors.grey[50] : Colors.grey[100],
        contentPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? 20 : 16,
          vertical: isTablet ? 20 : 16,
        ),
        labelStyle: TextStyle(
          color: enabled ? const Color(0xFF4A5568) : Colors.grey[500],
          fontSize: isTablet ? 16 : 14,
        ),
      ),
    );
  }

  Widget _buildPasswordTip(String tip, bool isTablet) {
    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 8 : 4),
      child: Text(
        tip,
        style: TextStyle(
          fontSize: isTablet ? 14 : 12,
          color: const Color(0xFF4A5568),
        ),
      ),
    );
  }
}
