import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moovie/main.dart';
import 'package:moovie/models/movie_model.dart';
import 'package:moovie/screens/details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavouritesScreen extends ConsumerStatefulWidget {
  final List<String> movieInfo;
  final List<String> genreLists;
  const FavouritesScreen(
      {super.key, required this.movieInfo, required this.genreLists});

  @override
  ConsumerState<FavouritesScreen> createState() => _FavouritesScreenState();
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
          widget.movieInfo.clear();
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
                itemCount: widget.movieInfo.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1800 / 2700,
                ),
                itemBuilder: (context, index) {
                  String stringInfo = widget.movieInfo[index];
                  Map<String, dynamic> jsonInfo = json.decode(stringInfo);
                  Result res = Result.fromJson(jsonInfo);
                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DetailsScreen(
                            movie: res,
                            genres: widget.genreLists[index].split('--'),
                          ),
                        ),
                      );
                    },
                    onLongPress: () {
                      setState(() {
                        widget.movieInfo.removeAt(index);
                        widget.genreLists.removeAt(index);
                      });
                      prefs.setStringList('favs', widget.movieInfo);
                      prefs.setStringList('favs-genre', widget.genreLists);
                    },
                    child: Hero(
                      tag: res.id,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: res.posterPath == null
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
                                    "https://image.tmdb.org/t/p/original${res.posterPath}",
                                key: UniqueKey(),
                              ),
                      ),
                    ),
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
