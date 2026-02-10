import 'dart:io';

import 'package:coach_app/config/constants/environment.dart';
import 'package:coach_app/infrastructure/services/coach_api_service.dart';
import 'package:coach_app/infrastructure/services/dashboard_service.dart';
import 'package:coach_app/infrastructure/services/upload_api_service.dart';
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
      if (mounted) setState(() => _loadingMeta = false);
      return;
    }

    try {
      final coachApi = ref.read(coachApiServiceProvider);
      final categoriasData = await coachApi.getCategorias();
      final posicionesData = await coachApi.getPosiciones();

      final categoriasRaw = categoriasData?['categorias'] as List<dynamic>? ?? const [];
      _equipos = categoriasRaw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
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
    } catch (_) {
      if (!mounted) return;
      CustomModal.showNetworkError(
        context,
        detail: 'No fue posible cargar equipos/posiciones.',
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
    return const [];
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
    setState(() {
      _equipoError = equipoOk ? null : 'Selecciona un equipo';
    });
    if (!formOk || !equipoOk) return;

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
      final uploadApi = ref.read(uploadApiServiceProvider);

      String? fotoUrl;
      if (_selectedImage != null) {
        final fileName = _selectedImage!.path.split(Platform.pathSeparator).last;
        final uploadRes = await uploadApi.uploadFoto(
          await MultipartFile.fromFile(_selectedImage!.path, filename: fileName),
        );
        fotoUrl = uploadRes['url']?.toString() ??
            uploadRes['foto_url']?.toString() ??
            uploadRes['path']?.toString();
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
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(249, 248, 247, 1),
        appBar: CustomAppbar(
          title: 'Añadir jugador',
          onPressed: () => context.pop(),
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
                  _equipoError = null;
                }),
                onPosicionChanged: (v) => setState(() => _posicionId = v),
                onDorsalChanged: (v) => setState(() => _dorsal = v),
                onAlturaChanged: (v) => setState(() => _alturaCm = v),
                onPesoChanged: (v) => setState(() => _pesoKg = v),
                onPieChanged: (v) => setState(() => _pieHabil = v),
                onSubmit: _submit,
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
    required this.onPosicionChanged,
    required this.onDorsalChanged,
    required this.onAlturaChanged,
    required this.onPesoChanged,
    required this.onPieChanged,
    required this.onSubmit,
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
  final ValueChanged<int?> onPosicionChanged;
  final ValueChanged<int?> onDorsalChanged;
  final ValueChanged<int?> onAlturaChanged;
  final ValueChanged<double?> onPesoChanged;
  final ValueChanged<String?> onPieChanged;
  final VoidCallback onSubmit;

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
              lockEquipo
                  ? _LockedField(
                      text: _equipoLabelById(equipos, equipoId) ?? 'Equipo asignado',
                    )
                  : _SelectField<int>(
                      value: equipoId,
                      hint: 'Selecciona equipo',
                      items: equipos
                          .map((e) => DropdownMenuItem<int>(
                                value: e['id'] as int,
                                child: Text(_equipoLabel(e)),
                              ))
                          .toList(),
                      onChanged: onEquipoChanged,
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
                  text: saving ? 'Guardando...' : 'Crear Jugador',
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
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
