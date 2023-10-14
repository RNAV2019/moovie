import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moovie/main.dart';
import 'package:moovie/models/movie_model.dart';
import 'package:moovie/models/series_model.dart';
import 'package:moovie/screens/movie_details_screen.dart';
import 'package:moovie/screens/series_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavouritesScreen extends ConsumerStatefulWidget {
  final List<String> movieSeriesInfo;
  final List<String> genreLists;
  final List<String> typeInfo;
  const FavouritesScreen({
    super.key,
    required this.movieSeriesInfo,
    required this.genreLists,
    required this.typeInfo,
  });

  @override
  ConsumerState<FavouritesScreen> createState() => _FavouritesScreenState();
}

enum TypeInfo {
  movie,
  series,
}

class _FavouritesScreenState extends ConsumerState<FavouritesScreen> {
  late SharedPreferences prefs;
  Map<int, String> genreMap = {};

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((value) {
      prefs = value;
    });
  }

  showDeleteConfirmDialog(BuildContext context, ColorScheme? lightDynamic,
      ColorScheme? darkDynamic) {
    bool isDarkMode = ref.watch(darkModeProvider);
    // set up the buttons
    Widget cancelButton = MaterialButton(
      onPressed: () => Navigator.of(context).pop(),
      textColor: isDarkMode
          ? darkDynamic?.onSurfaceVariant
          : lightDynamic?.onSurfaceVariant,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(6),
        ),
      ),
      child: const Text("Cancel"),
    );
    Widget deleteButton = MaterialButton(
      textColor: isDarkMode
          ? darkDynamic?.onSurfaceVariant
          : lightDynamic?.onSurfaceVariant,
      onPressed: () {
        setState(() {
          widget.movieSeriesInfo.clear();
          widget.genreLists.clear();
        });
        prefs.clear();
        Navigator.of(context).pop();
      },
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(6),
        ),
      ),
      child: const Text("Delete"),
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Delete all favourites"),
      icon: const Icon(
        Icons.delete_forever,
        size: 28,
      ),
      iconColor: darkDynamic?.surfaceTint,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(12),
        ),
      ),
      backgroundColor: isDarkMode
          ? darkDynamic?.surfaceVariant
          : lightDynamic?.surfaceVariant,
      titleTextStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: isDarkMode
                ? darkDynamic?.onSurfaceVariant
                : lightDynamic?.onSurfaceVariant,
          ),
      contentTextStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: isDarkMode
                ? darkDynamic?.onSurfaceVariant
                : lightDynamic?.onSurfaceVariant,
          ),
      content:
          const Text("Would you like to delete all of your saved favourites?"),
      actions: [
        cancelButton,
        deleteButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DynamicColorBuilder(
          builder: (lightDynamic, darkDynamic) => alert,
        );
      },
    );
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
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: IconButton(
                  icon: Icon(
                    Icons.delete_forever,
                    color: isDarkMode
                        ? darkDynamic?.secondary
                        : lightDynamic?.secondary,
                    size: 28,
                  ),
                  onPressed: () {
                    showDeleteConfirmDialog(context, lightDynamic, darkDynamic);
                  },
                ),
              ),
            ],
            title: Text(
              'Favourites',
              style: TextStyle(
                  color: isDarkMode
                      ? darkDynamic?.onSurface
                      : lightDynamic?.onSurface),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: widget.movieSeriesInfo.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1800 / 2700,
                ),
                itemBuilder: (context, index) {
                  String stringInfo = widget.movieSeriesInfo[index];
                  TypeInfo typeInfo =
                      TypeInfo.values.byName(widget.typeInfo[index]);
                  Map<String, dynamic> jsonInfo = json.decode(stringInfo);
                  late MovieResult movieResult;
                  late SeriesResult seriesResult;
                  if (typeInfo == TypeInfo.movie) {
                    movieResult = MovieResult.fromJson(jsonInfo);
                  } else {
                    seriesResult = SeriesResult.fromJson(jsonInfo);
                  }
                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      if (typeInfo == TypeInfo.movie) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MovieDetailsScreen(
                              movie: movieResult,
                              genres: widget.genreLists[index].split('--'),
                            ),
                          ),
                        );
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SeriesDetailsScreen(
                              series: seriesResult,
                              genres: widget.genreLists[index].split('--'),
                            ),
                          ),
                        );
                      }
                    },
                    onLongPress: () {
                      setState(() {
                        widget.movieSeriesInfo.removeAt(index);
                        widget.genreLists.removeAt(index);
                        widget.typeInfo.removeAt(index);
                      });
                      prefs.setStringList('favs', widget.movieSeriesInfo);
                      prefs.setStringList('favs-genre', widget.genreLists);
                      prefs.setStringList('favs-types', widget.typeInfo);
                    },
                    child: typeInfo == TypeInfo.movie
                        ? Display(
                            id: movieResult.id,
                            posterPath: movieResult.posterPath)
                        : Display(
                            id: seriesResult.id,
                            posterPath: seriesResult.posterPath),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class Display extends ConsumerWidget {
  final int id;
  final String? posterPath;
  const Display({
    super.key,
    required this.id,
    required this.posterPath,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isDarkMode = ref.watch(darkModeProvider);
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return Hero(
          tag: id,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: posterPath == null
                ? Container(
                    width: 1800,
                    height: 2700,
                    color:
                        isDarkMode ? darkDynamic?.error : lightDynamic?.error,
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
                    imageUrl: "https://image.tmdb.org/t/p/original$posterPath",
                    key: UniqueKey(),
                  ),
          ),
        );
      },
    );
  }
}
