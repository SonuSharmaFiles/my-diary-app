import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/diary_entry.dart';
import '../services/hive_service.dart';
import '../services/image_service.dart';

class DiaryProvider with ChangeNotifier {
  List<DiaryEntry> _entries = [];
  bool _isLoading = false;
  String? _error;

  List<DiaryEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Grouped entries by date
  Map<String, List<DiaryEntry>> get groupedEntries => HiveService.getEntriesGroupedByDate();

  DiaryProvider() {
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Initialize Hive if not already initialized
      if (!Hive.isBoxOpen(HiveService.diaryBoxName)) {
        await HiveService.init();
      }
      
      _entries = HiveService.getEntriesSortedByDate();
      _error = null;
    } catch (e) {
      _error = 'Failed to load entries: $e';
      _entries = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addEntry({
    required String content,
    String? mood,
    String? location,
    String? imagePath,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newEntry = DiaryEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content,
        createdAt: DateTime.now(),
        mood: mood,
        location: location,
        imagePath: imagePath,
      );

      await HiveService.addEntry(newEntry);
      _entries.insert(0, newEntry);
      _error = null;
    } catch (e) {
      _error = 'Failed to add entry: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateEntry(DiaryEntry updatedEntry) async {
    _isLoading = true;
    notifyListeners();

    try {
      await HiveService.updateEntry(updatedEntry);
      
      final index = _entries.indexWhere((entry) => entry.id == updatedEntry.id);
      if (index != -1) {
        _entries[index] = updatedEntry;
        // Re-sort entries
        _entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
      
      _error = null;
    } catch (e) {
      _error = 'Failed to update entry: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteEntry(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Find the entry to delete
      final entryToDelete = _entries.firstWhere((entry) => entry.id == id);
      
      // Delete the associated image if it exists
      if (entryToDelete.imagePath != null) {
        await ImageService.deleteImage(entryToDelete.imagePath!);
      }
      
      // Delete the entry from database
      await HiveService.deleteEntry(id);
      _entries.removeWhere((entry) => entry.id == id);
      _error = null;
    } catch (e) {
      _error = 'Failed to delete entry: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await _loadEntries();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Helper method to get entry by id
  DiaryEntry? getEntryById(String id) {
    return _entries.firstWhere((entry) => entry.id == id);
  }
  
  // Check if there are any entries
  bool get hasEntries => _entries.isNotEmpty;
  
  // Get entry count
  int get entryCount => _entries.length;
}