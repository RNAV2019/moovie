import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moovie/components/search.dart';
import 'package:moovie/constants.dart';
import 'package:moovie/main.dart';
import 'package:moovie/models/movie_model.dart';
import 'package:moovie/screens/details_screen.dart';
import 'package:moovie/services/api_service.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  List<SearchResult>? results = [];
  Map<int, String> genreMap = {};
  int page = 1;

  @override
  void initState() {
    super.initState();
    getGenres();
  }

  void getGenres() async {
    List<dynamic> genres = (await ApiService().getGenres())!;
    for (var i = 0; i < genres.length; i++) {
      genreMap.addAll({genres[i]['id']: genres[i]['name']});
    }
  }

  void getSearchResults(String query) async {
    results = await ApiService().searchMovie(query, 1);
    setState(() {
      results;
    });
  }

  void getNewSearchResults(String query) async {
    List<SearchResult>? tmpResults =
        await ApiService().searchMovie(query, page);
    tmpResults != null
        ? results?.addAll(tmpResults.map((movie) => movie))
        : null;
    setState(() {
      results;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = ref.watch(darkModeProvider);
    String queryState = ref.watch(queryProvider);
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
          'Search',
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
          child: Column(
            children: [
              Search(
                getSearchResults: getSearchResults,
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: NotificationListener<ScrollEndNotification>(
                    onNotification: (scrollEnd) {
                      final metrics = scrollEnd.metrics;
                      if (metrics.atEdge) {
                        bool isTop = metrics.pixels == 0;
                        if (isTop) {
                        } else {
                          setState(() {
                            page += 1;
                            getNewSearchResults(queryState);
                          });
                        }
                      }
                      return true;
                    },
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        childAspectRatio: 1800 / 2700,
                        maxCrossAxisExtent: 200,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                      ),
                      itemCount: results?.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            List<String> genreNames = [];
                            for (var i = 0;
                                i < results![index].genreIds.length;
                                i++) {
                              if (genreMap
                                  .containsKey(results![index].genreIds[i])) {
                                genreNames.add(
                                    genreMap[results![index].genreIds[i]]
                                        as String);
                              }
                            }

                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => DetailsScreen(
                                      movie: Result.fromJson(
                                          results![index].toJson()),
                                      genres: genreNames,
                                    )));
                          },
                          child: Container(
                            alignment: Alignment.center,
                            child: Hero(
                              tag: results != null ? results![index].id : "",
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: results == null ||
                                        results?[index].posterPath == null
                                    ? Container(
                                        width: 1800,
                                        height: 2700,
                                        color: Colors.grey[600],
                                        child: const Center(
                                            child: Icon(
                                          Icons.block,
                                          color: Colors.red,
                                          size: 64,
                                        )),
                                      )
                                    : CachedNetworkImage(
                                        imageUrl:
                                            'https://image.tmdb.org/t/p/original${results![index].posterPath}',
                                        key: UniqueKey(),
                                      ),
                              ),
                            ),
                          ),
                        );
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
