import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import './providers/diary_provider.dart';
import './screens/home_screen.dart';
import './models/diary_entry.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters BEFORE opening any boxes or running the app
  Hive.registerAdapter(DiaryEntryAdapter());
  
  // Open the diary box
  await Hive.openBox<DiaryEntry>('diary_entries');
  
  runApp(const MyDiaryApp());
}

class MyDiaryApp extends StatelessWidget {
  const MyDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => DiaryProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'My Diary',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: false,
          brightness: Brightness.light,
          primaryColor: const Color(0xFF2B8CEE),
          scaffoldBackgroundColor: const Color(0xFFF6F7F8),
          fontFamily: 'Inter',
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Color(0xFF1E293B),
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.white,
            margin: EdgeInsets.zero,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: false,
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            hintStyle: TextStyle(
              color: const Color(0xFF94A3B8),
              fontSize: 16,
            ),
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontFamily: 'Inter',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
            displayMedium: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
            bodyLarge: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: Color(0xFF334155),
            ),
            bodyMedium: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
            bodySmall: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: Color(0xFF94A3B8),
            ),
            labelLarge: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: false,
          brightness: Brightness.dark,
          primaryColor: const Color(0xFF2B8CEE),
          scaffoldBackgroundColor: const Color(0xFF101922),
          fontFamily: 'Inter',
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: const Color(0xFF1E293B),
            margin: EdgeInsets.zero,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: false,
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            hintStyle: TextStyle(
              color: const Color(0xFF64748B),
              fontSize: 16,
            ),
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontFamily: 'Inter',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            displayMedium: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            bodyLarge: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: Color(0xFFE2E8F0),
            ),
            bodyMedium: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Color(0xFF94A3B8),
            ),
            bodySmall: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
            labelLarge: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
