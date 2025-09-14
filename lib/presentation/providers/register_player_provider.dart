import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// Provider para manejar la imagen seleccionada
final selectedImageProvider = StateProvider<File?>((ref) => null);

final formFieldsRegisterPlayerProvider = Provider<List<Widget>>((ref) {
  List<Widget> fields = [
    _buildField('Nombre Completo', 'Ingresa el nombre completo'),
    _buildField('Número de camiseta', 'Número del 1 al 99'),
    _buildField('Fecha de nacimiento', 'DD/MM/AAAA'),
    _buildField('Posición', 'Delantero'),
    _buildField('Altura', '1.75m'),
    _buildField('Peso', '70kg'),
    _buildField('Categoría', 'Sub-18'),
    _buildField('Pierna hábil', 'Derecha'),
    _buildField('Teléfono de contacto', '300 123 4567'),
    _buildField('Correo electrónico', 'jugador@email.com'),
    _buildField('Estado de salud / Lesiones actuales', 'Describe el estado'),
    _buildField('Equipo', 'Nombre del equipo'),
    _buildPhotoField(), // Campo especial para foto
  ];

  return withVerticalSpacing(fields, 10);
});

Widget _buildField(String? label, String hintText) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: CustomText(text: label!, fontWeight: FontWeight.w700, size: 16),
      ),
      const SizedBox(height: 15),
      CustomTextFormField(hintText: hintText),
    ],
  );
}

Widget _buildPhotoField() {
  return Consumer(
    builder: (context, ref, child) {
      final selectedImage = ref.watch(selectedImageProvider);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: CustomText(
              text: 'Foto',
              fontWeight: FontWeight.w700,
              size: 16,
            ),
          ),
          const SizedBox(height: 15),
          GestureDetector(
            onTap: () => _showPhotoOptions(context, ref),
            child: Container(
              height: selectedImage != null ? 120 : 50,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  selectedImage != null
                      ? Column(
                        children: [
                          // Mostrar imagen seleccionada
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.file(
                                  selectedImage,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          // Botón para cambiar imagen
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.edit,
                                  color: Colors.blue[600],
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                CustomText(
                                  text: 'Cambiar foto',
                                  size: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue[600],
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          CustomText(
                            text: 'Seleccionar foto',
                            size: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
            ),
          ),
        ],
      );
    },
  );
}

void _showPhotoOptions(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Barra superior
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Título
            CustomText(
              text: 'Seleccionar foto',
              size: 18,
              fontWeight: FontWeight.w700,
            ),
            const SizedBox(height: 20),

            // Opción 1: Cámara
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const CustomText(
                text: 'Tomar foto',
                size: 16,
                fontWeight: FontWeight.w500,
              ),
              onTap: () {
                Navigator.pop(context);
                _takePhoto(context, ref);
              },
            ),

            // Opción 2: Galería
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const CustomText(
                text: 'Seleccionar de galería',
                size: 16,
                fontWeight: FontWeight.w500,
              ),
              onTap: () {
                Navigator.pop(context);
                _selectFromGallery(context, ref);
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      );
    },
  );
}

Future<void> _takePhoto(BuildContext context, WidgetRef ref) async {
  try {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      maxHeight: 600,
      imageQuality: 80,
    );

    if (image != null) {
      ref.read(selectedImageProvider.notifier).state = File(image.path);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto tomada exitosamente'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al tomar foto: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

Future<void> _selectFromGallery(BuildContext context, WidgetRef ref) async {
  try {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 600,
      imageQuality: 80,
    );

    if (image != null) {
      ref.read(selectedImageProvider.notifier).state = File(image.path);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Imagen seleccionada exitosamente'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al seleccionar imagen: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

List<Widget> withVerticalSpacing(List<Widget> widgets, double spacing) {
  return [
    for (int i = 0; i < widgets.length; i++) ...[
      widgets[i],
      if (i < widgets.length - 1) SizedBox(height: spacing),
    ],
  ];
}
