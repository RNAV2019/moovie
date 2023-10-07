import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return Scaffold(
          backgroundColor:
              isDarkMode ? darkDynamic?.surface : lightDynamic?.surface,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_left_rounded,
                color: isDarkMode
                    ? darkDynamic?.secondary
                    : lightDynamic?.secondary,
                size: 38,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Settings',
              style: TextStyle(
                color: isDarkMode
                    ? darkDynamic?.onSurface
                    : lightDynamic?.onSurface,
              ),
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
                      color: darkDynamic?.secondary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      title: Text(
                        'Theme',
                        style: TextStyle(
                            color: isDarkMode
                                ? darkDynamic?.onSecondary
                                : lightDynamic?.onSecondary,
                            fontWeight: FontWeight.bold),
                      ),
                      trailing: SizedBox(
                        width: 100,
                        height: 100,
                        child: Switch(
                          value: ref.read(darkModeProvider.notifier).state,
                          activeColor: isDarkMode
                              ? darkDynamic?.onPrimary
                              : lightDynamic?.onPrimary,
                          inactiveTrackColor: isDarkMode
                              ? darkDynamic?.onPrimary
                              : lightDynamic?.onPrimary,
                          onChanged: (value) {
                            ref.read(darkModeProvider.notifier).state =
                                !ref.read(darkModeProvider.notifier).state;
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
      },
    );
  }
}
