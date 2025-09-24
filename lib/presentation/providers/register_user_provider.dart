import 'package:flutter_riverpod/flutter_riverpod.dart';

enum FieldType { text, select, date }

enum DateFieldKind { full, year }

class RegisterField {
  final String label;
  final FieldType type;
  final List<String> options;
  final DateFieldKind? dateKind;
  final String? helper;
  final bool isRequired;

  const RegisterField({
    required this.label,
    this.type = FieldType.text,
    this.options = const [],
    this.dateKind,
    this.helper,
    this.isRequired = true,
  });
}

final registerFieldsProvider = Provider<List<RegisterField>>((ref) => const [
      RegisterField(label: 'Nombre', helper: 'Tu primer nombre legal.'),
      RegisterField(label: 'Apellido', helper: 'Tu primer apellido.'),
      RegisterField(
        label: 'Fecha Nacimiento',
        type: FieldType.date,
        dateKind: DateFieldKind.full,
        helper: 'Selecciona tu fecha de nacimiento completa.',
      ),
      RegisterField(
        label: 'Escuela de Formación Deportiva',
        type: FieldType.select,
        options: ['Iniciación', 'Precompetitivo', 'Avanzado', 'Alto Rendimiento'],
        helper: 'Selecciona tu nivel actual en la EFD.',
      ),
      RegisterField(
        label: 'Año vinculación',
        type: FieldType.date,
        dateKind: DateFieldKind.year,
        helper: 'Año en que ingresaste a la EFD.',
      ),
      RegisterField(label: 'Lateralidad', helper: '¿Diestro, zurdo o ambidiestro?'),
      RegisterField(label: 'Lugar de nacimiento', helper: 'Ciudad y país.'),
      RegisterField(label: 'Ciudad de residencia', helper: 'Donde vives actualmente.'),
      RegisterField(label: 'Correo electrónico', helper: 'Para notificaciones y acceso.'),
      RegisterField(label: 'Correo Teléfono de contacto', helper: 'Teléfono del responsable o tuyo.'),
      RegisterField(label: 'Nombre Acudiente 1', helper: 'Padre, madre o tutor.'),
      RegisterField(label: 'Nombre Acudiente 2', helper: 'Opcional si aplica.', isRequired: false),
      RegisterField(label: 'Teléfono contacto acudiente', helper: 'Número del acudiente principal.'),
    ]);

final registerFormValuesProvider = StateProvider<Map<String, String?>>(
  (ref) => {},
);

// Indicates if the user attempted to submit, to trigger error helpers
final registerSubmitAttemptedProvider = StateProvider<bool>(
  (ref) => false,
);

