import 'dart:convert';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:moovie/models/movie_model.dart';

const BASE_URL = "https://api.themoviedb.org/3/movie";
const BASE_IMAGE_URL = "https://image.tmdb.org/t/p/w500";
const BASE_SEARCH_URL = "https://api.themoviedb.org/3/search/movie";

class ApiService {
  var client = http.Client();

  // Gets a list of recent movies
  Future<List<Result>?> getMovies(int? page) async {
    try {
      var uri = Uri.parse(
          "$BASE_URL/now_playing?api_key=${dotenv.env['API_KEY']}&language=en-GB&page=${page ?? 1}");
      var response = await client.get(uri);
      if (response.statusCode == 200) {
        var json = response.body;
        return movieModelFromJson(json).results;
      }
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

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
    } catch (e) {
      log(e.toString());
    }
    return;
  }

  // Get Movie Info (Runtime, Status and Trailer Video) from Movie
  Future<MovieInfo?> getMovieInfo(int id) async {
    try {
      var uri = Uri.parse(
          "$BASE_URL/${id.toString()}?api_key=${dotenv.env['API_KEY']}&append_to_response=videos");
      var response = await client.get(uri);
      if (response.statusCode == 200) {
        var json = response.body;
        // var decoded = jsonDecode(json);
        // return decoded["runtime"].toString();
        return movieInfoModelFromJson(json);
      }
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

  // Search through The Movie Database for the movies
  Future<List<SearchResult>?> searchMovie(String query) async {
    try {
      var uri = Uri.parse(
          "$BASE_SEARCH_URL?api_key=${dotenv.env['API_KEY']}&query=$query");
      var response = await client.get(uri);
      if (response.statusCode == 200) {
        var json = response.body;
        return searchModelFromJson(json).results;
      }
    } catch (e, s) {
      log("$e - $s - SearchResults");
    }
    return null;
  }
}
