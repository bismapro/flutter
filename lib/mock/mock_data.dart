class MockData {
  // Mock prayer times
  static const List<Map<String, dynamic>> prayerTimes = [
    {'name': 'Fajr', 'time': '05:30', 'icon': 'sunrise'},
    {'name': 'Dhuhr', 'time': '12:15', 'icon': 'sun'},
    {'name': 'Asr', 'time': '15:45', 'icon': 'partly_sunny'},
    {'name': 'Maghrib', 'time': '18:20', 'icon': 'sunset'},
    {'name': 'Isha', 'time': '19:45', 'icon': 'nights_stay'},
  ];

  // Mock articles
  static const List<Map<String, dynamic>> articles = [
    {
      'id': 1,
      'title': 'The Importance of Prayer in Islam',
      'summary': 'Understanding the significance of the five daily prayers',
      'author': 'Islamic Scholar',
      'date': '2025-09-20',
      'readTime': '5 min read',
      'category': 'Worship',
      'imageUrl': '',
    },
    {
      'id': 2,
      'title': 'Ramadan: A Month of Spiritual Reflection',
      'summary': 'Exploring the spiritual aspects of fasting during Ramadan',
      'author': 'Dr. Ahmad Hassan',
      'date': '2025-09-18',
      'readTime': '7 min read',
      'category': 'Fasting',
      'imageUrl': '',
    },
    {
      'id': 3,
      'title': 'The Beauty of Quranic Recitation',
      'summary': 'Discovering the art and spirituality of Quran recitation',
      'author': 'Qari Muhammad',
      'date': '2025-09-15',
      'readTime': '4 min read',
      'category': 'Quran',
      'imageUrl': '',
    },
  ];

  // Mock community events
  static const List<Map<String, dynamic>> communityEvents = [
    {
      'id': 1,
      'title': 'Friday Prayer Gathering',
      'description': 'Join us for the weekly Friday prayer and sermon',
      'date': '2025-09-29',
      'time': '12:30',
      'location': 'Main Mosque',
      'attendees': 120,
    },
    {
      'id': 2,
      'title': 'Islamic Study Circle',
      'description': 'Weekly discussion on Islamic teachings and values',
      'date': '2025-09-30',
      'time': '19:00',
      'location': 'Community Center',
      'attendees': 45,
    },
    {
      'id': 3,
      'title': 'Charity Drive',
      'description': 'Collecting donations for local families in need',
      'date': '2025-10-05',
      'time': '10:00',
      'location': 'Mosque Courtyard',
      'attendees': 80,
    },
  ];

  // Mock Quran surahs (simplified)
  static const List<Map<String, dynamic>> surahs = [
    {
      'number': 1,
      'name': 'Al-Fatihah',
      'englishName': 'The Opening',
      'verses': 7,
      'revelation': 'Meccan',
    },
    {
      'number': 2,
      'name': 'Al-Baqarah',
      'englishName': 'The Cow',
      'verses': 286,
      'revelation': 'Medinan',
    },
    {
      'number': 3,
      'name': 'Ali \'Imran',
      'englishName': 'The Family of Imran',
      'verses': 200,
      'revelation': 'Medinan',
    },
    // Add more surahs as needed
  ];

  // Mock user data
  static const Map<String, dynamic> userData = {
    'name': 'Ahmad Ibrahim',
    'email': 'ahmad.ibrahim@example.com',
    'joinDate': '2025-01-15',
    'location': 'Jakarta, Indonesia',
    'streak': 7, // days of consistent prayer
    'level': 'Beginner',
  };
}
