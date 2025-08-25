import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final formFieldsRegisterPlayerProvider = Provider<List<Widget>>((ref) {
  List<Widget> fields = [
    _buildField('Nombre Completo'),
    _buildField('Número de camiseta'),
    _buildField('Fecha de nacimiento'),
    _buildField('Posicion'),
    _buildField('Altura y peso'),
    _buildField('Categoría'),
    _buildField('Pierna hábil'),
    _buildField('Teléfono de contacto'),
    _buildField('Correo electrónico'),
    _buildField('Estado de salud / Lesiones actuales.'),
    _buildField('Equipo'),
    _buildField('Foto'),
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
      const SizedBox(height: 15),
      CustomTextFormField(hintText: 'Escriba un texto'),
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
