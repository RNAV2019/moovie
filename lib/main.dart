import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moovie/screens/home_screen.dart';
import 'package:moovie/screens/search_screen.dart';
import 'package:moovie/screens/settings_screen.dart';

final darkModeProvider = StateProvider<bool>((ref) => true);

Future main() async {
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Flutter Demo',
        home: const HomeScreen(),
        theme: ThemeData(
          textTheme: GoogleFonts.latoTextTheme(),
        ),
        debugShowCheckedModeBanner: false,
        routes: {
          '/settings': (context) => const SettingsScreen(),
          '/search': (context) => const SearchScreen(),
        },
      ),
    );
  }
}
