import 'package:cinemapedia/config/constants/environment.dart';
import 'package:cinemapedia/domain/datasources/movies_datasource.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/domain/infraestructure/mappers/movie_mapper.dart';
import 'package:cinemapedia/domain/infraestructure/models/moviedb/moviedb_response.dart';
import 'package:dio/dio.dart';

class MoviedbDatasource extends MoviesDatasource {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.themoviedb.org/3',
      queryParameters: {'api_key': Environment.movieDBKey, 'language': 'es-MX'},
    ),
  );

  @override
  Future<List<Movie>> getNowPlating({int page = 1}) async {
    final response = await dio.get('/movie/now_playing');
    final movieDbResponse = MovieDbResponse.fromJson(response.data);

    final List<Movie> movies =
        movieDbResponse.results
            .map((moviedb) => MovieMapper.movieDBToEntity(moviedb))
            .toList();
    return movies;
  }
}
