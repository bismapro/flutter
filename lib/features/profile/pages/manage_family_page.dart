import 'package:flutter/material.dart';
import 'package:test_flutter/features/compass/pages/compass_page.dart';

class FamilyMember {
  final String id;
  final String name;
  final int age;
  final String role;
  final String avatar;
  final bool isActive;

  const FamilyMember({
    required this.id,
    required this.name,
    required this.age,
    required this.role,
    required this.avatar,
    this.isActive = true,
  });
}

class ManageFamilyPage extends StatefulWidget {
  const ManageFamilyPage({super.key});

  @override
  State<ManageFamilyPage> createState() => _ManageFamilyPageState();
}

class _ManageFamilyPageState extends State<ManageFamilyPage> {
  List<FamilyMember> familyMembers = [
    const FamilyMember(
      id: '1',
      name: 'Ahmad Fauzan',
      age: 35,
      role: 'Ayah',
      avatar: '👨‍💼',
    ),
    const FamilyMember(
      id: '2',
      name: 'Siti Aminah',
      age: 32,
      role: 'Ibu',
      avatar: '👩‍💼',
    ),
    const FamilyMember(
      id: '3',
      name: 'Ahmad',
      age: 15,
      role: 'Anak',
      avatar: '👦',
    ),
    const FamilyMember(
      id: '4',
      name: 'Fatimah',
      age: 12,
      role: 'Anak',
      avatar: '👧',
    ),
    const FamilyMember(
      id: '5',
      name: 'Ali',
      age: 8,
      role: 'Anak',
      avatar: '👶',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isLargeScreen = screenWidth > 800;

    // Responsive values
    final horizontalPadding = isLargeScreen ? 32.0 : (isTablet ? 24.0 : 20.0);
    final cardPadding = isTablet ? 20.0 : 16.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Kelola Keluarga',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isTablet ? 22 : 20,
          ),
        ),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add, size: isTablet ? 28 : 24),
            onPressed: () => _showAddMemberDialog(context),
            tooltip: 'Tambah Anggota',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Info
            Container(
              width: double.infinity,
              margin: EdgeInsets.all(horizontalPadding),
              padding: EdgeInsets.all(cardPadding),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E88E5), Color(0xFF26A69A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.family_restroom,
                        color: Colors.white,
                        size: isTablet ? 32 : 28,
                      ),
                      SizedBox(width: isTablet ? 16 : 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Anggota Keluarga',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: isTablet ? 16 : 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${familyMembers.length} Orang',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isTablet ? 24 : 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isTablet ? 16 : 12),
                  Text(
                    'Kelola anggota keluarga untuk monitoring ibadah yang lebih baik',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: isTablet ? 15 : 13,
                    ),
                  ),
                ],
              ),
            ),

            // Family Members List
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Anggota Keluarga',
                      style: TextStyle(
                        fontSize: isTablet ? 20 : 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                    SizedBox(height: isTablet ? 16 : 12),

                    // Family Members Cards
                    ...familyMembers.map(
                      (member) => Container(
                        constraints: BoxConstraints(
                          maxWidth: isLargeScreen ? 600 : double.infinity,
                        ),
                        margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
                        child: _buildMemberCard(
                          member,
                          isTablet,
                          isLargeScreen,
                        ),
                      ),
                    ),

                    SizedBox(height: isTablet ? 24 : 20),

                    // Add Member Button
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: isLargeScreen ? 600 : double.infinity,
                      ),
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showAddMemberDialog(context),
                        icon: Icon(Icons.person_add, size: isTablet ? 24 : 20),
                        label: Text(
                          'Tambah Anggota Keluarga',
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1E88E5),
                          side: const BorderSide(
                            color: Color(0xFF1E88E5),
                            width: 2,
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: isTablet ? 16 : 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: isTablet ? 32 : 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberCard(
    FamilyMember member,
    bool isTablet,
    bool isLargeScreen,
  ) {
    final cardPadding = isTablet ? 20.0 : 16.0;
    final avatarSize = isTablet ? 60.0 : 50.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Row(
          children: [
            // Avatar
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                color: _getRoleColor(member.role).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  member.avatar,
                  style: TextStyle(fontSize: isTablet ? 28 : 24),
                ),
              ),
            ),

            SizedBox(width: isTablet ? 16 : 12),

            // Member Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D3748),
                    ),
                  ),
                  SizedBox(height: isTablet ? 6 : 4),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 10 : 8,
                          vertical: isTablet ? 6 : 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getRoleColor(member.role),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          member.role,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 12 : 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: isTablet ? 12 : 8),
                      Text(
                        '${member.age} tahun',
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          color: const Color(0xFF4A5568),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                size: isTablet ? 24 : 20,
                color: const Color(0xFF4A5568),
              ),
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _showEditMemberDialog(context, member);
                    break;
                  case 'delete':
                    _showDeleteConfirmation(context, member);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                if (member.role != 'Ayah' && member.role != 'Ibu')
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Hapus', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Ayah':
        return const Color(0xFF1E88E5);
      case 'Ibu':
        return const Color(0xFF26A69A);
      case 'Anak':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  void _showAddMemberDialog(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    final nameController = TextEditingController();
    final ageController = TextEditingController();
    String selectedRole = 'Anak';
    String selectedAvatar = '👶';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Tambah Anggota Keluarga',
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: isTablet ? 400 : 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Avatar Selection
                Text(
                  'Pilih Avatar:',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: isTablet ? 12 : 8),
                Wrap(
                  spacing: isTablet ? 12 : 8,
                  children: ['👦', '👧', '👶', '🧒', '👨', '👩'].map((avatar) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedAvatar = avatar;
                        });
                      },
                      child: Container(
                        width: isTablet ? 50 : 40,
                        height: isTablet ? 50 : 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selectedAvatar == avatar
                                ? const Color(0xFF1E88E5)
                                : Colors.grey[300]!,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            avatar,
                            style: TextStyle(fontSize: isTablet ? 24 : 20),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: isTablet ? 20 : 16),

                // Name Field
                TextField(
                  controller: nameController,
                  style: TextStyle(fontSize: isTablet ? 16 : 14),
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.person_outline),
                    labelStyle: TextStyle(fontSize: isTablet ? 16 : 14),
                  ),
                ),

                SizedBox(height: isTablet ? 16 : 12),

                // Age Field
                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: isTablet ? 16 : 14),
                  decoration: InputDecoration(
                    labelText: 'Usia',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.cake_outlined),
                    labelStyle: TextStyle(fontSize: isTablet ? 16 : 14),
                  ),
                ),

                SizedBox(height: isTablet ? 16 : 12),

                // Role Dropdown
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: const Color(0xFF2D3748),
                  ),
                  decoration: InputDecoration(
                    labelText: 'Peran',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.family_restroom),
                    labelStyle: TextStyle(fontSize: isTablet ? 16 : 14),
                  ),
                  items: ['Anak', 'Ayah', 'Ibu', 'Kakek', 'Nenek'].map((role) {
                    return DropdownMenuItem(value: role, child: Text(role));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: TextStyle(fontSize: isTablet ? 16 : 14),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    ageController.text.isNotEmpty) {
                  final newMember = FamilyMember(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    age: int.parse(ageController.text),
                    role: selectedRole,
                    avatar: selectedAvatar,
                  );

                  this.setState(() {
                    familyMembers.add(newMember);
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${nameController.text} berhasil ditambahkan!',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: Text(
                'Tambah',
                style: TextStyle(fontSize: isTablet ? 16 : 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditMemberDialog(BuildContext context, FamilyMember member) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    final nameController = TextEditingController(text: member.name);
    final ageController = TextEditingController(text: member.age.toString());
    String selectedRole = member.role;
    String selectedAvatar = member.avatar;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Edit Anggota Keluarga',
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: isTablet ? 400 : 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Avatar Selection
                Text(
                  'Pilih Avatar:',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: isTablet ? 12 : 8),
                Wrap(
                  spacing: isTablet ? 12 : 8,
                  children: ['👦', '👧', '👶', '🧒', '👨', '👩'].map((avatar) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedAvatar = avatar;
                        });
                      },
                      child: Container(
                        width: isTablet ? 50 : 40,
                        height: isTablet ? 50 : 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selectedAvatar == avatar
                                ? const Color(0xFF1E88E5)
                                : Colors.grey[300]!,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            avatar,
                            style: TextStyle(fontSize: isTablet ? 24 : 20),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: isTablet ? 20 : 16),

                // Name Field
                TextField(
                  controller: nameController,
                  style: TextStyle(fontSize: isTablet ? 16 : 14),
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.person_outline),
                    labelStyle: TextStyle(fontSize: isTablet ? 16 : 14),
                  ),
                ),

                SizedBox(height: isTablet ? 16 : 12),

                // Age Field
                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: isTablet ? 16 : 14),
                  decoration: InputDecoration(
                    labelText: 'Usia',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.cake_outlined),
                    labelStyle: TextStyle(fontSize: isTablet ? 16 : 14),
                  ),
                ),

                SizedBox(height: isTablet ? 16 : 12),

                // Role Dropdown
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: const Color(0xFF2D3748),
                  ),
                  decoration: InputDecoration(
                    labelText: 'Peran',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.family_restroom),
                    labelStyle: TextStyle(fontSize: isTablet ? 16 : 14),
                  ),
                  items: ['Anak', 'Ayah', 'Ibu', 'Kakek', 'Nenek'].map((role) {
                    return DropdownMenuItem(value: role, child: Text(role));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: TextStyle(fontSize: isTablet ? 16 : 14),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    ageController.text.isNotEmpty) {
                  final updatedMember = FamilyMember(
                    id: member.id,
                    name: nameController.text,
                    age: int.parse(ageController.text),
                    role: selectedRole,
                    avatar: selectedAvatar,
                  );

                  this.setState(() {
                    final index = familyMembers.indexWhere(
                      (m) => m.id == member.id,
                    );
                    if (index != -1) {
                      familyMembers[index] = updatedMember;
                    }
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data anggota berhasil diperbarui!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: Text(
                'Simpan',
                style: TextStyle(fontSize: isTablet ? 16 : 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, FamilyMember member) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Hapus Anggota',
          style: TextStyle(
            fontSize: isTablet ? 20 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus ${member.name} dari keluarga?',
          style: TextStyle(fontSize: isTablet ? 16 : 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: TextStyle(fontSize: isTablet ? 16 : 14),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                familyMembers.removeWhere((m) => m.id == member.id);
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${member.name} berhasil dihapus dari keluarga',
                  ),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Hapus',
              style: TextStyle(fontSize: isTablet ? 16 : 14),
            ),
          ),
        ],
      ),
    );
  }
}
