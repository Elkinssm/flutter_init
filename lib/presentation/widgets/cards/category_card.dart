import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final int year;
  final int members;
  final bool isSelected;
  final VoidCallback? onTapCard;
  final VoidCallback? onTapAssistance;
  const CategoryCard({
    super.key,
    required this.year,
    required this.members,
    required this.isSelected,
    this.onTapCard,
    this.onTapAssistance,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTapCard,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        height: 110,
        width: double.infinity,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(245, 240, 230, 1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                isSelected
                    ? const Color.fromRGBO(173, 111, 57, 1)
                    : const Color.fromRGBO(245, 240, 230, 1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                      color: Colors.black12,
                    ),
                  ]
                  : [
                    BoxShadow(
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                      color: Colors.black12,
                    ),
                  ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 7,
          children: [
            Expanded(
              child: Container(
                height: 88,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(224, 222, 217, 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  spacing: 0.01,
                  children: [
                    Image.asset(
                      'assets/images/members-icon.png',
                      width: 25,
                      height: 25,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CustomText(
                          text: '$year',
                          size: 22,
                          fontWeight: FontWeight.w800,
                        ),
                        CustomText(
                          text: '$members Miembros',
                          size: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            _AssistanceTag(onTapButton: onTapAssistance),
          ],
        ),
      ),
    );
  }
}

class _AssistanceTag extends StatelessWidget {
  final VoidCallback? onTapButton;
  const _AssistanceTag({this.onTapButton});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTapButton,
      child: Container(
        height: 88,
        width: 88,
        decoration: BoxDecoration(
          color: Color.fromRGBO(224, 222, 217, 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomText(
              text: 'Asistencia',
              size: 13,
              fontWeight: FontWeight.w400,
            ),
            const SizedBox(height: 5),
            Image.asset(
              'assets/images/asistance-icon.png',
              width: 45,
              height: 45,
            ),
          ],
        ),
      ),
    );
  }
}
