import 'package:cinemapedia/domain/infraestructure/datasources/moviedb_datasource.dart';
import 'package:cinemapedia/domain/infraestructure/repositories/movie_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Este repositorio es inmutable y se puede compartir entre todos los widgets de la aplicación.
final movieRepositoryProvider = Provider((ref) {
  return MovieRepositoryImpl(MoviedbDatasource());
});
