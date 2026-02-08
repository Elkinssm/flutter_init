import 'package:coach_app/config/router/app_router.dart';
import 'package:coach_app/infrastructure/services/auth_service.dart';
import 'package:coach_app/presentation/helpers/globals.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Pantalla de depuración: muestra la respuesta del login (AuthResult + sesión guardada).
class AuthInfoScreen extends StatelessWidget {
  static const String name = '/auth_info_screen';

  const AuthInfoScreen({super.key, this.extra});

  final AuthResult? extra;

  @override
  Widget build(BuildContext context) {
    final auth = extra;
    if (auth == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Info Login')),
        body: const Center(
          child: Text('No hay datos de login (navegación sin extra).'),
        ),
      );
    }

    final u = auth.user;
    final tokenPreview = auth.token != null && auth.token!.length > 12
        ? '${auth.token!.substring(0, 12)}...'
        : auth.token ?? '—';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Respuesta del login'),
        backgroundColor: const Color(0xFF0B1926),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Section(
              title: 'AuthResult',
              children: [
                _Row('message', auth.message),
                _Row('token', tokenPreview),
                _Row('expiresAt', auth.expiresAt ?? '—'),
              ],
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'User (AuthUser)',
              children: [
                _Row('id', '${u.id}'),
                _Row('email', u.email),
                _Row('rol', u.rol),
                _Row('nombre', u.nombre),
                _Row('apellido', u.apellido),
                _Row('estado', u.estado),
                _Row('fecha_registro', u.fechaRegistro),
                _Row('ultimo_login', u.ultimoLogin),
                _Row('intentos_fallidos', '${u.intentosFallidos}'),
                _Row('perfil_completo', '${u.profileComplete}'),
                _Row('normalizedRole', u.normalizedRole),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Rol usado en app: ${currentUserRole ?? "—"}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                final dest = currentUserRole == 'coach'
                    ? '/coach_screen'
                    : '/player_screen';
                // Usar contexto del navigator raíz para evitar crash al reemplazar la pila.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final ctx = rootNavKey.currentContext;
                  if (ctx != null && ctx.mounted) {
                    GoRouter.of(ctx).go(dest);
                  }
                });
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0B1926),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                'Ir a ${currentUserRole == 'coach' ? 'Coach' : 'Player'}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0B1926),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
