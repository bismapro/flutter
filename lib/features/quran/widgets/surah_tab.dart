import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test_flutter/app/theme.dart';
import 'package:test_flutter/data/models/quran/surah.dart';
import 'package:test_flutter/features/quran/pages/surah_detail_page.dart';

class SurahTab extends StatefulWidget {
  const SurahTab({super.key});

  @override
  State<SurahTab> createState() => _SurahTabState();
}

class _SurahTabState extends State<SurahTab> {
  List<Surah> _surahs = [];
  List<Surah> _filteredSurahs = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  List<Surah>? _cachedUpdatedSurahs;

  @override
  void initState() {
    super.initState();
    _loadSurahsFromJson();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSurahsFromJson() async {
    try {
      // Load JSON file from assets
      final String jsonString = await rootBundle.loadString(
        'assets/quran/surah.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Parse surat_list
      final List<dynamic> suratList = jsonData['surat_list'];

      // Convert to Surah objects
      final List<Surah> surahs = suratList.map((item) {
        return Surah(
          nomor: item['nomor'],
          nama: item['nama'],
          namaLatin: item['namaLatin'],
          jumlahAyat: item['jumlahAyat'],
          tempatTurun: item['tempatTurun'],
          arti: item['arti'],
          deskripsi: item['deskripsi'],
          audioFull: Map<String, String>.from(item['audioFull']),
        );
      }).toList();

      if (mounted) {
        setState(() {
          _surahs = surahs;
          _filteredSurahs = surahs;
          _cachedUpdatedSurahs = surahs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading surahs: $e'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _filterSurahs(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSurahs = _surahs;
      } else {
        _filteredSurahs = _surahs.where((surah) {
          return surah.nama.toLowerCase().contains(query.toLowerCase()) ||
              surah.namaLatin.toLowerCase().contains(query.toLowerCase()) ||
              surah.arti.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1024;

    return Column(
      children: [
        // Search Bar
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: isDesktop
                ? 32.0
                : isTablet
                ? 28.0
                : 24.0,
            vertical: isTablet ? 16 : 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isTablet ? 18 : 16),
            border: Border.all(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
                spreadRadius: -5,
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _filterSurahs,
            style: TextStyle(fontSize: isTablet ? 16 : 15),
            decoration: InputDecoration(
              hintText: 'Cari surat...',
              hintStyle: TextStyle(
                color: AppTheme.onSurfaceVariant.withValues(alpha: 0.6),
                fontSize: isTablet ? 16 : 15,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: AppTheme.primaryBlue,
                size: isTablet ? 26 : 24,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: AppTheme.onSurfaceVariant,
                        size: isTablet ? 24 : 22,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        _filterSurahs('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isTablet ? 24 : 20,
                vertical: isTablet ? 18 : 16,
              ),
            ),
          ),
        ),

        // Surahs List
        Expanded(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryBlue),
                )
              : _filteredSurahs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(isTablet ? 28 : 24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryBlue.withValues(alpha: 0.1),
                              AppTheme.accentGreen.withValues(alpha: 0.1),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.search_off_rounded,
                          size: isDesktop
                              ? 72
                              : isTablet
                              ? 68
                              : 64,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      SizedBox(height: isTablet ? 28 : 24),
                      Text(
                        'Tidak ada surat ditemukan',
                        style: TextStyle(
                          fontSize: isTablet ? 20 : 18,
                          color: AppTheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: isTablet ? 10 : 8),
                      Text(
                        'Coba kata kunci lain',
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : isDesktop
              ? GridView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 40 : 20,
                    vertical: isTablet ? 16 : 8,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: screenWidth > 1400 ? 3 : 2,
                    childAspectRatio: 4.0,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _filteredSurahs.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final surah = _filteredSurahs[index];
                    return _buildSurahCard(surah, isTablet, isDesktop);
                  },
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 24 : 20,
                    vertical: isTablet ? 12 : 8,
                  ),
                  itemCount: _filteredSurahs.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final surah = _filteredSurahs[index];
                    return _buildSurahCard(surah, isTablet, isDesktop);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSurahCard(Surah surah, bool isTablet, bool isDesktop) {
    return GestureDetector(
      onTap: () {
        print('📖 Opening Surah: ${surah.nomor} - ${surah.namaLatin}');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SurahDetailPage(
              surah: surah,
              allSurahs: _cachedUpdatedSurahs ?? [],
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: isTablet ? 18 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isTablet ? 22 : 20),
          border: Border.all(
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
              spreadRadius: -5,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(
            isDesktop
                ? 22
                : isTablet
                ? 20
                : 18,
          ),
          child: Row(
            children: [
              // Surah Number with gradient
              Container(
                width: isDesktop
                    ? 56
                    : isTablet
                    ? 54
                    : 52,
                height: isDesktop
                    ? 56
                    : isTablet
                    ? 54
                    : 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryBlue.withValues(alpha: 0.15),
                      AppTheme.accentGreen.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: isDesktop
                          ? 56
                          : isTablet
                          ? 54
                          : 52,
                      color: AppTheme.primaryBlue.withValues(alpha: 0.25),
                    ),
                    Text(
                      surah.nomor.toString(),
                      style: TextStyle(
                        fontSize: isTablet ? 19 : 17,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: isTablet ? 18 : 16),

              // Surah Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      surah.namaLatin,
                      style: TextStyle(
                        fontSize: isDesktop
                            ? 19
                            : isTablet
                            ? 18
                            : 17,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurface,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isTablet ? 8 : 6),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 10 : 8,
                            vertical: isTablet ? 5 : 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              isTablet ? 7 : 6,
                            ),
                          ),
                          child: Text(
                            surah.tempatTurun.toUpperCase(),
                            style: TextStyle(
                              fontSize: isTablet ? 12 : 11,
                              color: AppTheme.accentGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: isTablet ? 10 : 8),
                        Icon(
                          Icons.circle,
                          size: isTablet ? 5 : 4,
                          color: AppTheme.onSurfaceVariant,
                        ),
                        SizedBox(width: isTablet ? 10 : 8),
                        Flexible(
                          child: Text(
                            '${surah.jumlahAyat} Ayat',
                            style: TextStyle(
                              fontSize: isTablet ? 14 : 13,
                              color: AppTheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(width: isTablet ? 16 : 12),

              // Arabic Name
              Text(
                surah.nama,
                style: TextStyle(
                  fontSize: isDesktop
                      ? 26
                      : isTablet
                      ? 24
                      : 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
