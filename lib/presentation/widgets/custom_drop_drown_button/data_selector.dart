import 'package:coach_app/presentation/widgets/texts/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DataSelector extends ConsumerWidget {
  final StateProvider<String?> provider;
  const DataSelector({required this.provider, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedValue = ref.watch(provider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 25,
            width: 125,
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(3, 3),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: DropdownButtonFormField<String>(
              value: selectedValue,
              hint: const CustomText(
                text: 'Seleccionar',
                size: 12,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(
                    color: Color(0xFFAAAAAA),
                    width: 1,
                  ),
                ),
              ),
              elevation: 4,
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
              items:
                  [
                    'Peso',
                    'IMC',
                    'Estatura',
                    'Velocidad',
                  ].map((value) => _buildDropdownItem(value)).toList(),
              selectedItemBuilder: (context) {
                return ['Peso', 'IMC', 'Estatura', 'Velocidad'].map((value) {
                  return Align(
                    alignment: Alignment.center,
                    child: CustomText(
                      text: value,
                      fontWeight: FontWeight.bold,
                      size: 12,
                    ),
                  );
                }).toList();
              },
              onChanged: (String? newValue) {
                ref.read(provider.notifier).state = newValue!;
              },
            ),
          ),
        ],
      ),
    );
  }
}

DropdownMenuItem<String> _buildDropdownItem(String value) {
  return DropdownMenuItem<String>(
    value: value,
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(0),
          child: CustomText(
            text: value,
            size: 12,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(color: Color.fromRGBO(217, 73, 41, 1)),
      ],
    ),
  );
}
