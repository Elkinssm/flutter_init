import 'package:coach_app/config/constants/environment.dart';
import 'package:coach_app/infrastructure/services/coach_api_service.dart';
import 'package:coach_app/presentation/helpers/api_error_message.dart';
import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class NewMatchScreen extends StatelessWidget {
  static const String name = '/new_match_screen';
  const NewMatchScreen({super.key, this.equipoId});
  final int? equipoId;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(249, 248, 247, 1),
        appBar: CustomAppbar(
          title: 'Nuevo Partido',
          onPressed: () => context.pop(),
        ),
        bottomNavigationBar: const CustomBottomAppbar(),
        floatingActionButton: const CustomFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        resizeToAvoidBottomInset: true,
        body: _NewMatchView(equipoId: equipoId),
      ),
    );
  }
}

class _NewMatchView extends ConsumerStatefulWidget {
  const _NewMatchView({this.equipoId});
  final int? equipoId;

  @override
  ConsumerState<_NewMatchView> createState() => _NewMatchViewState();
}

class _NewMatchViewState extends ConsumerState<_NewMatchView> {
  final _rivalController = TextEditingController();
  final _lugarController = TextEditingController();
  final _competenciaController = TextEditingController();
  int? _selectedEquipoId;
  String? _selectedCategoria;
  String? _selectedCondicionPartido;
  String? _selectedTipoPartido;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _saving = false;
  bool _initializedSelection = false;

  static const _condicionesPartido = <String>[
    'Local / Casa',
    'Visitante / Fuera',
  ];

  static const _tiposPartido = <String>['TORNEO', 'AMISTOSO', 'ENTRENAMIENTO'];

  @override
  void dispose() {
    _rivalController.dispose();
    _lugarController.dispose();
    _competenciaController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFD94929),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF0B1926),
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

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFD94929),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF0B1926),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  String _formatDate() {
    if (_selectedDate == null) return 'DD/MM/AAAA';
    return '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}';
  }

  String _formatTime() {
    if (_selectedTime == null) return '00:00';
    return '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final categoriasAsync = ref.watch(coachCategoriasProvider);
    final equipos = _buildEquipoOptions(categoriasAsync.valueOrNull);
    final categorias = _buildCategorias(equipos);
    _syncInitialSelection(equipos);
    final launchedFromTeam = widget.equipoId != null;

    final equiposFiltrados =
        _selectedCategoria == null
            ? equipos
            : equipos.where((e) => e.categoria == _selectedCategoria).toList();
    final hasSingleCategoria = launchedFromTeam || categorias.length == 1;
    final hasSingleEquipo = launchedFromTeam || equiposFiltrados.length == 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de sección
          Text(
            'Programar Encuentro',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0B1926),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Completa los detalles para la próxima jornada.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 24),

          if (Environment.useBackend) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(0, 0, 0, 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('CATEGORÍA'),
                  const SizedBox(height: 8),
                  hasSingleCategoria
                      ? _buildLockedSelector(
                        text: _selectedCategoria ?? categorias.first,
                        icon: Icons.category_outlined,
                      )
                      : _buildSimpleDropdown<String>(
                        value: _selectedCategoria,
                        hint: 'Selecciona categoría',
                        items: categorias,
                        icon: Icons.category_outlined,
                        itemLabel: (v) => v,
                        onChanged: (value) {
                          setState(() {
                            _selectedCategoria = value;
                            final equiposCat =
                                equipos
                                    .where((e) => e.categoria == value)
                                    .toList();
                            _selectedEquipoId =
                                equiposCat.isNotEmpty
                                    ? equiposCat.first.id
                                    : null;
                          });
                        },
                      ),
                  const SizedBox(height: 20),
                  _buildLabel('EQUIPO'),
                  const SizedBox(height: 8),
                  if (categoriasAsync.isLoading &&
                      categoriasAsync.valueOrNull == null)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    hasSingleEquipo
                        ? _buildLockedSelector(
                          text:
                              _findEquipoById(
                                equipos,
                                _selectedEquipoId,
                              )?.nombre ??
                              (equiposFiltrados.isNotEmpty
                                  ? equiposFiltrados.first.nombre
                                  : 'Equipo'),
                          icon: Icons.shield_outlined,
                        )
                        : _buildSimpleDropdown<_EquipoOption>(
                          value: _findEquipoById(
                            equiposFiltrados,
                            _selectedEquipoId,
                          ),
                          hint: 'Selecciona equipo',
                          items: equiposFiltrados,
                          icon: Icons.shield_outlined,
                          itemLabel: (e) => e.nombre,
                          onChanged: (value) {
                            setState(() {
                              _selectedEquipoId = value?.id;
                              _selectedCategoria = value?.categoria;
                            });
                          },
                        ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Tarjeta principal de información
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromRGBO(0, 0, 0, 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Campo: Nombre del Rival
                _buildLabel('NOMBRE DEL RIVAL'),
                const SizedBox(height: 8),
                _buildInputField(
                  controller: _rivalController,
                  hintText: 'Ej: CF Barcelona',
                  icon: Icons.shield_outlined,
                  iconColor: const Color(0xFFD94929),
                ),
                const SizedBox(height: 20),

                // Campo: Condición del Partido
                _buildLabel('CONDICIÓN DEL PARTIDO'),
                const SizedBox(height: 8),
                _buildDropdownField(
                  value: _selectedCondicionPartido,
                  hint: 'Selecciona condición',
                  items: _condicionesPartido,
                  onChanged:
                      (value) =>
                          setState(() => _selectedCondicionPartido = value),
                ),
                const SizedBox(height: 20),

                // Campo: Tipo de Partido
                _buildLabel('TIPO DE PARTIDO'),
                const SizedBox(height: 8),
                _buildDropdownField(
                  value: _selectedTipoPartido,
                  hint: 'Selecciona tipo',
                  items: _tiposPartido,
                  onChanged:
                      (value) => setState(() => _selectedTipoPartido = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tarjeta de Fecha, Hora y Lugar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromRGBO(0, 0, 0, 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fecha y Hora - Labels
                Row(
                  children: [
                    Expanded(child: _buildLabel('FECHA')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildLabel('HORA')),
                  ],
                ),
                const SizedBox(height: 8),
                // Fecha y Hora - Campos
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildDateTimeField(
                        value: _formatDate(),
                        icon: Icons.calendar_month_rounded,
                        iconColor: const Color(0xFFD94929),
                        onTap: _selectDate,
                        isSelected: _selectedDate != null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDateTimeField(
                        value: _formatTime(),
                        icon: Icons.access_time_filled_rounded,
                        iconColor: const Color(0xFF0B1926),
                        onTap: _selectTime,
                        isSelected: _selectedTime != null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Lugar / Estadio
                _buildLabel('LUGAR / ESTADIO'),
                const SizedBox(height: 8),
                _buildInputField(
                  controller: _lugarController,
                  hintText: 'Ej: Estadio Municipal',
                  icon: Icons.location_on_rounded,
                  iconColor: const Color(0xFFD94929),
                ),
                const SizedBox(height: 20),
                _buildLabel('COMPETENCIA'),
                const SizedBox(height: 8),
                _buildInputField(
                  controller: _competenciaController,
                  hintText: 'Ej: Liga Juvenil 2026',
                  icon: Icons.emoji_events_outlined,
                  iconColor: const Color(0xFFD94929),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Botón Crear Partido
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _saving ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD94929),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_circle_outline, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    _saving ? 'Guardando...' : 'Crear Partido',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final equipoId = _selectedEquipoId ?? widget.equipoId;

    if (equipoId == null) {
      CustomModal.show(
        context: context,
        title: 'Falta equipo',
        message: 'Selecciona una categoría y un equipo para crear el partido.',
        type: ModalType.warning,
      );
      return;
    }
    if (_rivalController.text.trim().isEmpty ||
        _selectedCondicionPartido == null ||
        _selectedTipoPartido == null ||
        _selectedDate == null) {
      CustomModal.show(
        context: context,
        title: 'Campos obligatorios',
        message: 'Completa rival, condición, tipo de partido y fecha.',
        type: ModalType.warning,
      );
      return;
    }

    final fecha =
        '${_selectedDate!.year.toString().padLeft(4, '0')}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
    String? hora;
    if (_selectedTime != null) {
      hora =
          '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';
    }

    final body = <String, dynamic>{
      'equipo_id': equipoId,
      'rival_nombre': _rivalController.text.trim(),
      'es_local': _selectedCondicionPartido == 'Local / Casa',
      'fecha': fecha,
      'tipo_partido': _selectedTipoPartido,
      'estado_partido': 'PROGRAMADO',
    };
    if ((hora ?? '').isNotEmpty) body['hora'] = hora;
    if (_lugarController.text.trim().isNotEmpty) {
      body['lugar'] = _lugarController.text.trim();
    }
    if (_competenciaController.text.trim().isNotEmpty) {
      body['competencia'] = _competenciaController.text.trim();
    }

    if (!Environment.useBackend) {
      CustomModal.show(
        context: context,
        title: 'Partido creado',
        message: 'Guardado en modo local (mock).',
        type: ModalType.success,
        onButtonPressed: () {
          Navigator.of(context).pop();
          context.pop();
        },
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final res = await ref.read(coachApiServiceProvider).postPartido(body);
      ref.invalidate(coachPartidosProvider);
      ref.invalidate(coachPartidosByEquipoProvider(equipoId));

      if (!mounted) return;
      CustomModal.show(
        context: context,
        title: 'Partido creado',
        message: res['message']?.toString() ?? 'El partido fue programado.',
        type: ModalType.success,
        onButtonPressed: () {
          Navigator.of(context).pop();
          context.pop();
        },
      );
    } catch (e) {
      if (!mounted) return;
      CustomModal.show(
        context: context,
        title: 'No se pudo crear',
        message: apiErrorMessage(
          e,
          defaultMessage: 'No fue posible crear el partido. Intenta de nuevo.',
        ),
        type: ModalType.error,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  List<_EquipoOption> _buildEquipoOptions(Map<String, dynamic>? data) {
    final raw = (data?['categorias'] as List<dynamic>?) ?? const [];
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .map(
          (m) => _EquipoOption(
            id: (m['id'] as num?)?.toInt() ?? 0,
            nombre: m['nombre']?.toString() ?? 'Equipo',
            categoria: m['categoria']?.toString() ?? 'Sin categoría',
          ),
        )
        .where((e) => e.id > 0)
        .toList();
  }

  List<String> _buildCategorias(List<_EquipoOption> equipos) {
    final set = equipos.map((e) => e.categoria).toSet().toList();
    set.sort();
    return set;
  }

  _EquipoOption? _findEquipoById(List<_EquipoOption> equipos, int? id) {
    if (id == null) return null;
    for (final e in equipos) {
      if (e.id == id) return e;
    }
    return null;
  }

  void _syncInitialSelection(List<_EquipoOption> equipos) {
    if (_initializedSelection) return;

    if (equipos.isEmpty) {
      if (widget.equipoId != null && _selectedEquipoId == null) {
        _selectedEquipoId = widget.equipoId;
      }
      return;
    }

    _EquipoOption? base;
    if (widget.equipoId != null) {
      for (final e in equipos) {
        if (e.id == widget.equipoId) {
          base = e;
          break;
        }
      }
    }
    base ??= equipos.first;
    _initializedSelection = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _selectedEquipoId = base?.id;
        _selectedCategoria = base?.categoria;
      });
    });
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF374151),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            child: Icon(icon, size: 28, color: iconColor),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: const Color(0xFF0B1926),
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: GoogleFonts.inter(
                  fontSize: 15,
                  color: const Color(0xFF9CA3AF),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            child: const Icon(
              Icons.sports_soccer_rounded,
              size: 28,
              color: Color(0xFFD94929),
            ),
          ),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                hint: Text(
                  hint,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
                isExpanded: true,
                icon: const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(
                    Icons.unfold_more_rounded,
                    color: Color(0xFF6B7280),
                    size: 24,
                  ),
                ),
                items:
                    items
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(
                              item,
                              style: GoogleFonts.inter(fontSize: 15),
                            ),
                          ),
                        )
                        .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleDropdown<T>({
    required T? value,
    required String hint,
    required List<T> items,
    required IconData icon,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            child: Icon(icon, size: 24, color: const Color(0xFFD94929)),
          ),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                hint: Text(
                  hint,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
                isExpanded: true,
                icon: const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(
                    Icons.unfold_more_rounded,
                    color: Color(0xFF6B7280),
                    size: 24,
                  ),
                ),
                items:
                    items
                        .map(
                          (item) => DropdownMenuItem<T>(
                            value: item,
                            child: Text(
                              itemLabel(item),
                              style: GoogleFonts.inter(fontSize: 15),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedSelector({required String text, required IconData icon}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            child: Icon(icon, size: 24, color: const Color(0xFFD94929)),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: const Color(0xFF0B1926),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.lock_outline, size: 18, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeField({
    required String value,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color:
                      isSelected
                          ? const Color(0xFF0B1926)
                          : const Color(0xFF9CA3AF),
                ),
              ),
            ),
            Icon(icon, size: 28, color: iconColor),
          ],
        ),
      ),
    );
  }
}

class _EquipoOption {
  final int id;
  final String nombre;
  final String categoria;

  const _EquipoOption({
    required this.id,
    required this.nombre,
    required this.categoria,
  });
}
