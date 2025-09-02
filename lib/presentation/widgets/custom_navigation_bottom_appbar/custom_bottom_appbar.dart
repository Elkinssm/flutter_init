import 'package:coach_app/presentation/providers/selected_icon_provider.dart';
import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coach_app/presentation/helpers/responsive.dart';
import 'package:go_router/go_router.dart';

class CustomBottomAppbar extends ConsumerWidget {
  const CustomBottomAppbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIconProvider);

    final bottomInset = MediaQuery.of(context).padding.bottom;
    final barBaseH = 60.0;
    final totalH = barBaseH + bottomInset;

    final whiteCurveH = barBaseH;
    final orangeCurveH = barBaseH;
    final orangelineH = barBaseH;
    final blockBarH = barBaseH;

    final iconSize = isPhone(context) ? ts(context, 24) : ts(context, 26);
    final gapForFab = isPhone(context) ? wp(context, 0.16) : wp(context, 0.18);

    return SizedBox(
      height: totalH,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: orangeCurveH,
                width: double.infinity,
                child: CustomPaint(
                  painter: CurvedBarPainterOrange(context: context),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: whiteCurveH,
                width: double.infinity,
                child: CustomPaint(
                  painter: CurvedBarPainterWhite(context: context),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: orangelineH,
                width: double.infinity,
                child: CustomPaint(
                  painter: CurvedLinePainterOrange(context: context),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: orangelineH,
                width: double.infinity,
                child: CustomPaint(
                  painter: CurvedLine2PainterOrange(context: context),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: BlockBarPainterOrange(),
              child: SizedBox(height: blockBarH),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomInset * 0.5,
            child: SizedBox(
              height: barBaseH,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildIcon(
                    context,
                    ref,
                    0,
                    selectedIndex,
                    'home',
                    iconSize,
                    ontap: () => context.go('/coach_screen'),
                  ),
                  _buildIcon(
                    context,
                    ref,
                    1,
                    selectedIndex,
                    'winner',
                    iconSize,
                  ),
                  SizedBox(width: gapForFab),
                  _buildIcon(
                    context,
                    ref,
                    2,
                    selectedIndex,
                    'stadium',
                    iconSize,
                  ),
                  _buildIcon(
                    context,
                    ref,
                    3,
                    selectedIndex,
                    'message',
                    iconSize,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(
    BuildContext context,
    WidgetRef ref,
    int index,
    int selectedIndex,
    String name,
    double iconSize, {
    VoidCallback? ontap,
  }) {
    final isSelected = selectedIndex == index;
    final imagePath =
        isSelected
            ? 'assets/images/$name-100.png'
            : 'assets/images/$name-black-100.png';

    final tapBox = isPhone(context) ? 48.0 : 52.0;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        ref.read(selectedIconProvider.notifier).state = index;
        ontap?.call();
      },
      child: SizedBox(
        width: tapBox,
        height: tapBox,
        child: Center(
          child: Image.asset(
            imagePath,
            height: iconSize,
            width: iconSize,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
