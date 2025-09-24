import 'package:coach_app/presentation/helpers/responsive.dart';
import 'package:coach_app/presentation/providers/register_user_provider.dart';
import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:coach_app/presentation/widgets/inputs/app_form_field_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:coach_app/config/router/app_router.dart' as app_router;

class RegisterScreen extends StatelessWidget {
  static const String name = 'register_screen';
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(249, 248, 247, 1),
        appBar: const CustomAppbar(title: 'Registro jugador'),
        body: const _RegisterView(),
      ),
    );
  }
}

class _RegisterView extends ConsumerWidget {
  const _RegisterView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fields = ref.watch(registerFieldsProvider);
    final titleTextSize = ts(context, 32);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            const SizedBox(height: 26),
            CustomText(
              text: 'Registrate gratis',
              size: titleTextSize,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
            const SizedBox(height: 36),
            Expanded(
              child: ListView.separated(
                physics: const ClampingScrollPhysics(),
                itemCount: fields.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final field = fields[index];
                  final currentValue = ref.watch(
                    registerFormValuesProvider.select((m) => m[field.label]),
                  );
                  final attempted = ref.watch(registerSubmitAttemptedProvider);
                  final isEmpty = (currentValue == null || currentValue.toString().trim().isEmpty);
                  final errorText = (attempted && field.isRequired && isEmpty)
                      ? 'Este campo es obligatorio'
                      : null;

                  return AppFormFieldTile(
                    key: ValueKey('field_$index'),
                    label: field.label,
                    type: field.type,
                    options: field.options,
                    dateKind: field.dateKind,
                    // helper solo si quieres mostrar texto informativo constante
                    helper: null,
                    isRequired: field.isRequired,
                    value: currentValue,
                    errorText: errorText,
                    onChanged: (val) {
                      final values = ref.read(registerFormValuesProvider);
                      ref.read(registerFormValuesProvider.notifier).state = {
                        ...values,
                        field.label: val,
                      };
                    },
                  );
                },
            ),
            ),
            const SizedBox(height: 25),
            OnboardingNextButton(
              text: 'Registrate',
              action: () {
                FocusManager.instance.primaryFocus?.unfocus();
                // Mark submit attempted to show inline errors
                ref.read(registerSubmitAttemptedProvider.notifier).state = true;
                final fields = ref.read(registerFieldsProvider);
                final values = ref.read(registerFormValuesProvider);

                final missing = <String>[];
                for (final f in fields) {
                  final v = values[f.label];
                  if (!f.isRequired) continue;
                  switch (f.type) {
                    case FieldType.text:
                      if (v == null || v.trim().isEmpty) missing.add(f.label);
                      break;
                    case FieldType.select:
                    case FieldType.date:
                      if (v == null || v.isEmpty) missing.add(f.label);
                      break;
                  }
                }

                if (missing.isNotEmpty) return; // inline errors are visible now

                // Log data to console so you can see what's sent
                // ignore: avoid_print
                print('Registro: $values');

                // Bypass role guard: mark current user as player to allow navigation
                app_router.currentUserRole = 'player';
                context.push('/player_screen');
              },
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}

// _FieldTile replaced by reusable AppFormFieldTile in widgets/inputs/app_form_field_tile.dart
