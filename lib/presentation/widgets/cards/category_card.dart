import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryCard extends StatelessWidget {
  final int year;
  final int members;
  final bool isSelected;
  /// Si se indica, se muestra en lugar del año (ej. "Sub-21" desde API).
  final String? displayLabel;
  final VoidCallback? onTapCard;
  final VoidCallback? onTapAssistance;
  const CategoryCard({
    super.key,
    required this.year,
    required this.members,
    required this.isSelected,
    this.displayLabel,
    this.onTapCard,
    this.onTapAssistance,
  });

  static const _cardBg = Color.fromRGBO(245, 240, 230, 1);
  static const _accent = Color.fromRGBO(173, 111, 57, 1);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _cardBg,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTapCard,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? _accent : _cardBg,
              width: isSelected ? 2.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? _accent.withValues(alpha: 0.25)
                    : Colors.black.withValues(alpha: 0.07),
                blurRadius: isSelected ? 14 : 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              // Icono grande con sombra
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _accent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _accent.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.groups_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayLabel ?? '$year',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0B1926),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.person_rounded,
                          size: 14,
                          color: _accent.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$members miembros',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Botón asistencia
              _AssistanceTag(onTapButton: onTapAssistance),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssistanceTag extends StatelessWidget {
  final VoidCallback? onTapButton;
  const _AssistanceTag({this.onTapButton});

  static const _accent = Color.fromRGBO(173, 111, 57, 1);

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final tagWidth = (screenW * 0.20).clamp(84.0, 108.0);

    return InkWell(
      onTap: onTapButton,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: tagWidth,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: _accent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: _accent.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.fact_check_rounded,
              color: Colors.white,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              'Asistencia',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: tagWidth < 92 ? 9.5 : 10,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
