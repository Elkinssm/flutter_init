# coach_app

Aplicación Flutter para gestión deportiva con dos perfiles de usuario:

- `Coach`: administra equipos, categorías, jugadores y partidos.
- `Jugador`: consulta su perfil, categoría, asistencia, historial y rendimiento.

## Qué hace la app

- Autenticación con login/registro.
- Enrutamiento por rol (`coach` o `player`) con control de acceso.
- Dashboard para coach con métricas y acciones rápidas.
- Dashboard para jugador con estado de perfil, asistencia y próximo encuentro.
- Gestión de equipos, detalle de equipo y estado de jugadores.
- Historial de asistencia con opción de exportar/compartir PDF.

## Stack técnico

- Flutter + Dart
- Riverpod (estado)
- go_router (navegación)
- Dio (HTTP)
- table_calendar y syncfusion_flutter_charts (UI de datos)
- shared_preferences (sesión local)

## Estructura principal

- `lib/config/`: entorno, router, tema, errores.
- `lib/infrastructure/services/`: servicios de API y sesión.
- `lib/presentation/screens/`: pantallas de autenticación y negocio.
- `lib/presentation/providers/`: estado global y de UI.
- `lib/presentation/widgets/`: componentes reutilizables.

## Flujo funcional resumido

1. App inicia en `loading_screen`.
2. Navega a `welcome_screen`.
3. Usuario hace `login` o `register`.
4. Se identifica rol:
- `coach` -> `coach_screen`
- `player` -> `player_screen`
5. Según rol, se habilitan rutas y acciones permitidas.

## Desarrollo local

1. Instalar dependencias:

```bash
flutter pub get
```

2. Configurar variables de entorno en `.env`.

3. Ejecutar:

```bash
flutter run
```

## Notas de rutas

- Rutas públicas: `loading`, `welcome`, `login`, `register`, `health_check`.
- El `coach` puede acceder a todas las pantallas.
- El `player` está restringido a sus pantallas de jugador.

## Licencia

MIT
