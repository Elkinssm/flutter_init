import 'dart:io';

import 'package:coach_app/config/constants/environment.dart';
import 'package:coach_app/infrastructure/services/coach_api_service.dart';
import 'package:coach_app/infrastructure/services/upload_api_service.dart';
import 'package:coach_app/presentation/helpers/responsive.dart';
import 'package:coach_app/presentation/providers/auth_role_provider.dart';
import 'package:coach_app/presentation/providers/calendar2_provider.dart';
import 'package:coach_app/presentation/providers/player_photo_overrides_provider.dart';
import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

final playerMonthAttendanceProvider =
    FutureProvider.family<
      Map<DateTime, String>,
      ({int equipoId, int jugadorId, int year, int month})
    >((ref, params) async {
      final api = ref.read(coachApiServiceProvider);
      final result = <DateTime, String>{};

      final data = await api.getJugadorAsistenciaCalendario(
        params.jugadorId,
        year: params.year,
        month: params.month,
        equipoId: params.equipoId,
      );
      if (data == null) return result;

      final rows = (data['dias'] as List<dynamic>?) ??
          (data['asistencias'] as List<dynamic>?) ??
          const <dynamic>[];

      for (final item in rows) {
        if (item is! Map) continue;
        final row = Map<String, dynamic>.from(item);
        final rawDate = row['fecha'] ?? row['date'] ?? row['fecha_entrenamiento'];
        final raw = rawDate?.toString() ?? '';
        if (raw.isEmpty) continue;
        final iso = raw.length >= 10 ? raw.substring(0, 10) : raw;
        final dt = DateTime.tryParse(iso);
        if (dt == null) continue;
        final key = DateTime(dt.year, dt.month, dt.day);
        final rawStatus =
            (row['estado'] ?? row['asistencia_estado'])?.toString().toUpperCase();
        result[key] =
            (rawStatus == null || rawStatus.isEmpty) ? 'PENDIENTE' : rawStatus;
      }

      return result;
    });

class PlayerStatusScreen extends ConsumerStatefulWidget {
  static const String name = '/player_status_screen';
  final String names;
  final String image;
  final int? jugadorId;

  const PlayerStatusScreen({
    super.key,
    required this.names,
    required this.image,
    this.jugadorId,
  });

  @override
  ConsumerState<PlayerStatusScreen> createState() => _PlayerStatusScreenState();
}

class _PlayerStatusScreenState extends ConsumerState<PlayerStatusScreen> {
  final _picker = ImagePicker();
  bool _updatingPhoto = false;
  late String _photoRef;

  @override
  void initState() {
    super.initState();
    _photoRef = widget.image;
  }

  @override
  Widget build(BuildContext context) {
    final isCoach = ref.watch(currentUserRoleProvider) == 'coach';

    return SafeArea(
      top: false,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: const Color.fromRGBO(249, 248, 247, 1),
        appBar: const CustomAppbar(title: 'Detalles del jugador'),
        bottomNavigationBar: const CustomBottomAppbar(),
        floatingActionButton: const CustomFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: _PlayerStatusView(
          playerName: widget.names,
          playerImage: _photoRef,
          jugadorId: widget.jugadorId,
          canEditPhoto: isCoach && widget.jugadorId != null,
          loadingPhoto: _updatingPhoto,
          onEditPhoto: () => _showPhotoOptions(context),
        ),
      ),
    );
  }

  Future<void> _showPhotoOptions(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
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
              const Text('Actualizar foto', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Tomar foto'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUpload(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Elegir de galería'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUpload(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndUpload(ImageSource source) async {
    if (widget.jugadorId == null || _updatingPhoto) return;

    final image = await _picker.pickImage(
      source: source,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (image == null || !mounted) return;

    setState(() => _updatingPhoto = true);
    try {
      final uploadApi = ref.read(uploadApiServiceProvider);
      final coachApi = ref.read(coachApiServiceProvider);

      final uploadRes = await uploadApi.uploadFoto(
        await MultipartFile.fromFile(
          image.path,
          filename: image.path.split(Platform.pathSeparator).last,
        ),
      );

      final fotoUrl = uploadRes['url']?.toString() ??
          uploadRes['foto_url']?.toString() ??
          uploadRes['path']?.toString();

      if ((fotoUrl ?? '').isEmpty) {
        throw Exception('No se recibió URL de foto en la respuesta de upload.');
      }

      final normalized = _normalizePhotoRef(fotoUrl!);

      await coachApi.putJugador(widget.jugadorId!, {'foto_url': normalized});

      if (!mounted) return;
      setState(() => _photoRef = normalized);
      ref.read(playerPhotoOverridesProvider.notifier).update((state) {
        final copy = Map<int, String>.from(state);
        copy[widget.jugadorId!] = normalized;
        return copy;
      });
      ref.invalidate(coachJugadorDetailProvider(widget.jugadorId!));

      CustomModal.show(
        context: context,
        title: 'Foto actualizada',
        message: 'La foto del jugador se actualizó correctamente.',
        type: ModalType.success,
      );
    } catch (e) {
      if (!mounted) return;
      CustomModal.show(
        context: context,
        title: 'No se pudo actualizar',
        message: '$e',
        type: ModalType.error,
      );
    } finally {
      if (mounted) setState(() => _updatingPhoto = false);
    }
  }

  String _normalizePhotoRef(String raw) {
    return _normalizePhotoUrl(raw);
  }
}

class _PlayerStatusView extends ConsumerWidget {
  final String playerName;
  final String playerImage;
  final int? jugadorId;
  final bool canEditPhoto;
  final bool loadingPhoto;
  final VoidCallback? onEditPhoto;

  const _PlayerStatusView({
    required this.playerName,
    required this.playerImage,
    required this.jugadorId,
    required this.canEditPhoto,
    required this.loadingPhoto,
    this.onEditPhoto,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assistanceState = ref.watch(assistanceProvider2);
    final assistanceNotifier = ref.read(assistanceProvider2.notifier);
    final detailAsync = jugadorId == null
        ? null
        : ref.watch(coachJugadorDetailProvider(jugadorId!));
    final overrides = ref.watch(playerPhotoOverridesProvider);

    final detail = detailAsync?.valueOrNull ?? <String, dynamic>{};
    final jugador = detail['jugador'] is Map
        ? Map<String, dynamic>.from(detail['jugador'])
        : <String, dynamic>{};
    final equipos = detail['equipos'] as List<dynamic>? ?? const [];
    final primerEquipo = equipos.isNotEmpty && equipos.first is Map
        ? Map<String, dynamic>.from(equipos.first as Map)
        : <String, dynamic>{};
    final equipoId = (primerEquipo['id'] as num?)?.toInt();
    final monthAttendanceAsync =
        (Environment.useBackend &&
            jugadorId != null &&
            equipoId != null)
        ? ref.watch(
            playerMonthAttendanceProvider((
              equipoId: equipoId,
              jugadorId: jugadorId!,
              year: assistanceState.focusedDay.year,
              month: assistanceState.focusedDay.month,
            )),
          )
        : null;
    final asistencia = detail['asistencia'] is Map
        ? Map<String, dynamic>.from(detail['asistencia'])
        : <String, dynamic>{};
    final attendanceByDay = <DateTime, String>{
      ..._extractAttendanceByDay(detail),
      ...(monthAttendanceAsync?.valueOrNull ?? const <DateTime, String>{}),
    };

    final nombreBackend = jugador['nombre_completo']?.toString();
    final nombreFinal = (nombreBackend ?? '').trim().isNotEmpty
        ? nombreBackend!.trim()
        : playerName;

    final equipoNombre = primerEquipo['nombre']?.toString() ?? '';
    final categoria = primerEquipo['categoria']?.toString() ?? '';
    final headerSub = [categoria, equipoNombre]
        .where((e) => e.isNotEmpty)
        .join(' - ')
        .trim();
    final subtitleFinal = headerSub.isEmpty ? 'Jugador' : headerSub;

    final totalEntrenamientos =
        (asistencia['total_entrenamientos'] as num?)?.toInt();
    final totalAsistencias = (asistencia['asistencias'] as num?)?.toInt();
    final porcentaje = (asistencia['porcentaje'] as num?)?.toDouble();
    final resumenFinal = (totalEntrenamientos == null &&
            totalAsistencias == null &&
            porcentaje == null)
        ? 'Sin resumen de asistencia'
        : 'Total sesiones: ${totalEntrenamientos ?? '--'}  ·  Asistencia: ${totalAsistencias ?? '--'}  ·  % Asistencia: ${porcentaje?.toStringAsFixed(0) ?? '--'}%';

    final overridePhoto = jugadorId != null ? overrides[jugadorId!] : null;
    final backendPhoto = _normalizePhoto(jugador['foto_url']?.toString());
    final imageFinal = overridePhoto ?? backendPhoto ?? playerImage;

    return SingleChildScrollView(
      child: maxWidthCenter(
        context: context,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Stack(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color.fromRGBO(27, 71, 56, 1),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 1,
                          offset: const Offset(0, 3),
                          color: Colors.black12,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 89,
                    height: 96,
                    child: ClipOval(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 0.5),
                        child: _buildImage(imageFinal),
                      ),
                    ),
                  ),
                  if (canEditPhoto)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: loadingPhoto ? null : onEditPhoto,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: loadingPhoto ? Colors.grey : const Color(0xFFD94929),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: loadingPhoto
                              ? const Padding(
                                  padding: EdgeInsets.all(6),
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: hp(context, 0.015)),
              CustomText(
                text: nombreFinal,
                textAlign: TextAlign.center,
                size: ts(context, 22),
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0B1926),
              ),
              SizedBox(height: hp(context, 0.01)),
              CustomText(
                text: subtitleFinal,
                size: ts(context, 13),
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
              SizedBox(height: hp(context, 0.02)),
              CustomText(
                text: resumenFinal,
                textAlign: TextAlign.center,
                fontWeight: FontWeight.w400,
                size: ts(context, 13),
                color: Colors.black87,
              ),
              SizedBox(height: hp(context, 0.05)),
              Container(
                width: double.infinity,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomText(
                  text: 'Asistencia',
                  size: ts(context, 18),
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0B1926),
                ),
              ),
              SizedBox(height: 25),
              _Calendar(
                assistanceState: assistanceState,
                assistanceNotifier: assistanceNotifier,
                attendanceByDay: attendanceByDay,
                isLoading: monthAttendanceAsync?.isLoading ?? false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String imageRef) {
    if (imageRef.startsWith('http://') || imageRef.startsWith('https://')) {
      return Image.network(
        imageRef,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset('assets/images/student-eg1-icon.png', fit: BoxFit.cover),
      );
    }
    return Image.asset(
      imageRef,
      fit: BoxFit.cover,
      cacheWidth: 128,
      cacheHeight: 128,
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
    );
  }

  static String? _normalizePhoto(String? raw) {
    final value = (raw ?? '').trim();
    if (value.isEmpty || value.toLowerCase() == 'null') return null;
    return _normalizePhotoUrl(value);
  }

  static Map<DateTime, String> _extractAttendanceByDay(
    Map<String, dynamic> detail,
  ) {
    final result = <DateTime, String>{};

    final candidates = <dynamic>[
      detail['asistencias'],
      detail['asistencia_detalle'],
      detail['historial_asistencia'],
      (detail['asistencia'] is Map)
          ? (detail['asistencia'] as Map)['detalles']
          : null,
      (detail['asistencia'] is Map)
          ? (detail['asistencia'] as Map)['asistencias']
          : null,
      (detail['asistencia'] is Map)
          ? (detail['asistencia'] as Map)['por_dia']
          : null,
    ];

    for (final source in candidates) {
      if (source is! List) continue;
      for (final item in source) {
        if (item is! Map) continue;
        final row = Map<String, dynamic>.from(item);
        final rawDate =
            row['fecha'] ?? row['fecha_entrenamiento'] ?? row['date'];
        final dt = _parseDate(rawDate?.toString());
        if (dt == null) continue;

        final rawStatus = (row['estado'] ?? row['asistencia_estado'])
            ?.toString()
            .toUpperCase();
        final normalizedStatus =
            (rawStatus == null || rawStatus.isEmpty) ? 'PENDIENTE' : rawStatus;

        // Si hay múltiples fuentes, la primera que tenga estado para el día gana.
        result.putIfAbsent(dt, () => normalizedStatus);
      }
    }

    return result;
  }

  static DateTime? _parseDate(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    final normalized = v.length >= 10 ? v.substring(0, 10) : v;
    final dt = DateTime.tryParse(normalized);
    if (dt == null) return null;
    return DateTime(dt.year, dt.month, dt.day);
  }
}

String _normalizePhotoUrl(String raw) {
  final value = raw.trim();
  if (value.isEmpty || value.toLowerCase() == 'null') return '';

  final uri = Uri.tryParse(value);
  if (uri != null && uri.hasScheme && uri.host.isNotEmpty) {
    final isLocalHost =
        uri.host == 'localhost' || uri.host == '127.0.0.1' || uri.host == '10.0.2.2';
    final normalizedPath = _normalizePhotoPath(uri.path);
    if (isLocalHost) {
      return '${
          Environment.baseUrl
      }$normalizedPath${uri.hasQuery ? '?${uri.query}' : ''}';
    }
    if (normalizedPath != uri.path) {
      return uri.replace(path: normalizedPath).toString();
    }
    return value;
  }

  final normalizedPath = _normalizePhotoPath(value);
  return '${Environment.baseUrl}$normalizedPath';
}

String _normalizePhotoPath(String path) {
  var p = path.trim();
  if (p.isEmpty) return p;

  p = p.replaceFirst('/test_app/storage/', '/storage/');
  p = p.replaceFirst('test_app/storage/', 'storage/');
  p = p.replaceFirst('/api/storage/', '/storage/');
  p = p.replaceFirst('api/storage/', 'storage/');

  if (p.startsWith('/fotos/')) p = '/storage$p';
  if (p.startsWith('fotos/')) p = '/storage/$p';
  if (p.startsWith('storage/')) p = '/$p';
  if (!p.startsWith('/')) p = '/$p';

  return p;
}

class _Calendar extends StatelessWidget {
  const _Calendar({
    required this.assistanceState,
    required this.assistanceNotifier,
    required this.attendanceByDay,
    required this.isLoading,
  });

  final Assistance2State assistanceState;
  final AssistanceNotifier assistanceNotifier;
  final Map<DateTime, String> attendanceByDay;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(203, 213, 225, 1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(3, 3),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLoading)
            const Padding(
              padding: EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: LinearProgressIndicator(
                minHeight: 3,
                color: Color(0xFFD94929),
                backgroundColor: Color(0xFFD9D9D9),
              ),
            ),
          TableCalendar(
            pageAnimationEnabled: true,
            pageAnimationDuration: const Duration(milliseconds: 300),
            pageAnimationCurve: Curves.easeInOut,
            rowHeight: 38,
            locale: 'es_ES',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: assistanceState.focusedDay,
            selectedDayPredicate: (day) => isSameDay(assistanceState.selectedDay, day),
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.black),
              rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.black),
              titleTextStyle: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
              titleTextFormatter: (date, locale) =>
                  '${toBeginningOfSentenceCase(DateFormat.MMMM(locale).format(date))} ${date.year}',
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              defaultTextStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF0B1926),
              ),
              weekendTextStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF0B1926),
              ),
              todayTextStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0B1926),
              ),
              selectedTextStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0B1926),
              ),
              todayDecoration: const BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                return _buildDayCell(day, isSelected: false);
              },
              todayBuilder: (context, day, focusedDay) {
                final isSelected = isSameDay(assistanceState.selectedDay, day);
                return _buildDayCell(
                  day,
                  isSelected: isSelected,
                  forcePlain: true,
                );
              },
              selectedBuilder: (context, day, focusedDay) {
                return _buildDayCell(day, isSelected: true, forcePlain: true);
              },
            ),
            onDaySelected: (selectedDay, focusedDay) {
              assistanceNotifier.selectDay(selectedDay, focusedDay);
            },
            onPageChanged: (focusedDay) {
              assistanceNotifier.changeMonth(focusedDay);
            },
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: const [
              _LegendItem(label: 'Presente', color: Color(0xFF55A06F)),
              _LegendItem(label: 'Ausente', color: Color(0xFFD2AF35)),
              _LegendItem(label: 'Pendiente', color: Color(0xFF34495E)),
            ],
          ),
        ],
      ),
    );
  }

  static Color? _statusColor(String? status) {
    final normalized = (status ?? '').toUpperCase();
    switch (normalized) {
      case 'PRESENTE':
        return const Color(0xFF55A06F);
      // Igualar semántica con camisas en Asistencia diaria:
      // AUSENTE/TARDANZA/JUSTIFICADO se muestran como "ausente" (amarillo).
      case 'AUSENTE':
      case 'TARDANZA':
      case 'JUSTIFICADO':
        return const Color(0xFFD2AF35);
      case 'PENDIENTE':
        return const Color(0xFF34495E);
      default:
        return null;
    }
  }

  Widget? _buildDayCell(
    DateTime day, {
    required bool isSelected,
    bool forcePlain = false,
  }) {
    final key = DateTime(day.year, day.month, day.day);
    final status = attendanceByDay[key];
    final fill = _statusColor(status);

    if (fill == null && !isSelected && !forcePlain) return null;

    return Center(
      child: Container(
        width: 27,
        height: 27,
        decoration: BoxDecoration(
          color: fill ?? Colors.transparent,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: const Color(0xFFD94929), width: 2)
              : null,
        ),
        child: Center(
          child: Text(
            '${day.day}',
            style: TextStyle(
              color: fill == null ? const Color(0xFF0B1926) : Colors.white,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374957),
          ),
        ),
      ],
    );
  }
}
