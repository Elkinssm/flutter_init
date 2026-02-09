import 'package:coach_app/presentation/providers/selected_buttons_provider.dart';
import 'package:coach_app/presentation/widgets/texts/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomActionButtonWidget extends ConsumerWidget {
  final String label;
  final EdgeInsets? padding;
  final VoidCallback? onPressed;
  const CustomActionButtonWidget({
    required this.label,
    this.padding,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedMenuProvider) == label;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        ref.read(selectedMenuProvider.notifier).state = label;
        onPressed?.call();
      },
      child: AnimatedContainer(
        height: 34,
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(vertical: 7, horizontal: 3),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(245, 240, 230, 1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color:
                selected
                    ? const Color.fromRGBO(173, 111, 57, 1)
                    : Colors.transparent,
            width: 2,
          ),
          boxShadow: const [
            BoxShadow(
              blurRadius: 4,
              offset: Offset(0, 4),
              color: Colors.black26,
            ),
          ],
        ),
        child: CustomText(
          text: label,
          size: 12,
          fontWeight: FontWeight.w600,
          color:
              selected
                  ? const Color.fromRGBO(217, 73, 41, 1)
                  : const Color.fromRGBO(55, 73, 87, 1),
        ),
      ),
    );
  }
}
