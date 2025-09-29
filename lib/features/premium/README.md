# Premium Feature Module

Modul ini berisi semua komponen yang berkaitan dengan fitur premium dashboard untuk monitoring aktivitas ibadah anak.

## Struktur Folder

```
features/premium/
├── models/
│   └── child_data.dart          # Model data anak
├── pages/
│   ├── premium_page.dart        # Halaman utama premium dashboard
│   └── detail_report_page.dart  # Halaman detail laporan
├── widgets/
│   ├── child_card.dart          # Widget kartu anak
│   ├── summary_stats_card.dart  # Widget kartu statistik ringkasan
│   ├── quick_action_card.dart   # Widget kartu aksi cepat
│   └── section_header.dart      # Widget header section
├── providers/
│   └── premium_provider.dart    # Provider untuk state management (opsional)
└── premium.dart                 # Export file untuk module
```

## Komponen

### Models

- **ChildData**: Model data untuk informasi anak termasuk nama, avatar, progress sholat, progress Al-Quran, dan badges

### Pages

- **PremiumPage**: Halaman utama dengan tab monitoring dan challenges
- **DetailReportPage**: Halaman detail laporan untuk anak tertentu

### Widgets

- **ChildCard**: Kartu untuk menampilkan informasi singkat anak
- **SummaryStatsCard**: Kartu statistik ringkasan (total anak, rata-rata badge, dll)
- **QuickActionCard**: Kartu aksi cepat (lihat laporan, beri reward)
- **SectionHeader**: Header untuk setiap section dalam halaman

### Providers

- **PremiumProvider**: Provider untuk state management (opsional, saat ini menggunakan StatefulWidget)

## Usage

Import module ini dengan menggunakan:

```dart
import 'package:your_app/features/premium/premium.dart';

// Atau import spesifik:
import 'package:your_app/features/premium/pages/premium_page.dart';
```

## Fitur

1. **Monitoring Dashboard**:

   - Statistik ringkasan anak
   - Daftar anak dengan progress masing-masing
   - Quick actions untuk laporan dan reward

2. **Challenges Tab**:

   - Tantangan mingguan
   - Achievement gallery
   - Progress tracking

3. **Interactive Features**:
   - Tambah anak baru
   - Detail report untuk setiap anak
   - Pull to refresh

## Theming

Module ini menggunakan color scheme yang konsisten:

- Primary: `Color(0xFF1E88E5)` (Blue)
- Secondary: `Color(0xFF26A69A)` (Teal)
- Accent: `Color(0xFFFF9800)` (Orange)
- Background: `Colors.grey[50]`

## Future Enhancements

- [ ] Integrasi dengan backend API
- [ ] Push notifications untuk reminder
- [ ] Gamification features
- [ ] Export laporan ke PDF
- [ ] Sinkronisasi data real-time
