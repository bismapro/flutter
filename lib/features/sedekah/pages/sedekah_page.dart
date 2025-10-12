import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:test_flutter/app/theme.dart';
import 'package:test_flutter/core/utils/responsive_helper.dart';
import 'package:test_flutter/core/widgets/toast.dart';
import 'package:test_flutter/data/models/sedekah/sedekah.dart';
import 'package:test_flutter/features/sedekah/pages/tambah_sedekah_page.dart';
import 'package:test_flutter/features/sedekah/sedekah_provider.dart';
import 'package:test_flutter/features/sedekah/sedekah_state.dart';

class SedekahPage extends ConsumerStatefulWidget {
  const SedekahPage({super.key});

  @override
  ConsumerState<SedekahPage> createState() => _SedekahPageState();
}

class _SedekahPageState extends ConsumerState<SedekahPage> {
  // ---------- Responsive utils ----------
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
    if (ResponsiveHelper.isExtraLargeScreen(c)) return 960;
    if (ResponsiveHelper.isLargeScreen(c)) return 820;
    return double.infinity;
  }

  EdgeInsets _hpad(BuildContext c) => EdgeInsets.symmetric(
    horizontal: ResponsiveHelper.getResponsivePadding(c).left,
  );

  Future<void> _goToAdd() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TambahSedekahPage()),
    );

    // Refresh data after coming back from add page if success
    if (result != null && result['success'] == true) {
      await _refreshData();
    }
  }

  Future<void> _refreshData() async {
    await ref.read(sedekahProvider.notifier).loadSedekah();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch data
      ref.read(sedekahProvider.notifier).loadSedekah();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch provider
    final sedekahState = ref.watch(sedekahProvider);
    final sedekahStats = sedekahState.sedekahStats;
    final totalHariIni = sedekahStats?.totalHariIni ?? 0;
    final totalBulanIni = sedekahStats?.totalBulanIni ?? 0;
    final riwayat = sedekahStats?.riwayat ?? <Sedekah>[];
    final status = sedekahState.status;
    final message = sedekahState.message;
    final isOffline = sedekahState.isOffline;

    // Listen to state changes for showing messages
    ref.listen<SedekahState>(sedekahProvider, (previous, next) {
      if (next.status == SedekahStatus.success && next.message != null) {
        showMessageToast(
          context,
          message: next.message!,
          type: ToastType.success,
        );
        ref.read(sedekahProvider.notifier).clearMessage();
      } else if (next.status == SedekahStatus.error && next.message != null) {
        showMessageToast(
          context,
          message: next.message!,
          type: ToastType.error,
        );
        ref.read(sedekahProvider.notifier).clearMessage();
      }
    });

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
                  Padding(
                    padding: _hpad(
                      context,
                    ).copyWith(top: _px(context, 20), bottom: _px(context, 8)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(_px(context, 10)),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.primaryBlue.withValues(alpha: 0.1),
                                    AppTheme.accentGreen.withValues(alpha: 0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.volunteer_activism_rounded,
                                color: AppTheme.primaryBlue,
                                size: _px(context, 26),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Tracker Sedekah',
                                        style: TextStyle(
                                          fontSize: _ts(context, 26),
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.onSurface,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      if (isOffline) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.shade100,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.cloud_off,
                                                size: 12,
                                                color: Colors.orange.shade700,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Offline',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.orange.shade700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  SizedBox(height: _px(context, 4)),
                                  Text(
                                    'Catat amal sedekah Anda',
                                    style: TextStyle(
                                      fontSize: _ts(context, 14),
                                      color: AppTheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Refresh button
                            if (status != SedekahStatus.loading &&
                                status != SedekahStatus.refreshing)
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.primaryBlue.withValues(
                                        alpha: 0.1,
                                      ),
                                      AppTheme.accentGreen.withValues(
                                        alpha: 0.1,
                                      ),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  onPressed: _refreshData,
                                  icon: const Icon(Icons.refresh_rounded),
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: _px(context, 16)),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: _buildContent(
                      context,
                      status,
                      message,
                      riwayat,
                      totalHariIni,
                      totalBulanIni,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryBlue, AppTheme.accentGreen],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _goToAdd,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    SedekahStatus status,
    String? message,
    List<Sedekah> riwayat,
    int totalHariIni,
    int totalBulanIni,
  ) {
    // Loading state (initial load)
    if (status == SedekahStatus.loading) {
      return _buildLoadingState(context);
    }

    // Error state
    if (status == SedekahStatus.error && message != null) {
      return _buildErrorState(context, message);
    }

    // Success state (loaded, offline, refreshing)
    return Column(
      children: [
        // Statistics
        Padding(
          padding: _hpad(context),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _StatCard(
                  value: totalHariIni.toString(),
                  label: 'Hari ini',
                  color: AppTheme.accentGreen,
                  icon: Icons.today_rounded,
                  ts: (x) => _ts(context, x),
                  px: (x) => _px(context, x),
                ),
              ),
              SizedBox(width: _px(context, 12)),
              Expanded(
                child: _StatCard(
                  value: totalBulanIni.toString(),
                  label: 'Bulan ini',
                  color: AppTheme.primaryBlue,
                  icon: Icons.calendar_month_rounded,
                  ts: (x) => _ts(context, x),
                  px: (x) => _px(context, x),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: _px(context, 18)),

        // Section header
        Padding(
          padding: _hpad(context),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(_px(context, 6)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryBlue.withValues(alpha: 0.15),
                      AppTheme.primaryBlue.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.history_rounded,
                  color: AppTheme.primaryBlue,
                  size: _px(context, 18),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Riwayat Sedekah',
                style: TextStyle(
                  fontSize: _ts(context, 18),
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: _px(context, 10)),

        // List
        Expanded(
          child: riwayat.isEmpty
              ? _buildEmptyState(context)
              : RefreshIndicator(
                  onRefresh: _refreshData,
                  color: AppTheme.primaryBlue,
                  child: ListView.builder(
                    padding: _hpad(context),
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    itemCount: riwayat.length,
                    itemBuilder: (_, i) => _riwayatTile(context, riwayat[i]),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Column(
      children: [
        // Loading statistics
        Padding(
          padding: _hpad(context),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildLoadingCard(context)),
              SizedBox(width: _px(context, 12)),
              Expanded(child: _buildLoadingCard(context)),
            ],
          ),
        ),

        SizedBox(height: _px(context, 18)),

        // Section header
        Padding(
          padding: _hpad(context),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(_px(context, 6)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryBlue.withValues(alpha: 0.15),
                      AppTheme.primaryBlue.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.history_rounded,
                  color: AppTheme.primaryBlue,
                  size: _px(context, 18),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Riwayat Sedekah',
                style: TextStyle(
                  fontSize: _ts(context, 18),
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: _px(context, 10)),

        // Loading list
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: AppTheme.primaryBlue,
                  strokeWidth: 3,
                ),
                SizedBox(height: _px(context, 16)),
                Text(
                  'Memuat data sedekah...',
                  style: TextStyle(
                    fontSize: _ts(context, 16),
                    color: AppTheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(_px(context, 14)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: _px(context, 44),
            height: _px(context, 44),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.circle,
              color: AppTheme.primaryBlue.withValues(alpha: 0.3),
              size: _px(context, 22),
            ),
          ),
          SizedBox(width: _px(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: _px(context, 16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.onSurfaceVariant.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                SizedBox(height: _px(context, 8)),
                Container(
                  height: _px(context, 12),
                  width: _px(context, 60),
                  decoration: BoxDecoration(
                    color: AppTheme.onSurfaceVariant.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String errorMessage) {
    return Center(
      child: Padding(
        padding: _hpad(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(_px(context, 22)),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.red.withValues(alpha: 0.1),
                    Colors.red.withValues(alpha: 0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: _px(context, 58),
                color: Colors.red,
              ),
            ),
            SizedBox(height: _px(context, 18)),
            Text(
              'Gagal memuat data',
              style: TextStyle(
                fontSize: _ts(context, 18),
                color: AppTheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: _px(context, 6)),
            Text(
              errorMessage,
              style: TextStyle(
                fontSize: _ts(context, 14),
                color: AppTheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: _px(context, 20)),
            ElevatedButton.icon(
              onPressed: _refreshData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: _px(context, 20),
                  vertical: _px(context, 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: _hpad(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(_px(context, 22)),
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
                Icons.volunteer_activism_outlined,
                size: _px(context, 58),
                color: AppTheme.primaryBlue,
              ),
            ),
            SizedBox(height: _px(context, 18)),
            Text(
              'Belum ada sedekah tercatat',
              style: TextStyle(
                fontSize: _ts(context, 18),
                color: AppTheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: _px(context, 6)),
            Text(
              'Mulai catat sedekah dengan menekan tombol +',
              style: TextStyle(
                fontSize: _ts(context, 14),
                color: AppTheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _riwayatTile(BuildContext context, Sedekah sedekah) {
    final formattedDate = DateFormat(
      "d MMMM y 'pukul' HH:mm",
      "id_ID",
    ).format(sedekah.tanggal);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accentGreen.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentGreen.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(_px(context, 16)),
        child: Row(
          children: [
            Container(
              width: _px(context, 50),
              height: _px(context, 50),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accentGreen.withValues(alpha: 0.2),
                    AppTheme.accentGreen.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: AppTheme.accentGreen,
                size: _px(context, 26),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sedekah.jenisSedekah,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: _ts(context, 16),
                      color: AppTheme.onSurface,
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(height: _px(context, 4)),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: _px(context, 12),
                        color: AppTheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: _ts(context, 13),
                            color: AppTheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (sedekah.keterangan?.isNotEmpty ?? false) ...[
                    SizedBox(height: _px(context, 4)),
                    Text(
                      sedekah.keterangan!,
                      style: TextStyle(
                        fontSize: _ts(context, 12),
                        color: AppTheme.onSurfaceVariant.withValues(alpha: 0.7),
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Rp ${NumberFormat('#,###', 'id_ID').format(sedekah.jumlah)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: _ts(context, 16),
                color: AppTheme.accentGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;
  final double Function(double) px;
  final double Function(double) ts;

  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
    required this.px,
    required this.ts,
  });

  @override
  Widget build(BuildContext context) {
    final iconBox = px(44); // ukuran kotak ikon

    return Container(
      padding: EdgeInsets.all(px(14)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Kolom kiri: ikon
          Container(
            width: iconBox,
            height: iconBox,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.2),
                  color.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: px(22)),
          ),

          SizedBox(width: px(12)),

          // Kolom kanan: teks
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // value
                Text(
                  value,
                  style: TextStyle(
                    fontSize: ts(16),
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: px(4)),
                // label
                Text(
                  label,
                  style: TextStyle(
                    fontSize: ts(12),
                    color: AppTheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
