import 'package:coach_app/presentation/providers/register_provider.dart';
import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatelessWidget {
  static const String name = 'register_screen';
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(249, 248, 247, 1),
      appBar: CustomAppbar(title: 'Registro jugador'),
      body: _RegisterView(),
    );
  }
}

class _RegisterView extends ConsumerWidget {
  const _RegisterView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formFields = ref.watch(formFieldsProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            const SizedBox(height: 26),
            CustomText(
              text: 'Regístrate gratis',
              size: 32,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
            const SizedBox(height: 36),
            Flexible(
              child: ListView.builder(
                physics: const ClampingScrollPhysics(),
                itemCount: formFields.length,
                itemBuilder: (context, index) => formFields[index],
              ),
            ),
            const SizedBox(height: 25),
            OnboardingNextButton(
              text: 'Registrate',
              action: () {
                FocusManager.instance.primaryFocus?.unfocus();
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
