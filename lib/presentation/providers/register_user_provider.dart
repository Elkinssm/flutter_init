import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final formRegisterUserFieldsProvider = Provider<List<Widget>>((ref) {
  List<Widget> fields = [
    _buildField('Nombre'),
    _buildField('Apellido'),
    _buildField('Fecha Nacimiento'),
    _buildField('EFD → Select'),
    _buildField('Año vinculación a EFD'),
    _buildField('Lateralidad'),
    _buildField('Lugar de nacimiento'),
    _buildField('Ciudad de residencia'),
    _buildField('Correo electrónico'),
    _buildField('Correo Teléfono de contacto'),
    _buildField('Nombre Acudiente 1'),
    _buildField('Nombre Acudiente 2'),
    _buildField('Teléfono contacto acudiente'),
  ];

  return withVerticalSpacing(fields, 10);
});

Widget _buildField(String? label) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: CustomText(text: label!, fontWeight: FontWeight.w700, size: 16),
      ),
      const SizedBox(height: 10),
      CustomTextFormField(hintText: 'test'),
    ],
  );
}

List<Widget> withVerticalSpacing(List<Widget> widgets, double spacing) {
  return [
    for (int i = 0; i < widgets.length; i++) ...[
      widgets[i],
      if (i < widgets.length - 1) SizedBox(height: spacing),
    ],
  ];
}
