import 'package:flutter/material.dart';
import 'package:test_flutter/app/theme.dart';

class SunnahTab extends StatelessWidget {
  final List<Map<String, dynamic>> puasaSunnah;
  final Function(Map<String, dynamic>) onPuasaTap;

  const SunnahTab({
    super.key,
    required this.puasaSunnah,
    required this.onPuasaTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1024;

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop
            ? 32.0
            : isTablet
            ? 28.0
            : 24.0,
      ),
      itemCount: puasaSunnah.length,
      itemBuilder: (context, index) {
        final puasa = puasaSunnah[index];
        return _buildPuasaCard(puasa, isWajib: false);
      },
    );
  }

  Widget _buildPuasaCard(Map<String, dynamic> puasa, {required bool isWajib}) {
    return Builder(
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isTablet = screenWidth > 600;
        final isDesktop = screenWidth > 1024;

        return Container(
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
                  ? 24
                  : isTablet
                  ? 22
                  : 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: isDesktop
                          ? 56
                          : isTablet
                          ? 54
                          : 50,
                      height: isDesktop
                          ? 56
                          : isTablet
                          ? 54
                          : 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            puasa['color'].withValues(alpha: 0.15),
                            puasa['color'].withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
                        border: Border.all(
                          color: puasa['color'].withValues(alpha: 0.2),
                        ),
                      ),
                      child: Icon(
                        puasa['icon'],
                        color: puasa['color'],
                        size: isTablet ? 26 : 24,
                      ),
                    ),
                    SizedBox(width: isTablet ? 18 : 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  puasa['name'],
                                  style: TextStyle(
                                    fontSize: isDesktop
                                        ? 18
                                        : isTablet
                                        ? 17
                                        : 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.onSurface,
                                  ),
                                ),
                              ),
                              SizedBox(width: isTablet ? 10 : 8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 8 : 6,
                                  vertical: isTablet ? 4 : 3,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isWajib
                                        ? [
                                            AppTheme.errorColor.withValues(
                                              alpha: 0.15,
                                            ),
                                            AppTheme.errorColor.withValues(
                                              alpha: 0.1,
                                            ),
                                          ]
                                        : [
                                            AppTheme.accentGreen.withValues(
                                              alpha: 0.15,
                                            ),
                                            AppTheme.accentGreen.withValues(
                                              alpha: 0.1,
                                            ),
                                          ],
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color:
                                        (isWajib
                                                ? AppTheme.errorColor
                                                : AppTheme.accentGreen)
                                            .withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  isWajib ? 'WAJIB' : 'SUNNAH',
                                  style: TextStyle(
                                    fontSize: isTablet ? 11 : 10,
                                    fontWeight: FontWeight.bold,
                                    color: isWajib
                                        ? AppTheme.errorColor
                                        : AppTheme.accentGreen,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isTablet ? 6 : 4),
                          Text(
                            puasa['description'],
                            style: TextStyle(
                              fontSize: isTablet ? 15 : 14,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isTablet ? 18 : 16),
                Row(
                  children: [
                    _buildInfoChip(
                      'Durasi',
                      puasa['duration'],
                      Icons.schedule,
                      isTablet,
                    ),
                    SizedBox(width: isTablet ? 16 : 12),
                    _buildInfoChip(
                      'Periode',
                      puasa['period'],
                      Icons.event,
                      isTablet,
                    ),
                  ],
                ),
                SizedBox(height: isTablet ? 18 : 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => onPuasaTap(puasa),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: puasa['color'],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: isTablet ? 16 : 14,
                      ),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    child: Text(
                      'Lihat Detail & Tracking',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: isTablet ? 15 : 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(
    String label,
    String value,
    IconData icon,
    bool isTablet,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(isTablet ? 12 : 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryBlue.withValues(alpha: 0.05),
              AppTheme.accentGreen.withValues(alpha: 0.03),
            ],
          ),
          borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
          border: Border.all(
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: isTablet ? 18 : 16, color: AppTheme.primaryBlue),
            SizedBox(width: isTablet ? 8 : 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: isTablet ? 11 : 10,
                      color: AppTheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: isTablet ? 2 : 1),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: isTablet ? 13 : 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
