import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
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

  static const _pageSize = 20;

  final PagingController<int, Result> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    super.initState();
    getListGenres();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  @override
  void dispose() {
    super.dispose();
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
                child: PagedGridView<int, Result>(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
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
                              genreNames
                                  .add(genreMap[item.genreIds[i]] as String);
                            }
                          }

                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => DetailsScreen(
                                    movie: item,
                                    genres: genreNames,
                                  )));
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: Hero(
                            tag: item.id,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: item.posterPath == null
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
                                          'https://image.tmdb.org/t/p/original${item.posterPath}',
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
