import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_flutter/core/widgets/toast.dart';
import 'package:test_flutter/features/auth/auth_provider.dart';
import 'package:test_flutter/features/profile/profile_provider.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() {
    // Load profile data from storage first

    // Listen to profile state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).loadUser();
      final profileState = ref.read(profileProvider);
      final profile =
          profileState['profile']['user'] ?? profileState['profile'];

      if (profile != null) {
        _nameController.text = profile['name']?.toString() ?? '';
        _emailController.text = profile['email']?.toString() ?? '';
        _phoneController.text = profile['phone']?.toString() ?? '';
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final phone = _phoneController.text.trim();
      ref.read(profileProvider.notifier).updateProfile(name, email, phone);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    // Watch profile state
    final profileState = ref.watch(profileProvider);
    final isLoading = profileState['status'] == ProfileState.loading;
    final error = profileState['error'];

    if (profileState['status'] == ProfileState.error && error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showMessageToast(
          context,
          message: error.toString(),
          type: ToastType.error,
          duration: const Duration(seconds: 4),
        );
        ref.read(profileProvider.notifier).clearError();
      });
    }

    if (profileState['status'] == ProfileState.success) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showMessageToast(
          context,
          message: 'Profile updated successfully',
          type: ToastType.success,
          duration: const Duration(seconds: 3),
        );
        ref.read(profileProvider.notifier).clearSuccess();
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2D3748),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isTablet ? 32.0 : 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Avatar Section
                // Center(
                //   child: Stack(
                //     children: [
                //       Container(
                //         width: isTablet ? 120 : 100,
                //         height: isTablet ? 120 : 100,
                //         decoration: const BoxDecoration(
                //           shape: BoxShape.circle,
                //           gradient: LinearGradient(
                //             colors: [Color(0xFF1E88E5), Color(0xFF26A69A)],
                //             begin: Alignment.topLeft,
                //             end: Alignment.bottomRight,
                //           ),
                //         ),
                //         child: Icon(
                //           Icons.person,
                //           size: isTablet ? 60 : 50,
                //           color: Colors.white,
                //         ),
                //       ),
                //       Positioned(
                //         bottom: 0,
                //         right: 0,
                //         child: Container(
                //           width: isTablet ? 40 : 32,
                //           height: isTablet ? 40 : 32,
                //           decoration: BoxDecoration(
                //             color: const Color(0xFF1E88E5),
                //             shape: BoxShape.circle,
                //             border: Border.all(color: Colors.white, width: 2),
                //           ),
                //           child: Icon(
                //             Icons.camera_alt,
                //             size: isTablet ? 20 : 16,
                //             color: Colors.white,
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                SizedBox(height: isTablet ? 32 : 24),

                // Form Fields
                _buildTextField(
                  controller: _nameController,
                  label: 'Nama Lengkap',
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    return null;
                  },
                  isTablet: isTablet,
                ),

                SizedBox(height: isTablet ? 20 : 16),

                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Email tidak valid';
                    }
                    return null;
                  },
                  isTablet: isTablet,
                ),

                SizedBox(height: isTablet ? 20 : 16),

                _buildTextField(
                  controller: _phoneController,
                  label: 'Nomor Telepon',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nomor telepon tidak boleh kosong';
                    }
                    return null;
                  },
                  isTablet: isTablet,
                ),

                SizedBox(height: isTablet ? 40 : 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: isTablet ? 56 : 48,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: isLoading
                        ? SizedBox(
                            width: isTablet ? 24 : 20,
                            height: isTablet ? 24 : 20,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Simpan Perubahan',
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    required bool isTablet,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(
        fontSize: isTablet ? 18 : 16,
        color: const Color(0xFF2D3748),
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF1E88E5),
          size: isTablet ? 24 : 20,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? 20 : 16,
          vertical: isTablet ? 20 : 16,
        ),
        labelStyle: TextStyle(
          color: const Color(0xFF4A5568),
          fontSize: isTablet ? 16 : 14,
        ),
      ),
    );
  }
}
