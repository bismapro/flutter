import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;
import 'package:test_flutter/app/theme.dart';
import 'package:test_flutter/data/models/quran/juz.dart';
import 'package:test_flutter/features/quran/widgets/ayah_card.dart';

class JuzDetailPage extends StatefulWidget {
  final Juz juz;
  final List<Juz> allJuz;

  const JuzDetailPage({super.key, required this.juz, this.allJuz = const []});

  @override
  State<JuzDetailPage> createState() => _JuzDetailPageState();
}

class _JuzDetailPageState extends State<JuzDetailPage>
    with SingleTickerProviderStateMixin {
  int _currentJuzIndex = 0;

  late TabController _tabController;
  late PageController _pageController;
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _verseKeys = {};

  bool get _showTabs => widget.allJuz.isNotEmpty && widget.allJuz.length > 1;

  @override
  void initState() {
    super.initState();

    if (_showTabs) {
      final initialIndex = widget.allJuz.indexWhere(
        (j) => j.number == widget.juz.number,
      );

      _currentJuzIndex = initialIndex >= 0 ? initialIndex : 0;

      print('📖 Initializing with juz: ${widget.juz.number}');
      print('📖 Initial index: $_currentJuzIndex');
      print('📖 Total juz: ${widget.allJuz.length}');

      _tabController = TabController(
        length: widget.allJuz.length,
        vsync: this,
        initialIndex: _currentJuzIndex,
      );
      _pageController = PageController(initialPage: _currentJuzIndex);

      _tabController.addListener(() {
        if (_tabController.indexIsChanging) {
          _pageController.animateToPage(
            _tabController.index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    } else {
      print('📖 Single juz mode: ${widget.juz.number}');
    }
  }

  @override
  void dispose() {
    if (_showTabs) {
      _tabController.dispose();
      _pageController.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  Juz get _currentJuz =>
      _showTabs ? widget.allJuz[_currentJuzIndex] : widget.juz;

  int _getTotalVersesInJuz(int juzNumber) {
    final juzData = quran.getSurahAndVersesFromJuz(juzNumber);
    int total = 0;
    for (var verseRange in juzData.values) {
      // Calculate actual number of verses from range [start, end]
      final startVerse = verseRange.first;
      final endVerse = verseRange.last;
      total += (endVerse - startVerse + 1);
    }
    return total;
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentJuzIndex = index;
    });
    _tabController.animateTo(index);

    print('📖 Changed to juz: ${_currentJuz.number}');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1024;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryBlue.withOpacity(0.03),
              AppTheme.backgroundWhite,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(isTablet, isDesktop),
              if (_showTabs) _buildTabBar(),
              Expanded(
                child: _showTabs
                    ? PageView.builder(
                        controller: _pageController,
                        itemCount: widget.allJuz.length,
                        onPageChanged: _onPageChanged,
                        itemBuilder: (context, index) {
                          final currentJuz = widget.allJuz[index];
                          return _buildAyahsList(
                            currentJuz,
                            isTablet,
                            isDesktop,
                          );
                        },
                      )
                    : _buildAyahsList(_currentJuz, isTablet, isDesktop),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isTablet, bool isDesktop) {
    final totalVerses = _getTotalVersesInJuz(_currentJuz.number);

    return Container(
      padding: EdgeInsets.all(isTablet ? 14 : 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isDesktop
                ? 48
                : isTablet
                ? 44
                : 40,
            height: isDesktop
                ? 48
                : isTablet
                ? 44
                : 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryBlue.withOpacity(0.1),
                  AppTheme.accentGreen.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
              color: AppTheme.primaryBlue,
              iconSize: isTablet ? 20 : 18,
            ),
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Juz ${_currentJuz.number}',
                  style: GoogleFonts.poppins(
                    fontSize: isDesktop
                        ? 22
                        : isTablet
                        ? 21
                        : 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  '$totalVerses Ayat • ${_currentJuz.startSurahName} - ${_currentJuz.endSurahName}',
                  style: GoogleFonts.poppins(
                    fontSize: isTablet ? 14 : 13,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryBlue.withOpacity(0.1),
                  AppTheme.accentGreen.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${_currentJuz.number}',
              style: GoogleFonts.poppins(
                fontSize: isDesktop
                    ? 24
                    : isTablet
                    ? 22
                    : 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: AppTheme.accentGreen,
        indicatorWeight: 3,
        labelColor: AppTheme.primaryBlue,
        unselectedLabelColor: AppTheme.onSurfaceVariant,
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        dividerColor: Colors.transparent,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        tabs: widget.allJuz.map((juz) {
          return Tab(
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryBlue.withOpacity(0.1),
                        AppTheme.accentGreen.withOpacity(0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${juz.number}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('Juz ${juz.number}'),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAyahsList(Juz juz, bool isTablet, bool isDesktop) {
    _verseKeys.clear();

    // Get juz data: Map<int surahNumber, List<int> verses>
    final juzData = quran.getSurahAndVersesFromJuz(juz.number);

    return ListView.builder(
      key: ValueKey('juz_${juz.number}'),
      controller: _scrollController,
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 20,
        vertical: isTablet ? 12 : 8,
      ),
      physics: const BouncingScrollPhysics(),
      itemCount: juzData.length,
      itemBuilder: (context, surahIndex) {
        final surahNumber = juzData.keys.elementAt(surahIndex);
        final verseRange = juzData[surahNumber]!;

        // Generate full list of verses from range [start, end]
        final startVerse = verseRange.first;
        final endVerse = verseRange.last;
        final verses = List.generate(
          endVerse - startVerse + 1,
          (i) => startVerse + i,
        );

        print(
          '📝 Surah $surahNumber: Range $verseRange -> Full verses: $verses',
        );

        return Column(
          children: [
            // Surah Header
            Container(
              margin: const EdgeInsets.only(bottom: 16, top: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryBlue.withOpacity(0.1),
                    AppTheme.accentGreen.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$surahNumber',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quran.getSurahName(surahNumber),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.onSurface,
                          ),
                        ),
                        Text(
                          '${verses.length} Ayat • Ayat ${verses.first} - ${verses.last}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    quran.getSurahNameArabic(surahNumber),
                    style: GoogleFonts.amiriQuran(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),

            // Verses - Loop through ALL verses
            ...verses.map((verseNumber) {
              final verseKey = '${surahNumber}_$verseNumber';
              _verseKeys[verseKey] = GlobalKey();

              final arabicText = quran.getVerse(
                surahNumber,
                verseNumber,
                verseEndSymbol: false,
              );
              final translation = quran.getVerseTranslation(
                surahNumber,
                verseNumber,
                translation: quran.Translation.indonesian,
              );
              final verseEndSymbol = quran.getVerseEndSymbol(verseNumber);

              return AyahCard(
                key: _verseKeys[verseKey],
                verseNumber: verseNumber,
                arabicText: arabicText,
                translation: translation,
                verseEndSymbol: verseEndSymbol,
                onPlayVerse: () {},
                isTablet: isTablet,
                isDesktop: isDesktop,
                isPlaying: false,
              );
            }).toList(),
          ],
        );
      },
    );
  }
}
