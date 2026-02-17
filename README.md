# My Diary - Flutter Diary & Planner App

A clean, simple diary and planner mobile application built with Flutter using Provider for state management and Hive for local storage.

## Features

- 📝 Create diary entries with text-based notes
- 😊 Optional mood selection (emoji)
- 📍 Optional location tagging (string only)
- 🖼️ Optional image attachment per entry
- 📅 View previous entries in a scrollable list
- 📊 Entries grouped by date (Today, Yesterday, etc.)
- ✏️ Edit and delete existing entries
- 💾 Local persistence using Hive (offline storage)
- 📱 Responsive UI for mobile devices
- 🎨 Modern Material 3 design with soft shadows and rounded cards

## Tech Stack

- **Framework**: Flutter (stable)
- **State Management**: Provider
- **Local Storage**: Hive
- **Platforms**: Android, iOS, Web, macOS, Windows, Linux
- **Architecture**: Clean folder structure with separation of concerns

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/
│   └── diary_entry.dart        # DiaryEntry data model
├── providers/
│   └── diary_provider.dart     # State management with Provider
├── services/
│   └── hive_service.dart       # Hive database operations
├── screens/
│   ├── home_screen.dart        # Main home screen
│   └── entry_edit_screen.dart  # Entry editing screen
└── widgets/
    └── diary_entry_card.dart   # Reusable entry card widget
```

## Data Model

```dart
class DiaryEntry {
  String id;
  String content;
  DateTime createdAt;
  String? mood;      // Optional emoji
  String? location;  // Optional location string
  String? imagePath; // Optional image path
}
```

## Getting Started

### Prerequisites

- Flutter SDK (stable channel)
- Dart SDK
- IDE: VS Code or Android Studio with Flutter plugin

### Installation

1. Clone the repository
2. Navigate to the project directory:
   ```bash
   cd my_diary
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Generate Hive adapters (if needed):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

### Running the App

#### Web (Chrome)
```bash
flutter run -d chrome
```

#### Android
```bash
flutter run -d android
```

#### iOS
```bash
flutter run -d ios
```

#### macOS
```bash
flutter run -d macos
```

### Building for Release

#### Web
```bash
flutter build web
```

#### Android
```bash
flutter build apk --release
```

#### iOS
```bash
flutter build ios --release
```

## Usage Guide

### Creating a New Entry
1. Type your thoughts in the "Write about your day..." text field
2. (Optional) Select a mood by tapping an emoji
3. (Optional) Choose a location from the dropdown
4. Click "Save Entry" to save your diary entry

### Viewing Entries
- Entries are automatically grouped by date (Today, Yesterday, etc.)
- Each entry shows a preview with date, time, mood, and location
- Scroll through the list to see all your past entries

### Editing an Entry
1. Tap the three-dot menu (⋮) on any entry card
2. Select "Edit"
3. Make your changes in the edit screen
4. Tap "Save Changes"

### Deleting an Entry
1. Tap the three-dot menu (⋮) on any entry card
2. Select "Delete"
3. Confirm the deletion in the dialog

## Design Philosophy

- **Minimalist**: Clean, uncluttered interface focused on writing
- **Modern**: Material 3 design with soft shadows and rounded corners
- **Responsive**: Works well on different screen sizes
- **Accessible**: Clear typography and intuitive interactions
- **Offline-first**: All data stored locally for privacy and availability

## Code Quality

- Clean, readable, and commented code
- Follows Flutter best practices
- No deprecated APIs
- Proper error handling
- Consistent naming conventions

## Future Enhancements

Potential features for future versions:
- Search functionality
- Entry categories/tags
- Rich text formatting
- Export to PDF/Text
- Cloud backup
- Dark mode
- Password protection
- Calendar view
- Statistics and insights

## License

This project is open source and available for personal and educational use.

## Support

For issues or questions, please check the code comments or refer to Flutter documentation.