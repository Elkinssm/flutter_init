import 'package:coach_app/config/constants/environment.dart';
import 'package:coach_app/infrastructure/services/coach_api_service.dart';
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
  String? _selectedTipoPartido;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _saving = false;

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

                // Campo: Tipo de Partido
                _buildLabel('TIPO DE PARTIDO'),
                const SizedBox(height: 8),
                _buildDropdownField(),
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

    if (widget.equipoId == null) {
      CustomModal.show(
        context: context,
        title: 'Falta equipo',
        message: 'Debes entrar desde un equipo para crear el partido.',
        type: ModalType.warning,
      );
      return;
    }
    if (_rivalController.text.trim().isEmpty ||
        _selectedTipoPartido == null ||
        _selectedDate == null) {
      CustomModal.show(
        context: context,
        title: 'Campos obligatorios',
        message: 'Completa rival, tipo de partido y fecha.',
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
      'equipo_id': widget.equipoId,
      'rival_nombre': _rivalController.text.trim(),
      'es_local': _selectedTipoPartido == 'Local / Casa',
      'fecha': fecha,
    };
    if ((hora ?? '').isNotEmpty) body['hora'] = hora;
    if (_lugarController.text.trim().isNotEmpty) body['lugar'] = _lugarController.text.trim();
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
      ref.invalidate(coachPartidosByEquipoProvider(widget.equipoId!));

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
        message: '$e',
        type: ModalType.error,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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

  Widget _buildDropdownField() {
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
                value: _selectedTipoPartido,
                hint: Text(
                  'Local / Casa',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: const Color(0xFF0B1926),
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
                    ['Local / Casa', 'Visitante / Fuera']
                        .map(
                          (tipo) => DropdownMenuItem(
                            value: tipo,
                            child: Text(
                              tipo,
                              style: GoogleFonts.inter(fontSize: 15),
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() => _selectedTipoPartido = value);
                },
              ),
            ),
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
