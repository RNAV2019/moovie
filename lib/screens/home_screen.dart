// ignore_for_file: avoid_print
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moovie/components/category_chips.dart';
import 'package:moovie/components/movie_page_builder.dart';
import 'package:moovie/components/series_page_builder.dart';
import 'package:moovie/main.dart';
import 'package:moovie/models/movie_model.dart';
import 'package:moovie/screens/favourites_screen.dart';
import 'package:moovie/screens/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  String sortByCategory = 'movie';
  late final SharedPreferences prefs;

  List<MovieModel> movies = [];
  List<MovieInfo> movieInfos = [];
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((value) {
      prefs = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = ref.watch(darkModeProvider);
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return Scaffold(
          backgroundColor:
              isDarkMode ? darkDynamic?.surface : lightDynamic?.surface,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome,',
                            style: TextStyle(
                                color: isDarkMode
                                    ? darkDynamic?.onSurface.withOpacity(0.7)
                                    : lightDynamic?.onSurface.withOpacity(0.7),
                                fontSize: 14),
                          ),
                          Text(
                            'Relax and find a ${sortByCategory == "movie" ? "movie" : "series"}',
                            style: TextStyle(
                              color: isDarkMode
                                  ? darkDynamic?.onSurface
                                  : lightDynamic?.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        splashRadius: 24,
                        alignment: Alignment.center,
                        icon: Icon(
                          Icons.favorite,
                          color: isDarkMode
                              ? darkDynamic?.secondary
                              : lightDynamic?.secondary,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => FavouritesScreen(
                                movieSeriesInfo:
                                    prefs.getStringList("favs") ?? [],
                                typeInfo:
                                    prefs.getStringList("favs-types") ?? [],
                                genreLists:
                                    prefs.getStringList("favs-genre") ?? [],
                              ),
                            ),
                          );
                        },
                      ),
                      // IconButton(
                      //   splashRadius: 24,
                      //   alignment: Alignment.center,
                      //   icon: Icon(
                      //     Icons.close,
                      //     color: isDarkMode
                      //         ? darkDynamic?.secondary
                      //         : lightDynamic?.secondary,
                      //   ),
                      //   onPressed: () {
                      //     prefs.clear();
                      //   },
                      // ),
                      IconButton(
                        splashRadius: 24,
                        alignment: Alignment.center,
                        icon: Icon(
                          Icons.settings,
                          color: isDarkMode
                              ? darkDynamic?.secondary
                              : lightDynamic?.secondary,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  CategoryChips(
                      sortByCategory: sortByCategory,
                      updateSortByCategory: (value) {
                        setState(() {
                          sortByCategory = value;
                        });
                      }),
                  const SizedBox(
                    height: 12,
                  ),
                  Expanded(
                    child: sortByCategory == 'movie'
                        ? const MoviePageBuilder()
                        : const SeriesPageBuilder(),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor:
                isDarkMode ? darkDynamic?.secondary : lightDynamic?.secondary,
            onPressed: () => Navigator.of(context).pushNamed('/search'),
            child: Icon(
              Icons.search,
              color: isDarkMode
                  ? darkDynamic?.onSecondary
                  : lightDynamic?.onSecondary,
            ),
          ),
        );
      },
    );
  }
}
