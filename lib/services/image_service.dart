import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageService {
  /// Copy image from temporary location to permanent app storage
  /// This ensures images persist even after cache is cleared
  static Future<String> saveImagePermanently(String tempPath) async {
    try {
      // Get the app's permanent document directory
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      
      // Create a 'diary_images' subdirectory if it doesn't exist
      final Directory imagesDir = Directory('${appDocDir.path}/diary_images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      
      // Generate a unique filename using timestamp
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(tempPath)}';
      final String permanentPath = '${imagesDir.path}/$fileName';
      
      // Copy the file from temp location to permanent location
      final File tempFile = File(tempPath);
      await tempFile.copy(permanentPath);
      
      return permanentPath;
    } catch (e) {
      throw Exception('Failed to save image permanently: $e');
    }
  }
  
  /// Delete an image file from permanent storage
  static Future<void> deleteImage(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        await imageFile.delete();
      }
    } catch (e) {
      // Silently fail - image might already be deleted
      print('Failed to delete image: $e');
    }
  }
  
  /// Check if an image file exists
  static Future<bool> imageExists(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      return await imageFile.exists();
    } catch (e) {
      return false;
    }
  }
  
  /// Clean up orphaned images (images not referenced in any diary entry)
  static Future<void> cleanupOrphanedImages(List<String> activeImagePaths) async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final Directory imagesDir = Directory('${appDocDir.path}/diary_images');
      
      if (!await imagesDir.exists()) return;
      
      // Get all image files
      final List<FileSystemEntity> files = imagesDir.listSync();
      
      // Delete files not in active list
      for (final file in files) {
        if (file is File) {
          final String filePath = file.path;
          if (!activeImagePaths.contains(filePath)) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      print('Failed to cleanup orphaned images: $e');
    }
  }
}
