import 'package:cached_network_image/cached_network_image.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moovie/main.dart';
import 'package:moovie/models/movie_model.dart';
import 'package:moovie/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:unicons/unicons.dart';

class MovieDetailsScreen extends ConsumerStatefulWidget {
  final MovieResult movie;
  final List<String> genres;

  const MovieDetailsScreen({
    Key? key,
    required this.movie,
    required this.genres,
  }) : super(key: key);

  @override
  ConsumerState<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends ConsumerState<MovieDetailsScreen> {
  static const String ytBaseUrl = "https://www.youtube.com/watch?v=";
  static const Map<String, IconData> certificationIcons = <String, IconData>{
    "U": UniconsLine.zero_plus,
    "PG": UniconsLine.zero_plus,
    "12A": UniconsLine.twelve_plus,
    "12": UniconsLine.twelve_plus,
    "16": UniconsLine.sixteen_plus,
    "18": UniconsLine.eighteen_plus,
    "R18": UniconsLine.eighteen_plus,
  };
  late Future<MovieInfo?> futureMovieInfo;
  late MovieInfo movieInfo;
  late IconData? movieCertificationIcon = Icons.circle_outlined;
  late Uri movieTrailerUrl;
  late String movieCertification;

  @override
  void initState() {
    futureMovieInfo = ApiService().getMovieInfo(widget.movie.id);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      futureMovieInfo.then((info) {
        movieInfo = info!;
        List<ReleaseDate> certResult = movieInfo.releaseDates.results
            .where((element) => element.iso31661.toLowerCase() == 'gb')
            .first
            .releaseDates;
        movieCertification = certResult
            .where((element) => element.certification != '')
            .first
            .certification;
        if (movieCertification == '15') {
          movieCertification = '16';
        }
        movieCertificationIcon = certificationIcons[movieCertification];
        // Execute anything else you need to with your variable data.
        movieTrailerUrl = Uri.parse(ytBaseUrl + info.videos.results[0].key);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = ref.watch(darkModeProvider);
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return FutureBuilder(
          future: futureMovieInfo,
          builder: (context, snapshot) {
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
                  'Details',
                  style: TextStyle(
                    color: isDarkMode
                        ? darkDynamic?.onSurface
                        : lightDynamic?.onSurface,
                  ),
                ),
                centerTitle: true,
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 18),
                          child: Column(
                            children: [
                              SizedBox(
                                width: 180,
                                height: 270,
                                child: Hero(
                                  tag: widget.movie.id,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: widget.movie.posterPath == null
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
                                                  : lightDynamic
                                                      ?.errorContainer,
                                              size: 64,
                                            )),
                                          )
                                        : CachedNetworkImage(
                                            imageUrl:
                                                'https://image.tmdb.org/t/p/original${widget.movie.posterPath}',
                                            key: UniqueKey(),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          child: Column(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    child: Text(
                                      widget.movie.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall!
                                          .copyWith(
                                            color: isDarkMode
                                                ? darkDynamic?.onSurface
                                                : lightDynamic?.onSurface,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    snapshot.hasData
                                        ? movieInfo.status
                                        : "Loading...",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: snapshot.hasData &&
                                              (movieInfo.status == 'Released')
                                          ? Colors.green.shade800
                                          : darkDynamic?.errorContainer,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month_outlined,
                                        color: isDarkMode
                                            ? darkDynamic?.primary
                                            : lightDynamic?.primary,
                                        size: 22,
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        '${widget.movie.releaseDate?.day}/${widget.movie.releaseDate?.month}/${widget.movie.releaseDate?.year}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isDarkMode
                                              ? darkDynamic?.onSurface
                                              : lightDynamic?.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: isDarkMode
                                            ? darkDynamic?.primary
                                            : lightDynamic?.primary,
                                        size: 22,
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                          '${widget.movie.voteAverage.toString()}/10',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isDarkMode
                                                ? darkDynamic?.onSurface
                                                : lightDynamic?.onSurface,
                                          )),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.schedule,
                                        color: isDarkMode
                                            ? darkDynamic?.primary
                                            : lightDynamic?.primary,
                                        size: 22,
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        snapshot.hasData
                                            ? "${movieInfo.runtime} mins"
                                            : "Loading...",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isDarkMode
                                              ? darkDynamic?.onSurface
                                              : lightDynamic?.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        movieCertificationIcon,
                                        color: isDarkMode
                                            ? darkDynamic?.primary
                                            : lightDynamic?.primary,
                                        size: 22,
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        snapshot.hasData
                                            ? movieCertification
                                            : "Loading...",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isDarkMode
                                              ? darkDynamic?.onSurface
                                              : lightDynamic?.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 18),
                      child: Text(
                        widget.movie.overview,
                        style: TextStyle(
                          fontSize: 18,
                          color: isDarkMode
                              ? darkDynamic?.onSurface
                              : lightDynamic?.onSurface,
                        ),
                      ),
                    ),
                    Wrap(
                      direction: Axis.horizontal,
                      spacing: 8.0,
                      children: widget.genres.map((item) {
                        return Chip(
                          label: Text(
                            item,
                            style: TextStyle(
                                color: isDarkMode
                                    ? darkDynamic?.onPrimary
                                    : lightDynamic?.onPrimary),
                          ),
                          backgroundColor: isDarkMode
                              ? darkDynamic?.primary
                              : lightDynamic?.primary,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              floatingActionButton: FloatingActionButton(
                backgroundColor: isDarkMode
                    ? darkDynamic?.secondary
                    : lightDynamic?.secondary,
                onPressed: () async {
                  if (await canLaunchUrl(movieTrailerUrl)) {
                    await launchUrl(
                      movieTrailerUrl,
                      mode: LaunchMode.externalApplication,
                    );
                  } else {
                    throw 'Could not launch $movieTrailerUrl';
                  }
                },
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: isDarkMode
                      ? darkDynamic?.onSecondary
                      : lightDynamic?.onSecondary,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
