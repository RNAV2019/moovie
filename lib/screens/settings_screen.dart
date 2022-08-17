import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moovie/constants.dart';
import 'package:moovie/main.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool isSwitched = true;

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = ref.watch(darkModeProvider);
    return Scaffold(
      backgroundColor: isDarkMode ? bgColorDark : bgColorLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_left_rounded,
            color: isDarkMode ? Colors.white : Colors.black,
            size: 38,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Settings',
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: <Color>[
                    Colors.orangeAccent,
                    primary,
                  ], begin: Alignment.centerLeft, end: Alignment.centerRight),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  title: const Text(
                    'Theme',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  trailing: SizedBox(
                    width: 100,
                    height: 100,
                    child: Switch(
                      value: ref.read(darkModeProvider.state).state,
                      activeColor: bgColorDark,
                      inactiveTrackColor: bgColorLight,
                      onChanged: (value) {
                        ref.read(darkModeProvider.state).state =
                            !ref.read(darkModeProvider.state).state;
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
