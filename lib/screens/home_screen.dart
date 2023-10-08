// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lottie/lottie.dart';
import 'package:moovie/main.dart';
import 'package:moovie/models/movie_model.dart';
import 'package:moovie/screens/details_screen.dart';
import 'package:moovie/screens/favourites_screen.dart';
import 'package:moovie/screens/settings_screen.dart';
import 'package:moovie/services/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _heartController;
  late final SharedPreferences prefs;
  int heartId = 0;
  List<Result> movies = [];
  List<MovieInfo> movieInfos = [];
  Map<int, String> genreMap = {};
  bool isLoaded = false;

  static const _pageSize = 20;

  final PagingController<int, Result> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(vsync: this);
    _heartController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _heartController.reverse();
      }
    });
    SharedPreferences.getInstance().then((value) {
      prefs = value;
    });
    getListGenres();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _heartController.dispose();
    _pagingController.dispose();
  }

  Future<void> getListGenres() async {
    List<dynamic> genres = (await ApiService().getGenres())!;
    for (var i = 0; i < genres.length; i++) {
      genreMap.addAll({genres[i]['id']: genres[i]['name']});
    }
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = (await ApiService().getMovies(pageKey))!;
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
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
                            'Relax and find a movie',
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
                                movieInfo: prefs.getStringList("favs") ?? [],
                                genreLists:
                                    prefs.getStringList("favs-genre") ?? [],
                              ),
                            ),
                          );
                        },
                      ),
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
                  const SizedBox(
                    height: 36,
                  ),
                  Expanded(
                    child: PagedGridView<int, Result>(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        childAspectRatio: 1800 / 2700,
                        maxCrossAxisExtent: 200,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                      ),
                      pagingController: _pagingController,
                      builderDelegate: PagedChildBuilderDelegate<Result>(
                        itemBuilder: (context, item, index) {
                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              List<String> genreNames = [];
                              for (var i = 0; i < item.genreIds.length; i++) {
                                if (genreMap.containsKey(item.genreIds[i])) {
                                  genreNames.add(
                                      genreMap[item.genreIds[i]] as String);
                                }
                              }

                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => DetailsScreen(
                                    movie: item,
                                    genres: genreNames,
                                  ),
                                ),
                              );
                            },
                            onLongPress: () {
                              List<String> genreNames = [];
                              for (var i = 0; i < item.genreIds.length; i++) {
                                if (genreMap.containsKey(item.genreIds[i])) {
                                  genreNames.add(
                                      genreMap[item.genreIds[i]] as String);
                                }
                              }
                              setState(() {
                                heartId = item.id;
                              });
                              _heartController
                                ..duration = const Duration(milliseconds: 750)
                                ..forward();
                              List<String>? favList =
                                  prefs.getStringList('favs') ?? [];
                              List<String>? favGenreList =
                                  prefs.getStringList('favs-genre') ?? [];
                              if (favList.contains(json.encode(item))) {
                                favGenreList.removeAt(
                                    favList.indexOf(json.encode(item)));
                                favList.remove(json.encode(item));
                              } else {
                                favList.add(json.encode(item));
                                String genreListString = '';
                                // for (String genre in genreNames) {

                                // }
                                for (var i = 0; i < genreNames.length; i++) {
                                  if (i == genreNames.length - 1) {
                                    genreListString += genreNames[i];
                                  } else {
                                    genreListString += '${genreNames[i]}--';
                                  }
                                }
                                favGenreList.add(genreListString);
                              }
                              prefs.setStringList('favs', favList);
                              prefs.setStringList('favs-genre', favGenreList);
                              print('${item.title} has been held down btw');
                            },
                            child: Container(
                              alignment: Alignment.center,
                              child: Stack(
                                children: [
                                  Hero(
                                    tag: item.id,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: item.posterPath == null
                                          ? Container(
                                              width: 1800,
                                              height: 2700,
                                              color: isDarkMode
                                                  ? darkDynamic?.error
                                                  : lightDynamic?.error,
                                              child: Center(
                                                  child: Icon(
                                                Icons.block,
                                                color: isDarkMode
                                                    ? darkDynamic
                                                        ?.errorContainer
                                                    : lightDynamic
                                                        ?.errorContainer,
                                                size: 64,
                                              )),
                                            )
                                          : CachedNetworkImage(
                                              imageUrl:
                                                  'https://image.tmdb.org/t/p/original${item.posterPath}',
                                              key: UniqueKey(),
                                            ),
                                    ),
                                  ),
                                  item.id == heartId
                                      ? Lottie.asset(
                                          'assets/heart.json',
                                          controller: _heartController,
                                          animate: true,
                                          height: 2700,
                                          width: 1800,
                                          fit: BoxFit.contain,
                                          frameRate: FrameRate(120),
                                        )
                                      : Container()
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
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
