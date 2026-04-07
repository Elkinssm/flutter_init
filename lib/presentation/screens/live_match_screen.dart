import 'package:coach_app/infrastructure/services/coach_api_service.dart';
import 'package:coach_app/presentation/helpers/api_error_message.dart';
import 'package:coach_app/presentation/helpers/responsive.dart';
import 'package:coach_app/presentation/providers/selected_icon_provider.dart';
import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LiveMatchScreen extends ConsumerStatefulWidget {
  static const String name = '/live_match_screen';

  const LiveMatchScreen({super.key, this.partidoId});

  final int? partidoId;

  @override
  ConsumerState<LiveMatchScreen> createState() => _LiveMatchScreenState();
}

class _LiveMatchScreenState extends ConsumerState<LiveMatchScreen> {
  static const _bgColor = Color.fromRGBO(249, 246, 238, 1);
  static const _cardColor = Color.fromRGBO(217, 73, 41, 1);
  static const _green = Color.fromRGBO(43, 131, 10, 1);
  static const _yellow = Color.fromRGBO(255, 199, 44, 1);
  static const _red = Color.fromRGBO(205, 24, 30, 1);
  static const _slate = Color.fromRGBO(91, 108, 124, 1);
  static const _textDark = Color.fromRGBO(23, 22, 20, 1);
  static const _mutedText = Color.fromRGBO(109, 113, 118, 1);
  bool _dialogScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedIconProvider.notifier).state = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final partidoId = widget.partidoId;
    final detailAsync =
        partidoId == null
            ? const AsyncValue<Map<String, dynamic>?>.data(null)
            : ref.watch(coachPartidoDetalleProvider(partidoId));

    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: _bgColor,
        appBar: const CustomAppbar(
          title: 'Partido en vivo',
          showBackButton: true,
        ),
        bottomNavigationBar: const CustomBottomAppbar(),
        floatingActionButton: const CustomFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: detailAsync.when(
          data: (data) => _buildLoaded(context, data),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _buildLoaded(context, null, error: error),
        ),
      ),
    );
  }

  Widget _buildLoaded(
    BuildContext context,
    Map<String, dynamic>? rawData, {
    Object? error,
  }) {
    final live = _LiveMatchViewModel.fromApi(rawData);

    if (widget.partidoId == null) {
      _showFlowModal(
        title: 'Partido no disponible',
        message:
            'Esta vista requiere un partido válido. Ábrela desde el calendario o el detalle del partido.',
        type: ModalType.info,
      );
      return const SizedBox.shrink();
    }

    if (live == null) {
      _showFlowModal(
        title: 'No se pudo abrir el partido',
        message: apiErrorMessage(
          error,
          defaultMessage:
              'No fue posible cargar el detalle del partido. Intenta de nuevo.',
          forbiddenMessage: 'No tienes permisos para acceder a este partido.',
        ),
        type: ModalType.error,
      );
      return const SizedBox.shrink();
    }

    _dialogScheduled = false;

    return Container(
      color: _bgColor,
      child: RefreshIndicator(
        onRefresh: () async {
          final partidoId = widget.partidoId;
          if (partidoId != null) {
            ref.invalidate(coachPartidoDetalleProvider(partidoId));
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            swp(context, 0.04),
            18,
            swp(context, 0.04),
            120,
          ),
          child: maxWidthCenter(
            context: context,
            max: 760,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _LiveScoreCard(model: live),
                const SizedBox(height: 30),
                _SectionTitle(title: 'REGISTRAR EVENTO', trailing: null),
                const SizedBox(height: 14),
                _ActionGrid(
                  onGoal: () => _openGoalSheet(live),
                  onSubstitution: () => _openSubstitutionSheet(live),
                  onYellowCard:
                      () => _openCardSheet(live, _MatchCardType.yellow),
                  onRedCard: () => _openCardSheet(live, _MatchCardType.red),
                ),
                const SizedBox(height: 28),
                _SectionTitle(
                  title: 'EVENTOS DEL PARTIDO',
                  trailing: 'EVENTOS RECIENTES',
                ),
                const SizedBox(height: 14),
                _MatchLogCard(events: live.events),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed:
                      live.isFinished
                          ? null
                          : () => _showFinalizePending(),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(74),
                    backgroundColor: const Color.fromRGBO(25, 24, 22, 1),
                    disabledBackgroundColor: const Color.fromRGBO(
                      25,
                      24,
                      22,
                      0.45,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    'FINALIZAR PARTIDO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ts(context, 18),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openGoalSheet(_LiveMatchViewModel live) async {
    final partidoId = widget.partidoId;
    if (partidoId == null) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => _GoalEventSheet(
            partidoId: partidoId,
            live: live,
            onSaved: _handleEventSaved,
          ),
    );
  }

  Future<void> _openCardSheet(
    _LiveMatchViewModel live,
    _MatchCardType type,
  ) async {
    final partidoId = widget.partidoId;
    if (partidoId == null) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => _CardEventSheet(
            partidoId: partidoId,
            live: live,
            type: type,
            onSaved: _handleEventSaved,
          ),
    );
  }

  Future<void> _openSubstitutionSheet(_LiveMatchViewModel live) async {
    final partidoId = widget.partidoId;
    if (partidoId == null) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => _SubstitutionEventSheet(
            partidoId: partidoId,
            live: live,
            onSaved: _handleEventSaved,
          ),
    );
  }

  Future<void> _handleEventSaved(String message) async {
    final partidoId = widget.partidoId;
    if (partidoId == null) return;

    ref.invalidate(coachPartidoDetalleProvider(partidoId));
    ref.invalidate(coachPartidoPlantillaProvider(partidoId));

    if (!mounted) return;
    CustomModal.show(
      context: context,
      title: 'Evento registrado',
      message: message,
      type: ModalType.success,
    );
  }

  void _showFinalizePending() {
    CustomModal.show(
      context: context,
      title: 'Resultado pendiente',
      message:
          'La pantalla para finalizar el partido se conecta después de cerrar los modales de eventos.',
      type: ModalType.info,
    );
  }

  void _showFlowModal({
    required String title,
    required String message,
    required ModalType type,
  }) {
    if (_dialogScheduled || !mounted) return;
    _dialogScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      CustomModal.show(
        context: context,
        title: title,
        message: message,
        type: type,
        barrierDismissible: false,
        buttonText: 'Volver',
        onButtonPressed: () {
          Navigator.of(context).pop();
          if (!mounted) return;
          if (Navigator.of(context).canPop()) {
            context.pop();
          } else {
            context.go('/my_teams_screen');
          }
        },
      );
    });
  }
}

class _LiveScoreCard extends StatelessWidget {
  const _LiveScoreCard({required this.model});

  final _LiveMatchViewModel model;

  @override
  Widget build(BuildContext context) {
    final timerText = model.timerLabel;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromRGBO(194, 51, 10, 1),
            Color.fromRGBO(223, 85, 39, 1),
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(110, 46, 18, 0.18),
            blurRadius: 26,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 6,
            top: 10,
            child: Icon(
              Icons.sports_soccer,
              size: 112,
              color: Colors.black.withValues(alpha: 0.08),
            ),
          ),
          Column(
            children: [
              Text(
                'REGISTRO DE PARTIDO EN VIVO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ts(context, 12),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _ScoreTeamBlock(
                      score: model.homeScore.toString(),
                      name: model.homeName,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      color: Colors.black.withValues(alpha: 0.16),
                    ),
                    child: Text(
                      '${model.homeScore} - ${model.awayScore}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ts(context, 34),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _ScoreTeamBlock(
                      score: model.awayScore.toString(),
                      name: model.awayName,
                      alignEnd: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _LiveMatchScreenState._green,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.circle, color: Colors.white, size: 8),
                    const SizedBox(width: 8),
                    Text(
                      timerText,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ts(context, 14),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreTeamBlock extends StatelessWidget {
  const _ScoreTeamBlock({
    required this.score,
    required this.name,
    this.alignEnd = false,
  });

  final String score;
  final String name;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final align = alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          name.toUpperCase(),
          textAlign: alignEnd ? TextAlign.right : TextAlign.left,
          style: TextStyle(
            color: Colors.white,
            fontSize: ts(context, 18),
            fontWeight: FontWeight.w900,
            height: 1.05,
          ),
        ),
      ],
    );
  }
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid({
    required this.onGoal,
    required this.onSubstitution,
    required this.onYellowCard,
    required this.onRedCard,
  });

  final VoidCallback onGoal;
  final VoidCallback onSubstitution;
  final VoidCallback onYellowCard;
  final VoidCallback onRedCard;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 18,
      crossAxisSpacing: 18,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1,
      children: [
        _ActionTile(
          label: 'GOL',
          color: _LiveMatchScreenState._green,
          icon: Icons.sports_soccer_rounded,
          onTap: onGoal,
        ),
        _ActionTile(
          label: 'CAMBIO',
          color: _LiveMatchScreenState._slate,
          icon: Icons.sync_alt_rounded,
          onTap: onSubstitution,
        ),
        _ActionTile(
          label: 'TARJETA\nAMARILLA',
          color: _LiveMatchScreenState._yellow,
          icon: Icons.style_rounded,
          darkText: true,
          onTap: onYellowCard,
          iconRotation: -0.38,
        ),
        _ActionTile(
          label: 'TARJETA ROJA',
          color: _LiveMatchScreenState._red,
          icon: Icons.style_rounded,
          onTap: onRedCard,
          iconRotation: -0.38,
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
    this.darkText = false,
    this.iconRotation = 0,
  });

  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  final bool darkText;
  final double iconRotation;

  @override
  Widget build(BuildContext context) {
    final fg = darkText ? _LiveMatchScreenState._textDark : Colors.white;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.11),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.rotate(
                  angle: iconRotation,
                  child: Icon(icon, size: 38, color: fg),
                ),
                const SizedBox(height: 20),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: fg,
                    fontSize: ts(context, 16),
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MatchLogCard extends StatelessWidget {
  const _MatchLogCard({required this.events});

  final List<_LiveEventViewModel> events;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          if (events.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Text(
                'Todavia no hay eventos registrados en este partido.',
                style: TextStyle(
                  color: _LiveMatchScreenState._mutedText,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            ...events.map(
              (event) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _EventTile(event: event),
              ),
            ),
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event});

  final _LiveEventViewModel event;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(32, 27, 20, 0.05),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(event.icon, color: event.color, size: 20),
          const SizedBox(width: 12),
          Container(
            width: 4,
            height: 44,
            decoration: BoxDecoration(
              color: event.color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: TextStyle(
                    color: _LiveMatchScreenState._textDark,
                    fontSize: ts(context, 18),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  event.subtitle,
                  style: TextStyle(
                    color: _LiveMatchScreenState._mutedText,
                    fontSize: ts(context, 13),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            event.minuteLabel,
            style: TextStyle(
              color: _LiveMatchScreenState._cardColor,
              fontSize: ts(context, 18),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            color: _LiveMatchScreenState._textDark,
            fontSize: ts(context, 22),
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        if ((trailing ?? '').isNotEmpty)
          Text(
            trailing!,
            style: TextStyle(
              color: _LiveMatchScreenState._slate.withValues(alpha: 0.8),
              fontSize: ts(context, 12),
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
      ],
    );
  }
}

class _LiveMatchViewModel {
  _LiveMatchViewModel({
    required this.homeName,
    required this.awayName,
    required this.homeScore,
    required this.awayScore,
    required this.phaseLabel,
    required this.minute,
    required this.second,
    required this.isFinished,
    required this.ownTeamId,
    required this.homeTeamId,
    required this.awayTeamId,
    required this.events,
  });

  final String homeName;
  final String awayName;
  final int homeScore;
  final int awayScore;
  final String phaseLabel;
  final int minute;
  final int second;
  final bool isFinished;
  final int ownTeamId;
  final int homeTeamId;
  final int awayTeamId;
  final List<_LiveEventViewModel> events;

  int get rivalTeamId => ownTeamId == homeTeamId ? awayTeamId : homeTeamId;
  String get ownTeamName => ownTeamId == homeTeamId ? homeName : awayName;

  String get timerLabel =>
      '${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';

  static _LiveMatchViewModel? fromApi(Map<String, dynamic>? raw) {
    final partidoRaw = raw?['partido'];
    if (partidoRaw is! Map) return null;
    final partido = Map<String, dynamic>.from(partidoRaw);
    final local = _teamName(partido['equipo_local']);
    final visit = _teamName(partido['equipo_visitante']);
    final eventosRaw = (partido['eventos'] as List<dynamic>?) ?? const [];

    return _LiveMatchViewModel(
      homeName: local,
      awayName: visit,
      homeScore: _asInt(partido['goles_local']),
      awayScore: _asInt(partido['goles_visitante']),
      phaseLabel: _phaseLabel(partido['fase_partido']?.toString()),
      minute: _asInt(partido['minuto_actual']),
      second: _asInt(partido['segundo_actual']),
      isFinished: partido['estado_partido']?.toString() == 'FINALIZADO',
      ownTeamId: _asInt(partido['equipo_propio_id']),
      homeTeamId: _asInt(partido['equipo_local_id']),
      awayTeamId: _asInt(partido['equipo_visitante_id']),
      events:
          eventosRaw
              .whereType<Map>()
              .map(
                (event) => _LiveEventViewModel.fromApi(
                  Map<String, dynamic>.from(event),
                ),
              )
              .toList()
            ..sort((a, b) => b.minute.compareTo(a.minute)),
    );
  }

  static String _teamName(dynamic raw) {
    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      return map['nombre']?.toString() ?? 'Equipo';
    }
    return 'Equipo';
  }

  static String _phaseLabel(String? raw) {
    switch (raw) {
      case 'PRIMER_TIEMPO':
        return 'PRIMER TIEMPO';
      case 'FIN_PRIMER_TIEMPO':
        return 'MEDIO TIEMPO';
      case 'INICIO_SEGUNDO_TIEMPO':
      case 'SEGUNDO_TIEMPO':
        return 'SEGUNDO TIEMPO';
      case 'FINALIZADO':
        return 'FINALIZADO';
      default:
        return 'EN VIVO';
    }
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class _LiveEventViewModel {
  _LiveEventViewModel({
    required this.minuteLabel,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
  }) : minute = _parsedMinute(minuteLabel);

  final String minuteLabel;
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final int minute;

  static _LiveEventViewModel fromApi(Map<String, dynamic> raw) {
    final tipo = raw['tipo_evento']?.toString() ?? '';
    final jugadorRaw = raw['jugador'];
    final jugador =
        jugadorRaw is Map<String, dynamic>
            ? jugadorRaw
            : jugadorRaw is Map
            ? Map<String, dynamic>.from(jugadorRaw)
            : const <String, dynamic>{};
    final dorsal = jugador['dorsal']?.toString();
    final nombre = jugador['nombre_completo']?.toString() ?? '';
    final detalle = raw['detalle']?.toString();
    final minute = _LiveMatchViewModel._asInt(raw['minuto']);
    final descriptor = _subtitleForType(
      tipo,
      dorsal: dorsal,
      nombre: nombre,
      detalle: detalle,
    );

    return _LiveEventViewModel(
      minuteLabel: "${minute.toString().padLeft(2, '0')}'",
      title: _titleForType(tipo),
      subtitle: descriptor.isEmpty ? 'Evento del partido' : descriptor,
      color: _colorForType(tipo),
      icon: _iconForType(tipo),
    );
  }

  static int _parsedMinute(String raw) {
    return int.tryParse(raw.replaceAll("'", '').trim()) ?? 0;
  }

  static String _titleForType(String tipo) {
    switch (tipo) {
      case 'GOL':
        return 'Gol';
      case 'AUTOGOL':
        return 'Autogol';
      case 'CAMBIO':
        return 'Cambio';
      case 'TARJETA_AMARILLA':
        return 'Tarjeta amarilla';
      case 'TARJETA_ROJA':
        return 'Tarjeta roja';
      case 'INICIO_PARTIDO':
        return 'Inicio del partido';
      case 'FIN_PRIMER_TIEMPO':
        return 'Fin del primer tiempo';
      case 'INICIO_SEGUNDO_TIEMPO':
        return 'Inicio del segundo tiempo';
      case 'FIN_PARTIDO':
        return 'Partido finalizado';
      default:
        return 'Evento del partido';
    }
  }

  static String _subtitleForType(
    String tipo, {
    String? dorsal,
    required String nombre,
    String? detalle,
  }) {
    switch (tipo) {
      case 'INICIO_PARTIDO':
        return 'Inicio de la primera parte';
      case 'FIN_PRIMER_TIEMPO':
        return 'Final de la primera parte';
      case 'INICIO_SEGUNDO_TIEMPO':
        return 'Inicio de la segunda parte';
      case 'FIN_PARTIDO':
        return 'Cierre del partido';
      default:
        final parts = [
          if ((dorsal ?? '').isNotEmpty) '#$dorsal',
          if (nombre.isNotEmpty) nombre,
          if ((detalle ?? '').isNotEmpty) detalle,
        ];
        return parts.isEmpty ? 'Evento del partido' : parts.join(' ');
    }
  }

  static Color _colorForType(String tipo) {
    switch (tipo) {
      case 'GOL':
      case 'AUTOGOL':
        return _LiveMatchScreenState._green;
      case 'CAMBIO':
        return _LiveMatchScreenState._slate;
      case 'TARJETA_AMARILLA':
        return _LiveMatchScreenState._yellow;
      case 'TARJETA_ROJA':
        return _LiveMatchScreenState._red;
      default:
        return _LiveMatchScreenState._slate;
    }
  }

  static IconData _iconForType(String tipo) {
    switch (tipo) {
      case 'GOL':
      case 'AUTOGOL':
        return Icons.sports_soccer_rounded;
      case 'CAMBIO':
        return Icons.sync_alt_rounded;
      case 'TARJETA_AMARILLA':
      case 'TARJETA_ROJA':
        return Icons.style_rounded;
      case 'INICIO_PARTIDO':
      case 'FIN_PRIMER_TIEMPO':
      case 'INICIO_SEGUNDO_TIEMPO':
      case 'FIN_PARTIDO':
        return Icons.timer_outlined;
      default:
        return Icons.sports_soccer_outlined;
    }
  }
}

enum _MatchCardType { yellow, red }

class _PartidoPlantillaViewModel {
  const _PartidoPlantillaViewModel({
    required this.alineacionConfigurada,
    required this.players,
  });

  final bool alineacionConfigurada;
  final List<_PlantillaPlayer> players;

  List<_PlantillaPlayer> get onFieldPlayers =>
      players.where((player) => player.onField).toList()
        ..sort((a, b) => a.order.compareTo(b.order));

  List<_PlantillaPlayer> get benchPlayers =>
      players.where((player) => !player.onField).toList()
        ..sort((a, b) => a.order.compareTo(b.order));

  static _PartidoPlantillaViewModel? fromApi(Map<String, dynamic>? raw) {
    if (raw == null) return null;
    final jugadores = (raw['jugadores'] as List<dynamic>?) ?? const [];
    return _PartidoPlantillaViewModel(
      alineacionConfigurada: raw['alineacion_configurada'] == true,
      players:
          jugadores
              .whereType<Map>()
              .map(
                (item) =>
                    _PlantillaPlayer.fromMap(Map<String, dynamic>.from(item)),
              )
              .toList(),
    );
  }
}

class _PlantillaPlayer {
  const _PlantillaPlayer({
    required this.id,
    required this.fullName,
    required this.shirtNumber,
    required this.position,
    required this.photoUrl,
    required this.onField,
    required this.order,
  });

  final int id;
  final String fullName;
  final int? shirtNumber;
  final String position;
  final String? photoUrl;
  final bool onField;
  final int order;

  String get shortName {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first} ${parts[1]}';
    }
    return fullName;
  }

  static _PlantillaPlayer fromMap(Map<String, dynamic> map) {
    return _PlantillaPlayer(
      id: _LiveMatchViewModel._asInt(map['id']),
      fullName: map['nombre_completo']?.toString() ?? 'Jugador',
      shirtNumber:
          map['dorsal'] == null
              ? null
              : _LiveMatchViewModel._asInt(map['dorsal']),
      position: map['posicion']?.toString() ?? 'Sin posición',
      photoUrl: map['foto_url']?.toString(),
      onField: map['en_cancha'] == true,
      order: _LiveMatchViewModel._asInt(map['orden']),
    );
  }
}

class _EventSheetFrame extends StatelessWidget {
  const _EventSheetFrame({
    required this.title,
    required this.child,
    this.eyebrow,
    this.headerNote,
    this.headerIcon,
  });

  final String title;
  final Widget child;
  final String? eyebrow;
  final String? headerNote;
  final IconData? headerIcon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 32,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxHeight: 760),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(247, 242, 232, 1),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 24, 18, 20),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromRGBO(194, 51, 10, 1),
                      Color.fromRGBO(223, 85, 39, 1),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    if (headerIcon != null)
                      Positioned(
                        right: 34,
                        top: 8,
                        child: Icon(
                          headerIcon,
                          size: 104,
                          color: Colors.black.withValues(alpha: 0.08),
                        ),
                      ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if ((eyebrow ?? '').isNotEmpty)
                                Text(
                                  eyebrow!,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ts(context, 13),
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              if ((eyebrow ?? '').isNotEmpty)
                                const SizedBox(height: 8),
                              Text(
                                title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: ts(context, 30),
                                  fontWeight: FontWeight.w900,
                                  height: 0.95,
                                ),
                              ),
                              if ((headerNote ?? '').isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    headerNote!,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.78),
                                      fontSize: ts(context, 13),
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventSheetBody extends StatelessWidget {
  const _EventSheetBody({
    required this.subtitle,
    required this.content,
    required this.primaryLabel,
    required this.primaryColor,
    required this.secondaryLabel,
    required this.onPrimaryPressed,
    this.saving = false,
  });

  final String subtitle;
  final Widget content;
  final String primaryLabel;
  final Color primaryColor;
  final String secondaryLabel;
  final VoidCallback? onPrimaryPressed;
  final bool saving;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          subtitle.toUpperCase(),
          style: TextStyle(
            color: _LiveMatchScreenState._mutedText,
            fontSize: ts(context, 13),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 18),
        content,
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: saving ? null : () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(58),
                  backgroundColor: const Color.fromRGBO(226, 220, 208, 1),
                  foregroundColor: const Color.fromRGBO(75, 90, 107, 1),
                ),
                child: Text(
                  secondaryLabel.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: saving ? null : onPrimaryPressed,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(58),
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
                child:
                    saving
                        ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                        : Text(
                          primaryLabel.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EventInfoBanner extends StatelessWidget {
  const _EventInfoBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color.fromRGBO(235, 228, 214, 1)),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: _LiveMatchScreenState._mutedText,
          fontSize: ts(context, 14),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EventSheetError extends StatelessWidget {
  const _EventSheetError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _EventInfoBanner(message: message);
  }
}

class _PlayerAvatar extends StatelessWidget {
  const _PlayerAvatar({
    required this.photoUrl,
    required this.fallbackText,
    this.size = 56,
  });

  final String? photoUrl;
  final String fallbackText;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = (photoUrl ?? '').trim();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(28, 31, 35, 1),
        borderRadius: BorderRadius.circular(size / 4),
      ),
      clipBehavior: Clip.antiAlias,
      child:
          url.isNotEmpty
              ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => Center(
                      child: Text(
                        fallbackText,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ts(context, 18),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
              )
              : Center(
                child: Text(
                  fallbackText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ts(context, 18),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
    );
  }
}

class _ModalSectionHeader extends StatelessWidget {
  const _ModalSectionHeader({
    required this.index,
    required this.title,
    this.trailing,
    this.color = _LiveMatchScreenState._cardColor,
  });

  final int index;
  final String title;
  final String? trailing;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 34,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '$index. $title',
            style: TextStyle(
              color: _LiveMatchScreenState._textDark,
              fontSize: ts(context, 17),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if ((trailing ?? '').isNotEmpty)
          Text(
            trailing!.toUpperCase(),
            style: TextStyle(
              color: _LiveMatchScreenState._mutedText,
              fontSize: ts(context, 12),
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}

class _GoalPlayerCard extends StatelessWidget {
  const _GoalPlayerCard({
    required this.player,
    required this.selected,
    required this.onTap,
  });

  final _PlantillaPlayer player;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color:
                  selected
                      ? _LiveMatchScreenState._cardColor
                      : const Color.fromRGBO(233, 227, 216, 1),
              width: selected ? 2.2 : 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(32, 27, 20, 0.05),
                blurRadius: 10,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Stack(
                  children: [
                    _PlayerAvatar(
                      photoUrl: player.photoUrl,
                      fallbackText:
                          (player.shirtNumber ?? 0).toString().padLeft(2, '0'),
                      size: 68,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _LiveMatchScreenState._cardColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          (player.shirtNumber ?? 0).toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ts(context, 11),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        player.shortName.toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _LiveMatchScreenState._textDark,
                          fontSize: ts(context, 15),
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        player.position.toUpperCase(),
                        style: TextStyle(
                          color: _LiveMatchScreenState._mutedText,
                          fontSize: ts(context, 13),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OwnGoalCard extends StatelessWidget {
  const _OwnGoalCard({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color.fromRGBO(243, 239, 230, 1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color:
                  selected
                      ? _LiveMatchScreenState._cardColor
                      : const Color.fromRGBO(94, 112, 128, 0.75),
              width: 2,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(91, 108, 124, 1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.priority_high_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'AUTOGOL',
                        style: TextStyle(
                          color: _LiveMatchScreenState._textDark,
                          fontSize: ts(context, 16),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'EQUIPO RIVAL',
                        style: TextStyle(
                          color: _LiveMatchScreenState._mutedText,
                          fontSize: ts(context, 13),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  const Icon(
                    Icons.check_circle,
                    color: _LiveMatchScreenState._cardColor,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EventSectionLabel extends StatelessWidget {
  const _EventSectionLabel(
    this.label, {
    this.color = _LiveMatchScreenState._cardColor,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 34,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            color: _LiveMatchScreenState._textDark,
            fontSize: ts(context, 17),
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _MockPlayerRowTile extends StatelessWidget {
  const _MockPlayerRowTile({
    required this.player,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  final _PlantillaPlayer player;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            color: selected ? accentColor : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? accentColor : const Color.fromRGBO(235, 228, 214, 1),
              width: 1.4,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                if ((player.photoUrl ?? '').trim().isNotEmpty)
                  ClipOval(
                    child: SizedBox(
                      width: 54,
                      height: 54,
                      child: Image.network(
                        player.photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => _FallbackPlayerBubble(
                              shirtNumber: player.shirtNumber,
                              selected: selected,
                              accentColor: accentColor,
                            ),
                      ),
                    ),
                  )
                else
                  _FallbackPlayerBubble(
                    shirtNumber: player.shirtNumber,
                    selected: selected,
                    accentColor: accentColor,
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.fullName.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color:
                              selected
                                  ? Colors.white
                                  : _LiveMatchScreenState._textDark,
                          fontSize: ts(context, 16),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        player.position,
                        style: TextStyle(
                          color:
                              selected
                                  ? Colors.white.withValues(alpha: 0.9)
                                  : _LiveMatchScreenState._mutedText,
                          fontSize: ts(context, 13),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  const Icon(Icons.check_circle, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FallbackPlayerBubble extends StatelessWidget {
  const _FallbackPlayerBubble({
    required this.shirtNumber,
    required this.selected,
    required this.accentColor,
  });

  final int? shirtNumber;
  final bool selected;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color:
            selected ? Colors.white : const Color.fromRGBO(28, 31, 35, 1),
        borderRadius: BorderRadius.circular(27),
      ),
      child: Center(
        child: Text(
          (shirtNumber ?? 0).toString().padLeft(2, '0'),
          style: TextStyle(
            color: selected ? accentColor : Colors.white,
            fontSize: ts(context, 20),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _MockCardChoiceTile extends StatelessWidget {
  const _MockCardChoiceTile({
    required this.label,
    required this.color,
    required this.selected,
  });

  final String label;
  final Color color;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: selected ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color, width: selected ? 2.4 : 1.2),
      ),
      child: Stack(
        children: [
          if (selected)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(
                  Icons.check,
                  size: 20,
                  color:
                      color == _LiveMatchScreenState._yellow
                          ? _LiveMatchScreenState._textDark
                          : Colors.white,
                ),
              ),
            ),
          Column(
            children: [
              const SizedBox(height: 10),
              Transform.rotate(
                angle: -0.16,
                child: Container(
                  width: 54,
                  height: 84,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color:
                      color == _LiveMatchScreenState._yellow
                          ? _LiveMatchScreenState._textDark
                          : color.withValues(alpha: selected ? 0.95 : 0.45),
                  fontWeight: FontWeight.w900,
                  fontSize: ts(context, 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.onChanged,
    required this.hintText,
  });

  final ValueChanged<String> onChanged;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: const Color.fromRGBO(231, 226, 216, 1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _GoalEventSheet extends ConsumerStatefulWidget {
  const _GoalEventSheet({
    required this.partidoId,
    required this.live,
    required this.onSaved,
  });

  final int partidoId;
  final _LiveMatchViewModel live;
  final Future<void> Function(String message) onSaved;

  @override
  ConsumerState<_GoalEventSheet> createState() => _GoalEventSheetState();
}

class _GoalEventSheetState extends ConsumerState<_GoalEventSheet> {
  int? _selectedPlayerId;
  bool _autogol = false;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final plantillaAsync = ref.watch(
      coachPartidoPlantillaProvider(widget.partidoId),
    );

    return _EventSheetFrame(
      title: 'REGISTRAR GOL',
      headerIcon: Icons.sports_soccer_rounded,
      child: plantillaAsync.when(
        data: (raw) {
          final plantilla = _PartidoPlantillaViewModel.fromApi(raw);
          final players = plantilla?.onFieldPlayers ?? const <_PlantillaPlayer>[];
          return _EventSheetBody(
            subtitle: 'Selecciona al autor del gol',
            content: Column(
              children: [
                if (players.isEmpty)
                  const _EventInfoBanner(
                    message:
                        'No hay jugadores en cancha disponibles para registrar el gol.',
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: players.length + 1,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.34,
                        ),
                    itemBuilder: (context, index) {
                      if (index == players.length) {
                        return _OwnGoalCard(
                          selected: _autogol,
                          onTap: () {
                            setState(() {
                              _autogol = true;
                              _selectedPlayerId = null;
                            });
                          },
                        );
                      }

                      final player = players[index];
                      return _GoalPlayerCard(
                        player: player,
                        selected: !_autogol && _selectedPlayerId == player.id,
                        onTap: () {
                          setState(() {
                            _autogol = false;
                            _selectedPlayerId = player.id;
                          });
                        },
                      );
                    },
                  ),
              ],
            ),
            primaryLabel: 'Confirmar gol',
            primaryColor: _LiveMatchScreenState._cardColor,
            secondaryLabel: 'Cancelar',
            saving: _saving,
            onPrimaryPressed: players.isEmpty ? null : _submitGoal,
          );
        },
        loading:
            () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator()),
            ),
        error: (error, _) => _EventSheetError(message: apiErrorMessage(error)),
      ),
    );
  }

  Future<void> _submitGoal() async {
    if (!_autogol && _selectedPlayerId == null) {
      _showInlineInfo('Selecciona un jugador o marca autogol.');
      return;
    }

    setState(() => _saving = true);
    try {
      final body = <String, dynamic>{
        'equipo_id': _autogol ? widget.live.rivalTeamId : widget.live.ownTeamId,
        'tipo_evento': _autogol ? 'AUTOGOL' : 'GOL',
        'minuto': widget.live.minute,
      };
      if (!_autogol) {
        body['jugador_id'] = _selectedPlayerId;
      }

      final response = await ref
          .read(coachApiServiceProvider)
          .postPartidoEvento(widget.partidoId, body);
      if (!mounted) return;
      Navigator.of(context).pop();
      await widget.onSaved(
        response['message']?.toString() ?? 'Gol registrado correctamente.',
      );
    } catch (error) {
      if (!mounted) return;
      _showInlineInfo(apiErrorMessage(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showInlineInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CardEventSheet extends ConsumerStatefulWidget {
  const _CardEventSheet({
    required this.partidoId,
    required this.live,
    required this.type,
    required this.onSaved,
  });

  final int partidoId;
  final _LiveMatchViewModel live;
  final _MatchCardType type;
  final Future<void> Function(String message) onSaved;

  @override
  ConsumerState<_CardEventSheet> createState() => _CardEventSheetState();
}

class _CardEventSheetState extends ConsumerState<_CardEventSheet> {
  int? _selectedPlayerId;
  bool _saving = false;
  String _query = '';

  bool get _isYellow => widget.type == _MatchCardType.yellow;

  @override
  Widget build(BuildContext context) {
    final plantillaAsync = ref.watch(
      coachPartidoPlantillaProvider(widget.partidoId),
    );

    return _EventSheetFrame(
      title: _isYellow ? 'SANCIÓN DISCIPLINARIA' : 'TARJETA ROJA',
      headerNote: 'REGISTRO DE INCIDENCIA - ${widget.live.timerLabel}',
      child: plantillaAsync.when(
        data: (raw) {
          final plantilla = _PartidoPlantillaViewModel.fromApi(raw);
          final players = plantilla?.onFieldPlayers ?? const <_PlantillaPlayer>[];
          final filteredPlayers =
              players.where((player) {
                if (_query.trim().isEmpty) return true;
                final query = _query.trim().toLowerCase();
                return player.fullName.toLowerCase().contains(query) ||
                    (player.shirtNumber?.toString() ?? '').contains(query);
              }).toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ModalSectionHeader(
                index: 1,
                title: 'SELECCIONAR TARJETA',
                color: _LiveMatchScreenState._cardColor,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _MockCardChoiceTile(
                      label: 'Amarilla',
                      color: _LiveMatchScreenState._yellow,
                      selected: _isYellow,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _MockCardChoiceTile(
                      label: 'Roja',
                      color: _LiveMatchScreenState._red,
                      selected: !_isYellow,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              _ModalSectionHeader(
                index: 2,
                title:
                    _isYellow
                        ? 'JUGADOR AMONESTADO'
                        : 'JUGADOR EXPULSADO',
                color:
                    _isYellow
                        ? _LiveMatchScreenState._green
                        : _LiveMatchScreenState._cardColor,
                trailing: 'Filtro: ${widget.live.ownTeamName}',
              ),
              const SizedBox(height: 14),
              _SearchField(
                onChanged: (value) => setState(() => _query = value),
                hintText: 'Buscar por nombre o dorsal...',
              ),
              const SizedBox(height: 16),
              if (players.isEmpty)
                const _EventInfoBanner(
                  message:
                      'No hay jugadores en cancha disponibles para registrar la tarjeta.',
                )
              else if (filteredPlayers.isEmpty)
                const _EventInfoBanner(
                  message: 'No hay coincidencias con ese filtro.',
                )
              else
                ...filteredPlayers.map(
                  (player) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _MockPlayerRowTile(
                      player: player,
                      selected: _selectedPlayerId == player.id,
                      accentColor:
                          _isYellow
                              ? _LiveMatchScreenState._cardColor
                              : _LiveMatchScreenState._cardColor,
                      onTap: () {
                        setState(() => _selectedPlayerId = player.id);
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: _saving ? null : () => Navigator.of(context).pop(),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(72),
                        backgroundColor: const Color.fromRGBO(226, 220, 208, 1),
                        foregroundColor: const Color.fromRGBO(75, 90, 107, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'CANCELAR',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _saving || players.isEmpty ? null : _submitCard,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(72),
                        backgroundColor: _LiveMatchScreenState._cardColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child:
                          _saving
                              ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                              : Text(
                                _isYellow
                                    ? 'CONFIRMAR\nTARJETA'
                                    : 'CONFIRMAR\nROJA',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
        loading:
            () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator()),
            ),
        error: (error, _) => _EventSheetError(message: apiErrorMessage(error)),
      ),
    );
  }

  Future<void> _submitCard() async {
    if (_selectedPlayerId == null) {
      _showInlineInfo('Selecciona un jugador para continuar.');
      return;
    }

    setState(() => _saving = true);
    try {
      final response = await ref.read(coachApiServiceProvider).postPartidoEvento(
        widget.partidoId,
        {
          'equipo_id': widget.live.ownTeamId,
          'jugador_id': _selectedPlayerId,
          'tipo_evento':
              _isYellow ? 'TARJETA_AMARILLA' : 'TARJETA_ROJA',
          'minuto': widget.live.minute,
        },
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      await widget.onSaved(
        response['message']?.toString() ?? 'Tarjeta registrada correctamente.',
      );
    } catch (error) {
      if (!mounted) return;
      _showInlineInfo(apiErrorMessage(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showInlineInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SubstitutionEventSheet extends ConsumerStatefulWidget {
  const _SubstitutionEventSheet({
    required this.partidoId,
    required this.live,
    required this.onSaved,
  });

  final int partidoId;
  final _LiveMatchViewModel live;
  final Future<void> Function(String message) onSaved;

  @override
  ConsumerState<_SubstitutionEventSheet> createState() =>
      _SubstitutionEventSheetState();
}

class _SubstitutionEventSheetState
    extends ConsumerState<_SubstitutionEventSheet> {
  int? _playerOutId;
  int? _playerInId;
  late final TextEditingController _minuteController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _minuteController = TextEditingController(
      text: widget.live.minute.toString(),
    );
  }

  @override
  void dispose() {
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plantillaAsync = ref.watch(
      coachPartidoPlantillaProvider(widget.partidoId),
    );

    return _EventSheetFrame(
      title: 'REGISTRO DE CAMBIO',
      eyebrow: 'ACCIÓN DE CAMPO',
      headerIcon: Icons.sync_alt_rounded,
      child: plantillaAsync.when(
        data: (raw) {
          final plantilla = _PartidoPlantillaViewModel.fromApi(raw);
          final onField = plantilla?.onFieldPlayers ?? const <_PlantillaPlayer>[];
          final bench = plantilla?.benchPlayers ?? const <_PlantillaPlayer>[];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _EventSectionLabel('SALE DEL CAMPO'),
              const SizedBox(height: 12),
              if (onField.isEmpty)
                const _EventInfoBanner(
                  message: 'No hay jugadores en cancha disponibles.',
                )
              else
                ...onField.map(
                  (player) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                      child: _MockPlayerRowTile(
                        player: player,
                        selected: _playerOutId == player.id,
                        accentColor: _LiveMatchScreenState._cardColor,
                      onTap: () {
                        setState(() => _playerOutId = player.id);
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 18),
              const _EventSectionLabel(
                'ENTRA AL CAMPO',
                color: _LiveMatchScreenState._green,
              ),
              const SizedBox(height: 12),
              if (bench.isEmpty)
                const _EventInfoBanner(
                  message: 'No hay suplentes disponibles para este cambio.',
                )
              else
                ...bench.map(
                  (player) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                      child: _MockPlayerRowTile(
                        player: player,
                        selected: _playerInId == player.id,
                        accentColor: _LiveMatchScreenState._green,
                      onTap: () {
                        setState(() => _playerInId = player.id);
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(239, 233, 222, 1),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(28),
                    top: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.access_time_filled_rounded,
                                color: _LiveMatchScreenState._cardColor,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 44,
                                child: TextField(
                                  controller: _minuteController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  style: TextStyle(
                                    color: _LiveMatchScreenState._textDark,
                                    fontSize: ts(context, 22),
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              Text(
                                "'",
                                style: TextStyle(
                                  color: _LiveMatchScreenState._textDark,
                                  fontSize: ts(context, 22),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'MINUTO DEL CAMBIO',
                            style: TextStyle(
                              color: _LiveMatchScreenState._mutedText,
                              fontSize: ts(context, 14),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: _saving ? null : () => Navigator.of(context).pop(),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(70),
                              backgroundColor: const Color.fromRGBO(226, 220, 208, 1),
                              foregroundColor: const Color.fromRGBO(75, 90, 107, 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: const Text(
                              'CANCELAR',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          flex: 2,
                          child: FilledButton(
                            onPressed:
                                _saving || onField.isEmpty || bench.isEmpty
                                    ? null
                                    : _submitChange,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(70),
                              backgroundColor: _LiveMatchScreenState._green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child:
                                _saving
                                    ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: Colors.white,
                                      ),
                                    )
                                    : const Text(
                                      'CONFIRMAR\nCAMBIO',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        height: 1.1,
                                      ),
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading:
            () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator()),
            ),
        error: (error, _) => _EventSheetError(message: apiErrorMessage(error)),
      ),
    );
  }

  Future<void> _submitChange() async {
    if (_playerOutId == null || _playerInId == null) {
      _showInlineInfo('Selecciona quién sale y quién entra.');
      return;
    }

    final minute = int.tryParse(_minuteController.text.trim());
    if (minute == null || minute < 0) {
      _showInlineInfo('Ingresa un minuto válido para el cambio.');
      return;
    }

    setState(() => _saving = true);
    try {
      final response = await ref.read(coachApiServiceProvider).postPartidoEvento(
        widget.partidoId,
        {
          'equipo_id': widget.live.ownTeamId,
          'tipo_evento': 'CAMBIO',
          'minuto': minute,
          'jugador_sale_id': _playerOutId,
          'jugador_entra_id': _playerInId,
        },
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      await widget.onSaved(
        response['message']?.toString() ?? 'Cambio registrado correctamente.',
      );
    } catch (error) {
      if (!mounted) return;
      _showInlineInfo(apiErrorMessage(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showInlineInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
