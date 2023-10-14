// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:moovie/models/movie_model.dart';
import 'package:moovie/models/search_model.dart';
import 'package:moovie/models/series_model.dart';

const BASE_MOVIE_URL = "https://api.themoviedb.org/3/movie";
const BASE_SERIES_URL = "https://api.themoviedb.org/3/tv";
const BASE_IMAGE_URL = "https://image.tmdb.org/t/p/w500";
const BASE_SEARCH_URL = "https://api.themoviedb.org/3/search/movie";

const Map<String, String> API_HEADERS = <String, String>{
  "Authorization":
      "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJkYjA1ZDkwZTg2MTgxNjk5YTIzNWQ1MzI5N2VmNGM4MiIsInN1YiI6IjYyZjgwMTA1ZTc4Njg3MDA3YWM4YzE5YyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.zIFx_MF2o2Oimm8qlFUFUTR-TvjjH0tRnUjYw_yL9sM",
  "Accept": "application/json"
};

class ApiService {
  var client = http.Client();

  // Gets the list of genres
  Future<dynamic> getGenres() async {
    try {
      var uri = Uri.parse(
          "https://api.themoviedb.org/3/genre/movie/list?api_key=${dotenv.env['API_KEY']}&language=en-GB");
      var response = await client.get(uri);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final data = decoded['genres'];
        // final subset = decoded['genres'][0];
        return data;
      }
    } catch (e, s) {
      log("$e - $s");
    }
    return;
  }

  // Gets a list of popular movies
  Future<List<MovieResult>?> getPopularMovies(int page) async {
    try {
      var uri = Uri.parse(
          "$BASE_MOVIE_URL/now_playing?api_key=${dotenv.env['API_KEY']}&page=$page&language=en_GB");
      var response = await client.get(uri);
      if (response.statusCode == 200) {
        var json = response.body;
        return movieModelFromJson(json).results;
      }
    } catch (e, s) {
      log("$e - $s");
    }
    return null;
  }

  // Gets a list of popular series
  Future<List<SeriesResult>?> getPopularSeries(int page) async {
    try {
      var uri = Uri.parse(
          "$BASE_SERIES_URL/top_rated?api_key=${dotenv.env['API_KEY']}&language=en_GB&page=$page");
      var response = await client.get(uri);
      if (response.statusCode == 200) {
        var json = response.body;
        return seriesFromJson(json).results;
      }
    } catch (e, s) {
      log("$e - $s");
    }
    return null;
  }

  // Get Movie Info (Runtime, Status and Trailer Video) from Movie ID
  Future<MovieInfo?> getMovieInfo(int id) async {
    try {
      var uri = Uri.parse(
          "$BASE_MOVIE_URL/${id.toString()}?api_key=${dotenv.env['API_KEY']}&append_to_response=videos,release_dates");
      var response = await client.get(uri);
      if (response.statusCode == 200) {
        var json = response.body;
        return movieInfoModelFromJson(json);
      }
    } catch (e, s) {
      log("$e - $s");
    }
    return null;
  }

  // Get Series Info from Series ID
  Future<SeriesInfo?> getSeriesInfo(int id) async {
    try {
      var uri = Uri.parse(
          "$BASE_SERIES_URL/${id.toString()}?api_key=${dotenv.env['API_KEY']}&append_to_response=content_ratings");
      var response = await client.get(uri);
      if (response.statusCode == 200) {
        var json = response.body;
        return seriesInfoModelFromJson(json);
      }
    } catch (e, s) {
      log("$e - $s");
    }
    return null;
  }

  // Search through The Movie Database for the movies
  Future<List<SearchResult>?> searchMovie(String query, int pageKey) async {
    try {
      var uri = Uri.parse(
          "$BASE_SEARCH_URL?api_key=${dotenv.env['API_KEY']}&query=$query&page=$pageKey&language=en_GB");
      var response = await client.get(uri);
      if (response.statusCode == 200) {
        var json = response.body;
        return searchModelFromJson(json).results;
      }
    } catch (e, s) {
      log("$e - $s");
    }
    return null;
  }
}
