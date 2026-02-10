import 'package:coach_app/config/constants/environment.dart';
import 'package:coach_app/infrastructure/services/coach_api_service.dart';
import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// TshirtStatus is re-exported by widgets.dart

enum _BatchAction { allPresent, allAbsent }
enum _AttendanceFilter { all, present, absent, pending }

class DailyAttendanceScreen extends StatelessWidget {
  static const String name = '/daily_attendance_screen';
  const DailyAttendanceScreen({super.key, this.equipoId});
  final int? equipoId;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Color.fromRGBO(249, 248, 247, 1),
        appBar: CustomAppbar(title: 'Asistencia diaria'),
        bottomNavigationBar: CustomBottomAppbar(),
        floatingActionButton: CustomFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: _DailyAttendanceView(equipoId: equipoId),
      ),
    );
  }
}

class _DailyAttendanceView extends ConsumerStatefulWidget {
  const _DailyAttendanceView({this.equipoId});
  final int? equipoId;

  @override
  ConsumerState<_DailyAttendanceView> createState() => _DailyAttendanceViewState();
}

class _DailyAttendanceViewState extends ConsumerState<_DailyAttendanceView> {
  static const int _defaultTotalPlayers = 24;
  late List<String> playerNames;
  int? _highlightedIndex;
  DateTime _selectedDate = DateTime.now();
  final Map<int, TshirtStatus> _status = <int, TshirtStatus>{};
  bool _assetsPrecached = false;
  bool _submitting = false;
  String _statusSeed = '';
  _AttendanceFilter _filter = _AttendanceFilter.all;

  @override
  void initState() {
    super.initState();
    playerNames = List.generate(_defaultTotalPlayers, (i) => 'Camilo Andres');
    for (var i = 0; i < _defaultTotalPlayers; i++) {
      _status[i] = TshirtStatus.absent;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precarga de assets para evitar parpadeos/jank al mostrar íconos
    if (!_assetsPrecached) {
      _precacheTshirtIcons(context);
      _assetsPrecached = true;
    }
  }

  Future<void> _precacheTshirtIcons(BuildContext context) async {
    const assets = [
      'assets/images/tshirt-icon-green.png',
      'assets/images/tshirt-icon-yellow.png',
      'assets/images/tshirt-icon-blue.png',
    ];
    for (final path in assets) {
      await precacheImage(AssetImage(path), context);
    }
  }

  Future<void> _pickDate() async {
    const brand = Color.fromRGBO(217, 73, 41, 1);

    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      locale: const Locale('es', 'CO'),
      confirmText: 'aceptar',
      builder: (context, child) {
        final base = Theme.of(context);
        return Theme(
          data: base.copyWith(
            // Colores base del date picker
            colorScheme: base.colorScheme.copyWith(
              primary: brand, // afecta selección, encabezado, etc.
              onPrimary: Colors.white, // texto/íconos sobre primary
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  String get _formattedDate {
    final d = _selectedDate.day.toString().padLeft(2, '0');
    final m = _selectedDate.month.toString().padLeft(2, '0');
    final y = _selectedDate.year.toString();
    return '$d/$m/$y';
  }

  String get _apiDate {
    final d = _selectedDate.day.toString().padLeft(2, '0');
    final m = _selectedDate.month.toString().padLeft(2, '0');
    final y = _selectedDate.year.toString();
    return '$y-$m-$d';
  }

  @override
  Widget build(BuildContext context) {
    final equipoId = widget.equipoId;
    final useApi = Environment.useBackend && equipoId != null;
    final jugadoresAsync =
        useApi ? ref.watch(coachJugadoresProvider(equipoId)) : null;
    final asistenciaAsync =
        useApi
            ? ref.watch(
              coachAsistenciaProvider((equipoId: equipoId!, fecha: _apiDate)),
            )
            : null;

    int totalPlayers = _defaultTotalPlayers;
    List<String> names = playerNames;
    List<int> ids = List<int>.generate(totalPlayers, (i) => i + 1);
    var emptyFromApi = false;
    if (useApi && (jugadoresAsync?.hasValue ?? false)) {
      final value = (jugadoresAsync?.value) ?? {};
      final jugadores = (value['jugadores'] as List<dynamic>?) ?? [];
      if (jugadores.isEmpty) {
        totalPlayers = 0;
        names = const <String>[];
        ids = const <int>[];
        emptyFromApi = true;
      } else {
        totalPlayers = jugadores.length;
        names = jugadores.map((e) {
          final m =
              e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{};
          return m['nombre_completo']?.toString() ??
              m['nombre']?.toString() ??
              'Jugador';
        }).toList();
        ids = jugadores.map((e) {
          final m =
              e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{};
          final raw = m['jugador_id'] ?? m['id'];
          if (raw is int) return raw;
          return int.tryParse(raw?.toString() ?? '') ?? 0;
        }).toList();
      }
    }

    final backendStatusByJugadorId = <int, TshirtStatus>{};
    if (useApi && (asistenciaAsync?.hasValue ?? false)) {
      final value = asistenciaAsync?.value ?? {};
      final rows = (value['jugadores'] as List<dynamic>?) ?? const [];
      for (final row in rows) {
        final m = row is Map ? Map<String, dynamic>.from(row) : <String, dynamic>{};
        final rawId = m['jugador_id'];
        final id =
            rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '') ?? 0;
        if (id <= 0) continue;
        final estado = m['estado']?.toString().toUpperCase();
        final parsed = switch (estado) {
          'PRESENTE' => TshirtStatus.present,
          'AUSENTE' || 'TARDANZA' || 'JUSTIFICADO' => TshirtStatus.absent,
          _ => TshirtStatus.none,
        };
        backendStatusByJugadorId[id] = parsed;
      }
    }

    final seed = '${equipoId ?? 0}|$_apiDate|${ids.join(',')}|${backendStatusByJugadorId.hashCode}';
    if (_statusSeed != seed) {
      _status
        ..clear()
        ..addEntries(
          List.generate(totalPlayers, (i) {
            final id = i < ids.length ? ids[i] : 0;
            final st =
                backendStatusByJugadorId[id] ??
                (useApi ? TshirtStatus.none : TshirtStatus.absent);
            return MapEntry(i, st);
          }),
        );
      _statusSeed = seed;
    }

    final entries = List<_PlayerEntry>.generate(totalPlayers, (i) {
      final name = i < names.length ? names[i] : 'Jugador';
      final status = _status[i] ?? TshirtStatus.none;
      return _PlayerEntry(index: i, name: name, status: status);
    });

    final filteredEntries = entries.where((e) {
      return switch (_filter) {
        _AttendanceFilter.all => true,
        _AttendanceFilter.present => e.status == TshirtStatus.present,
        _AttendanceFilter.absent => e.status == TshirtStatus.absent,
        _AttendanceFilter.pending => e.status == TshirtStatus.none,
      };
    }).toList();

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final visibleStatuses = List<TshirtStatus>.generate(
            totalPlayers,
            (i) => _status[i] ?? TshirtStatus.none,
          );
          final presentCount =
              visibleStatuses.where((s) => s == TshirtStatus.present).length;
          final absentCount =
              visibleStatuses.where((s) => s == TshirtStatus.absent).length;
          final pendingCount =
              visibleStatuses.where((s) => s == TshirtStatus.none).length;
          final allPresent =
              totalPlayers > 0 &&
              visibleStatuses.every((s) => s == TshirtStatus.present);
          final allAbsent =
              totalPlayers > 0 &&
              visibleStatuses.every((s) => s == TshirtStatus.absent);
          const crossAxisCount = 4;
          const gridPadding = 20.0;
          final totalSpacing = gridPadding * 2 + 0 * (crossAxisCount - 1);
          final itemWidth =
              (constraints.maxWidth - totalSpacing) / crossAxisCount;
          final itemHeight = itemWidth;

          if (useApi &&
              jugadoresAsync?.isLoading == true &&
              names.length == _defaultTotalPlayers) {
            return const Center(child: CircularProgressIndicator());
          }

          return RepaintBoundary(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 00),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                SizedBox(height: 5),
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 6),
                  child: CustomText(
                    text: 'Seleccione una fecha',
                    size: 16,
                    fontWeight: FontWeight.w700,
                    color: Color.fromRGBO(55, 73, 87, 1),
                  ),
                ),
                SizedBox(height: 5),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color.fromRGBO(173, 111, 57, 1),
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const CustomText(
                          text: 'Fecha',
                          size: 14,
                          fontWeight: FontWeight.w500,
                          color: Color.fromRGBO(21, 71, 56, 1),
                        ),
                        CustomText(
                          text: _formattedDate,
                          size: 14,
                          fontWeight: FontWeight.w500,
                          color: Color.fromRGBO(21, 71, 56, 1),
                        ),
                        Icon(Icons.arrow_drop_down, size: 25),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'Todos ($totalPlayers)',
                        selected: _filter == _AttendanceFilter.all,
                        onTap: () => setState(() => _filter = _AttendanceFilter.all),
                      ),
                      const SizedBox(width: 6),
                      _FilterChip(
                        label: 'Presentes ($presentCount)',
                        selected: _filter == _AttendanceFilter.present,
                        onTap:
                            () => setState(() => _filter = _AttendanceFilter.present),
                      ),
                      const SizedBox(width: 6),
                      _FilterChip(
                        label: 'Ausentes ($absentCount)',
                        selected: _filter == _AttendanceFilter.absent,
                        onTap:
                            () => setState(() => _filter = _AttendanceFilter.absent),
                      ),
                      const SizedBox(width: 6),
                      _FilterChip(
                        label: 'Pendientes ($pendingCount)',
                        selected: _filter == _AttendanceFilter.pending,
                        onTap:
                            () => setState(() => _filter = _AttendanceFilter.pending),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child:
                      emptyFromApi
                          ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.groups_outlined,
                                    size: 56,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 12),
                                  CustomText(
                                    text:
                                        'Esta categoría aún no tiene jugadores.',
                                    textAlign: TextAlign.center,
                                    size: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color.fromRGBO(55, 73, 87, 1),
                                  ),
                                ],
                              ),
                            ),
                          )
                          : RepaintBoundary(
                            child: GridView.builder(
                              padding: const EdgeInsets.only(
                                top: 20,
                                right: 8,
                                left: 8,
                                bottom: 8,
                              ),
                              itemCount: filteredEntries.length,
                              physics: const BouncingScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    mainAxisSpacing: 0.0,
                                    crossAxisSpacing: 0.0,
                                    childAspectRatio: 1.12,
                                  ),
                              itemBuilder: (context, index) {
                                final entry = filteredEntries[index];
                                final number = entry.index + 1;
                                return _SelectedIcons(
                                  index: entry.index,
                                  name: entry.name,
                                  isHighlighted: _highlightedIndex == entry.index,
                                  status:
                                      _status[entry.index] ?? TshirtStatus.none,
                                  onHoldStart:
                                      () => setState(
                                        () => _highlightedIndex = entry.index,
                                      ),
                                  onHoldEnd:
                                      () => setState(
                                        () => _highlightedIndex = null,
                                      ),
                                  onTap: () {
                                    setState(() {
                                      final current =
                                          _status[entry.index] ??
                                          TshirtStatus.none;
                                      _status[entry.index] =
                                          current == TshirtStatus.present
                                              ? TshirtStatus.absent
                                              : TshirtStatus.present;
                                    });
                                  },
                                  number: number,
                                  itemWidth: itemWidth,
                                  itemHeight: itemHeight,
                                );
                              },
                            ),
                          ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const CustomText(
                      text: 'Asistencia',
                      size: 16,
                      fontWeight: FontWeight.w700,
                      color: Color.fromRGBO(55, 73, 87, 1),
                    ),
                    const Spacer(),
                    CustomText(
                      text: '$presentCount/$totalPlayers',
                      size: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color.fromRGBO(21, 71, 56, 1),
                    ),
                    const SizedBox(width: 4),
                    PopupMenuButton<_BatchAction>(
                      tooltip: 'Acciones',
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        setState(() {
                          switch (value) {
                            case _BatchAction.allPresent:
                              for (var i = 0; i < totalPlayers; i++) {
                                _status[i] = TshirtStatus.present;
                              }
                              break;
                            case _BatchAction.allAbsent:
                              for (var i = 0; i < totalPlayers; i++) {
                                _status[i] = TshirtStatus.absent;
                              }
                              break;
                          }
                        });
                      },
                      itemBuilder:
                          (context) => [
                            PopupMenuItem<_BatchAction>(
                              value: _BatchAction.allPresent,
                              enabled: !allPresent,
                              child: const ListTile(
                                leading: Icon(Icons.done_all),
                                title: Text('Todos presentes'),
                                dense: true,
                              ),
                            ),
                            PopupMenuItem<_BatchAction>(
                              value: _BatchAction.allAbsent,
                              enabled: !allAbsent,
                              child: const ListTile(
                                leading: Icon(Icons.clear),
                                title: Text('Todos ausentes'),
                                dense: true,
                              ),
                            ),
                          ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Acciones ahora están integradas en el menú de la fila superior
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: totalPlayers == 0 ? 0 : presentCount / totalPlayers,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color.fromRGBO(21, 71, 56, 1),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: OnboardingNextButton(
                    text: _submitting ? 'Registrando...' : 'Registrar Asistencia',
                    isEnabled:
                        !_submitting && totalPlayers > 0 && presentCount > 0,
                    action: () async {
                      if (_submitting) return;

                      // En local, mantener flujo sin backend.
                      if (!useApi || equipoId == null) {
                        if (!mounted) return;
                        CustomModal.show(
                          context: context,
                          title: 'Asistencia registrada',
                          message: 'Los datos se guardaron en modo local.',
                          type: ModalType.success,
                          buttonText: 'Aceptar',
                          onButtonPressed: () {
                            Navigator.of(context).pop();
                            if (context.mounted) context.go('/coach_screen');
                          },
                        );
                        return;
                      }

                      final asistencias = <Map<String, dynamic>>[];
                      for (var i = 0; i < totalPlayers; i++) {
                        final jugadorId = i < ids.length ? ids[i] : 0;
                        if (jugadorId <= 0) continue;
                        final state = _status[i] ?? TshirtStatus.none;
                        asistencias.add({
                          'jugador_id': jugadorId,
                          'estado':
                              state == TshirtStatus.present
                                  ? 'PRESENTE'
                                  : 'AUSENTE',
                        });
                      }

                      if (asistencias.isEmpty) {
                        if (!mounted) return;
                        CustomModal.show(
                          context: context,
                          title: 'Sin jugadores válidos',
                          message: 'No hay jugadores válidos para registrar.',
                          type: ModalType.warning,
                          buttonText: 'Entendido',
                        );
                        return;
                      }

                      setState(() => _submitting = true);
                      try {
                        await ref
                            .read(coachApiServiceProvider)
                            .postAsistencia(
                              equipoId,
                              fecha: _apiDate,
                              asistencias: asistencias,
                            );
                        if (!mounted) return;
                        CustomModal.show(
                          context: context,
                          title: 'Asistencia registrada',
                          message: 'La asistencia se guardó correctamente.',
                          type: ModalType.success,
                          buttonText: 'Aceptar',
                          onButtonPressed: () {
                            Navigator.of(context).pop();
                            if (context.mounted) context.go('/coach_screen');
                          },
                        );
                      } catch (e) {
                        if (!mounted) return;
                        CustomModal.show(
                          context: context,
                          title: 'Error al registrar',
                          message: 'No se pudo registrar la asistencia.\n$e',
                          type: ModalType.error,
                          buttonText: 'Entendido',
                        );
                      } finally {
                        if (mounted) setState(() => _submitting = false);
                      }
                    },
                  ),
                ),
                // Leave room so the FAB/bottom bar doesn't overlap the CTA
                const SizedBox(height: 30),
              ],
            ),
            ),
          );
        },
      ),
    );
  }
}

class _SelectedIcons extends StatelessWidget {
  const _SelectedIcons({
    required this.index,
    required this.name,
    required this.isHighlighted,
    required this.onHoldStart,
    required this.onHoldEnd,
    required this.onTap,
    required this.status,
    required this.number,
    required this.itemWidth,
    required this.itemHeight,
  });

  final int index;
  final String name;
  final bool isHighlighted;
  final VoidCallback onHoldStart;
  final VoidCallback onHoldEnd;
  final VoidCallback onTap;
  final TshirtStatus status;
  final int number;
  final double itemWidth;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTapDown: (_) => onHoldStart(),
          onTapUp: (_) => onHoldEnd(),
          onTap: onTap,
          onTapCancel: onHoldEnd,
          child: CustomTshirtIcon(
            number: number,
            width: itemWidth * 0.7,
            height: itemHeight * 0.7,
            status: status,
          ),
        ),
        Positioned(
          top: -6,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: isHighlighted ? 1 : 0,
            child: IgnorePointer(
              ignoring: true,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(217, 73, 41, 1),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: CustomText(
                  text: name,
                  color: Colors.white,
                  size: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFFD94929) : Colors.white;
    final fg = selected ? Colors.white : const Color(0xFF374957);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFFD94929) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
        ),
      ),
    );
  }
}

class _PlayerEntry {
  const _PlayerEntry({
    required this.index,
    required this.name,
    required this.status,
  });

  final int index;
  final String name;
  final TshirtStatus status;
}
