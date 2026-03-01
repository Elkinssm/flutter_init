import 'dart:io';

import 'package:coach_app/config/constants/environment.dart';
import 'package:coach_app/infrastructure/services/coach_api_service.dart';
import 'package:coach_app/infrastructure/services/dashboard_service.dart';
import 'package:coach_app/infrastructure/services/upload_api_service.dart';
import 'package:coach_app/presentation/helpers/api_error_message.dart';
import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class CreateTeamScreen extends ConsumerStatefulWidget {
  static const String name = '/create_team_screen';
  const CreateTeamScreen({super.key});

  @override
  ConsumerState<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends ConsumerState<CreateTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _picker = ImagePicker();

  String? _categoria;
  File? _escudoFile;
  bool _saving = false;

  String get _teamInitials {
    final raw = _nombreCtrl.text.trim();
    if (raw.isEmpty) return 'EQ';
    final parts = raw.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'EQ';
    if (parts.length == 1) {
      final word = parts.first;
      return (word.length >= 2 ? word.substring(0, 2) : word).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  List<String> _buildCategorias(Map<String, dynamic>? payload) {
    final raw = payload?['categorias'] as List<dynamic>? ?? const [];
    final set =
        raw
            .whereType<Map>()
            .map((e) => (e['categoria'] ?? '').toString().trim())
            .where((v) => v.isNotEmpty)
            .toSet()
            .toList();
    if (set.isEmpty) {
      return const ['U13', 'U15', 'U17', 'U20'];
    }
    set.sort();
    return set;
  }

  Future<void> _pickEscudo() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (image == null || !mounted) return;
    setState(() => _escudoFile = File(image.path));
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final formOk = _formKey.currentState?.validate() ?? false;
    if (!formOk || (_categoria ?? '').trim().isEmpty) {
      CustomModal.show(
        context: context,
        title: 'Faltan datos',
        message: 'Completa nombre y categoría para crear el equipo.',
        type: ModalType.warning,
        buttonText: 'Entendido',
      );
      return;
    }

    if (!Environment.useBackend) {
      CustomModal.show(
        context: context,
        title: 'Sin backend',
        message: 'Activa backend para crear equipos reales.',
        type: ModalType.warning,
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final coachApi = ref.read(coachApiServiceProvider);
      final uploadApi = ref.read(uploadApiServiceProvider);

      String? escudoUrl;
      if (_escudoFile != null) {
        final fileName = _escudoFile!.path.split(Platform.pathSeparator).last;
        final multipart = await MultipartFile.fromFile(
          _escudoFile!.path,
          filename: fileName,
        );
        final uploadRes = await uploadApi.uploadFoto(multipart);
        escudoUrl =
            uploadRes['url']?.toString() ??
            uploadRes['foto_url']?.toString() ??
            uploadRes['path']?.toString();
      }

      final body = <String, dynamic>{
        'nombre': _nombreCtrl.text.trim(),
        'categoria': _categoria!.trim().toUpperCase(),
        if ((escudoUrl ?? '').isNotEmpty) 'escudo_url': escudoUrl,
      };

      final res = await coachApi.postEquipo(body);
      if (!mounted) return;
      ref.invalidate(coachCategoriasProvider);
      ref.invalidate(coachDashboardProvider);

      CustomModal.show(
        context: context,
        title: 'Equipo creado',
        message: res['message']?.toString() ?? 'Equipo creado correctamente.',
        type: ModalType.success,
        buttonText: 'Aceptar',
        onButtonPressed: () {
          Navigator.of(context).pop();
          context.pop(true);
        },
      );
    } catch (e) {
      if (!mounted) return;
      CustomModal.show(
        context: context,
        title: 'No se pudo crear',
        message: apiErrorMessage(
          e,
          defaultMessage: 'No fue posible crear el equipo. Intenta de nuevo.',
          forbiddenMessage: 'No tienes permisos para crear equipos.',
        ),
        type: ModalType.error,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriasAsync = ref.watch(coachCategoriasProvider);
    final categorias = _buildCategorias(categoriasAsync.valueOrNull);
    _categoria ??= categorias.isNotEmpty ? categorias.first : null;

    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(249, 248, 247, 1),
        appBar: CustomAppbar(
          title: 'Crear Equipo',
          onPressed: () => context.pop(),
        ),
        bottomNavigationBar: const CustomBottomAppbar(),
        floatingActionButton: const CustomFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F3EA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE7D7C3)),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _CreateTeamLabel('NOMBRE DEL EQUIPO'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nombreCtrl,
                        onChanged: (_) => setState(() {}),
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          hintText: 'Ej. Juveniles A',
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: const Icon(
                            Icons.edit,
                            color: Color(0xFFE86A4E),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2D7C8),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2D7C8),
                            ),
                          ),
                        ),
                        validator: (v) {
                          final value = (v ?? '').trim();
                          if (value.isEmpty) {
                            return 'Ingresa el nombre del equipo';
                          }
                          if (value.length < 2) return 'Nombre demasiado corto';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      const _CreateTeamLabel('CATEGORÍA'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue:
                            categorias.contains(_categoria) ? _categoria : null,
                        decoration: InputDecoration(
                          hintText: 'Selecciona una categoría',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2D7C8),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2D7C8),
                            ),
                          ),
                        ),
                        items:
                            categorias
                                .map(
                                  (e) => DropdownMenuItem<String>(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) => setState(() => _categoria = v),
                        validator:
                            (v) =>
                                (v ?? '').trim().isEmpty
                                    ? 'Selecciona categoría'
                                    : null,
                      ),
                      const SizedBox(height: 14),
                      const _CreateTeamLabel('ESCUDO DEL EQUIPO'),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _pickEscudo,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFFFD5C8),
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFF3EFEA),
                                      Color(0xFFE7DFD5),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFE4DAD2),
                                  ),
                                ),
                                child: ClipOval(
                                  child:
                                      _escudoFile == null
                                          ? Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Text(
                                                _teamInitials,
                                                style: const TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w800,
                                                  color: Color(0xFFA59586),
                                                ),
                                              ),
                                              const Positioned(
                                                bottom: 8,
                                                right: 8,
                                                child: Icon(
                                                  Icons.shield_outlined,
                                                  color: Color(0xFFC5B9AE),
                                                  size: 16,
                                                ),
                                              ),
                                            ],
                                          )
                                          : Image.file(
                                            _escudoFile!,
                                            fit: BoxFit.cover,
                                          ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Subir escudo',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF6C5C4F),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'JPG, PNG o SVG (Máx. 2MB)',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFFA79A8E),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFEFE9),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.upload_file,
                                      size: 14,
                                      color: Color(0xFFD94929),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Seleccionar Archivo',
                                      style: TextStyle(
                                        color: Color(0xFFD94929),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _saving ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD94929),
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon:
                              _saving
                                  ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Icon(Icons.group_add_outlined),
                          label: Text(_saving ? 'Creando...' : 'Crear Equipo'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateTeamLabel extends StatelessWidget {
  const _CreateTeamLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFD67B5F),
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
      ),
    );
  }
}
