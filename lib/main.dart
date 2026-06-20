import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/note_service.dart';
import 'screens/home_screen.dart';

final _cardTheme = CardThemeData(
  elevation: 1,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
);

const _fabTheme = FloatingActionButtonThemeData(
  elevation: 2,
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NotepadApp());
}

class NotepadApp extends StatelessWidget {
  const NotepadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NoteService(),
      child: MaterialApp(
        title: 'Notepad',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          cardTheme: _cardTheme,
          floatingActionButtonTheme: _fabTheme,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          cardTheme: _cardTheme,
          floatingActionButtonTheme: _fabTheme,
        ),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
