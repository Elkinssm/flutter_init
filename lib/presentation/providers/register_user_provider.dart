import 'package:flutter_riverpod/flutter_riverpod.dart';

final registerFieldLabelsProvider = Provider<List<String>>((ref) => [
  'Nombre',
  'Apellido',
  'Fecha Nacimiento',
  'EFD → Select',
  'Año vinculación a EFD',
  'Lateralidad',
  'Lugar de nacimiento',
  'Ciudad de residencia',
  'Correo electrónico',
  'Correo Teléfono de contacto',
  'Nombre Acudiente 1',
  'Nombre Acudiente 2',
  'Teléfono contacto acudiente',
]);

