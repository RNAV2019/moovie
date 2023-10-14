// To parse this JSON data, do
//
//     final series = seriesFromJson(jsonString);

import 'dart:convert';

SeriesModel seriesFromJson(String str) =>
    SeriesModel.fromJson(json.decode(str));

String seriesToJson(SeriesModel data) => json.encode(data.toJson());

class SeriesModel {
  int page;
  List<SeriesResult> results;

  SeriesModel({
    required this.page,
    required this.results,
  });

  factory SeriesModel.fromJson(Map<String, dynamic> json) => SeriesModel(
        page: json["page"],
        results: List<SeriesResult>.from(
            json["results"].map((x) => SeriesResult.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "page": page,
        "results": List<dynamic>.from(results.map((x) => x.toJson())),
      };
}

class SeriesResult {
  String? backdropPath;
  DateTime firstAirDate;
  List<int> genreIds;
  int id;
  String name;
  String overview;
  double popularity;
  String? posterPath;
  double voteAverage;
  int voteCount;
  String type = "series";

  SeriesResult({
    required this.backdropPath,
    required this.firstAirDate,
    required this.genreIds,
    required this.id,
    required this.name,
    required this.overview,
    required this.popularity,
    required this.posterPath,
    required this.voteAverage,
    required this.voteCount,
  });

  factory SeriesResult.fromJson(Map<String, dynamic> json) => SeriesResult(
        backdropPath: json["backdrop_path"],
        firstAirDate: DateTime.parse(json["first_air_date"]),
        genreIds: List<int>.from(json["genre_ids"].map((x) => x)),
        id: json["id"],
        name: json["name"],
        overview: json["overview"],
        popularity: json["popularity"]?.toDouble(),
        posterPath: json["poster_path"],
        voteAverage: json["vote_average"]?.toDouble(),
        voteCount: json["vote_count"],
      );

  Map<String, dynamic> toJson() => {
        "backdrop_path": backdropPath,
        "first_air_date":
            "${firstAirDate.year.toString().padLeft(4, '0')}-${firstAirDate.month.toString().padLeft(2, '0')}-${firstAirDate.day.toString().padLeft(2, '0')}",
        "genre_ids": List<dynamic>.from(genreIds.map((x) => x)),
        "id": id,
        "name": name,
        "overview": overview,
        "popularity": popularity,
        "poster_path": posterPath,
        "vote_average": voteAverage,
        "vote_count": voteCount,
      };
}

// Series Info

SeriesInfo seriesInfoModelFromJson(String str) =>
    SeriesInfo.fromJson(json.decode(str));

String seriesInfoToJson(SeriesInfo data) => json.encode(data.toJson());

class SeriesInfo {
  DateTime? firstAirDate;
  int? numberOfEpisodes;
  int? numberOfSeasons;
  String? status;
  ContentRatings? contentRatings;

  SeriesInfo({
    required this.firstAirDate,
    required this.numberOfEpisodes,
    required this.numberOfSeasons,
    required this.status,
    required this.contentRatings,
  });

  factory SeriesInfo.fromJson(Map<String, dynamic> json) => SeriesInfo(
        firstAirDate: DateTime.parse(json["first_air_date"]),
        numberOfEpisodes: json["number_of_episodes"],
        numberOfSeasons: json["number_of_seasons"],
        status: json["status"],
        contentRatings: ContentRatings.fromJson(json["content_ratings"]),
      );

  Map<String, dynamic> toJson() => {
        "first_air_date":
            "${firstAirDate?.year.toString().padLeft(4, '0')}-${firstAirDate?.month.toString().padLeft(2, '0')}-${firstAirDate?.day.toString().padLeft(2, '0')}",
        "number_of_episodes": numberOfEpisodes,
        "number_of_seasons": numberOfSeasons,
        "status": status,
        "content_ratings": contentRatings?.toJson(),
      };
}

class ContentRatings {
  List<ContentResult>? results;

  ContentRatings({
    required this.results,
  });

  factory ContentRatings.fromJson(Map<String, dynamic> json) => ContentRatings(
        results: List<ContentResult>.from(
            json["results"].map((x) => ContentResult.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "results": List<dynamic>.from(results!.map((x) => x.toJson())),
      };
}

class ContentResult {
  List<String>? descriptors;
  String? iso31661;
  String? rating;

  ContentResult({
    required this.descriptors,
    required this.iso31661,
    required this.rating,
  });

  factory ContentResult.fromJson(Map<String, dynamic> json) => ContentResult(
        descriptors: List<String>.from(json["descriptors"].map((x) => x)),
        iso31661: json["iso_3166_1"],
        rating: json["rating"],
      );

  Map<String, dynamic> toJson() => {
        "descriptors": List<dynamic>.from(descriptors!.map((x) => x)),
        "iso_3166_1": iso31661,
        "rating": rating,
      };
}

class Season {
  DateTime? airDate;
  int? episodeCount;
  int? id;
  String? name;
  String? overview;
  String? posterPath;
  int? seasonNumber;
  double? voteAverage;

  Season({
    required this.airDate,
    required this.episodeCount,
    required this.id,
    required this.name,
    required this.overview,
    required this.posterPath,
    required this.seasonNumber,
    required this.voteAverage,
  });

  factory Season.fromJson(Map<String, dynamic> json) => Season(
        airDate: DateTime.parse(json["air_date"]),
        episodeCount: json["episode_count"],
        id: json["id"],
        name: json["name"],
        overview: json["overview"],
        posterPath: json["poster_path"],
        seasonNumber: json["season_number"],
        voteAverage: json["vote_average"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "air_date":
            "${airDate?.year.toString().padLeft(4, '0')}-${airDate?.month.toString().padLeft(2, '0')}-${airDate?.day.toString().padLeft(2, '0')}",
        "episode_count": episodeCount,
        "id": id,
        "name": name,
        "overview": overview,
        "poster_path": posterPath,
        "season_number": seasonNumber,
        "vote_average": voteAverage,
      };
}
