# cinemapedia

# Dev

1. Copiar .env.template y renombrarlo a .env
2. Cmabiar las variables de entonrno (The MovieDB)

1. Arquitectura General:

Domain Layer: Contiene entidades, repositorios abstractos y datasources abstractas. Ejemplo:
lib/domain/entities/movie.dart
lib/domain/repositories/movies_repository.dart (abstracto)
lib/domain/datasources/movies_datasource.dart (abstracto)
Infrastructure Layer: Implementa los repositorios y datasources definidos en domain. Aquí se conecta a APIs externas (The Movie DB) usando, por ejemplo, Dio.
lib/domain/infraestructure/repositories/movie_repository_impl.dart
lib/domain/infraestructure/datasources/moviedb_datasource.dart
Presentation Layer: Proveedores de estado con Riverpod y widgets. Ejemplo:
lib/presentation/providers/movies/movies_respository_provider.dart
Uso de ProviderScope en main.dart para envolver la aplicación.
2. Gestión de Estado:

Se utiliza Riverpod como framework para estado global y dependencias, facilitando el manejo inmutable y compartido de repositorios y servicios en toda la app.
3. Configuración y Temas:

Configuración de rutas (appRouter) y temas (AppTheme) en main.dart.
Uso de .env para variables sensibles (API Keys, etc).
4. Scaffolding Multi-Plataforma:

El proyecto incluye carpetas para android, linux, windows, y web, permitiendo construir para escritorio, móvil y web.
Los archivos CMakeLists.txt y scripts de plataforma muestran cómo se orquesta el build en cada sistema, siguiendo el estándar Flutter para desktop/web.
5. Plugins y Dependencias:

Integración con plugins de Flutter y configuración automática vía archivos generados (generated_plugins.cmake).
Uso de Dio para llamadas HTTP.
Ejemplo de flujo de datos:

El proveedor (movieRepositoryProvider) expone una instancia de MovieRepositoryImpl.
MovieRepositoryImpl depende de un datasource (MoviedbDatasource) que se comunica con la API de The Movie DB.
Los widgets consumen los datos a través de Riverpod, manteniendo la UI reactiva y desacoplada de la lógica de negocio.
