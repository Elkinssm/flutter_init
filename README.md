# Coach_App

Coach_App es una aplicación Flutter multi-plataforma para explorar películas usando la API de [The Movie DB](https://www.themoviedb.org/). El proyecto está estructurado siguiendo buenas prácticas de Clean Architecture y usa Riverpod para la gestión de estado.

## 🚀 Desarrollo Local

1. **Configura las variables de entorno**
   - Copia el archivo `.env.template` y renómbralo a `.env`.
   - Cambia las variables de entorno según tu clave de The Movie DB.

2. **Instala dependencias**
   ```bash
   flutter pub get
   ```

3. **Corre la app**
   ```bash
   flutter run
   ```

---

## 🏗️ Arquitectura General

El proyecto está estructurado en tres capas principales:

### 1. **Domain Layer**
- Contiene entidades, repositorios abstractos y datasources abstractas.
- Ejemplo de archivos:
  - `lib/domain/entities/movie.dart`
  - `lib/domain/repositories/movies_repository.dart` (abstracto)
  - `lib/domain/datasources/movies_datasource.dart` (abstracto)

### 2. **Infrastructure Layer**
- Implementa los repositorios y datasources definidos en _Domain_.
- Se conecta a APIs externas (The Movie DB) usando, por ejemplo, Dio.
- Ejemplo de archivos:
  - `lib/domain/infraestructure/repositories/movie_repository_impl.dart`
  - `lib/domain/infraestructure/datasources/moviedb_datasource.dart`

### 3. **Presentation Layer**
- Proveedores de estado con Riverpod y widgets.
- Ejemplo de archivos:
  - `lib/presentation/providers/movies/movies_respository_provider.dart`
- Uso de `ProviderScope` en `main.dart` para envolver la aplicación.

---

## 🔄 Gestión de Estado

- **Riverpod** se utiliza como framework para estado global y dependencias.
- Facilita el manejo inmutable y compartido de repositorios y servicios en toda la app.

---

## 🎨 Configuración y Temas

- Configuración de rutas (`appRouter`) y temas (`AppTheme`) en `main.dart`.
- Uso de `.env` para variables sensibles (API Keys, etc).

---

## 🖥️ Scaffolding Multi-Plataforma

- El proyecto incluye carpetas para `android`, `linux`, `windows`, y `web`, permitiendo construir para escritorio, móvil y web.
- Los archivos `CMakeLists.txt` y scripts de plataforma orquestan el build en cada sistema, siguiendo el estándar Flutter para desktop/web.

---

## 🔌 Plugins y Dependencias

- Integración con plugins de Flutter y configuración automática vía archivos generados (`generated_plugins.cmake`).
- Uso de **Dio** para llamadas HTTP.

---

## 📦 Ejemplo de Flujo de Datos

1. El proveedor (`movieRepositoryProvider`) expone una instancia de `MovieRepositoryImpl`.
2. `MovieRepositoryImpl` depende de un datasource (`MoviedbDatasource`) que se comunica con la API de The Movie DB.
3. Los widgets consumen los datos a través de Riverpod, manteniendo la UI reactiva y desacoplada de la lógica de negocio.

---

## 📝 Licencia

MIT
