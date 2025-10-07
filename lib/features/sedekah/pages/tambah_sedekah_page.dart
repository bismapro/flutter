import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test_flutter/app/theme.dart';
import 'package:test_flutter/core/utils/responsive_helper.dart';

class TambahSedekahPage extends StatefulWidget {
  const TambahSedekahPage({super.key});

  @override
  State<TambahSedekahPage> createState() => _TambahSedekahPageState();
}

class _TambahSedekahPageState extends State<TambahSedekahPage> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  // Responsive utils
  double _scale(BuildContext c) {
    if (ResponsiveHelper.isSmallScreen(c)) return .9;
    if (ResponsiveHelper.isMediumScreen(c)) return 1.0;
    if (ResponsiveHelper.isLargeScreen(c)) return 1.1;
    return 1.2;
  }

  double _px(BuildContext c, double base) => base * _scale(c);
  double _ts(BuildContext c, double base) =>
      ResponsiveHelper.adaptiveTextSize(c, base);

  double _maxWidth(BuildContext c) {
    if (ResponsiveHelper.isExtraLargeScreen(c)) return 820;
    if (ResponsiveHelper.isLargeScreen(c)) return 680;
    return double.infinity;
  }

  EdgeInsets _hpad(BuildContext c) => EdgeInsets.symmetric(
    horizontal: ResponsiveHelper.getResponsivePadding(c).left,
  );

  final List<String> _types = const [
    'Sedekah Pagi',
    'Sedekah Siang',
    'Sedekah Sore',
    'Sedekah Malam',
    'Sedekah Jumat',
    'Sedekah Subuh',
    'Sedekah Dzuhur',
    'Sedekah Ashar',
    'Sedekah Maghrib',
    'Sedekah Isya',
    'Lainnya',
  ];

  @override
  void dispose() {
    _typeController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppTheme.primaryBlue,
            onPrimary: Colors.white,
            onSurface: AppTheme.onSurface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'date': _selectedDate,
        'amount': int.parse(_amountController.text.replaceAll('.', '')),
        'type': _typeController.text,
        'note': _noteController.text,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryBlue.withValues(alpha: 0.03),
              AppTheme.backgroundWhite,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: _maxWidth(context)),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(_px(context, 16)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                          spreadRadius: -5,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryBlue.withValues(alpha: 0.1),
                                AppTheme.accentGreen.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back_rounded),
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tambah Sedekah',
                                style: TextStyle(
                                  fontSize: _ts(context, 20),
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.onSurface,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              Text(
                                'Catat sedekah Anda',
                                style: TextStyle(
                                  fontSize: _ts(context, 13),
                                  color: AppTheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Form
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: _hpad(
                        context,
                      ).add(EdgeInsets.symmetric(vertical: _px(context, 18))),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Jenis
                            Text(
                              'Jenis Sedekah',
                              style: TextStyle(
                                fontSize: _ts(context, 15),
                                fontWeight: FontWeight.w600,
                                color: AppTheme.onSurface,
                              ),
                            ),
                            SizedBox(height: _px(context, 10)),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppTheme.primaryBlue.withValues(
                                    alpha: 0.1,
                                  ),
                                ),
                              ),
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  hintText: 'Pilih jenis sedekah',
                                  prefixIcon: const Icon(
                                    Icons.category_rounded,
                                    color: AppTheme.primaryBlue,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: _px(context, 20),
                                    vertical: _px(context, 14),
                                  ),
                                ),
                                items: _types
                                    .map(
                                      (t) => DropdownMenuItem(
                                        value: t,
                                        child: Text(t),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) =>
                                    _typeController.text = v ?? '',
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'Pilih jenis sedekah'
                                    : null,
                              ),
                            ),

                            SizedBox(height: _px(context, 16)),

                            // Tanggal
                            Text(
                              'Tanggal Sedekah',
                              style: TextStyle(
                                fontSize: _ts(context, 15),
                                fontWeight: FontWeight.w600,
                                color: AppTheme.onSurface,
                              ),
                            ),
                            SizedBox(height: _px(context, 10)),
                            InkWell(
                              onTap: _pickDate,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: _px(context, 20),
                                  vertical: _px(context, 14),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppTheme.primaryBlue.withValues(
                                      alpha: 0.1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      color: AppTheme.primaryBlue,
                                      size: _px(context, 22),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      DateFormat(
                                        'dd MMMM yyyy',
                                        'id_ID',
                                      ).format(_selectedDate),
                                      style: TextStyle(
                                        fontSize: _ts(context, 15),
                                        color: AppTheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: _px(context, 16)),

                            // Nominal
                            Text(
                              'Nominal Sedekah',
                              style: TextStyle(
                                fontSize: _ts(context, 15),
                                fontWeight: FontWeight.w600,
                                color: AppTheme.onSurface,
                              ),
                            ),
                            SizedBox(height: _px(context, 10)),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppTheme.accentGreen.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                              ),
                              child: TextFormField(
                                controller: _amountController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'Masukkan nominal',
                                  prefixIcon: const Icon(
                                    Icons.payments_rounded,
                                    color: AppTheme.accentGreen,
                                  ),
                                  prefixText: 'Rp ',
                                  prefixStyle: TextStyle(
                                    color: AppTheme.onSurface,
                                    fontSize: _ts(context, 15),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: _px(context, 20),
                                    vertical: _px(context, 14),
                                  ),
                                ),
                                onChanged: (value) {
                                  final clean = value.replaceAll('.', '');
                                  if (clean.isNotEmpty) {
                                    final f = NumberFormat('#,###', 'id_ID');
                                    final formatted = f.format(
                                      int.parse(clean),
                                    );
                                    _amountController.value = TextEditingValue(
                                      text: formatted,
                                      selection: TextSelection.collapsed(
                                        offset: formatted.length,
                                      ),
                                    );
                                  }
                                },
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'Masukkan nominal sedekah'
                                    : null,
                              ),
                            ),

                            SizedBox(height: _px(context, 16)),

                            // Catatan
                            Text(
                              'Catatan (Opsional)',
                              style: TextStyle(
                                fontSize: _ts(context, 15),
                                fontWeight: FontWeight.w600,
                                color: AppTheme.onSurface,
                              ),
                            ),
                            SizedBox(height: _px(context, 10)),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppTheme.primaryBlue.withValues(
                                    alpha: 0.1,
                                  ),
                                ),
                              ),
                              child: TextFormField(
                                controller: _noteController,
                                maxLines: 4,
                                decoration: InputDecoration(
                                  hintText: 'Tulis catatan...',
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.only(
                                      bottom: _px(context, 60),
                                    ),
                                    child: const Icon(
                                      Icons.note_alt_rounded,
                                      color: AppTheme.primaryBlue,
                                    ),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: _px(context, 20),
                                    vertical: _px(context, 14),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: _px(context, 24)),

                            // Save Button
                            SizedBox(
                              height: _px(context, 52),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.primaryBlue,
                                      AppTheme.accentGreen,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryBlue.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: _save,
                                  icon: const Icon(
                                    Icons.save_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  label: Text(
                                    'Simpan Sedekah',
                                    style: TextStyle(
                                      fontSize: _ts(context, 16),
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
  }
}
