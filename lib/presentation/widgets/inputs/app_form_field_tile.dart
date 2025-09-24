import 'package:coach_app/presentation/helpers/responsive.dart';
import 'package:coach_app/presentation/providers/register_user_provider.dart'
    show FieldType, DateFieldKind; // reuse existing enums
import 'package:coach_app/presentation/widgets/inputs/custom_text_from_field.dart';
import 'package:flutter/material.dart';

class AppFormFieldTile extends StatelessWidget {
  final String label;
  final FieldType type;
  final List<String> options;
  final DateFieldKind? dateKind;
  final String? helper;
  final bool isRequired;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String? errorText;

  const AppFormFieldTile({
    super.key,
    required this.label,
    required this.type,
    required this.onChanged,
    this.options = const [],
    this.dateKind,
    this.helper,
    this.isRequired = true,
    this.value,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final textSize = ts(context, 16);
    final spacing = shp(context, 0.010);

    Widget input;

    if (type == FieldType.select) {
      input = Container(
        decoration: BoxDecoration(
          color:
              Theme.of(context).inputDecorationTheme.fillColor ?? Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: value,
            hint: const Text('Seleccione una opción'),
            icon: const Icon(Icons.arrow_drop_down),
            items: options
                .map((opt) => DropdownMenuItem<String>(
                      value: opt,
                      child: Text(opt),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      );
    } else if (type == FieldType.date &&
        (dateKind ?? DateFieldKind.full) == DateFieldKind.year) {
      input = InkWell(
        onTap: () async {
          final selected = await showModalBottomSheet<String>(
            context: context,
            builder: (ctx) {
              final currentYear = DateTime.now().year;
              final years = List<String>.generate(
                currentYear - 1800 + 1,
                (i) => (currentYear - i).toString(),
              );
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      height: 4,
                      width: 40,
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Selecciona año',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemBuilder: (_, i) {
                          final y = years[i];
                          return ListTile(
                            title: Text(y),
                            onTap: () => Navigator.of(ctx).pop(y),
                          );
                        },
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemCount: years.length,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
          if (selected != null) onChanged(selected);
        },
        child: AbsorbPointer(
          child: CustomTextFormField(
            hintText: 'Selecciona año',
            controller: TextEditingController(text: value ?? ''),
          ),
        ),
      );
    } else if (type == FieldType.date &&
        (dateKind ?? DateFieldKind.full) == DateFieldKind.full) {
      input = InkWell(
        onTap: () async {
          final now = DateTime.now();
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime(now.year - 10, now.month, now.day),
            firstDate: DateTime(1900, 1, 1),
            lastDate: DateTime(now.year, now.month, now.day),
            helpText: 'Selecciona fecha',
          );
          if (picked != null) {
            final s =
                '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
            onChanged(s);
          }
        },
        child: AbsorbPointer(
          child: CustomTextFormField(
            hintText: 'Selecciona fecha',
            controller: TextEditingController(text: value ?? ''),
          ),
        ),
      );
    } else {
      input = CustomTextFormField(
        hintText: 'Ingresa $label',
        onChanged: onChanged,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: swp(context, 0.01)),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: textSize,
                  ),
                ),
              ),
              if (isRequired)
                const Text('*',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        SizedBox(height: spacing),
        input,
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: swp(context, 0.01)),
            child: Text(
              errorText!,
              style: TextStyle(color: Colors.red[700], fontSize: ts(context, 12), fontWeight: FontWeight.w600),
            ),
          ),
        ] else if (helper != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: swp(context, 0.01)),
            child: Text(
              helper!,
              style: TextStyle(color: Colors.grey[600], fontSize: ts(context, 12)),
            ),
          ),
        ],
      ],
    );
  }
}
