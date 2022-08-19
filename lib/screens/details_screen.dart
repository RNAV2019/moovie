// ignore_for_file: constant_identifier_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moovie/constants.dart';
import 'package:moovie/main.dart';
import 'package:moovie/models/movie_model.dart';
import 'package:moovie/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsScreen extends ConsumerStatefulWidget {
  final Result movie;
  final List<String> genres;

  const DetailsScreen({
    Key? key,
    required this.movie,
    required this.genres,
  }) : super(key: key);

  @override
  ConsumerState<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends ConsumerState<DetailsScreen> {
  static const YOUTUBE_BASE_URL = "https://www.youtube.com/watch?v=";
  late MovieInfo movieInfo;
  late Future<MovieInfo?> futureMovieInfo;
  late Uri movieTrailerUrl;

  @override
  void initState() {
    futureMovieInfo = ApiService().getMovieInfo(widget.movie.id);
    // futureMovieVideo = ApiService().getMovieTrailer(widget.movie.id);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      futureMovieInfo.then((info) {
        movieInfo = info!;
        // Execute anything else you need to with your variable data.
        movieTrailerUrl =
            Uri.parse(YOUTUBE_BASE_URL + info.videos.results[0].key);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = ref.watch(darkModeProvider);
    return FutureBuilder(
      future: futureMovieInfo,
      builder: (context, snapshot) {
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
              'Details',
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
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
                                child: CachedNetworkImage(
                                  imageUrl:
                                      'https://image.tmdb.org/t/p/original${widget.movie.posterPath}',
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
                                width: MediaQuery.of(context).size.width * 0.4,
                                child: Text(
                                  widget.movie.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline5!
                                      .copyWith(
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black,
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
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_month_outlined,
                                    color: primary,
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
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: primary,
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
                                            ? Colors.white
                                            : Colors.black87),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.schedule,
                                    color: primary,
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
                                            ? Colors.white
                                            : Colors.black87),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Text(
                    widget.movie.overview,
                    style: TextStyle(
                        fontSize: 18,
                        color: isDarkMode ? Colors.white : Colors.black54),
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 20),
                //   child: SizedBox(
                //     width: MediaQuery.of(context).size.width,
                //     height: 64,
                //     child: ListView.separated(
                //       separatorBuilder: (context, index) {
                //         return const SizedBox(
                //           width: 8,
                //         );
                //       },
                //       scrollDirection: Axis.horizontal,
                //       itemCount: widget.genres.length,
                //       itemBuilder: (context, index) {
                //         return Chip(label: Text(widget.genres[index]));
                //       },
                //     ),
                //   ),
                // ),
                Wrap(
                  direction: Axis.horizontal,
                  spacing: 8.0,
                  children: widget.genres.map((item) {
                    return Chip(label: Text(item));
                  }).toList(),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: primary,
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
            child: const Icon(
              Icons.play_arrow_rounded,
              color: bgColorDark,
            ),
          ),
        );
      },
    );
  }
}
