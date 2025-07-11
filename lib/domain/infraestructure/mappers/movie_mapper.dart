import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/domain/infraestructure/models/moviedb/movie_moviedb.dart';

class MovieMapper {
  static Movie movieDBToEntity(MovieMovieDB moviedb) => Movie(
    backdropPath:
        moviedb.backdropPath != ''
            ? 'https://image.tmdb.org/t/p/w500${moviedb.backdropPath}'
            : 'https://cdn11.bigcommerce.com/s-2gncvdgiio/images/stencil/1280x1280/products/89573/171487/Keep_Calm_Ok_Not_That_Calm_Znl_291118_frr__30524.1589150191.jpg?c=1',
    adult: moviedb.adult,
    genreIds: moviedb.genreIds.map((e) => e.toString()).toList(),
    id: moviedb.id,
    originalLanguage: moviedb.originalLanguage,
    originalTitle: moviedb.originalTitle,
    overview: moviedb.overview,
    popularity: moviedb.popularity,
    posterPath:
        moviedb.posterPath != ''
            ? 'https://image.tmdb.org/t/p/w500${moviedb.posterPath}'
            : 'https://cdn11.bigcommerce.com/s-2gncvdgiio/images/stencil/1280x1280/products/89573/171487/Keep_Calm_Ok_Not_That_Calm_Znl_291118_frr__30524.1589150191.jpg?c=1',
    releaseDate: moviedb.releaseDate,
    title: moviedb.title,
    video: moviedb.video,
    voteAverage: moviedb.voteAverage,
    voteCount: moviedb.voteCount,
  );
}
