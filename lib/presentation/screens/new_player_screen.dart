import 'dart:io';

import 'package:coach_app/config/constants/environment.dart';
import 'package:coach_app/infrastructure/services/coach_api_service.dart';
import 'package:coach_app/infrastructure/services/dashboard_service.dart';
import 'package:coach_app/infrastructure/services/mi_perfil_service.dart';
import 'package:coach_app/infrastructure/services/public_api_service.dart';
import 'package:coach_app/infrastructure/services/upload_api_service.dart';
import 'package:coach_app/presentation/providers/auth_role_provider.dart';
import 'package:coach_app/presentation/providers/profile_incomplete_provider.dart';
import 'package:coach_app/presentation/providers/session_provider.dart';
import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class NewPlayerScreen extends ConsumerStatefulWidget {
  static const String name = '/new_player_screen';
  const NewPlayerScreen({super.key, this.equipoId});

  final int? equipoId;

  @override
  ConsumerState<NewPlayerScreen> createState() => _NewPlayerScreenState();
}

class _NewPlayerScreenState extends ConsumerState<NewPlayerScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombreCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  final _fechaCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _saludCtrl = TextEditingController();

  final _picker = ImagePicker();

  bool _loadingMeta = true;
  bool _saving = false;
  File? _selectedImage;

  List<Map<String, dynamic>> _equipos = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _posiciones = <Map<String, dynamic>>[];

  int? _equipoId;
  String? _categoria;
  int? _posicionId;
  int? _dorsal;
  int? _alturaCm;
  double? _pesoKg;
  String? _pieHabil;

  String? _equipoError;

  static const _piesHabiles = <String>['Derecha', 'Izquierda', 'Ambas'];
  static final _dorsales = List<int>.generate(99, (i) => i + 1);
  static final _alturasCm = List<int>.generate(151, (i) => i + 100);
  static final _pesosKg = List<double>.generate(191, (i) => (i + 10).toDouble());
  bool get _isPlayerMode => ref.read(currentUserRoleProvider) == 'player';

  @override
  void initState() {
    super.initState();
    _equipoId = widget.equipoId;
    Future.microtask(_loadInitialData);
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _fechaCtrl.dispose();
    _telefonoCtrl.dispose();
    _emailCtrl.dispose();
    _saludCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() => _loadingMeta = true);

    // Precargar datos de sesión para no pedir al usuario repetir información.
    try {
      final sessionUser = await ref.read(sessionServiceProvider).getSavedUser();
      if (sessionUser != null) {
        if (_emailCtrl.text.trim().isEmpty) {
          _emailCtrl.text = sessionUser.email;
        }
        if (_nombreCtrl.text.trim().isEmpty &&
            sessionUser.nombre.trim().isNotEmpty) {
          _nombreCtrl.text = sessionUser.nombre.trim();
        }
        if (_apellidoCtrl.text.trim().isEmpty &&
            sessionUser.apellido.trim().isNotEmpty) {
          _apellidoCtrl.text = sessionUser.apellido.trim();
        }
      }
    } catch (_) {
      // Si falla lectura de sesión, continuamos con carga normal.
    }

    // Precargar desde /mi-perfil (fuente de verdad al editar perfil).
    if (Environment.useBackend && _isPlayerMode) {
      try {
        final miPerfil = await ref.read(miPerfilServiceProvider).getMiPerfil();
        _prefillFromMiPerfil(miPerfil);
      } catch (_) {
        // Si falla, seguimos con sesión + metadatos.
      }
    }

    if (!Environment.useBackend) {
      _equipos = [
        {'id': 1, 'nombre': 'Juveniles A', 'categoria': 'U17'},
        {'id': 2, 'nombre': 'Juveniles B', 'categoria': 'U15'},
      ];
      _posiciones = [
        {'id': 1, 'nombre': 'Portero', 'codigo': 'PO'},
        {'id': 2, 'nombre': 'Defensa', 'codigo': 'DF'},
        {'id': 3, 'nombre': 'Mediocampista', 'codigo': 'MC'},
        {'id': 4, 'nombre': 'Delantero', 'codigo': 'DL'},
      ];
      _equipoId ??= (_equipos.isNotEmpty ? _equipos.first['id'] as int : null);
      _categoria = _categoriaByEquipoId(_equipoId);
      if (mounted) setState(() => _loadingMeta = false);
      return;
    }

    try {
      Map<String, dynamic>? categoriasData;
      Map<String, dynamic>? posicionesData;
      if (_isPlayerMode) {
        final publicApi = ref.read(publicApiServiceProvider);
        categoriasData = await publicApi.getEquiposDisponibles();
        categoriasData ??= await publicApi.getEquipos();
        if (categoriasData == null) {
          throw Exception('No fue posible cargar equipos públicos.');
        }
        posicionesData = await publicApi.getPosiciones();
      } else {
        final coachApi = ref.read(coachApiServiceProvider);
        categoriasData = await coachApi.getCategorias();
        posicionesData = await coachApi.getPosiciones();
      }

      final categoriasRaw = _isPlayerMode
          ? _extractListFromPayload(
              categoriasData,
              preferredKeys: const ['equipos', 'data'],
            )
          : (categoriasData?['categorias'] as List<dynamic>? ?? const []);
      _equipos = categoriasRaw
          .whereType<Map>()
          .map((e) => _normalizeEquipoForForm(Map<String, dynamic>.from(e)))
          .toList();

      final posicionesRaw = _extractListFromPayload(
        posicionesData,
        preferredKeys: const ['posiciones', 'data'],
      );
      _posiciones = posicionesRaw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      final currentExists = _equipos.any((e) => e['id'] == _equipoId);
      if (!currentExists) {
        _equipoId = _equipos.isNotEmpty ? _equipos.first['id'] as int : null;
      }
      _categoria = _categoriaByEquipoId(_equipoId);
    } catch (_) {
      if (!mounted) return;
      CustomModal.showNetworkError(
        context,
        detail: _isPlayerMode
            ? 'No fue posible cargar equipos/categorías del backend.'
            : 'No fue posible cargar equipos/posiciones.',
      );
    } finally {
      if (mounted) setState(() => _loadingMeta = false);
    }
  }

  List<dynamic> _extractListFromPayload(
    Map<String, dynamic>? data, {
    required List<String> preferredKeys,
  }) {
    if (data == null) return const [];
    for (final key in preferredKeys) {
      final v = data[key];
      if (v is List) return v;
    }
    final dataNode = data['data'];
    if (dataNode is List) return dataNode;
    if (dataNode is Map) {
      final nested = Map<String, dynamic>.from(dataNode);
      for (final key in preferredKeys) {
        final v = nested[key];
        if (v is List) return v;
      }
      final items = nested['items'];
      if (items is List) return items;
    }
    return const [];
  }

  String? _categoriaByEquipoId(int? id) {
    if (id == null) return null;
    for (final e in _equipos) {
      if (e['id'] == id) return e['categoria']?.toString();
    }
    return null;
  }

  Map<String, dynamic> _normalizeEquipoForForm(Map<String, dynamic> raw) {
    final id = raw['id'] ?? raw['equipo_id'];
    final nombre = (raw['nombre'] ??
            raw['equipo'] ??
            raw['nombre_equipo'] ??
            raw['equipo_nombre'] ??
            '')
        .toString()
        .trim();
    final rawCategoria = raw['categoria'] ??
        raw['categoria_nombre'] ??
        raw['nombre_categoria'] ??
        raw['categoria_codigo'];
    final categoria = rawCategoria is Map
        ? (rawCategoria['nombre'] ??
                rawCategoria['codigo'] ??
                rawCategoria['categoria'] ??
                '')
            .toString()
            .trim()
        : (rawCategoria ?? '').toString().trim();

    return {
      ...raw,
      'id': id,
      'nombre': nombre.isEmpty ? 'Equipo' : nombre,
      'categoria': categoria,
    };
  }

  void _prefillFromMiPerfil(Map<String, dynamic>? payload) {
    if (payload == null) return;

    final usuario = payload['usuario'] is Map
        ? Map<String, dynamic>.from(payload['usuario'])
        : <String, dynamic>{};
    final jugador = payload['jugador'] is Map
        ? Map<String, dynamic>.from(payload['jugador'])
        : <String, dynamic>{};
    final equipoActual = payload['equipo_actual'] is Map
        ? Map<String, dynamic>.from(payload['equipo_actual'])
        : <String, dynamic>{};

    final nombre = (usuario['nombre'] ?? jugador['nombre'] ?? '').toString().trim();
    final apellido = (usuario['apellido'] ?? jugador['apellido'] ?? '').toString().trim();
    final email = (usuario['email'] ?? jugador['email'] ?? '').toString().trim();

    if (nombre.isNotEmpty && _nombreCtrl.text.trim().isEmpty) {
      _nombreCtrl.text = nombre;
    }
    if (apellido.isNotEmpty && _apellidoCtrl.text.trim().isEmpty) {
      _apellidoCtrl.text = apellido;
    }
    if (email.isNotEmpty && _emailCtrl.text.trim().isEmpty) {
      _emailCtrl.text = email;
    }

    final fecha = (jugador['fecha_nacimiento'] ?? '').toString().trim();
    if (fecha.isNotEmpty && _fechaCtrl.text.trim().isEmpty) {
      _fechaCtrl.text = fecha;
    }

    final telefono = (jugador['telefono_contacto'] ?? '').toString().trim();
    if (telefono.isNotEmpty && _telefonoCtrl.text.trim().isEmpty) {
      _telefonoCtrl.text = telefono;
    }

    final salud = (jugador['estado_salud'] ?? '').toString().trim();
    if (salud.isNotEmpty && _saludCtrl.text.trim().isEmpty) {
      _saludCtrl.text = salud;
    }

    final equipoIdRaw = jugador['equipo_id'] ?? jugador['equipo_actual_id'] ?? jugador['equipo'];
    final equipoIdVal = equipoIdRaw is int ? equipoIdRaw : int.tryParse(equipoIdRaw?.toString() ?? '');
    final equipoActualIdRaw = equipoActual['id'];
    final equipoActualIdVal = equipoActualIdRaw is int
        ? equipoActualIdRaw
        : int.tryParse(equipoActualIdRaw?.toString() ?? '');
    if (equipoIdVal != null) {
      _equipoId = equipoIdVal;
    } else if (equipoActualIdVal != null) {
      _equipoId = equipoActualIdVal;
    }

    final dorsalRaw = jugador['dorsal_actual'] ?? jugador['dorsal'];
    final dorsalVal = dorsalRaw is int ? dorsalRaw : int.tryParse(dorsalRaw?.toString() ?? '');
    if (dorsalVal != null) _dorsal = dorsalVal;

    final alturaRaw = jugador['altura_cm'];
    final alturaVal = alturaRaw is int ? alturaRaw : int.tryParse(alturaRaw?.toString() ?? '');
    if (alturaVal != null) _alturaCm = alturaVal;

    final pesoRaw = jugador['peso_kg'];
    final pesoVal = pesoRaw is num ? pesoRaw.toDouble() : double.tryParse(pesoRaw?.toString() ?? '');
    if (pesoVal != null) _pesoKg = pesoVal;

    final pie = (jugador['pie_habil'] ?? '').toString().trim();
    if (pie.isNotEmpty) _pieHabil = pie;

    final posRaw = jugador['posicion_id'];
    final posVal = posRaw is int ? posRaw : int.tryParse(posRaw?.toString() ?? '');
    if (posVal != null) _posicionId = posVal;

    final categoria = (jugador['categoria'] ?? jugador['categoria_nombre'] ?? '').toString().trim();
    final categoriaRoot = (equipoActual['categoria'] ?? '').toString().trim();
    if (categoria.isNotEmpty) {
      _categoria = categoria;
    } else if (categoriaRoot.isNotEmpty) {
      _categoria = categoriaRoot;
    }
  }

  List<String> _categoriasDisponibles() {
    final set = _equipos
        .map((e) => (e['categoria']?.toString() ?? '').trim())
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    set.sort();
    return set;
  }

  List<Map<String, dynamic>> _equiposFiltrados() {
    if ((_categoria ?? '').isEmpty) return _equipos;
    return _equipos.where((e) => e['categoria']?.toString() == _categoria).toList();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 12, now.month, now.day),
      firstDate: DateTime(1990, 1, 1),
      lastDate: now,
      helpText: 'Selecciona fecha de nacimiento',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _fechaCtrl.text =
          '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await _picker.pickImage(
      source: source,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (image == null || !mounted) return;
    setState(() => _selectedImage = File(image.path));
  }

  Future<void> _showPhotoOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const CustomText(
                  text: 'Seleccionar foto',
                  fontWeight: FontWeight.w700,
                  size: 18,
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: const Text('Tomar foto'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Elegir de galería'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final formOk = _formKey.currentState?.validate() ?? false;
    final equipoOk = _equipoId != null;
    final posicionOk = !_isPlayerMode || _posicionId != null;
    final fechaOk = !_isPlayerMode || _fechaCtrl.text.trim().isNotEmpty;
    final categoriaOk = !_isPlayerMode || ((_categoria ?? '').trim().isNotEmpty);
    setState(() {
      _equipoError = equipoOk
          ? null
          : 'Selecciona un equipo';
    });
    if (!formOk || !equipoOk || !posicionOk || !fechaOk || !categoriaOk) {
      if (_isPlayerMode && mounted) {
        CustomModal.show(
          context: context,
          title: 'Faltan datos',
          message: !categoriaOk
              ? 'El backend no está enviando categoría por equipo. No se puede completar el perfil hasta corregir ese dato.'
              : 'Completa fecha de nacimiento y posición para continuar.',
          type: ModalType.warning,
          buttonText: 'Entendido',
        );
      }
      return;
    }

    if (!Environment.useBackend) {
      if (!mounted) return;
      CustomModal.show(
        context: context,
        title: 'Jugador creado',
        message: 'Guardado en modo local (mock).',
        type: ModalType.success,
        buttonText: 'Aceptar',
        onButtonPressed: () {
          Navigator.of(context).pop();
          if (context.canPop()) context.pop();
        },
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final coachApi = ref.read(coachApiServiceProvider);
      final miPerfilApi = ref.read(miPerfilServiceProvider);
      final uploadApi = ref.read(uploadApiServiceProvider);

      String? fotoUrl;
      MultipartFile? fotoFile;
      if (_selectedImage != null) {
        final fileName = _selectedImage!.path.split(Platform.pathSeparator).last;
        fotoFile = await MultipartFile.fromFile(_selectedImage!.path, filename: fileName);
        if (!_isPlayerMode) {
          final uploadRes = await uploadApi.uploadFoto(fotoFile);
          fotoUrl = uploadRes['url']?.toString() ??
              uploadRes['foto_url']?.toString() ??
              uploadRes['path']?.toString();
        }
      }

      if (_isPlayerMode) {
        final body = <String, dynamic>{
          'nombre': _nombreCtrl.text.trim(),
          'apellido': _apellidoCtrl.text.trim(),
          'equipo_id': _equipoId,
          'posicion_id': _posicionId ?? (_posiciones.isNotEmpty ? _posiciones.first['id'] : null),
          'fecha_nacimiento': _fechaCtrl.text.trim(),
          'anio_vinculacion': DateTime.now().year,
          'lugar_nacimiento': 'No definido',
          'ciudad_residencia': 'No definido',
          'telefono_contacto': _telefonoCtrl.text.trim().isEmpty
              ? '0000000000'
              : _telefonoCtrl.text.trim(),
          'acudiente_nombre_1': 'No definido',
          'acudiente_telefono': _telefonoCtrl.text.trim().isEmpty
              ? '0000000000'
              : _telefonoCtrl.text.trim(),
          'pie_habil': _pieHabil ?? 'Derecha',
        };
        if (_dorsal != null) body['dorsal_actual'] = _dorsal;
        if (_alturaCm != null) body['altura_cm'] = _alturaCm;
        if (_pesoKg != null) body['peso_kg'] = _pesoKg;
        if (_saludCtrl.text.trim().isNotEmpty) {
          body['estado_salud'] = _saludCtrl.text.trim();
        }

        final res = await miPerfilApi.putMiPerfilCompletar(body);
        if (fotoFile != null) {
          await miPerfilApi.putMiPerfilFoto(fotoFile);
        }
        ref.invalidate(miPerfilProvider);
        ref.invalidate(jugadorDashboardProvider);
        ref.read(currentUserProfileCompleteProvider.notifier).state = true;
        final fullName =
            '${_nombreCtrl.text.trim()} ${_apellidoCtrl.text.trim()}'.trim();
        if (fullName.isNotEmpty) {
          ref.read(currentUserDisplayNameProvider.notifier).state = fullName;
          final parts = fullName.split(RegExp(r'\s+'));
          final initials = parts.length > 1
              ? '${parts.first[0]}${parts.last[0]}'
              : parts.first[0];
          ref.read(currentUserInitialsProvider.notifier).state = initials.toUpperCase();
        }

        final message = res['message']?.toString() ?? 'Perfil completado correctamente.';
        if (!mounted) return;
        CustomModal.show(
          context: context,
          title: 'Perfil completado',
          message: message,
          type: ModalType.success,
          buttonText: 'Aceptar',
          onButtonPressed: () {
            Navigator.of(context).pop();
            if (!context.mounted) return;
            context.go('/player_screen');
          },
        );
        return;
      }

      final body = <String, dynamic>{
        'nombre_completo': '${_nombreCtrl.text.trim()} ${_apellidoCtrl.text.trim()}'.trim(),
        'equipo_id': _equipoId,
      };

      if (_dorsal != null) body['dorsal'] = _dorsal;
      if (_fechaCtrl.text.trim().isNotEmpty) {
        body['fecha_nacimiento'] = _fechaCtrl.text.trim();
      }
      if (_posicionId != null) body['posicion_id'] = _posicionId;

      if (_alturaCm != null) body['altura_cm'] = _alturaCm;
      if (_pesoKg != null) body['peso_kg'] = _pesoKg;

      if ((_pieHabil ?? '').isNotEmpty) body['pie_habil'] = _pieHabil;
      if (_telefonoCtrl.text.trim().isNotEmpty) {
        body['telefono_contacto'] = _telefonoCtrl.text.trim();
      }
      if (_emailCtrl.text.trim().isNotEmpty) body['email'] = _emailCtrl.text.trim();
      if (_saludCtrl.text.trim().isNotEmpty) {
        body['estado_salud'] = _saludCtrl.text.trim();
      }
      if ((fotoUrl ?? '').isNotEmpty) body['foto_url'] = fotoUrl;

      final res = await coachApi.postJugadorByCategoria(_equipoId!, body);
      final message = res['message']?.toString() ?? 'Jugador creado exitosamente.';

      ref.invalidate(coachDashboardProvider);
      ref.invalidate(coachCategoriasProvider);
      if (_equipoId != null) ref.invalidate(coachJugadoresProvider(_equipoId!));

      if (!mounted) return;
      CustomModal.show(
        context: context,
        title: 'Registro exitoso',
        message: message,
        type: ModalType.success,
        buttonText: 'Aceptar',
        onButtonPressed: () {
          Navigator.of(context).pop();
          if (context.canPop()) context.pop();
        },
      );
    } catch (e) {
      if (!mounted) return;
      CustomModal.show(
        context: context,
        title: 'No se pudo crear',
        message: '$e',
        type: ModalType.error,
        buttonText: 'Aceptar',
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPlayerMode = ref.watch(currentUserRoleProvider) == 'player';
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(249, 248, 247, 1),
        appBar: CustomAppbar(
          title: isPlayerMode ? 'Completar perfil' : 'Añadir jugador',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(isPlayerMode ? '/player_screen' : '/coach_screen');
            }
          },
        ),
        bottomNavigationBar: const CustomBottomAppbar(),
        floatingActionButton: const CustomFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: _loadingMeta
            ? const Center(child: CircularProgressIndicator())
            : _NewPlayerView(
                formKey: _formKey,
                nombreCtrl: _nombreCtrl,
                apellidoCtrl: _apellidoCtrl,
                fechaCtrl: _fechaCtrl,
                telefonoCtrl: _telefonoCtrl,
                emailCtrl: _emailCtrl,
                saludCtrl: _saludCtrl,
                selectedImage: _selectedImage,
                equipos: _equipos,
                categorias: _categoriasDisponibles(),
                categoria: _categoria,
                equiposFiltrados: _equiposFiltrados(),
                posiciones: _posiciones,
                equipoId: _equipoId,
                lockEquipo: widget.equipoId != null,
                posicionId: _posicionId,
                dorsal: _dorsal,
                alturaCm: _alturaCm,
                pesoKg: _pesoKg,
                pieHabil: _pieHabil,
                equipoError: _equipoError,
                saving: _saving,
                onPickDate: _pickBirthDate,
                onPickPhoto: _showPhotoOptions,
                onEquipoChanged: (v) => setState(() {
                  _equipoId = v;
                  _categoria = _categoriaByEquipoId(v) ?? _categoria;
                  _equipoError = null;
                }),
                onCategoriaChanged: (v) => setState(() {
                  _categoria = v;
                  final filtrados = _equiposFiltrados();
                  final exists = filtrados.any((e) => e['id'] == _equipoId);
                  _equipoId = exists
                      ? _equipoId
                      : (filtrados.isNotEmpty ? filtrados.first['id'] as int : null);
                  _equipoError = null;
                }),
                onPosicionChanged: (v) => setState(() => _posicionId = v),
                onDorsalChanged: (v) => setState(() => _dorsal = v),
                onAlturaChanged: (v) => setState(() => _alturaCm = v),
                onPesoChanged: (v) => setState(() => _pesoKg = v),
                onPieChanged: (v) => setState(() => _pieHabil = v),
                onSubmit: _submit,
                isPlayerMode: isPlayerMode,
              ),
      ),
    );
  }
}

class _NewPlayerView extends StatelessWidget {
  const _NewPlayerView({
    required this.formKey,
    required this.nombreCtrl,
    required this.apellidoCtrl,
    required this.fechaCtrl,
    required this.telefonoCtrl,
    required this.emailCtrl,
    required this.saludCtrl,
    required this.selectedImage,
    required this.equipos,
    required this.categorias,
    required this.categoria,
    required this.equiposFiltrados,
    required this.posiciones,
    required this.equipoId,
    required this.lockEquipo,
    required this.posicionId,
    required this.dorsal,
    required this.alturaCm,
    required this.pesoKg,
    required this.pieHabil,
    required this.equipoError,
    required this.saving,
    required this.onPickDate,
    required this.onPickPhoto,
    required this.onEquipoChanged,
    required this.onCategoriaChanged,
    required this.onPosicionChanged,
    required this.onDorsalChanged,
    required this.onAlturaChanged,
    required this.onPesoChanged,
    required this.onPieChanged,
    required this.onSubmit,
    required this.isPlayerMode,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nombreCtrl;
  final TextEditingController apellidoCtrl;
  final TextEditingController fechaCtrl;
  final TextEditingController telefonoCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController saludCtrl;

  final File? selectedImage;
  final List<Map<String, dynamic>> equipos;
  final List<String> categorias;
  final String? categoria;
  final List<Map<String, dynamic>> equiposFiltrados;
  final List<Map<String, dynamic>> posiciones;
  final int? equipoId;
  final bool lockEquipo;
  final int? posicionId;
  final int? dorsal;
  final int? alturaCm;
  final double? pesoKg;
  final String? pieHabil;
  final String? equipoError;
  final bool saving;

  final VoidCallback onPickDate;
  final VoidCallback onPickPhoto;
  final ValueChanged<int?> onEquipoChanged;
  final ValueChanged<String?> onCategoriaChanged;
  final ValueChanged<int?> onPosicionChanged;
  final ValueChanged<int?> onDorsalChanged;
  final ValueChanged<int?> onAlturaChanged;
  final ValueChanged<double?> onPesoChanged;
  final ValueChanged<String?> onPieChanged;
  final VoidCallback onSubmit;
  final bool isPlayerMode;

  @override
  Widget build(BuildContext context) {
    final kb = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Form(
          key: formKey,
          child: ListView(
            padding: EdgeInsets.only(top: 20, bottom: kb + 24),
            children: [
              const _FieldLabel(text: 'Nombre'),
              _InputField(
                controller: nombreCtrl,
                hintText: 'Ingresa el nombre',
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'El nombre es obligatorio'
                    : null,
              ),
              const SizedBox(height: 12),

              const _FieldLabel(text: 'Apellido'),
              _InputField(
                controller: apellidoCtrl,
                hintText: 'Ingresa el apellido',
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'El apellido es obligatorio'
                    : null,
              ),
              const SizedBox(height: 12),

              const _FieldLabel(text: 'Equipo'),
              if (!lockEquipo && categorias.isNotEmpty) ...[
                const SizedBox(height: 8),
                const _FieldLabel(text: 'Categoría'),
                _SelectField<String>(
                  value: categoria,
                  hint: 'Selecciona categoría',
                  items: categorias
                      .map(
                        (c) => DropdownMenuItem<String>(
                          value: c,
                          child: Text(c),
                        ),
                      )
                      .toList(),
                  onChanged: categorias.isEmpty ? null : onCategoriaChanged,
                ),
                const SizedBox(height: 12),
                const _FieldLabel(text: 'Equipo'),
              ],
              if (!lockEquipo && categorias.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4, bottom: 6),
                  child: Text(
                    'No llegaron categorías desde backend para los equipos.',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              lockEquipo
                  ? _LockedField(
                      text: _equipoLabelById(equipos, equipoId) ?? 'Equipo asignado',
                    )
                  : _SelectField<int>(
                      value: equipoId,
                      hint: 'Selecciona equipo',
                      items: (categorias.isEmpty ? equipos : equiposFiltrados)
                          .map((e) => DropdownMenuItem<int>(
                                value: e['id'] as int,
                                child: Text(_equipoLabel(e)),
                              ))
                          .toList(),
                      onChanged: onEquipoChanged,
                    ),
              if (equipoId != null)
                Builder(
                  builder: (_) {
                    final selected = _equipoById(equipos, equipoId);
                    final categoriaSel =
                        (selected?['categoria']?.toString() ?? '').trim();
                    final escuelaSel =
                        (selected?['escuela_nombre']?.toString() ?? '').trim();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8, left: 4),
                      child: Text(
                        'Categoría: ${categoriaSel.isEmpty ? '--' : categoriaSel}'
                        '${escuelaSel.isEmpty ? '' : '   •   Escuela: $escuelaSel'}',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                        ),
                      ),
                    );
                  },
                ),
              if ((equipoError ?? '').isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    equipoError!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(height: 12),

              const _FieldLabel(text: 'Número de camiseta'),
              _WheelPickerField<int>(
                value: dorsal,
                hint: 'Selecciona dorsal',
                options: _NewPlayerScreenState._dorsales,
                labelOf: (n) => '$n',
                onChanged: onDorsalChanged,
              ),
              const SizedBox(height: 12),

              const _FieldLabel(text: 'Fecha de nacimiento'),
              InkWell(
                onTap: onPickDate,
                child: AbsorbPointer(
                  child: _InputField(
                    controller: fechaCtrl,
                    hintText: 'YYYY-MM-DD',
                  ),
                ),
              ),
              const SizedBox(height: 12),

              const _FieldLabel(text: 'Posición'),
              _SelectField<int>(
                value: posicionId,
                hint: posiciones.isEmpty ? 'Sin posiciones disponibles' : 'Selecciona posición',
                items: posiciones
                    .map((p) => DropdownMenuItem<int>(
                          value: p['id'] as int,
                          child: Text(_posicionLabel(p)),
                        ))
                    .toList(),
                onChanged: posiciones.isEmpty ? null : onPosicionChanged,
              ),
              const SizedBox(height: 12),

              const _FieldLabel(text: 'Altura'),
              _WheelPickerField<int>(
                value: alturaCm,
                hint: 'Selecciona altura (cm)',
                options: _NewPlayerScreenState._alturasCm,
                labelOf: (n) => '$n cm',
                onChanged: onAlturaChanged,
              ),
              const SizedBox(height: 12),

              const _FieldLabel(text: 'Peso'),
              _WheelPickerField<double>(
                value: pesoKg,
                hint: 'Selecciona peso (kg)',
                options: _NewPlayerScreenState._pesosKg,
                labelOf: (n) => '${n.toStringAsFixed(0)} kg',
                onChanged: onPesoChanged,
              ),
              const SizedBox(height: 12),

              const _FieldLabel(text: 'Pierna hábil'),
              _SelectField<String>(
                value: pieHabil,
                hint: 'Selecciona pierna hábil',
                items: _NewPlayerScreenState._piesHabiles
                    .map((p) => DropdownMenuItem<String>(value: p, child: Text(p)))
                    .toList(),
                onChanged: onPieChanged,
              ),
              const SizedBox(height: 12),

              const _FieldLabel(text: 'Teléfono de contacto'),
              _InputField(
                controller: telefonoCtrl,
                hintText: '300 123 4567',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),

              const _FieldLabel(text: 'Correo electrónico'),
              _InputField(
                controller: emailCtrl,
                hintText: 'jugador@email.com',
                keyboardType: TextInputType.emailAddress,
                readOnly: isPlayerMode,
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (t.isEmpty) return null;
                  if (!t.contains('@')) return 'Correo inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              const _FieldLabel(text: 'Estado de salud / Lesiones actuales'),
              _InputField(
                controller: saludCtrl,
                hintText: 'Describe el estado',
                maxLines: 3,
              ),
              const SizedBox(height: 12),

              const _FieldLabel(text: 'Foto (opcional)'),
              InkWell(
                onTap: onPickPhoto,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: selectedImage == null
                      ? Row(
                          children: const [
                            Icon(Icons.camera_alt_outlined, color: Colors.grey),
                            SizedBox(width: 8),
                            Text('Seleccionar foto'),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                selectedImage!,
                                height: 140,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                              'Cambiar foto',
                              textAlign: TextAlign.left,
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OnboardingNextButton(
                  text: saving
                      ? 'Guardando...'
                      : (isPlayerMode ? 'Completar perfil' : 'Crear Jugador'),
                  isEnabled: !saving,
                  action: saving ? null : onSubmit,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  static String _equipoLabel(Map<String, dynamic> e) {
    final nombre = e['nombre']?.toString() ?? 'Equipo';
    final categoria = e['categoria']?.toString() ?? '';
    return categoria.isEmpty ? nombre : '$nombre - $categoria';
  }

  static Map<String, dynamic>? _equipoById(
    List<Map<String, dynamic>> equipos,
    int? id,
  ) {
    if (id == null) return null;
    for (final e in equipos) {
      if (e['id'] == id) return e;
    }
    return null;
  }

  static String? _equipoLabelById(List<Map<String, dynamic>> equipos, int? id) {
    if (id == null) return null;
    for (final e in equipos) {
      if (e['id'] == id) return _equipoLabel(e);
    }
    return null;
  }

  static String _posicionLabel(Map<String, dynamic> p) {
    final nombre = p['nombre']?.toString() ?? '';
    final codigo = p['codigo']?.toString() ?? '';
    if (nombre.isEmpty && codigo.isEmpty) return 'Posición';
    if (codigo.isEmpty) return nombre;
    if (nombre.isEmpty) return codigo;
    return '$nombre ($codigo)';
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            height: 1.2,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.readOnly = false,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      readOnly: readOnly,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: readOnly ? const Color.fromRGBO(245, 245, 245, 1) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: readOnly
            ? const Icon(Icons.lock_outline, size: 18, color: Colors.grey)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}

class _SelectField<T> extends StatelessWidget {
  const _SelectField({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  final T? value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}

class _LockedField extends StatelessWidget {
  const _LockedField({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
          const Icon(Icons.lock_outline, size: 18, color: Colors.grey),
        ],
      ),
    );
  }
}

class _WheelPickerField<T> extends StatelessWidget {
  const _WheelPickerField({
    required this.value,
    required this.hint,
    required this.options,
    required this.labelOf,
    required this.onChanged,
  });

  final T? value;
  final String hint;
  final List<T> options;
  final String Function(T value) labelOf;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final display = value == null ? hint : labelOf(value as T);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        if (options.isEmpty) return;
        final selected = await _showPicker(context);
        if (selected != null) onChanged(selected);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                display,
                style: TextStyle(
                  fontSize: 16,
                  color: value == null ? Colors.grey[700] : Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Future<T?> _showPicker(BuildContext context) async {
    var selectedIndex = 0;
    if (value != null) {
      final idx = options.indexOf(value as T);
      selectedIndex = idx >= 0 ? idx : 0;
    }

    return showModalBottomSheet<T>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        var tempIndex = selectedIndex;
        final controller = FixedExtentScrollController(initialItem: selectedIndex);

        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: SizedBox(
                height: 320,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancelar'),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, options[tempIndex]),
                            child: const Text('Aceptar'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListWheelScrollView.useDelegate(
                        controller: controller,
                        itemExtent: 44,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          setModalState(() => tempIndex = index);
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: options.length,
                          builder: (context, index) {
                            final item = options[index];
                            final selected = index == tempIndex;
                            return Center(
                              child: Text(
                                labelOf(item),
                                style: TextStyle(
                                  fontSize: selected ? 20 : 17,
                                  fontWeight:
                                      selected ? FontWeight.w700 : FontWeight.w400,
                                  color: selected ? Colors.black : Colors.grey[700],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
