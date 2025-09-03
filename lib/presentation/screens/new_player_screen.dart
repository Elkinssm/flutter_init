import 'package:coach_app/presentation/providers/register_player_provider.dart';
import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class NewPlayerScreen extends StatelessWidget {
  static const String name = '/new_player_screen';
  const NewPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Color.fromRGBO(249, 248, 247, 1),
        appBar: CustomAppbar(
          title: 'Añadir jugador',
          onPressed: () => context.goNamed('/coach_screen'),
        ),
        bottomNavigationBar: CustomBottomAppbar(),
        floatingActionButton: CustomFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        resizeToAvoidBottomInset: false,
        body: _NewPlayerView(),
      ),
    );
  }
}

class _NewPlayerView extends ConsumerWidget {
  const _NewPlayerView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formFields = ref.watch(formFieldsRegisterPlayerProvider);
    final kb = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Flexible(
              child: ListView.builder(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.only(bottom: kb + 24),
                itemCount: formFields.length + 1,
                itemBuilder: (context, index) {
                  if (index < formFields.length) {
                    return formFields[index];
                  } else {
                    return Column(
                      children: [
                        const SizedBox(height: 25),
                        OnboardingNextButton(
                          text: 'Crear Jugador',
                          action: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                        ),
                        const SizedBox(height: 10),
                      ],
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 2),
          ],
        ),
      ),
    );
  }
}
