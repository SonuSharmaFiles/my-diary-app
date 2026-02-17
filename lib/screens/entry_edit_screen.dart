import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/diary_entry.dart';
import '../providers/diary_provider.dart';
import '../services/image_service.dart';

class EntryEditScreen extends StatefulWidget {
  final DiaryEntry entry;

  const EntryEditScreen({super.key, required this.entry});

  @override
  State<EntryEditScreen> createState() => _EntryEditScreenState();
}

class _EntryEditScreenState extends State<EntryEditScreen> {
  late TextEditingController _textController;
  late String? _selectedMood;
  late String? _selectedLocation;
  late String? _selectedImagePath;

  final List<String> _moodOptions = ['😊', '😢', '😡', '😴', '🤔', '🎉', '❤️', '🌟'];
  final List<String> _locationOptions = ['Home', 'Work', 'School', 'Park', 'Cafe', 'Travel'];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.entry.content);
    _selectedMood = widget.entry.mood;
    _selectedLocation = widget.entry.location;
    _selectedImagePath = widget.entry.imagePath;
  }

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

  Widget _buildImagePreview(String imagePath) {
    // Check if the image is a URL or local file path
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
          );
        },
      );
    } else {
      return Image.file(
        File(imagePath),
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
          );
        },
      );
    }
  }

  Future<void> _saveChanges(BuildContext context) async {
    final content = _textController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Entry cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Handle image path changes
    String? finalImagePath = _selectedImagePath;
    
    // If user selected a new image (different from original)
    if (_selectedImagePath != null && _selectedImagePath != widget.entry.imagePath) {
      try {
        // Check if the selected image is not already in permanent storage
        if (!_selectedImagePath!.contains('/diary_images/')) {
          finalImagePath = await ImageService.saveImagePermanently(_selectedImagePath!);
        }
        
        // Delete old image if it exists
        if (widget.entry.imagePath != null) {
          await ImageService.deleteImage(widget.entry.imagePath!);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save image: $e'),
            backgroundColor: Colors.orange,
          ),
        );
        // Continue without image update
        finalImagePath = widget.entry.imagePath;
      }
    }
    // If user removed the image
    else if (_selectedImagePath == null && widget.entry.imagePath != null) {
      // Delete the old image
      await ImageService.deleteImage(widget.entry.imagePath!);
    }

    final updatedEntry = widget.entry.copyWith(
      content: content,
      mood: _selectedMood,
      location: _selectedLocation,
      imagePath: finalImagePath,
    );

    final provider = Provider.of<DiaryProvider>(context, listen: false);
    await provider.updateEntry(updatedEntry);

    if (provider.error == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Entry updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveChanges(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date and Time
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date: ${widget.entry.formattedDate}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Time: ${widget.entry.formattedTime}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Content Editor
            Expanded(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Content',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: InputDecoration(
                            hintText: 'Write about your day...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Mood and Location Selection
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mood & Location',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Mood Selection
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mood',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 50,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _moodOptions.length,
                            itemBuilder: (context, index) {
                              final mood = _moodOptions[index];
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedMood = _selectedMood == mood ? null : mood;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _selectedMood == mood
                                        ? Colors.blue[100]
                                        : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: _selectedMood == mood
                                          ? Colors.blue
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Text(
                                    mood,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Location Selection
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Location',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedLocation,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('None'),
                            ),
                            ..._locationOptions.map((location) {
                              return DropdownMenuItem(
                                value: location,
                                child: Text(location),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedLocation = value;
                            });
                          },
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Image Selection
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Image',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Image Preview if selected
                        if (_selectedImagePath != null) ...[
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: _buildImagePreview(_selectedImagePath!),
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
                          const SizedBox(height: 8),
                        ],
                        
                        // Select button
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image,
                                  color: _selectedImagePath != null
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey[600]!,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _selectedImagePath != null
                                      ? 'Change image'
                                      : 'Select an image',
                                  style: TextStyle(
                                    color: _selectedImagePath != null
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey[600]!,
                                    fontWeight: _selectedImagePath != null
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _saveChanges(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}