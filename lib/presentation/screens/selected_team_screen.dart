import 'package:coach_app/config/constants/environment.dart';
import 'package:coach_app/infrastructure/services/coach_api_service.dart';
import 'package:coach_app/presentation/helpers/api_error_message.dart';
import 'package:coach_app/presentation/helpers/responsive.dart';
import 'package:coach_app/presentation/providers/selected_buttons_provider.dart';
import 'package:coach_app/presentation/screens/player_status_screen.dart';
import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectedTeamScreen extends ConsumerStatefulWidget {
  static const String name = '/selected_team_screen';
  const SelectedTeamScreen({super.key, required this.teamName, this.equipoId});
  final String teamName;
  final int? equipoId;

  @override
  ConsumerState<SelectedTeamScreen> createState() => _SelectedTeamScreenState();
}

class _SelectedTeamScreenState extends ConsumerState<SelectedTeamScreen> {
  @override
  void initState() {
    super.initState();
    // Siempre arrancar en "Inicio" al entrar al equipo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedMenuProvider.notifier).state = 'Inicio';

      const avatars = [
        'assets/images/student-eg1-icon.png',
        'assets/images/student-eg2-icon.png',
        'assets/images/student-eg3-icon.png',
        'assets/images/student-eg4-icon.png',
        'assets/images/student-eg5-icon.png',
        'assets/images/student-eg6-icon.png',
      ];
      for (final a in avatars) {
        precacheImage(AssetImage(a), context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        extendBody: true,
        backgroundColor: const Color.fromRGBO(249, 248, 247, 1),
        appBar: CustomAppbar(title: widget.teamName),
        bottomNavigationBar: const CustomBottomAppbar(),
        floatingActionButton: const CustomFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: _SelectedTeamView(
          teamName: widget.teamName,
          equipoId: widget.equipoId,
        ),
      ),
    );
  }
}

class _SelectedTeamView extends ConsumerWidget {
  const _SelectedTeamView({required this.teamName, this.equipoId});
  final String teamName;
  final int? equipoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedMenuProvider) ?? 'Inicio';

    Widget content;
    switch (selected) {
      case 'Inicio':
        content = _TeamOverviewSection(equipoId: equipoId);
        break;
      case 'Alineación':
        content = _LineupSection(equipoId: equipoId);
        break;
      case 'Partidos':
        content = _PartidosSection(equipoId: equipoId);
        break;
      default:
        content = const SizedBox();
    }

    return maxWidthCenter(
      context: context,
      max: 880,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _TopSegmentTabs(
              selected: selected,
              onChanged: (value) {
                ref.read(selectedMenuProvider.notifier).state = value;
              },
            ),
            const SizedBox(height: 10),
            content,
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _LineupSection extends ConsumerStatefulWidget {
  const _LineupSection({this.equipoId});

  final int? equipoId;

  @override
  ConsumerState<_LineupSection> createState() => _LineupSectionState();
}

class _LineupSectionState extends ConsumerState<_LineupSection> {
  static const _red = Color(0xFFD94929);
  static const _green = Color(0xFF23840C);
  static const _cream = Color.fromRGBO(249, 246, 238, 1);
  static const _dark = Color(0xFF171614);

  bool _hydrated = false;
  String _formation = '4-3-3';
  String _savedSignature = '';
  String? _selectedSlotKey;
  final Map<String, _LineupPlayer?> _assigned = {};
  List<_LineupPlayer> _players = const [];
  List<String> _formations = const ['4-3-3'];
  bool _saving = false;

  List<_LineupSlot> get _slots => _slotsForFormation(_formation);

  void _hydrate(Map<String, dynamic>? lineupData, Map<String, dynamic>? playersData) {
    if (_hydrated) return;

    final lineup = lineupData ?? <String, dynamic>{};
    final rawFormation =
        (lineup['formacion'] ??
                (lineup['equipo'] is Map
                    ? (lineup['equipo'] as Map)['formacion']
                    : null))
            ?.toString();
    _formation = (rawFormation == null || rawFormation.trim().isEmpty)
        ? '4-3-3'
        : rawFormation.trim();

    final formacionesRaw =
        (lineup['formaciones_disponibles'] as List<dynamic>?) ?? const [];
    _formations =
        formacionesRaw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    if (_formations.isEmpty) {
      _formations = const ['4-3-3', '4-4-2', '3-5-2', '4-2-3-1', '5-3-2', '3-4-3'];
    }
    if (!_formations.contains(_formation)) {
      _formations = [_formation, ..._formations];
    }

    final rosterRaw = (playersData?['jugadores'] as List<dynamic>?) ?? const [];
    final lineupRaw = (lineup['jugadores'] as List<dynamic>?) ?? const [];
    final byId = <int, _LineupPlayer>{};
    for (final item in [...rosterRaw, ...lineupRaw]) {
      if (item is! Map) continue;
      final player = _LineupPlayer.fromMap(Map<String, dynamic>.from(item));
      if (player.id != null) byId[player.id!] = player;
    }
    _players = byId.values.toList()
      ..sort((a, b) => (a.dorsal ?? 999).compareTo(b.dorsal ?? 999));

    _assigned.clear();
    final availableSlots = _slots;
    for (final slot in availableSlots) {
      _assigned[slot.key] = null;
    }
    final usedKeys = <String>{};
    final lineupPlayers =
        lineupRaw
            .whereType<Map>()
            .map((e) => _LineupPlayer.fromMap(Map<String, dynamic>.from(e)))
            .where((p) => p.id != null && p.titular && p.enCancha)
            .toList()
          ..sort((a, b) => (a.orden ?? 999).compareTo(b.orden ?? 999));

    for (final player in lineupPlayers) {
      final key = _bestSlotKeyForPlayer(player, availableSlots, usedKeys);
      if (key == null) continue;
      _assigned[key] = player;
      usedKeys.add(key);
    }

    _hydrated = true;
    _savedSignature = _currentSignature();
  }

  String? _bestSlotKeyForPlayer(
    _LineupPlayer player,
    List<_LineupSlot> slots,
    Set<String> usedKeys,
  ) {
    final code = (player.slotCodigo ?? player.posicionCodigo).toUpperCase();
    final exactByOrder =
        slots.where((s) => s.apiCode == code && s.order == player.orden).toList();
    if (exactByOrder.isNotEmpty && !usedKeys.contains(exactByOrder.first.key)) {
      return exactByOrder.first.key;
    }
    final byCode = slots.where((s) => s.apiCode == code && !usedKeys.contains(s.key));
    if (byCode.isNotEmpty) return byCode.first.key;
    final free = slots.where((s) => !usedKeys.contains(s.key));
    return free.isEmpty ? null : free.first.key;
  }

  void _changeFormation(String formation) {
    setState(() {
      final previousFormation = _formation;
      _formation = formation;
      _selectedSlotKey = null;
      final nextSlots = _slotsForFormation(formation);
      final kept = <String, _LineupPlayer?>{};
      final usedPlayerIds = <int>{};
      for (final slot in nextSlots) {
        final previousSameKey = _assigned[slot.key];
        if (previousSameKey?.id != null) {
          kept[slot.key] = previousSameKey;
          usedPlayerIds.add(previousSameKey!.id!);
          continue;
        }
        final previousByCode = _assigned.entries.firstWhere(
          (entry) {
            final oldSlot =
                _slotsForFormation(previousFormation)
                    .where((s) => s.key == entry.key)
                    .firstOrNull;
            final id = entry.value?.id;
            return oldSlot?.apiCode == slot.apiCode &&
                id != null &&
                !usedPlayerIds.contains(id);
          },
          orElse: () => const MapEntry('', null),
        );
        kept[slot.key] = previousByCode.value;
        if (previousByCode.value?.id != null) {
          usedPlayerIds.add(previousByCode.value!.id!);
        }
      }
      _assigned
        ..clear()
        ..addAll(kept);
    });
  }

  @override
  Widget build(BuildContext context) {
    final equipoId = widget.equipoId;
    if (equipoId == null) {
      return const Expanded(
        child: Center(child: Text('No se encontró el equipo seleccionado.')),
      );
    }

    final lineupAsync = ref.watch(coachAlineacionProvider(equipoId));
    final playersAsync = ref.watch(coachJugadoresProvider(equipoId));

    if ((lineupAsync.isLoading || playersAsync.isLoading) &&
        lineupAsync.valueOrNull == null &&
        playersAsync.valueOrNull == null) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }

    if ((lineupAsync.hasError || playersAsync.hasError) &&
        lineupAsync.valueOrNull == null &&
        playersAsync.valueOrNull == null) {
      final error = lineupAsync.error ?? playersAsync.error;
      return Expanded(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Color(0xFFD94929), size: 42),
                const SizedBox(height: 10),
                Text(
                  apiErrorMessage(
                    error,
                    defaultMessage: 'No se pudo cargar la alineación.',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(coachAlineacionProvider(equipoId));
                    ref.invalidate(coachJugadoresProvider(equipoId));
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    _hydrate(lineupAsync.valueOrNull, playersAsync.valueOrNull);

    final selectedSlot =
        _selectedSlotKey == null
            ? null
            : _slots.where((s) => s.key == _selectedSlotKey).firstOrNull;
    final assignedCount = _assigned.values.where((p) => p != null).length;
    final hasPendingChanges = _savedSignature != _currentSignature();
    final availablePlayers =
        _players
            .where((p) => !_assigned.values.any((a) => a?.id == p.id))
            .where((p) {
              if (selectedSlot == null) return true;
              return _matchesSlot(p, selectedSlot);
            })
            .toList();

    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LineupHeader(
              formation: _formation,
              formations: _formations,
              assignedCount: assignedCount,
              totalSlots: _slots.length,
              isEditing: hasPendingChanges,
              onFormationChanged: _changeFormation,
            ),
            const SizedBox(height: 12),
            _TacticalBoard(
              slots: _slots,
              assigned: _assigned,
              selectedSlotKey: _selectedSlotKey,
              onSlotTap: _handleSlotTap,
            ),
            const SizedBox(height: 10),
            Text(
              selectedSlot == null
                  ? 'Selecciona una posición para asignar un jugador'
                  : 'Selecciona jugador para ${selectedSlot.name} (${selectedSlot.label})',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF6B7280),
              ),
            ),
            if (hasPendingChanges) ...[
              const SizedBox(height: 12),
              _ProgressLine(assigned: assignedCount, total: _slots.length),
              const SizedBox(height: 14),
            ] else
              const SizedBox(height: 14),
            _AvailablePlayersCard(
              players: availablePlayers,
              selectedSlot: selectedSlot,
              onAssign:
                  selectedSlot == null ? null : (player) => _assignSelectedPlayer(player),
            ),
            if (hasPendingChanges) ...[
              const SizedBox(height: 14),
              _LineupActions(
                canSave: assignedCount > 0 && !_saving,
                isComplete: assignedCount == _slots.length,
                saving: _saving,
                onSave: () => _saveLineup(equipoId),
                onClear: _clearLineup,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleSlotTap(_LineupSlot slot) {
    final current = _assigned[slot.key];
    if (current == null) {
      setState(() => _selectedSlotKey = slot.key);
      _showAssignSheet(slot);
      return;
    }
    _showReplaceSheet(slot, current);
  }

  void _assignSelectedPlayer(_LineupPlayer player) {
    final slotKey = _selectedSlotKey;
    if (slotKey == null) return;
    setState(() {
      _assigned[slotKey] = player.copyWith(slotCodigo: _slotByKey(slotKey)?.apiCode);
      _selectedSlotKey = null;
    });
  }

  void _assignPlayerToSlot(_LineupSlot slot, _LineupPlayer player) {
    setState(() {
      _assigned[slot.key] = player.copyWith(slotCodigo: slot.apiCode);
      _selectedSlotKey = null;
    });
    Navigator.of(context).pop();
  }

  void _removeSlot(_LineupSlot slot) {
    setState(() {
      _assigned[slot.key] = null;
      _selectedSlotKey = slot.key;
    });
    Navigator.of(context).pop();
  }

  void _clearLineup() {
    setState(() {
      for (final slot in _slots) {
        _assigned[slot.key] = null;
      }
      _selectedSlotKey = null;
    });
  }

  Future<void> _saveLineup(int equipoId) async {
    setState(() => _saving = true);
    try {
      final jugadores = <Map<String, dynamic>>[];
      for (final slot in _slots) {
        final player = _assigned[slot.key];
        if (player == null || player.id == null) continue;
        jugadores.add({
          'jugador_id': player.id,
          'titular': true,
          'en_cancha': true,
          'orden': slot.order,
          'slot_codigo': slot.apiCode,
        });
      }
      final response = await ref
          .read(coachApiServiceProvider)
          .putAlineacion(equipoId, {
            'formacion': _formation,
            'jugadores': jugadores,
          });
      if (!mounted) return;
      ref.invalidate(coachAlineacionProvider(equipoId));
      setState(() {
        _savedSignature = _currentSignature();
      });
      CustomModal.show(
        context: context,
        title: 'Alineación guardada',
        message:
            response['message']?.toString() ??
            'La alineación base del equipo se guardó correctamente.',
        type: ModalType.success,
      );
    } catch (e) {
      if (!mounted) return;
      CustomModal.show(
        context: context,
        title: 'No se pudo guardar',
        message: apiErrorMessage(
          e,
          defaultMessage: 'No se pudo guardar la alineación. Intenta de nuevo.',
        ),
        type: ModalType.error,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _currentSignature() {
    final parts = <String>[_formation];
    for (final slot in _slots) {
      final player = _assigned[slot.key];
      parts.add('${slot.key}:${slot.apiCode}:${slot.order}:${player?.id ?? 'null'}');
    }
    return parts.join('|');
  }

  void _showReplaceSheet(_LineupSlot slot, _LineupPlayer current) {
    final candidates =
        _players
            .where((p) => p.id != current.id)
            .where((p) => !_assigned.values.any((a) => a?.id == p.id))
            .where((p) => _matchesSlot(p, slot))
            .toList();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => _ReplacePlayerSheet(
            slot: slot,
            current: current,
            candidates: candidates,
            onReplace: (player) => _assignPlayerToSlot(slot, player),
            onRemove: () => _removeSlot(slot),
          ),
    );
  }

  void _showAssignSheet(_LineupSlot slot) {
    final candidates =
        _players
            .where((p) => !_assigned.values.any((a) => a?.id == p.id))
            .where((p) => _matchesSlot(p, slot))
            .toList();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => _SelectPlayerSheet(
            slot: slot,
            candidates: candidates,
            onSelect: (player) => _assignPlayerToSlot(slot, player),
          ),
    ).whenComplete(() {
      if (!mounted) return;
      if (_assigned[slot.key] == null) {
        setState(() => _selectedSlotKey = null);
      }
    });
  }

  _LineupSlot? _slotByKey(String key) =>
      _slots.where((slot) => slot.key == key).firstOrNull;

  bool _matchesSlot(_LineupPlayer player, _LineupSlot slot) {
    final code = player.posicionCodigo.toUpperCase();
    final slotCode = slot.apiCode.toUpperCase();
    if (code == slotCode) return true;
    if (slot.group == 'DEL') return ['DEL', 'DC', 'EI', 'ED', 'ST'].contains(code);
    if (slot.group == 'MED') return ['MC', 'MCD', 'MCO', 'MED'].contains(code);
    if (slot.group == 'DEF') {
      return ['DEF', 'DFC', 'LI', 'LD', 'DF', 'DC'].contains(code);
    }
    if (slot.group == 'POR') return ['POR', 'PO', 'GK'].contains(code);
    return true;
  }

  static List<_LineupSlot> _slotsForFormation(String formation) {
    switch (formation) {
      case '4-4-2':
        return const [
          _LineupSlot('DC_1', 'DC', 'DC', 'Delantero centro', 'DEL', 0.38, 0.15, 1),
          _LineupSlot('DC_2', 'DC', 'DC', 'Delantero centro', 'DEL', 0.62, 0.15, 2),
          _LineupSlot('MI', 'MI', 'MI', 'Medio izquierdo', 'MED', 0.16, 0.40, 3),
          _LineupSlot('MC_1', 'MC', 'MC', 'Medio centro', 'MED', 0.38, 0.43, 4),
          _LineupSlot('MC_2', 'MC', 'MC', 'Medio centro', 'MED', 0.62, 0.43, 5),
          _LineupSlot('MD', 'MD', 'MD', 'Medio derecho', 'MED', 0.84, 0.40, 6),
          _LineupSlot('LI', 'LI', 'LI', 'Lateral izquierdo', 'DEF', 0.15, 0.68, 7),
          _LineupSlot('DFC_1', 'DFC', 'DFC', 'Defensa central', 'DEF', 0.38, 0.70, 8),
          _LineupSlot('DFC_2', 'DFC', 'DFC', 'Defensa central', 'DEF', 0.62, 0.70, 9),
          _LineupSlot('LD', 'LD', 'LD', 'Lateral derecho', 'DEF', 0.85, 0.68, 10),
          _LineupSlot('POR', 'POR', 'POR', 'Portero', 'POR', 0.50, 0.90, 11),
        ];
      case '3-5-2':
        return const [
          _LineupSlot('DC_1', 'DC', 'DC', 'Delantero centro', 'DEL', 0.38, 0.14, 1),
          _LineupSlot('DC_2', 'DC', 'DC', 'Delantero centro', 'DEL', 0.62, 0.14, 2),
          _LineupSlot('MI', 'MI', 'MI', 'Carrilero izquierdo', 'MED', 0.12, 0.42, 3),
          _LineupSlot('MC_1', 'MC', 'MC', 'Medio centro', 'MED', 0.32, 0.43, 4),
          _LineupSlot('MCD', 'MCD', 'MCD', 'Medio defensivo', 'MED', 0.50, 0.48, 5),
          _LineupSlot('MC_2', 'MC', 'MC', 'Medio centro', 'MED', 0.68, 0.43, 6),
          _LineupSlot('MD', 'MD', 'MD', 'Carrilero derecho', 'MED', 0.88, 0.42, 7),
          _LineupSlot('DFC_1', 'DFC', 'DFC', 'Defensa central', 'DEF', 0.28, 0.72, 8),
          _LineupSlot('DFC_2', 'DFC', 'DFC', 'Defensa central', 'DEF', 0.50, 0.74, 9),
          _LineupSlot('DFC_3', 'DFC', 'DFC', 'Defensa central', 'DEF', 0.72, 0.72, 10),
          _LineupSlot('POR', 'POR', 'POR', 'Portero', 'POR', 0.50, 0.90, 11),
        ];
      default:
        return const [
          _LineupSlot('EI', 'EI', 'EI', 'Extremo izquierdo', 'DEL', 0.20, 0.17, 1),
          _LineupSlot('DC', 'DC', 'DC', 'Delantero centro', 'DEL', 0.50, 0.13, 2),
          _LineupSlot('ED', 'ED', 'ED', 'Extremo derecho', 'DEL', 0.80, 0.17, 3),
          _LineupSlot('MC_1', 'MC', 'MC', 'Medio centro', 'MED', 0.22, 0.42, 4),
          _LineupSlot('MCD', 'MCD', 'MCD', 'Medio defensivo', 'MED', 0.50, 0.48, 5),
          _LineupSlot('MC_2', 'MC', 'MC', 'Medio centro', 'MED', 0.78, 0.42, 6),
          _LineupSlot('LI', 'LI', 'LI', 'Lateral izquierdo', 'DEF', 0.15, 0.69, 7),
          _LineupSlot('DFC_1', 'DFC', 'DFC', 'Defensa central', 'DEF', 0.38, 0.71, 8),
          _LineupSlot('DFC_2', 'DFC', 'DFC', 'Defensa central', 'DEF', 0.62, 0.71, 9),
          _LineupSlot('LD', 'LD', 'LD', 'Lateral derecho', 'DEF', 0.85, 0.69, 10),
          _LineupSlot('POR', 'POR', 'POR', 'Portero', 'POR', 0.50, 0.90, 11),
        ];
    }
  }
}

class _LineupHeader extends StatelessWidget {
  const _LineupHeader({
    required this.formation,
    required this.formations,
    required this.assignedCount,
    required this.totalSlots,
    required this.isEditing,
    required this.onFormationChanged,
  });

  final String formation;
  final List<String> formations;
  final int assignedCount;
  final int totalSlots;
  final bool isEditing;
  final ValueChanged<String> onFormationChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color.fromRGBO(224, 214, 200, 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ARMAR ALINEACIÓN',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: _LineupSectionState._dark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isEditing
                      ? '$assignedCount / $totalSlots jugadores asignados'
                      : 'Formación base del equipo',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(245, 240, 230, 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: formation,
                items:
                    formations
                        .map(
                          (f) => DropdownMenuItem<String>(
                            value: f,
                            child: Text(
                              f,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w800,
                                color: _LineupSectionState._red,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) onFormationChanged(value);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TacticalBoard extends StatelessWidget {
  const _TacticalBoard({
    required this.slots,
    required this.assigned,
    required this.selectedSlotKey,
    required this.onSlotTap,
  });

  final List<_LineupSlot> slots;
  final Map<String, _LineupPlayer?> assigned;
  final String? selectedSlotKey;
  final ValueChanged<_LineupSlot> onSlotTap;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.78,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF16790D), Color(0xFF0E5D08)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.16),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: CustomPaint(
            painter: _PitchPainter(),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children:
                      slots.map((slot) {
                        final player = assigned[slot.key];
                        final size = constraints.maxWidth * 0.17;
                        return Positioned(
                          left: constraints.maxWidth * slot.x - size / 2,
                          top: constraints.maxHeight * slot.y - size / 2,
                          width: size,
                          child: _LineupSlotChip(
                            slot: slot,
                            player: player,
                            selected: selectedSlotKey == slot.key,
                            onTap: () => onSlotTap(slot),
                          ),
                        );
                      }).toList(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _LineupSlotChip extends StatelessWidget {
  const _LineupSlotChip({
    required this.slot,
    required this.player,
    required this.selected,
    required this.onTap,
  });

  final _LineupSlot slot;
  final _LineupPlayer? player;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final occupied = player != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color:
                  occupied
                      ? Colors.white
                      : Colors.white.withValues(alpha: selected ? 0.95 : 0.10),
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    selected
                        ? _LineupSectionState._red
                        : Colors.white.withValues(alpha: 0.80),
                width: selected ? 3 : 1.5,
              ),
              boxShadow:
                  selected
                      ? [
                        BoxShadow(
                          color: _LineupSectionState._red.withValues(alpha: 0.45),
                          blurRadius: 16,
                        ),
                      ]
                      : null,
            ),
            child:
                occupied
                    ? ClipOval(
                      child: _LineupAvatar(
                        name: player!.shortName,
                        imageUrl: player!.fotoUrl,
                      ),
                    )
                    : const Icon(Icons.add, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color:
                  occupied
                      ? _LineupSectionState._red
                      : Colors.black.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              slot.label,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final stripe = Paint()..color = Colors.white.withValues(alpha: 0.035);
    for (var i = 0; i < 6; i++) {
      if (i.isEven) {
        canvas.drawRect(
          Rect.fromLTWH(0, size.height / 6 * i, size.width, size.height / 6),
          stripe,
        );
      }
    }
    final field = Rect.fromLTWH(14, 14, size.width - 28, size.height - 28);
    canvas.drawRect(field, line);
    canvas.drawLine(
      Offset(14, size.height / 2),
      Offset(size.width - 14, size.height / 2),
      line,
    );
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 42, line);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width / 2, 14),
        width: size.width * 0.36,
        height: 54,
      ),
      line,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height - 14),
        width: size.width * 0.36,
        height: 54,
      ),
      line,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({required this.assigned, required this.total});

  final int assigned;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : assigned / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$assigned / $total jugadores asignados',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: _LineupSectionState._dark,
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            backgroundColor: const Color.fromRGBO(230, 224, 214, 1),
            valueColor: const AlwaysStoppedAnimation<Color>(
              _LineupSectionState._green,
            ),
          ),
        ),
      ],
    );
  }
}

class _AvailablePlayersCard extends StatelessWidget {
  const _AvailablePlayersCard({
    required this.players,
    required this.selectedSlot,
    required this.onAssign,
  });

  final List<_LineupPlayer> players;
  final _LineupSlot? selectedSlot;
  final ValueChanged<_LineupPlayer>? onAssign;

  @override
  Widget build(BuildContext context) {
    final slot = selectedSlot;
    final title =
        slot == null ? 'SUPLENTES' : 'JUGADORES PARA ${slot.label}';
    final countLabel =
        slot == null ? '${players.length} suplentes' : '${players.length} opciones';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color.fromRGBO(224, 214, 200, 1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: _LineupSectionState._dark,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(213, 241, 199, 1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  countLabel,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: _LineupSectionState._green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (slot == null)
            if (players.isEmpty)
              const _LineupInfoBox(text: 'No hay suplentes disponibles.')
            else
              ...players.take(10).map(
                    (player) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _AvailablePlayerTile(player: player),
                    ),
                  )
          else if (players.isEmpty)
            _LineupInfoBox(
              text: 'No hay jugadores disponibles para ${slot.label}.',
            )
          else
            ...players.take(8).map(
                  (player) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _AvailablePlayerTile(
                      player: player,
                      onTap: onAssign == null ? null : () => onAssign!(player),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _LineupInfoBox extends StatelessWidget {
  const _LineupInfoBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: _LineupSectionState._cream,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF6B7280),
        ),
      ),
    );
  }
}

class _AvailablePlayerTile extends StatelessWidget {
  const _AvailablePlayerTile({required this.player, this.onTap});

  final _LineupPlayer player;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(251, 248, 241, 1),
          borderRadius: BorderRadius.circular(14),
          border: Border(
            left: BorderSide(
              color: _colorForGroup(player.posicionCodigo),
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 42,
              height: 42,
              child: ClipOval(
                child: _LineupAvatar(name: player.shortName, imageUrl: player.fotoUrl),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: _LineupSectionState._dark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      _MiniTag(text: player.posicionCodigo),
                      if (player.dorsal != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          '#${player.dorsal}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.add_circle,
                color: _LineupSectionState._red,
              ),
          ],
        ),
      ),
    );
  }

  static Color _colorForGroup(String code) {
    final c = code.toUpperCase();
    if (['DEL', 'DC', 'EI', 'ED', 'ST'].contains(c)) return _LineupSectionState._red;
    if (['MC', 'MCD', 'MCO', 'MED'].contains(c)) return const Color(0xFF6C8194);
    if (['POR', 'PO', 'GK'].contains(c)) return const Color(0xFF2F8F3A);
    return const Color(0xFF6C8194);
  }
}

class _ReplacePlayerSheet extends StatelessWidget {
  const _ReplacePlayerSheet({
    required this.slot,
    required this.current,
    required this.candidates,
    required this.onReplace,
    required this.onRemove,
  });

  final _LineupSlot slot;
  final _LineupPlayer current;
  final List<_LineupPlayer> candidates;
  final ValueChanged<_LineupPlayer> onReplace;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.62,
      minChildSize: 0.40,
      maxChildSize: 0.90,
      builder:
          (_, controller) => Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: ListView(
              controller: controller,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${slot.name.toUpperCase()} (${slot.label})',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: _LineupSectionState._dark,
                  ),
                ),
                const SizedBox(height: 14),
                _CurrentPlayerCard(player: current),
                const SizedBox(height: 18),
                Text(
                  'REEMPLAZAR POR',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 10),
                if (candidates.isEmpty)
                  const _LineupInfoBox(text: 'No hay jugadores disponibles para reemplazar.')
                else
                  ...candidates.map(
                    (player) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _AvailablePlayerTile(
                        player: player,
                        onTap: () => onReplace(player),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Quitar jugador'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _LineupSectionState._red,
                    side: const BorderSide(color: _LineupSectionState._red),
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}

class _SelectPlayerSheet extends StatelessWidget {
  const _SelectPlayerSheet({
    required this.slot,
    required this.candidates,
    required this.onSelect,
  });

  final _LineupSlot slot;
  final List<_LineupPlayer> candidates;
  final ValueChanged<_LineupPlayer> onSelect;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.58,
      minChildSize: 0.36,
      maxChildSize: 0.88,
      builder:
          (_, controller) => Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: ListView(
              controller: controller,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'SELECCIONAR JUGADOR',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: _LineupSectionState._dark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${slot.name} (${slot.label})',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 14),
                if (candidates.isEmpty)
                  _LineupInfoBox(
                    text:
                        'No hay jugadores disponibles para esta posición. Prueba otra posición o revisa la plantilla.',
                  )
                else
                  ...candidates.map(
                    (player) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _AvailablePlayerTile(
                        player: player,
                        onTap: () => onSelect(player),
                      ),
                    ),
                  ),
              ],
            ),
          ),
    );
  }
}

class _CurrentPlayerCard extends StatelessWidget {
  const _CurrentPlayerCard({required this.player});

  final _LineupPlayer player;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(251, 248, 241, 1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 46,
            height: 46,
            child: ClipOval(
              child: _LineupAvatar(name: player.shortName, imageUrl: player.fotoUrl),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _LineupSectionState._dark,
                  ),
                ),
                const SizedBox(height: 3),
                Row(children: [_MiniTag(text: player.posicionCodigo)]),
              ],
            ),
          ),
          Text(
            'Actual',
            style: GoogleFonts.inter(
              color: _LineupSectionState._green,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _LineupActions extends StatelessWidget {
  const _LineupActions({
    required this.canSave,
    required this.isComplete,
    required this.saving,
    required this.onSave,
    required this.onClear,
  });

  final bool canSave;
  final bool isComplete;
  final bool saving;
  final VoidCallback onSave;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isComplete)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(225, 246, 217, 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: _LineupSectionState._green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Alineación completa. Lista para guardar.',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w800,
                      color: _LineupSectionState._green,
                    ),
                  ),
                ),
              ],
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: canSave ? onSave : null,
            style: FilledButton.styleFrom(
              backgroundColor: _LineupSectionState._red,
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'GUARDAR ALINEACIÓN',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.delete_outline),
            label: const Text('LIMPIAR ALINEACIÓN'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _LineupSectionState._red,
              side: const BorderSide(color: _LineupSectionState._red),
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniTag extends StatelessWidget {
  const _MiniTag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(245, 224, 218, 1),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: _LineupSectionState._red,
        ),
      ),
    );
  }
}

class _LineupAvatar extends StatelessWidget {
  const _LineupAvatar({required this.name, this.imageUrl});

  final String name;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = _normalizeImageUrl(imageUrl);
    if (url != null) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _initials(),
      );
    }
    return _initials();
  }

  Widget _initials() {
    final initials =
        name
            .trim()
            .split(RegExp(r'\s+'))
            .where((p) => p.isNotEmpty)
            .take(2)
            .map((p) => p[0].toUpperCase())
            .join();
    return Container(
      color: const Color(0xFFD6E5EF),
      alignment: Alignment.center,
      child: Text(
        initials.isEmpty ? 'JG' : initials,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w900,
          color: const Color(0xFF22423A),
        ),
      ),
    );
  }

  static String? _normalizeImageUrl(String? raw) {
    final v = (raw ?? '').trim();
    if (v.isEmpty || v.toLowerCase() == 'null') return null;
    if (v.startsWith('http://localhost')) {
      return v.replaceFirst(
        'http://localhost',
        '${Environment.backendScheme}://${Environment.backendHost}:${Environment.backendPort}',
      );
    }
    if (v.startsWith('https://localhost')) {
      return v.replaceFirst(
        'https://localhost',
        '${Environment.backendScheme}://${Environment.backendHost}:${Environment.backendPort}',
      );
    }
    if (v.startsWith('http://') || v.startsWith('https://')) return v;
    if (v.startsWith('/')) return '${Environment.baseUrl}$v';
    return '${Environment.baseUrl}/$v';
  }
}

class _LineupSlot {
  const _LineupSlot(
    this.key,
    this.apiCode,
    this.label,
    this.name,
    this.group,
    this.x,
    this.y,
    this.order,
  );

  final String key;
  final String apiCode;
  final String label;
  final String name;
  final String group;
  final double x;
  final double y;
  final int order;
}

class _LineupPlayer {
  const _LineupPlayer({
    required this.id,
    required this.name,
    required this.dorsal,
    required this.posicion,
    required this.posicionCodigo,
    required this.fotoUrl,
    required this.titular,
    required this.enCancha,
    required this.orden,
    required this.slotCodigo,
  });

  final int? id;
  final String name;
  final int? dorsal;
  final String posicion;
  final String posicionCodigo;
  final String? fotoUrl;
  final bool titular;
  final bool enCancha;
  final int? orden;
  final String? slotCodigo;

  String get shortName {
    final parts = name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'Jugador';
    if (parts.length == 1) return parts.first;
    return '${parts.first} ${parts.last[0]}.';
  }

  _LineupPlayer copyWith({String? slotCodigo}) {
    return _LineupPlayer(
      id: id,
      name: name,
      dorsal: dorsal,
      posicion: posicion,
      posicionCodigo: posicionCodigo,
      fotoUrl: fotoUrl,
      titular: titular,
      enCancha: enCancha,
      orden: orden,
      slotCodigo: slotCodigo ?? this.slotCodigo,
    );
  }

  factory _LineupPlayer.fromMap(Map<String, dynamic> map) {
    final id = (map['id'] as num?)?.toInt() ?? (map['jugador_id'] as num?)?.toInt();
    final nombre =
        map['nombre_completo']?.toString().trim() ??
        [
          map['nombre']?.toString().trim(),
          map['apellido']?.toString().trim(),
        ].where((e) => (e ?? '').isNotEmpty).join(' ').trim();
    final pos = map['posicion'];
    String posText = 'Jugador';
    if (pos is Map) {
      final p = Map<String, dynamic>.from(pos);
      posText = (p['nombre'] ?? p['codigo'] ?? p['abreviatura'] ?? 'Jugador').toString();
    } else if (pos != null) {
      posText = pos.toString();
    }
    final posCode =
        (map['posicion_codigo'] ??
                map['posicion_abreviatura'] ??
                map['posicion_codigo_api'] ??
                _guessPositionCode(posText))
            .toString()
            .toUpperCase();
    return _LineupPlayer(
      id: id,
      name: nombre.isEmpty ? 'Jugador' : nombre,
      dorsal: (map['dorsal'] as num?)?.toInt() ??
          (map['dorsal_actual'] as num?)?.toInt() ??
          int.tryParse(map['numero_camiseta']?.toString() ?? ''),
      posicion: posText,
      posicionCodigo: posCode,
      fotoUrl: map['foto_url']?.toString(),
      titular: map['titular'] == true,
      enCancha: map['en_cancha'] == true,
      orden: (map['orden'] as num?)?.toInt(),
      slotCodigo: map['slot_codigo']?.toString().toUpperCase(),
    );
  }

  static String _guessPositionCode(String raw) {
    final v = raw.toLowerCase();
    if (v.contains('port')) return 'POR';
    if (v.contains('del')) return 'DEL';
    if (v.contains('medio') || v.contains('centro')) return 'MC';
    if (v.contains('def')) return 'DFC';
    return raw.toUpperCase();
  }
}

class _TopSegmentTabs extends StatelessWidget {
  const _TopSegmentTabs({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const items = ['Inicio', 'Alineación', 'Partidos'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(245, 240, 230, 1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color.fromRGBO(224, 214, 200, 1)),
      ),
      child: Row(
        children:
            items.map((item) {
              final active = item == selected;
              return Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => onChanged(item),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color:
                          active ? const Color(0xFFD94929) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      item,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color:
                            active
                                ? Colors.white
                                : const Color.fromRGBO(55, 73, 87, 1),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}

/// Sección combinada: detalles del equipo + listado de jugadores.
class _TeamOverviewSection extends ConsumerWidget {
  const _TeamOverviewSection({this.equipoId});
  final int? equipoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (equipoId == null) {
      return const Expanded(
        child: Center(child: Text('No se encontró el equipo seleccionado.')),
      );
    }

    final jugadoresAsync = ref.watch(coachJugadoresProvider(equipoId!));
    final equipoAsync = ref.watch(coachEquipoProvider(equipoId!));
    final partidosAsync = ref.watch(coachPartidosByEquipoProvider(equipoId!));

    if (Environment.useBackend &&
        (jugadoresAsync.isLoading || equipoAsync.isLoading) &&
        jugadoresAsync.valueOrNull == null &&
        equipoAsync.valueOrNull == null) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }

    if (Environment.useBackend &&
        (jugadoresAsync.hasError || equipoAsync.hasError) &&
        jugadoresAsync.valueOrNull == null &&
        equipoAsync.valueOrNull == null) {
      final error = jugadoresAsync.error ?? equipoAsync.error;
      return Expanded(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Color(0xFFD94929), size: 42),
                const SizedBox(height: 10),
                Text(
                  apiErrorMessage(
                    error,
                    defaultMessage:
                        'No se pudo cargar la información del equipo.',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(coachJugadoresProvider(equipoId!));
                    ref.invalidate(coachEquipoProvider(equipoId!));
                    ref.invalidate(coachPartidosByEquipoProvider(equipoId!));
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final jugadoresData = jugadoresAsync.valueOrNull ?? <String, dynamic>{};
    final equipoData = equipoAsync.valueOrNull ?? <String, dynamic>{};
    final partidosData = partidosAsync.valueOrNull ?? <String, dynamic>{};

    final equipoFromJugadores =
        (jugadoresData['equipo'] is Map)
            ? Map<String, dynamic>.from(jugadoresData['equipo'])
            : <String, dynamic>{};
    final equipo =
        (equipoData['equipo'] is Map)
            ? Map<String, dynamic>.from(equipoData['equipo'])
            : equipoFromJugadores;

    final jugadoresRaw =
        (jugadoresData['jugadores'] as List<dynamic>?) ?? const [];
    final jugadores =
        jugadoresRaw
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

    final totalJugadores =
        (jugadoresData['total'] as num?)?.toInt() ?? jugadores.length;
    final hasMoreJugadores = jugadores.length > 3;
    final visibleJugadores =
        hasMoreJugadores ? jugadores.take(3).toList() : jugadores;
    final categoria = equipo['categoria']?.toString() ?? 'Sin categoría';
    final teamName =
        (equipo['nombre']?.toString().trim().isNotEmpty ?? false)
            ? equipo['nombre'].toString()
            : 'Equipo';

    final partidosRaw =
        (partidosData['partidos'] as List<dynamic>?) ?? const [];
    final partidos =
        partidosRaw
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
    final record = _buildRecord(partidos);
    final proximoPartido = _nextMatchShort(partidos);
    final nextMatch = _nextMatchMap(partidos);

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            _NextMatchHeroCard(
              teamName: teamName,
              partido: nextMatch,
              onLineup: () {
                ref.read(selectedMenuProvider.notifier).state = 'Alineación';
              },
              onDetails: () {
                ref.read(selectedMenuProvider.notifier).state = 'Partidos';
              },
            ),
            const SizedBox(height: 18),
            Text(
              'Resumen del equipo',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0B1926),
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.75,
              children: [
                _DashboardMetricCard(
                  icon: Icons.groups_rounded,
                  label: 'Integrantes',
                  value: '$totalJugadores',
                  footer: 'jugadores',
                  tone: 0,
                ),
                _DashboardMetricCard(
                  icon: Icons.sports_soccer_rounded,
                  label: 'Categoría',
                  value: categoria,
                  footer: categoria.toUpperCase().startsWith('U')
                      ? 'Sub ${categoria.replaceAll(RegExp(r'[^0-9]'), '')}'
                      : 'Equipo',
                  tone: 1,
                ),
                _DashboardMetricCard(
                  icon: Icons.emoji_events_outlined,
                  label: 'Récord',
                  value: record,
                  footer: 'Últimos partidos',
                  tone: 2,
                ),
                _DashboardMetricCard(
                  icon: Icons.event_rounded,
                  label: 'Próximo partido',
                  value: proximoPartido,
                  footer: 'Calendario',
                  tone: 3,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  'Plantilla',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: const Color(0xFF0B1926),
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    ref.read(selectedMenuProvider.notifier).state =
                        'Alineación';
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Ver todos',
                          style: GoogleFonts.inter(
                            color: const Color(0xFFD94929),
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: Color(0xFFD94929),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const _SquadSearchRow(),
            const SizedBox(height: 12),
            if (jugadores.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'No hay jugadores registrados en este equipo.',
                  style: GoogleFonts.inter(color: const Color(0xFF6B7280)),
                ),
              )
            else
              _SquadPanel(
                jugadores: visibleJugadores,
                equipoId: equipoId!,
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _NextMatchHeroCard extends StatelessWidget {
  const _NextMatchHeroCard({
    required this.teamName,
    required this.partido,
    required this.onLineup,
    required this.onDetails,
  });

  final String teamName;
  final Map<String, dynamic>? partido;
  final VoidCallback onLineup;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    final rival =
        (partido?['rival_nombre'] ?? partido?['rival'] ?? 'Rival por definir')
            .toString();
    final competencia = (partido?['competencia'] ?? 'Próximo encuentro').toString();
    final fecha = _prettyMatchDate(partido?['fecha']?.toString());
    final hora = _prettyHour(partido?['hora']?.toString());
    final hasMatch = partido != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: const Border(left: BorderSide(color: Color(0xFFD94929), width: 5)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.08),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -38,
            top: -6,
            bottom: -22,
            child: Transform.rotate(
              angle: -0.35,
              child: Icon(
                Icons.sports_soccer,
                size: 150,
                color: const Color(0xFF23840C).withValues(alpha: 0.12),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hasMatch ? '› PRÓXIMO PARTIDO' : '› SIN PARTIDO PROGRAMADO',
                style: GoogleFonts.inter(
                  color: const Color(0xFFD94929),
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                hasMatch ? '$fecha · $hora' : 'Programa un encuentro',
                style: GoogleFonts.inter(
                  color: const Color(0xFF0B1926),
                  fontWeight: FontWeight.w900,
                  fontSize: 25,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                competencia,
                style: GoogleFonts.inter(
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _TeamShield(label: _abbr(teamName), color: const Color(0xFFD94929)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      teamName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0B1926),
                      ),
                    ),
                  ),
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(245, 240, 230, 1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      'VS',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      rival,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0B1926),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _TeamShield(label: _abbr(rival), color: const Color(0xFF28558C)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onLineup,
                      icon: const Icon(Icons.chevron_right_rounded),
                      label: const Text('ARMAR ALINEACIÓN'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFD94929),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onDetails,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFD94929),
                        side: const BorderSide(color: Color(0xFFD94929)),
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('VER DETALLES'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _prettyMatchDate(String? raw) {
    final d = DateTime.tryParse(raw ?? '');
    if (d == null) return '--';
    const wd = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    const mo = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return '${wd[d.weekday - 1]} ${d.day} ${mo[d.month - 1]}';
  }

  static String _prettyHour(String? raw) {
    if ((raw ?? '').isEmpty) return '--:--';
    final parts = raw!.split(':');
    if (parts.length < 2) return raw;
    return '${parts[0].padLeft(2, '0')}:${parts[1]}';
  }

  static String _abbr(String value) {
    final words = value.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (words.isEmpty) return 'FC';
    if (words.length == 1) return words.first.substring(0, words.first.length.clamp(1, 3)).toUpperCase();
    return words.take(2).map((e) => e[0]).join().toUpperCase();
  }
}

class _TeamShield extends StatelessWidget {
  const _TeamShield({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1.4),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _DashboardMetricCard extends StatelessWidget {
  const _DashboardMetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.footer,
    required this.tone,
  });

  final IconData icon;
  final String label;
  final String value;
  final String footer;
  final int tone;

  @override
  Widget build(BuildContext context) {
    const colors = [
      Color(0xFFD94929),
      Color(0xFF2F80ED),
      Color(0xFF6F42C1),
      Color(0xFF43A047),
    ];
    final color = colors[tone % colors.length];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.06),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 27),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.7,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0B1926),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  footer,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SquadSearchRow extends StatelessWidget {
  const _SquadSearchRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: Color(0xFF6B7280)),
                const SizedBox(width: 10),
                Text(
                  'Buscar jugador...',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              const Icon(Icons.filter_list_rounded, color: Color(0xFF6B7280)),
              const SizedBox(width: 6),
              Text(
                'Filtros',
                style: GoogleFonts.inter(
                  color: const Color(0xFF374957),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SquadPanel extends StatelessWidget {
  const _SquadPanel({required this.jugadores, required this.equipoId});

  final List<Map<String, dynamic>> jugadores;
  final int equipoId;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.06),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ListView.separated(
        itemCount: jugadores.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder:
            (_, i) => _DashboardPlayerTile(
              jugador: jugadores[i],
              equipoId: equipoId,
            ),
      ),
    );
  }
}

class _DashboardPlayerTile extends StatelessWidget {
  const _DashboardPlayerTile({required this.jugador, required this.equipoId});

  final Map<String, dynamic> jugador;
  final int equipoId;

  @override
  Widget build(BuildContext context) {
    final nombre = _TeamPlayerTile._displayName(jugador);
    final jugadorId = (jugador['id'] as num?)?.toInt();
    final photo = _TeamPlayerTile._normalizeImageUrl(jugador['foto_url']?.toString());
    final dorsal = (jugador['dorsal'] ?? jugador['dorsal_actual'] ?? jugador['numero_camiseta'])?.toString() ?? '--';
    final posicion = _TeamPlayerTile._positionAbbr(jugador);
    final tag = _TeamPlayerTile._positionTag(posicion);

    return InkWell(
      onTap:
          jugadorId == null
              ? null
              : () => context.pushNamed(
                PlayerStatusScreen.name,
                extra: {
                  'name': nombre,
                  'image': photo ?? '',
                  'jugador_id': jugadorId,
                  'equipo_id': equipoId,
                },
              ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            SizedBox(
              width: 54,
              height: 54,
              child: ClipOval(
                child: (photo ?? '').isNotEmpty
                    ? Image.network(photo!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _TeamPlayerTile._initialsAvatar(nombre))
                    : _TeamPlayerTile._initialsAvatar(nombre),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0B1926),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '#$dorsal',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: tag.$2,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tag.$1,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: tag.$3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          jugador['posicion']?.toString() ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: const Color(0xFF6B7280),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}

class _TeamPlayerTile extends StatelessWidget {
  const _TeamPlayerTile({required this.jugador, required this.equipoId});
  final Map<String, dynamic> jugador;
  final int equipoId;

  @override
  Widget build(BuildContext context) {
    final jugadorId = (jugador['id'] as num?)?.toInt();
    final nombre = _displayName(jugador);
    final dorsal =
        (jugador['dorsal'] ??
                jugador['dorsal_actual'] ??
                jugador['numero_camiseta'])
            ?.toString() ??
        '--';
    final posicion = _positionAbbr(jugador);
    final posicionTag = _positionTag(posicion);
    final photo = _normalizeImageUrl(jugador['foto_url']?.toString());

    return InkWell(
      onTap:
          jugadorId == null
              ? null
              : () => context.pushNamed(
                PlayerStatusScreen.name,
                extra: {
                  'name': nombre,
                  'image': photo ?? '',
                  'jugador_id': jugadorId,
                  'equipo_id': equipoId,
                },
              ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(251, 248, 241, 1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color.fromRGBO(235, 227, 216, 1)),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.04),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE0D6C8), width: 1.5),
              ),
              child: ClipOval(
                child:
                    (photo ?? '').isNotEmpty
                        ? Image.network(
                          photo!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _initialsAvatar(nombre),
                        )
                        : _initialsAvatar(nombre),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    nombre,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0B1926),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '#$dorsal',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF374957),
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: Color(0xFF9CA3AF),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: posicionTag.$2,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          posicionTag.$1,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: posicionTag.$3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(55, 73, 87, 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF9CA3AF),
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _displayName(Map<String, dynamic> j) {
    final full = j['nombre_completo']?.toString().trim() ?? '';
    if (full.isNotEmpty) return full;
    final nombre = j['nombre']?.toString().trim() ?? '';
    final apellido = j['apellido']?.toString().trim() ?? '';
    final composed = '$nombre $apellido'.trim();
    return composed.isEmpty ? 'Jugador' : composed;
  }

  static String _positionAbbr(Map<String, dynamic> j) {
    final pos = j['posicion'];
    if (pos is Map) {
      final m = Map<String, dynamic>.from(pos);
      return (m['abreviatura'] ?? m['codigo'] ?? m['nombre'] ?? '--')
          .toString()
          .toUpperCase();
    }
    final direct =
        (j['posicion_abreviatura'] ??
                j['posicion_codigo'] ??
                j['posicion_nombre'])
            ?.toString();
    if (direct != null && direct.trim().isNotEmpty) {
      return direct.toUpperCase();
    }
    return '--';
  }

  static (String, Color, Color) _positionTag(String raw) {
    switch (raw.toUpperCase()) {
      case 'PO':
      case 'GK':
        return (
          'GK',
          const Color.fromRGBO(227, 238, 255, 1),
          const Color.fromRGBO(84, 125, 214, 1),
        );
      case 'DC':
      case 'DFC':
      case 'DEF':
        return (
          'DEF',
          const Color.fromRGBO(224, 247, 235, 1),
          const Color.fromRGBO(34, 123, 77, 1),
        );
      case 'MC':
      case 'MCD':
      case 'MCO':
      case 'MED':
        return (
          'MCO',
          const Color.fromRGBO(255, 244, 199, 1),
          const Color.fromRGBO(165, 120, 18, 1),
        );
      case 'DEL':
      case 'EI':
      case 'ED':
      case 'ST':
        return (
          'DEL',
          const Color.fromRGBO(255, 228, 238, 1),
          const Color.fromRGBO(193, 66, 113, 1),
        );
      default:
        return (
          raw.toUpperCase(),
          const Color.fromRGBO(242, 235, 226, 1),
          const Color.fromRGBO(107, 114, 128, 1),
        );
    }
  }

  static String? _normalizeImageUrl(String? raw) {
    final v = (raw ?? '').trim();
    if (v.isEmpty || v.toLowerCase() == 'null') return null;
    if (v.startsWith('http://localhost')) {
      return v.replaceFirst(
        'http://localhost',
        '${Environment.backendScheme}://${Environment.backendHost}:${Environment.backendPort}',
      );
    }
    if (v.startsWith('https://localhost')) {
      return v.replaceFirst(
        'https://localhost',
        '${Environment.backendScheme}://${Environment.backendHost}:${Environment.backendPort}',
      );
    }
    if (v.startsWith('http://') || v.startsWith('https://')) return v;
    if (v.startsWith('/')) return '${Environment.baseUrl}$v';
    return '${Environment.baseUrl}/$v';
  }

  static Widget _initialsAvatar(String name) {
    final initials =
        name
            .trim()
            .split(RegExp(r'\s+'))
            .where((p) => p.isNotEmpty)
            .take(2)
            .map((p) => p[0].toUpperCase())
            .join();
    return Container(
      color: const Color(0xFFD6E5EF),
      child: Center(
        child: Text(
          initials.isEmpty ? 'JG' : initials,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF22423A),
          ),
        ),
      ),
    );
  }

}

String _buildRecord(List<Map<String, dynamic>> partidos) {
  var v = 0;
  var e = 0;
  var d = 0;
  for (final p in partidos) {
    final resultado = p['resultado']?.toString() ?? '';
    final diff = _PartidosSectionState._resultDiff(resultado);
    if (diff == null) continue;
    if (diff > 0) {
      v++;
    } else if (diff < 0) {
      d++;
    } else {
      e++;
    }
  }
  return '$v V · $e E · $d D';
}

String _nextMatchShort(List<Map<String, dynamic>> partidos) {
  final now = DateTime.now();
  Map<String, dynamic>? next;
  DateTime? nextDt;

  for (final p in partidos) {
    final raw = p['fecha']?.toString() ?? '';
    final dt = DateTime.tryParse(raw);
    final hasResult = (p['resultado']?.toString().trim().isNotEmpty ?? false);
    if (dt == null || hasResult || dt.isBefore(now)) continue;
    if (nextDt == null || dt.isBefore(nextDt)) {
      nextDt = dt;
      next = p;
    }
  }

  if (next == null || nextDt == null) return '--';

  const wd = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
  const mo = [
    'Ene',
    'Feb',
    'Mar',
    'Abr',
    'May',
    'Jun',
    'Jul',
    'Ago',
    'Sep',
    'Oct',
    'Nov',
    'Dic',
  ];
  return '${wd[nextDt.weekday - 1]} ${nextDt.day} ${mo[nextDt.month - 1]}';
}

Map<String, dynamic>? _nextMatchMap(List<Map<String, dynamic>> partidos) {
  final now = DateTime.now();
  Map<String, dynamic>? next;
  DateTime? nextDt;

  for (final p in partidos) {
    final raw = p['fecha']?.toString() ?? '';
    final dt = DateTime.tryParse(raw);
    final hasResult = (p['resultado']?.toString().trim().isNotEmpty ?? false);
    if (dt == null || hasResult || dt.isBefore(DateTime(now.year, now.month, now.day))) {
      continue;
    }
    if (nextDt == null || dt.isBefore(nextDt)) {
      nextDt = dt;
      next = p;
    }
  }

  return next;
}

/// Sección de Partidos: crear partido + próximos + historial.
class _PartidosSection extends ConsumerStatefulWidget {
  const _PartidosSection({this.equipoId});
  final int? equipoId;

  @override
  ConsumerState<_PartidosSection> createState() => _PartidosSectionState();
}

class _PartidosSectionState extends ConsumerState<_PartidosSection> {
  int? _selectedMonth;
  int _initialRetryAttempts = 0;
  static const int _maxInitialRetries = 2;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now().month;
  }

  bool _canOpenLive(Map<String, dynamic> partido) {
    final id = partido['id'];
    if (id is! num) return false;
    final estado = partido['estado_partido']?.toString().trim().toUpperCase();
    return estado != 'FINALIZADO';
  }

  @override
  Widget build(BuildContext context) {
    final partidosAsync =
        widget.equipoId == null
            ? ref.watch(coachPartidosProvider)
            : ref.watch(coachPartidosByEquipoProvider(widget.equipoId!));

    if (partidosAsync.hasError && partidosAsync.valueOrNull == null) {
      if (_shouldRetryInitialLoad(partidosAsync.error) &&
          _initialRetryAttempts < _maxInitialRetries) {
        _initialRetryAttempts += 1;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future<void>.delayed(const Duration(milliseconds: 700), () {
            if (!mounted) return;
            if (widget.equipoId == null) {
              ref.invalidate(coachPartidosProvider);
            } else {
              ref.invalidate(coachPartidosByEquipoProvider(widget.equipoId!));
            }
          });
        });

        return const Expanded(
          child: Center(child: CircularProgressIndicator()),
        );
      }

      return Expanded(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Color(0xFFD94929), size: 42),
                const SizedBox(height: 10),
                Text(
                  apiErrorMessage(
                    partidosAsync.error,
                    defaultMessage: 'No se pudieron cargar los partidos.',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    if (widget.equipoId == null) {
                      ref.invalidate(coachPartidosProvider);
                    } else {
                      ref.invalidate(
                        coachPartidosByEquipoProvider(widget.equipoId!),
                      );
                    }
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (partidosAsync.hasValue) {
      _initialRetryAttempts = 0;
    }

    final raw =
        ((partidosAsync.valueOrNull?['partidos'] as List<dynamic>?) ??
            const []);
    final partidos =
        raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();

    final now = DateTime.now();
    final month = _selectedMonth ?? now.month;
    final monthPartidos =
        partidos.where((p) {
          final dt = DateTime.tryParse(p['fecha']?.toString() ?? '');
          return dt != null && dt.month == month && dt.year == now.year;
        }).toList();

    monthPartidos.sort((a, b) {
      final ad =
          DateTime.tryParse(a['fecha']?.toString() ?? '') ?? DateTime(2100);
      final bd =
          DateTime.tryParse(b['fecha']?.toString() ?? '') ?? DateTime(2100);
      return ad.compareTo(bd);
    });

    final hoy = <Map<String, dynamic>>[];
    final proximos = <Map<String, dynamic>>[];
    final pasados = <Map<String, dynamic>>[];
    for (final p in monthPartidos) {
      final d = DateTime.tryParse(p['fecha']?.toString() ?? '');
      final hasResult = (p['resultado']?.toString().trim().isNotEmpty ?? false);
      if (d == null) continue;
      final only = DateTime(d.year, d.month, d.day);
      final today = DateTime(now.year, now.month, now.day);
      if (only == today) {
        hoy.add(p);
      } else if (hasResult || only.isBefore(today)) {
        pasados.add(p);
      } else {
        proximos.add(p);
      }
    }

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              'CALENDARIO DE PARTIDOS',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF9CA3AF),
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed:
                    () => context.pushNamed(
                      '/new_match_screen',
                      extra: widget.equipoId,
                    ),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text(
                  'Crear partido',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  backgroundColor: const Color(0xFFD94929),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const SizedBox(height: 14),
            _MonthChipsRow(
              selectedMonth: month,
              onMonthSelected: (m) => setState(() => _selectedMonth = m),
            ),
            const SizedBox(height: 14),
            _AgendaSectionHeader(title: _todayHeader(now), count: hoy.length),
            const SizedBox(height: 10),
            if (partidosAsync.isLoading && partidosAsync.valueOrNull == null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (hoy.isEmpty)
              _emptyDayCard()
            else
              ...hoy.map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _MatchAgendaCard(
                    partido: p,
                    isToday: true,
                    onOpenLive:
                        _canOpenLive(p)
                            ? () => context.push(
                              '/live_match_screen',
                              extra: (p['id'] as num).toInt(),
                            )
                            : null,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            const _SectionMiniTitle(title: 'Próximos'),
            const SizedBox(height: 10),
            if (proximos.isEmpty)
              _emptyHint('No hay próximos partidos en este mes')
            else
              ...proximos.map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _MatchAgendaCard(
                    partido: p,
                    onOpenLive:
                        _canOpenLive(p)
                            ? () => context.push(
                              '/live_match_screen',
                              extra: (p['id'] as num).toInt(),
                            )
                            : null,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            const _SectionMiniTitle(title: 'Pasados'),
            const SizedBox(height: 10),
            if (pasados.isEmpty)
              _emptyHintCard('Sin partidos finalizados en este periodo')
            else
              ...pasados.take(5).map((p) {
                final resultado = p['resultado']?.toString() ?? '--';
                final diff = _PartidosSectionState._resultDiff(resultado);
                bool? isVictory;
                if (diff == null) {
                  isVictory = null;
                } else if (diff > 0) {
                  isVictory = true;
                } else if (diff < 0) {
                  isVictory = false;
                } else {
                  isVictory = null;
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _MatchHistoryTile(
                    rival: 'Vs ${p['rival_nombre'] ?? p['rival'] ?? 'Rival'}',
                    date: _PartidosSectionState._formatShortDate(
                      p['fecha']?.toString(),
                    ),
                    resultado: resultado,
                    isVictory: isVictory,
                  ),
                );
              }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _emptyHint(String text) {
    return Text(text, style: GoogleFonts.inter(color: const Color(0xFF6B7280)));
  }

  Widget _emptyDayCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color.fromRGBO(213, 229, 244, 1)),
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(217, 73, 41, 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.sports_soccer, color: Color(0xFFD94929)),
          ),
          const SizedBox(height: 10),
          Text(
            'Día de descanso',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0B1926),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'No hay partidos programados para hoy.',
            style: GoogleFonts.inter(
              color: const Color(0xFF6B7280),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyHintCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color.fromRGBO(224, 214, 200, 1)),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(color: const Color(0xFF9CA3AF), fontSize: 13),
      ),
    );
  }

  static String _todayHeader(DateTime date) {
    const m = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    return 'Hoy, ${date.day.toString().padLeft(2, '0')} de ${m[date.month - 1]}';
  }

  static String _formatShortDate(String? rawDate) {
    final d = DateTime.tryParse(rawDate ?? '');
    if (d == null) return rawDate ?? '--';
    const m = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }

  bool _shouldRetryInitialLoad(Object? error) {
    if (error is! DioException) return false;
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        ((error.response?.statusCode ?? 0) >= 500);
  }

  static int? _resultDiff(String resultado) {
    final parts = resultado.split('-').map((e) => e.trim()).toList();
    if (parts.length != 2) return null;
    final a = int.tryParse(parts[0]);
    final b = int.tryParse(parts[1]);
    if (a == null || b == null) return null;
    return a - b;
  }
}

class _MonthChipsRow extends StatelessWidget {
  const _MonthChipsRow({
    required this.selectedMonth,
    required this.onMonthSelected,
  });

  final int selectedMonth;
  final ValueChanged<int> onMonthSelected;

  @override
  Widget build(BuildContext context) {
    const labels = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 12,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final month = i + 1;
          final active = month == selectedMonth;
          return InkWell(
            onTap: () => onMonthSelected(month),
            borderRadius: BorderRadius.circular(18),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color:
                    active
                        ? const Color(0xFFD94929)
                        : const Color.fromRGBO(245, 240, 230, 1),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color:
                      active
                          ? const Color(0xFFD94929)
                          : const Color.fromRGBO(224, 214, 200, 1),
                  width: 1.2,
                ),
                boxShadow:
                    active
                        ? [
                          BoxShadow(
                            color: const Color(
                              0xFFD94929,
                            ).withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                        : const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 3,
                            offset: Offset(0, 2),
                          ),
                        ],
              ),
              child: Text(
                labels[i],
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : const Color(0xFF6B7280),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AgendaSectionHeader extends StatelessWidget {
  const _AgendaSectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              color: const Color.fromRGBO(55, 73, 87, 1),
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
        ),
        if (count > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(245, 240, 230, 1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$count PARTIDO${count == 1 ? '' : 'S'}',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFD94929),
              ),
            ),
          ),
      ],
    );
  }
}

class _SectionMiniTitle extends StatelessWidget {
  const _SectionMiniTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.inter(
        color: const Color.fromRGBO(55, 73, 87, 1),
        fontSize: 14,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.0,
      ),
    );
  }
}

class _MatchAgendaCard extends StatelessWidget {
  const _MatchAgendaCard({
    required this.partido,
    this.isToday = false,
    this.onOpenLive,
  });

  final Map<String, dynamic> partido;
  final bool isToday;
  final VoidCallback? onOpenLive;

  @override
  Widget build(BuildContext context) {
    final rival =
        (partido['rival_nombre'] ?? partido['rival'] ?? 'Rival por definir')
            .toString();
    final esLocal = partido['es_local'] == true;
    final competencia = (partido['competencia'] ?? 'Amistoso').toString();
    final lugar =
        (partido['lugar'] ?? partido['estadio'] ?? 'Lugar por definir')
            .toString();
    final hora = _hourText(partido['hora']?.toString());
    final fecha = _datePretty(partido['fecha']?.toString());
    final badgeColor =
        esLocal
            ? const Color(0xFFD94929)
            : const Color.fromRGBO(91, 108, 124, 1);
    final crestText = _crestLetters(rival);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color.fromRGBO(224, 214, 200, 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (isToday ? 'Próximo encuentro' : competencia).toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.9,
                        color: const Color.fromRGBO(173, 111, 57, 1),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      rival,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1B1B1B),
                        height: 1.05,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      esLocal ? 'LOCAL' : 'VISITANTE',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFF131313),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        crestText,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 18,
            runSpacing: 12,
            children: [
              _compactMeta(Icons.calendar_today_rounded, fecha),
              _compactMeta(Icons.schedule_rounded, hora),
              _compactMeta(Icons.location_on_rounded, lugar),
            ],
          ),
          if (onOpenLive != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onOpenLive,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(194, 51, 10, 1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Abrir partido',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _compactMeta(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: const Color(0xFFD94929)),
        const SizedBox(width: 7),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF4B5563),
          ),
        ),
      ],
    );
  }

  static String _crestLetters(String rival) {
    final cleaned = rival.trim();
    if (cleaned.isEmpty) return 'FC';
    final words = cleaned.split(RegExp(r'\s+'));
    if (words.length == 1) {
      final word = words.first;
      return word.substring(0, word.length >= 2 ? 2 : 1).toUpperCase();
    }
    final first = words.first.isNotEmpty ? words.first[0] : 'F';
    final last = words.last.isNotEmpty ? words.last[0] : 'C';
    return '$first$last'.toUpperCase();
  }

  static String _hourText(String? raw) {
    if ((raw ?? '').isEmpty) return '--:--';
    final hh = raw!.split(':');
    if (hh.length < 2) return raw;
    final h = int.tryParse(hh[0]) ?? 0;
    final m = hh[1];
    return '${h.toString().padLeft(2, '0')}:$m';
  }

  static String _datePretty(String? rawDate) {
    final d = DateTime.tryParse(rawDate ?? '');
    if (d == null) return rawDate ?? '--';
    const mo = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${d.day.toString().padLeft(2, '0')} ${mo[d.month - 1]} ${d.year}';
  }
}

/// Tile de historial de un partido jugado.
class _MatchHistoryTile extends StatelessWidget {
  final String rival;
  final String date;
  final String resultado;
  final bool? isVictory; // true=victoria, false=derrota, null=empate

  const _MatchHistoryTile({
    required this.rival,
    required this.date,
    required this.resultado,
    required this.isVictory,
  });

  @override
  Widget build(BuildContext context) {
    final Color tagColor;
    final String tagLabel;

    if (isVictory == true) {
      tagColor = const Color(0xFF16A34A);
      tagLabel = 'Victoria';
    } else if (isVictory == false) {
      tagColor = const Color(0xFFD94929);
      tagLabel = 'Derrota';
    } else {
      tagColor = const Color(0xFFF59E0B);
      tagLabel = 'Empate';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Info principal
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rival,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0B1926),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          // Resultado
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                resultado,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0B1926),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: tagColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tagLabel,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: tagColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
