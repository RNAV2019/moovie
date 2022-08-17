import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moovie/constants.dart';
import 'package:moovie/main.dart';
import 'package:moovie/models/movie_model.dart';
import 'package:moovie/screens/details_screen.dart';
import 'package:moovie/services/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<Result> movies = [];
  List<MovieInfo> movieInfos = [];
  Map<int, String> genreMap = {};
  bool isLoaded = false;
  int pageNumber = 1;

  @override
  void initState() {
    super.initState();
    _getMoviesAndInfo(1);
  }

  _getMoviesAndInfo(int? page) async {
    movies = (await ApiService().getMovies(page))!;
    List<dynamic> genres = (await ApiService().getGenres())!;
    for (var i = 0; i < genres.length; i++) {
      genreMap.addAll({genres[i]['id']: genres[i]['name']});
    }

    if (movies.isNotEmpty) {
      setState(() {
        isLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = ref.watch(darkModeProvider);
    return Scaffold(
      backgroundColor: isDarkMode ? bgColorDark : bgColorLight,
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
                            color: isDarkMode ? Colors.grey[500] : Colors.black,
                            fontSize: 14),
                      ),
                      Text(
                        'Relax and watch a movie',
                        style: TextStyle(
                          color: isDarkMode ? Colors.grey[300] : Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.more_vert,
                          color: isDarkMode ? Colors.grey[300] : Colors.black,
                        ),
                        onPressed: () {
                          Navigator.of(context).pushNamed('/settings');
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 18,
              ),
              const SizedBox(
                height: 18,
              ),
              Expanded(
                child: Visibility(
                  visible: isLoaded,
                  replacement: Center(
                    child: CircularProgressIndicator(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      childAspectRatio: 1800 / 2700,
                      maxCrossAxisExtent: 200,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    itemCount: movies.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          List<String> genreNames = [];
                          for (var i = 0;
                              i < movies[index].genreIds.length;
                              i++) {
                            if (genreMap
                                .containsKey(movies[index].genreIds[i])) {
                              genreNames.add(genreMap[movies[index].genreIds[i]]
                                  as String);
                            }
                          }

                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => DetailsScreen(
                                    movie: movies[index],
                                    genres: genreNames,
                                  )));
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: Hero(
                            tag: movies[index].id,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: CachedNetworkImage(
                                imageUrl:
                                    'https://image.tmdb.org/t/p/original${movies[index].posterPath}',
                              ),
                            ),
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
        backgroundColor: primary,
        onPressed: () => Navigator.of(context).pushNamed('/search'),
        child: const Icon(
          Icons.search,
          color: bgColorDark,
        ),
      ),
    );
  }
}
