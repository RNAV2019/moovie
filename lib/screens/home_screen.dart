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
  final ScrollController _scrollController =
      ScrollController(initialScrollOffset: 0, keepScrollOffset: true);

  void returnToTop() {
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  List<MovieModel> movies = [];
  List<MovieInfo> movieInfos = [];
  bool isLoaded = false;
  bool isTop = true;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((value) {
      prefs = value;
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels > 2000) {
        if (isTop == true) {
          setState(() {
            isTop = false;
          });
        }
      } else {
        setState(() {
          isTop = true;
        });
      }
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
                        ? MoviePageBuilder(
                            controller: _scrollController,
                          )
                        : SeriesPageBuilder(
                            controller: _scrollController,
                          ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              isTop == false
                  ? FloatingActionButton.small(
                      backgroundColor: isDarkMode
                          ? darkDynamic?.secondary
                          : lightDynamic?.secondary,
                      onPressed: () => returnToTop(),
                      child: Icon(
                        Icons.arrow_upward_rounded,
                        color: isDarkMode
                            ? darkDynamic?.onSecondary
                            : lightDynamic?.onSecondary,
                        size: 22,
                      ),
                    )
                  : Container(),
              FloatingActionButton(
                backgroundColor: isDarkMode
                    ? darkDynamic?.secondary
                    : lightDynamic?.secondary,
                onPressed: () => Navigator.of(context).pushNamed('/search'),
                child: Icon(
                  Icons.search,
                  color: isDarkMode
                      ? darkDynamic?.onSecondary
                      : lightDynamic?.onSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
