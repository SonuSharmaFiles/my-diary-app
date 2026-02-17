# Changelog

## Version 2.0.0 (Build 2) - 2026-02-13

### 🐛 Bug Fixes
- **CRITICAL**: Fixed package name mismatch that caused app crashes on Play Store
  - Updated MainActivity package from `com.example.my_diary` to `io.mydiary.journal`
  - Moved MainActivity to correct directory structure
  
- **CRITICAL**: Added ProGuard/R8 rules for Hive database
  - Prevents data serialization issues in release builds
  - Ensures diary entries are properly saved and loaded
  
- **CRITICAL**: Fixed Android 13+ permission issues
  - Added `READ_MEDIA_IMAGES` permission for Android 13+
  - Updated `READ_EXTERNAL_STORAGE` permission with maxSdkVersion
  - Added proper `WRITE_EXTERNAL_STORAGE` scoping
  
- **CRITICAL**: Added INTERNET permission
  - Required for Google Fonts to load properly
  - Allows sample images to display correctly

### 🚀 Improvements
- Enabled code minification and resource shrinking for smaller APK size
- Optimized ProGuard rules for better app performance
- Better permission handling across Android versions

### 📦 Technical Changes
- Version bumped from 1.0.0+1 to 2.0.0+2
- Added comprehensive ProGuard rules for:
  - Hive database and TypeAdapters
  - Flutter plugins (image_picker, path_provider)
  - Google Fonts
  - Model classes
- Enhanced AndroidManifest.xml with proper permissions

### 🔧 Files Modified
- `android/app/build.gradle.kts` - Added ProGuard configuration
- `android/app/proguard-rules.pro` - Created with comprehensive rules
- `android/app/src/main/AndroidManifest.xml` - Updated permissions
- `android/app/src/main/kotlin/io/mydiary/journal/MainActivity.kt` - Fixed package
- `pubspec.yaml` - Updated version to 2.0.0+2

---

## Version 1.0.0 (Build 1) - Initial Release

### Features
- Create and save diary entries
- Add images from camera or gallery
- Set mood and location tags
- View previous entries in chronological order
- Dark and light theme support
- Beautiful Material Design UI
