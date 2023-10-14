import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lottie/lottie.dart';
import 'package:moovie/main.dart';
import 'package:moovie/models/movie_model.dart';
import 'package:moovie/screens/movie_details_screen.dart';
import 'package:moovie/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MoviePageBuilder extends ConsumerStatefulWidget {
  final ScrollController controller;
  const MoviePageBuilder({super.key, required this.controller});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MoviePageBuilderState();
}

class _MoviePageBuilderState extends ConsumerState<MoviePageBuilder>
    with TickerProviderStateMixin {
  late final AnimationController _heartController;
  late final SharedPreferences prefs;
  static const _pageSize = 20;
  int heartId = 0;

  Map<int, String> genreMap = {};
  final PagingController<int, MovieResult> _pagingController =
      PagingController(firstPageKey: 1);

  Future<void> getListGenres() async {
    List<dynamic> genres = (await ApiService().getGenres())!;
    for (var i = 0; i < genres.length; i++) {
      genreMap.addAll({genres[i]['id']: genres[i]['name']});
    }
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = (await ApiService().getPopularMovies(pageKey))!;
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

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

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = ref.watch(darkModeProvider);
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return PagedGridView<int, MovieResult>(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            childAspectRatio: 1800 / 2700,
            maxCrossAxisExtent: 200,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          pagingController: _pagingController,
          scrollController: widget.controller,
          builderDelegate: PagedChildBuilderDelegate<MovieResult>(
            itemBuilder: (context, item, index) {
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  List<String> genreNames = [];
                  for (var i = 0; i < item.genreIds.length; i++) {
                    if (genreMap.containsKey(item.genreIds[i])) {
                      genreNames.add(genreMap[item.genreIds[i]] as String);
                    }
                  }

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MovieDetailsScreen(
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
                      genreNames.add(genreMap[item.genreIds[i]] as String);
                    }
                  }
                  setState(() {
                    heartId = item.id;
                  });
                  _heartController
                    ..duration = const Duration(milliseconds: 750)
                    ..forward();
                  List<String>? favList = prefs.getStringList('favs') ?? [];
                  List<String>? favGenreList =
                      prefs.getStringList('favs-genre') ?? [];
                  List<String>? favTypes =
                      prefs.getStringList('favs-types') ?? [];
                  if (favList.contains(json.encode(item))) {
                    favGenreList.removeAt(favList.indexOf(json.encode(item)));
                    favTypes.removeAt(favList.indexOf(json.encode(item)));
                    favList.remove(json.encode(item));
                  } else {
                    favList.add(json.encode(item));
                    String genreListString = '';
                    for (var i = 0; i < genreNames.length; i++) {
                      if (i == genreNames.length - 1) {
                        genreListString += genreNames[i];
                      } else {
                        genreListString += '${genreNames[i]}--';
                      }
                    }
                    favGenreList.add(genreListString);
                    favTypes.add(item.type);
                  }
                  prefs.setStringList('favs', favList);
                  prefs.setStringList('favs-genre', favGenreList);
                  prefs.setStringList('favs-types', favTypes);
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
                                        ? darkDynamic?.errorContainer
                                        : lightDynamic?.errorContainer,
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
        );
      },
    );
  }
}
