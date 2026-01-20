import 'package:flutter/material.dart';
import 'package:coach_app/presentation/helpers/responsive.dart';
import 'package:go_router/go_router.dart';

class CustomFloatingActionButton extends StatelessWidget {
  const CustomFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).size.height;

    double fabSize;
    fabSize =
        isSmallPhone(context)
            ? 52.0
            : isPhone(context)
            ? 48.0
            : isSmallTablet(context)
            ? 34.0
            : isLargeTablet(context)
            ? 38.0
            : 10.0;

    final iconSize =
        isSmallPhone(context)
            ? ts(context, 22)
            : (isPhone(context) ? ts(context, 24) : ts(context, 26));

    return Transform.translate(
      offset: Offset(0, -(-bottomInset * 0.01)),
      child: SizedBox(
        width: fabSize,
        height: fabSize,
        child: FloatingActionButton(
          onPressed:
              () => context.push('/selected_team_screen', extra: 'Equipo'),
          elevation: 0,
          highlightElevation: 0,
          shape: const CircleBorder(),
          backgroundColor: const Color.fromRGBO(79, 166, 38, 1),
          child: Image.asset(
            'assets/images/whistle-96.png',
            height: iconSize,
            width: iconSize,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
