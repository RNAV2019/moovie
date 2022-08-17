// To parse this JSON data, do
//
//     final movieModel = movieModelFromJson(jsonString);

import 'dart:convert';

MovieModel movieModelFromJson(String str) =>
    MovieModel.fromJson(json.decode(str));

String movieModelToJson(MovieModel data) => json.encode(data.toJson());

class MovieModel {
  MovieModel({
    required this.page,
    required this.results,
    required this.totalPages,
  });

  int page;
  int totalPages;
  List<Result> results;

  factory MovieModel.fromJson(Map<String, dynamic> json) => MovieModel(
        page: json["page"],
        totalPages: json["total_pages"],
        results:
            List<Result>.from(json["results"].map((x) => Result.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "page": page,
        "total_pages": totalPages,
        "results": List<dynamic>.from(results.map((x) => x.toJson())),
      };
}

class Result {
  Result({
    required this.id,
    required this.overview,
    required this.posterPath,
    required this.releaseDate,
    required this.title,
    required this.voteAverage,
    required this.genreIds,
  });

  int id;
  String overview;
  String posterPath;
  DateTime releaseDate;
  String title;
  double voteAverage;
  List<int> genreIds;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        overview: json["overview"],
        posterPath: json["poster_path"],
        releaseDate: DateTime.parse(json["release_date"]),
        title: json["title"],
        voteAverage: json["vote_average"].toDouble(),
        genreIds: List<int>.from(json["genre_ids"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "overview": overview,
        "poster_path": posterPath,
        "release_date":
            "${releaseDate.year.toString().padLeft(4, '0')}-${releaseDate.month.toString().padLeft(2, '0')}-${releaseDate.day.toString().padLeft(2, '0')}",
        "title": title,
        "vote_average": voteAverage,
        "genre_ids": List<dynamic>.from(genreIds.map((x) => x)),
      };
}

// Genre Model
GenreModel genreModelFromJson(String str) =>
    GenreModel.fromJson(json.decode(str));

String genreModelToJson(GenreModel data) => json.encode(data.toJson());

class GenreModel {
  GenreModel({
    required this.genres,
  });

  List<Genre> genres;

  factory GenreModel.fromJson(Map<String, dynamic> json) => GenreModel(
        genres: List<Genre>.from(json["genres"].map((x) => Genre.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "genres": List<dynamic>.from(genres.map((x) => x.toJson())),
      };
}

class Genre {
  Genre({
    required this.id,
    required this.name,
  });

  int id;
  String name;

  factory Genre.fromJson(Map<String, dynamic> json) => Genre(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}

// Movie Duration
MovieInfo movieInfoModelFromJson(String str) =>
    MovieInfo.fromJson(json.decode(str));

String movieInfoModelToJson(MovieInfo data) => json.encode(data.toJson());

class MovieInfo {
  MovieInfo({
    required this.runtime,
    required this.status,
    required this.videos,
  });

  int runtime;
  String status;
  Videos videos;

  factory MovieInfo.fromJson(Map<String, dynamic> json) => MovieInfo(
        runtime: json["runtime"],
        status: json["status"],
        videos: Videos.fromJson(json["videos"]),
      );

  Map<String, dynamic> toJson() => {
        "runtime": runtime,
        "status": status,
        "videos": videos.toJson(),
      };
}

class Videos {
  Videos({
    required this.results,
  });

  List<TrailerResult> results;

  factory Videos.fromJson(Map<String, dynamic> json) => Videos(
        results: List<TrailerResult>.from(
            json["results"].map((x) => TrailerResult.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "results": List<dynamic>.from(results.map((x) => x.toJson())),
      };
}

class TrailerResult {
  TrailerResult({
    required this.iso6391,
    required this.iso31661,
    required this.name,
    required this.key,
    required this.site,
    required this.size,
    required this.type,
    required this.official,
    required this.publishedAt,
    required this.id,
  });

  Iso6391? iso6391;
  Iso31661? iso31661;
  String name;
  String key;
  Site? site;
  int size;
  Type? type;
  bool official;
  DateTime publishedAt;
  String id;

  factory TrailerResult.fromJson(Map<String, dynamic> json) => TrailerResult(
        iso6391: iso6391Values.map[json["iso_639_1"]],
        iso31661: iso31661Values.map[json["iso_3166_1"]],
        name: json["name"],
        key: json["key"],
        site: siteValues.map[json["site"]],
        size: json["size"],
        type: typeValues.map[json["type"]],
        official: json["official"],
        publishedAt: DateTime.parse(json["published_at"]),
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "iso_639_1": iso6391Values.reverse[iso6391],
        "iso_3166_1": iso31661Values.reverse[iso31661],
        "name": name,
        "key": key,
        "site": siteValues.reverse[site],
        "size": size,
        "type": typeValues.reverse[type],
        "official": official,
        "published_at": publishedAt.toIso8601String(),
        "id": id,
      };
}

enum Iso31661 { US }

final iso31661Values = EnumValues({"US": Iso31661.US});

enum Iso6391 { EN }

final iso6391Values = EnumValues({"en": Iso6391.EN});

enum Site { YOU_TUBE }

final siteValues = EnumValues({"YouTube": Site.YOU_TUBE});

enum Type { TRAILER, CLIP, BTS, TEASER }

final typeValues = EnumValues({
  "Clip": Type.CLIP,
  "Trailer": Type.TRAILER,
  "Behind the Scenes": Type.BTS,
  "Teaser": Type.TEASER
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap;
    return reverseMap;
  }
}

// Search Model

SearchModel searchModelFromJson(String str) =>
    SearchModel.fromJson(json.decode(str));

String searchModelToJson(SearchModel data) => json.encode(data.toJson());

class SearchModel {
  SearchModel({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  int page;
  List<SearchResult> results;
  int totalPages;
  int totalResults;

  factory SearchModel.fromJson(Map<String, dynamic> json) => SearchModel(
        page: json["page"],
        results: List<SearchResult>.from(
            json["results"].map((x) => SearchResult.fromJson(x))),
        totalPages: json["total_pages"],
        totalResults: json["total_results"],
      );

  Map<String, dynamic> toJson() => {
        "page": page,
        "results": List<dynamic>.from(results.map((x) => x.toJson())),
        "total_pages": totalPages,
        "total_results": totalResults,
      };
}

class SearchResult {
  SearchResult({
    required this.id,
    required this.overview,
    required this.posterPath,
    required this.releaseDate,
    required this.title,
    required this.voteAverage,
    required this.genreIds,
  });

  int id;
  String overview;
  String? posterPath;
  String releaseDate;
  String title;
  double voteAverage;
  List<int> genreIds;

  factory SearchResult.fromJson(Map<String, dynamic> json) => SearchResult(
        genreIds: List<int>.from(json["genre_ids"].map((x) => x)),
        id: json["id"],
        overview: json["overview"],
        posterPath: json["poster_path"],
        releaseDate: json["release_date"],
        title: json["title"],
        voteAverage: json["vote_average"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "genre_ids": List<dynamic>.from(genreIds.map((x) => x)),
        "id": id,
        "overview": overview,
        "poster_path": posterPath,
        "release_date": releaseDate,
        "title": title,
        "vote_average": voteAverage,
      };
}
