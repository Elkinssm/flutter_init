import 'package:coach_app/presentation/helpers/responsive.dart';
import 'package:coach_app/presentation/providers/register_user_provider.dart';
import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatelessWidget {
  static const String name = 'register_screen';
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Color.fromRGBO(249, 248, 247, 1),
        appBar: CustomAppbar(title: 'Registro jugador'),
        body: _RegisterView(),
      ),
    );
  }
}

class _RegisterView extends ConsumerWidget {
  const _RegisterView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labels = ref.watch(registerFieldLabelsProvider);
    final titleTextSize = ts(context, 32);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            SizedBox(height: 26),
            CustomText(
              text: 'Regístrate gratis',
              size: titleTextSize,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
            SizedBox(height: 36),
            Expanded(
              child: ListView.separated(
                physics: const ClampingScrollPhysics(),
                itemCount: labels.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final label = labels[index];
                  return _FieldTile(
                    context: context,
                    label: label,
                    key: ValueKey('field_$index'),
                  );
                },
              ),
            ),
            SizedBox(height: 25),
            OnboardingNextButton(
              text: 'Registrate',
              action: () {
                FocusManager.instance.primaryFocus?.unfocus();
                context.push('/player_screen');
              },
            ),
            SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}

class _FieldTile extends StatelessWidget {
  final String label;
  final BuildContext context;
  const _FieldTile({super.key, required this.label, required this.context});

  @override
  Widget build(BuildContext context) {
    final textSize = ts(context, 16);
    final spacing = shp(context, 0.010);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: swp(context, 0.01)),
          child: CustomText(
            text: label,
            fontWeight: FontWeight.w700,
            size: textSize,
          ),
        ),
        SizedBox(height: spacing),
        const CustomTextFormField(hintText: 'test'),
      ],
    );
  }
}
