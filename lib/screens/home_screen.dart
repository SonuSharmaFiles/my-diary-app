import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/diary_provider.dart';
import '../widgets/diary_entry_card.dart';
import '../services/image_service.dart';
import 'entry_edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textController = TextEditingController();
  String? _selectedMood;
  String? _selectedLocation;
  String? _selectedImagePath;

  final List<String> _moodOptions = ['Happy', 'Sad', 'Excited', 'Tired', 'Thoughtful', 'Celebratory', 'Loving', 'Inspired'];
  final List<String> _locationOptions = ['Home', 'Work', 'School', 'Park', 'Cafe', 'Travel', 'Gym', 'Restaurant'];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    
    // Show a dialog to let user choose source
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: const Text('Choose where to pick the image from'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: const Text('Gallery'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: const Text('Camera'),
          ),
        ],
      ),
    );
    
    if (source == null) return;
    
    try {
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );
      
      if (pickedFile != null) {
        setState(() {
          _selectedImagePath = pickedFile.path;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image selected from ${source == ImageSource.gallery ? 'gallery' : 'camera'}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _selectMood() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Mood'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _moodOptions.length,
            itemBuilder: (context, index) {
              final mood = _moodOptions[index];
              return ListTile(
                title: Text(mood),
                trailing: _selectedMood == mood ? const Icon(Icons.check) : null,
                onTap: () {
                  setState(() {
                    _selectedMood = mood;
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _selectLocation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Location'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _locationOptions.length,
            itemBuilder: (context, index) {
              final location = _locationOptions[index];
              return ListTile(
                title: Text(location),
                trailing: _selectedLocation == location ? const Icon(Icons.check) : null,
                onTap: () {
                  setState(() {
                    _selectedLocation = location;
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _clearSelections() {
    setState(() {
      _selectedMood = null;
      _selectedLocation = null;
      _selectedImagePath = null;
    });
  }

  Future<void> _addEntry(BuildContext context) async {
    final content = _textController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write something in your diary'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Copy image to permanent storage if selected
    String? permanentImagePath;
    if (_selectedImagePath != null) {
      try {
        permanentImagePath = await ImageService.saveImagePermanently(_selectedImagePath!);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save image: $e'),
            backgroundColor: Colors.orange,
          ),
        );
        // Continue without image
      }
    }

    final provider = Provider.of<DiaryProvider>(context, listen: false);
    await provider.addEntry(
      content: content,
      mood: _selectedMood,
      location: _selectedLocation,
      imagePath: permanentImagePath,
    );

    if (provider.error == null) {
      _textController.clear();
      _clearSelections();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Entry saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _editEntry(BuildContext context, String entryId) {
    final provider = Provider.of<DiaryProvider>(context, listen: false);
    final entry = provider.getEntryById(entryId);
    if (entry != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EntryEditScreen(entry: entry),
        ),
      );
    }
  }

  Future<void> _deleteEntry(BuildContext context, String entryId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final provider = Provider.of<DiaryProvider>(context, listen: false);
      await provider.deleteEntry(entryId);
      
      if (provider.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entry deleted'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DiaryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.entries.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: provider.refresh,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.only(
                    top: 40,
                    bottom: 16,
                    left: 16,
                    right: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  child: Center(
                    child: Text(
                      'My Diary',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
                
                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          // New Entry Card
                          Container(
                            margin: const EdgeInsets.only(top: 8, bottom: 32),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardTheme.color,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(context).brightness == Brightness.light
                                    ? const Color(0xFFE2E8F0)
                                    : const Color(0xFF334155),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // New Entry Header
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.edit_note,
                                        color: Theme.of(context).primaryColor,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'NEW ENTRY',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.5,
                                              color: Theme.of(context).brightness == Brightness.light
                                                  ? const Color(0xFF64748B)
                                                  : const Color(0xFF94A3B8),
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // Text Area
                                  TextField(
                                    controller: _textController,
                                    maxLines: 5,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          fontSize: 18,
                                          color: Theme.of(context).brightness == Brightness.light
                                              ? const Color(0xFF1E293B)
                                              : const Color(0xFFF1F5F9),
                                        ),
                                    decoration: InputDecoration(
                                      hintText: "What's on your mind?",
                                      hintStyle: TextStyle(
                                        color: Theme.of(context).brightness == Brightness.light
                                            ? const Color(0xFF94A3B8)
                                            : const Color(0xFF64748B),
                                        fontSize: 18,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                  
                                  // Image Preview
                                  if (_selectedImagePath != null) ...[
                                    const SizedBox(height: 12),
                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.file(
                                            File(_selectedImagePath!),
                                            height: 120,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _selectedImagePath = null;
                                              });
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.6),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Divider
                                  Divider(
                                    color: Theme.of(context).brightness == Brightness.light
                                        ? const Color(0xFFF1F5F9)
                                        : const Color(0xFF334155),
                                    height: 1,
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Footer with icons and button
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Icons
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: _pickImage,
                                            child: Icon(
                                              Icons.image,
                                              color: _selectedImagePath != null
                                                  ? Theme.of(context).primaryColor
                                                  : (Theme.of(context).brightness == Brightness.light
                                                      ? const Color(0xFF94A3B8)
                                                      : const Color(0xFF64748B)),
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          GestureDetector(
                                            onTap: _selectMood,
                                            child: Icon(
                                              Icons.mood,
                                              color: _selectedMood != null
                                                  ? Theme.of(context).primaryColor
                                                  : (Theme.of(context).brightness == Brightness.light
                                                      ? const Color(0xFF94A3B8)
                                                      : const Color(0xFF64748B)),
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          GestureDetector(
                                            onTap: _selectLocation,
                                            child: Icon(
                                              Icons.location_on,
                                              color: _selectedLocation != null
                                                  ? Theme.of(context).primaryColor
                                                  : (Theme.of(context).brightness == Brightness.light
                                                      ? const Color(0xFF94A3B8)
                                                      : const Color(0xFF64748B)),
                                              size: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      // Save Button
                                      ElevatedButton(
                                        onPressed: () => _addEntry(context),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context).primaryColor,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 10,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(999),
                                          ),
                                        ),
                                        child: const Text(
                                          'Save Entry',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Previous Entries Header
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Previous Entries',
                                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                        fontSize: 20,
                                      ),
                                ),
                                Text(
                                  '${provider.entries.length} TOTAL',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Entries List
                          if (provider.hasEntries)
                            _buildEntriesList(context, provider)
                          else
                            _buildEmptyState(),
                          
                          const SizedBox(height: 48),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEntriesList(BuildContext context, DiaryProvider provider) {
    return Column(
      children: provider.entries.map((entry) {
        return DiaryEntryCard(
          entry: entry,
          onEdit: () => _editEntry(context, entry.id),
          onDelete: () => _deleteEntry(context, entry.id),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.book,
            size: 64,
            color: Theme.of(context).brightness == Brightness.light
                ? const Color(0xFFE2E8F0)
                : const Color(0xFF334155),
          ),
          const SizedBox(height: 16),
          Text(
            'No entries yet',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).brightness == Brightness.light
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by writing about your day',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}