import 'package:flutter/material.dart';

/// Dialog untuk menambah anak baru
class AddChildDialog extends StatefulWidget {
  final Function(String name, String email) onAdd;

  const AddChildDialog({super.key, required this.onAdd});

  @override
  State<AddChildDialog> createState() => _AddChildDialogState();
}

class _AddChildDialogState extends State<AddChildDialog> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleAdd() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onAdd(_nameController.text, _emailController.text);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_nameController.text} berhasil ditambahkan!'),
            backgroundColor: const Color(0xFF26A69A),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF26A69A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.person_add,
              color: Color(0xFF26A69A),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Tambah Anak',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            enabled: !_isLoading,
            decoration: InputDecoration(
              labelText: 'Nama Anak',
              hintText: 'Masukkan nama lengkap',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF26A69A),
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            enabled: !_isLoading,
            decoration: InputDecoration(
              labelText: 'Email/Username Anak',
              hintText: 'email@example.com',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF26A69A),
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Batal', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleAdd,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF26A69A),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text('Tambah'),
        ),
      ],
    );
  }
}

/// Dialog untuk mengirim reward ke anak
class RewardDialog extends StatefulWidget {
  final List<String> children;
  final Function(String childName, String message) onSend;

  const RewardDialog({super.key, required this.children, required this.onSend});

  @override
  State<RewardDialog> createState() => _RewardDialogState();
}

class _RewardDialogState extends State<RewardDialog> {
  String? _selectedChild;
  final _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    if (_selectedChild == null || _messageController.text.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onSend(_selectedChild!, _messageController.text);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reward berhasil dikirim ke $_selectedChild!'),
            backgroundColor: const Color(0xFF26A69A),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF26A69A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.card_giftcard,
              color: Color(0xFF26A69A),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Kirim Reward',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedChild,
            decoration: InputDecoration(
              labelText: 'Pilih Anak',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF26A69A),
                  width: 2,
                ),
              ),
            ),
            items: widget.children.map((child) {
              return DropdownMenuItem(value: child, child: Text(child));
            }).toList(),
            onChanged: _isLoading
                ? null
                : (value) {
                    setState(() {
                      _selectedChild = value;
                    });
                  },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _messageController,
            enabled: !_isLoading,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Pesan Semangat',
              hintText: 'Tulis pesan motivasi untuk anak...',
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: Icon(Icons.message_outlined),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF26A69A),
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Batal', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed:
              _isLoading ||
                  _selectedChild == null ||
                  _messageController.text.isEmpty
              ? null
              : _handleSend,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF26A69A),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text('Kirim'),
        ),
      ],
    );
  }
}
