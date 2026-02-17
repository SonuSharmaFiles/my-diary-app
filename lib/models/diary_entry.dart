import 'package:hive/hive.dart';

part 'diary_entry.g.dart';

@HiveType(typeId: 0)
class DiaryEntry {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String content;
  
  @HiveField(2)
  final DateTime createdAt;
  
  @HiveField(3)
  final String? mood;
  
  @HiveField(4)
  final String? location;
  
  @HiveField(5)
  final String? imagePath;
  
  DiaryEntry({
    required this.id,
    required this.content,
    required this.createdAt,
    this.mood,
    this.location,
    this.imagePath,
  });
  
  // Copy with method for editing
  DiaryEntry copyWith({
    String? id,
    String? content,
    DateTime? createdAt,
    String? mood,
    String? location,
    String? imagePath,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      mood: mood ?? this.mood,
      location: location ?? this.location,
      imagePath: imagePath ?? this.imagePath,
    );
  }
  
  // Helper method to get formatted date in HTML style: "OCTOBER 24, 2023"
  String get formattedDate {
    final months = [
      'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
      'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'
    ];
    final month = months[createdAt.month - 1];
    final day = createdAt.day;
    final year = createdAt.year;
    return '$month $day, $year';
  }
  
  // Helper method to get formatted time in HTML style: "Tuesday • 4:30 PM"
  String get formattedTime {
    final weekdays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final weekday = weekdays[createdAt.weekday % 7];
    
    final hour = createdAt.hour;
    final minute = createdAt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    
    return '$weekday • $displayHour:$minute $period';
  }
  
  // Helper method to check if entry has image
  bool get hasImage => imagePath != null && imagePath!.isNotEmpty;
  
  // Helper method to check if entry has mood
  bool get hasMood => mood != null && mood!.isNotEmpty;
  
  // Helper method to check if entry has location
  bool get hasLocation => location != null && location!.isNotEmpty;
}