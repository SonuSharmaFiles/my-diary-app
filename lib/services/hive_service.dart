import 'package:hive_flutter/hive_flutter.dart';
import '../models/diary_entry.dart';

class HiveService {
  static const String diaryBoxName = 'diary_entries';
  
  static Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(DiaryEntryAdapter());
    }
    
    // Open the diary entries box if not already open
    if (!Hive.isBoxOpen(diaryBoxName)) {
      await Hive.openBox<DiaryEntry>(diaryBoxName);
    }
  }
  
  static Box<DiaryEntry> get diaryBox => Hive.box<DiaryEntry>(diaryBoxName);
  
  // CRUD operations
  static Future<void> addEntry(DiaryEntry entry) async {
    await diaryBox.put(entry.id, entry);
  }
  
  static Future<void> updateEntry(DiaryEntry entry) async {
    await diaryBox.put(entry.id, entry);
  }
  
  static Future<void> deleteEntry(String id) async {
    await diaryBox.delete(id);
  }
  
  static DiaryEntry? getEntry(String id) {
    return diaryBox.get(id);
  }
  
  static List<DiaryEntry> getAllEntries() {
    return diaryBox.values.toList();
  }
  
  static List<DiaryEntry> getEntriesSortedByDate({bool descending = true}) {
    final entries = getAllEntries();
    entries.sort((a, b) => descending 
        ? b.createdAt.compareTo(a.createdAt)
        : a.createdAt.compareTo(b.createdAt));
    return entries;
  }
  
  static Future<void> clearAllEntries() async {
    await diaryBox.clear();
  }
  
  // Group entries by date
  static Map<String, List<DiaryEntry>> getEntriesGroupedByDate() {
    final entries = getEntriesSortedByDate();
    final Map<String, List<DiaryEntry>> groupedEntries = {};
    
    for (final entry in entries) {
      final dateKey = '${entry.createdAt.year}-${entry.createdAt.month.toString().padLeft(2, '0')}-${entry.createdAt.day.toString().padLeft(2, '0')}';
      
      if (!groupedEntries.containsKey(dateKey)) {
        groupedEntries[dateKey] = [];
      }
      groupedEntries[dateKey]!.add(entry);
    }
    
    return groupedEntries;
  }
  
  // Get formatted date string for display
  static String formatDateKey(String dateKey) {
    final parts = dateKey.split('-');
    if (parts.length != 3) return dateKey;
    
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    
    if (year == null || month == null || day == null) return dateKey;
    
    final date = DateTime(year, month, day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    
    if (date == today) return 'Today';
    if (date == yesterday) return 'Yesterday';
    
    // Format as "Day Month Year"
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return '${day} ${monthNames[month - 1]} ${year}';
  }
}