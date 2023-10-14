import 'package:cached_network_image/cached_network_image.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moovie/main.dart';
import 'package:moovie/models/series_model.dart';
import 'package:moovie/services/api_service.dart';
import 'package:unicons/unicons.dart';

class SeriesDetailsScreen extends ConsumerStatefulWidget {
  final SeriesResult series;
  final List<String> genres;

  const SeriesDetailsScreen({
    Key? key,
    required this.series,
    required this.genres,
  }) : super(key: key);

  @override
  ConsumerState<SeriesDetailsScreen> createState() =>
      _SeriesDetailsScreenState();
}

class _SeriesDetailsScreenState extends ConsumerState<SeriesDetailsScreen> {
  // static const String ytBaseUrl = "https://www.youtube.com/watch?v=";
  static const Map<String, IconData> certificationIcons = <String, IconData>{
    "U": UniconsLine.zero_plus,
    "PG": UniconsLine.zero_plus,
    "12A": UniconsLine.twelve_plus,
    "12": UniconsLine.twelve_plus,
    "16": UniconsLine.sixteen_plus,
    "18": UniconsLine.eighteen_plus,
    "R18": UniconsLine.eighteen_plus,
  };
  late Future<SeriesInfo?> futureSeriesInfo;
  late SeriesInfo seriesInfo;
  IconData? seriesCertificationIcon = Icons.circle_outlined;
  // late Uri seriesTrailerUrl;
  String seriesCertification = "No Rating Found";

  @override
  void initState() {
    print(widget.series.id);
    futureSeriesInfo = ApiService().getSeriesInfo(widget.series.id);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      futureSeriesInfo.then((info) {
        seriesInfo = info!;
        seriesCertification = seriesInfo.contentRatings!.results!
            .where((element) => element.iso31661!.toLowerCase() == 'gb')
            .first
            .rating!;
        if (seriesCertification == '15') {
          seriesCertification = '16';
        }
        seriesCertificationIcon = certificationIcons[seriesCertification];
        // Execute anything else you need to with your variable data.
        // movieTrailerUrl = Uri.parse(ytBaseUrl + info.videos.results[0].key);
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
          future: futureSeriesInfo,
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
                                  tag: widget.series.id,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: widget.series.posterPath == null
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
                                                'https://image.tmdb.org/t/p/original${widget.series.posterPath}',
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
                                      widget.series.name,
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
                                    snapshot.hasData &&
                                            seriesInfo.status != null
                                        ? seriesInfo.status!
                                        : "Loading...",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: snapshot.hasData &&
                                              (seriesInfo.status == 'Returning Series' ||
                                                  seriesInfo.status ==
                                                      'In Production' ||
                                                  seriesInfo.status ==
                                                      'Planned')
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
                                        UniconsLine.film,
                                        color: isDarkMode
                                            ? darkDynamic?.primary
                                            : lightDynamic?.primary,
                                        size: 22,
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        '${widget.series.firstAirDate.day}/${widget.series.firstAirDate.month}/${widget.series.firstAirDate.year}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isDarkMode
                                              ? darkDynamic?.onSurface
                                              : lightDynamic?.onSurface,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 6,
                                      ),
                                      Tooltip(
                                        triggerMode: TooltipTriggerMode.tap,
                                        preferBelow: true,
                                        enableFeedback: true,
                                        verticalOffset: 10.0,
                                        textAlign: TextAlign.center,
                                        textStyle: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 2,
                                        ),
                                        showDuration:
                                            const Duration(milliseconds: 2000),
                                        message: 'Date the first episode aired',
                                        child: Icon(
                                          UniconsLine.info_circle,
                                          color: darkDynamic?.primary,
                                          size: 16,
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
                                        '${widget.series.voteAverage.toString()}/10',
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
                                        UniconsLine.tv_retro,
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
                                            ? "${seriesInfo.numberOfSeasons} ${seriesInfo.numberOfSeasons == 1 ? 'season' : 'seasons'}"
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
                                        UniconsLine.video,
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
                                            ? "${seriesInfo.numberOfEpisodes} ${seriesInfo.numberOfEpisodes == 1 ? 'episode' : 'episodes'}"
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
                                        seriesCertificationIcon,
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
                                            ? seriesCertification
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
                        widget.series.overview,
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
              // floatingActionButton: FloatingActionButton(
              //   backgroundColor: isDarkMode
              //       ? darkDynamic?.secondary
              //       : lightDynamic?.secondary,
              //   onPressed: () async {
              //     if (await canLaunchUrl(movieTrailerUrl)) {
              //       await launchUrl(
              //         movieTrailerUrl,
              //         mode: LaunchMode.externalApplication,
              //       );
              //     } else {
              //       throw 'Could not launch $movieTrailerUrl';
              //     }
              //   },
              //   child: Icon(
              //     Icons.play_arrow_rounded,
              //     color: isDarkMode
              //         ? darkDynamic?.onSecondary
              //         : lightDynamic?.onSecondary,
              //   ),
              // ),
            );
          },
        );
      },
    );
  }
}
