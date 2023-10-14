import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moovie/main.dart';
import 'package:transparent_image/transparent_image.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool isSwitched = true;
  late Image darkSkeletonUI;
  late Image lightSkeletonUI;

  @override
  void initState() {
    darkSkeletonUI = Image.asset(
      'assets/skeleton-ui-dark.png',
      width: 180,
      height: 270,
    );
    lightSkeletonUI = Image.asset(
      'assets/skeleton-ui-light.png',
      width: 180,
      height: 270,
    );
    super.initState();
  }

  @override
  void didChangeDependencies() {
    precacheImage(darkSkeletonUI.image, context, size: const Size(180, 270));
    precacheImage(lightSkeletonUI.image, context, size: const Size(180, 270));
    super.didChangeDependencies();
  }

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
                      leading: Icon(
                        Icons.lightbulb_outline,
                        color: isDarkMode
                            ? darkDynamic?.onPrimary
                            : lightDynamic?.onPrimary,
                      ),
                      onTap: () {
                        bool isDarkMode = ref.watch(darkModeProvider);
                        showModalBottomSheet(
                          context: context,
                          showDragHandle: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          backgroundColor: isDarkMode
                              ? darkDynamic?.background
                              : lightDynamic?.background,
                          builder: (context) {
                            return SizedBox(
                              height: 400,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Dark',
                                          style: TextStyle(
                                            color: isDarkMode
                                                ? darkDynamic?.onBackground
                                                : lightDynamic?.onBackground,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          child: Image(
                                            image: darkSkeletonUI.image,
                                            height: 270,
                                            width: 180,
                                          ),
                                        ),
                                        IconButton(
                                          icon: isDarkMode
                                              ? const Icon(
                                                  Icons.check_circle,
                                                  color: Colors.lightBlue,
                                                )
                                              : Icon(
                                                  Icons.circle_outlined,
                                                  color: isDarkMode
                                                      ? darkDynamic
                                                          ?.onBackground
                                                      : lightDynamic
                                                          ?.onBackground,
                                                ),
                                          onPressed: () {
                                            ref
                                                .read(darkModeProvider.notifier)
                                                .state = true;
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Light',
                                          style: TextStyle(
                                            color: isDarkMode
                                                ? darkDynamic?.onBackground
                                                : lightDynamic?.onBackground,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          child: Image(
                                            image: lightSkeletonUI.image,
                                            height: 270,
                                            width: 180,
                                          ),
                                        ),
                                        IconButton(
                                          icon: isDarkMode
                                              ? Icon(
                                                  Icons.circle_outlined,
                                                  color: isDarkMode
                                                      ? darkDynamic
                                                          ?.onBackground
                                                      : lightDynamic
                                                          ?.onBackground,
                                                )
                                              : const Icon(
                                                  Icons.check_circle,
                                                  color: Colors.lightBlue,
                                                ),
                                          onPressed: () {
                                            ref
                                                .read(darkModeProvider.notifier)
                                                .state = false;
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      // trailing: SizedBox(
                      //   width: 100,
                      //   height: 100,
                      //   child: Switch(
                      //     value: ref.read(darkModeProvider.notifier).state,
                      //     activeColor: isDarkMode
                      //         ? darkDynamic?.onPrimary
                      //         : lightDynamic?.onPrimary,
                      //     inactiveTrackColor: isDarkMode
                      //         ? darkDynamic?.onPrimary
                      //         : lightDynamic?.onPrimary,
                      //     onChanged: (value) {
                      //       ref.read(darkModeProvider.notifier).state =
                      //           !ref.read(darkModeProvider.notifier).state;
                      //     },
                      //   ),
                      // ),
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
