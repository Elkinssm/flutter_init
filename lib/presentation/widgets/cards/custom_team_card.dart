import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';

class CustomTeamCard extends StatefulWidget {
  final String image;
  final String teamName;
  final int totalPlayers;
  final String teamClass;
  final bool isSelected;
  final VoidCallback? onTapCard;
  const CustomTeamCard({
    super.key,
    required this.image,
    required this.teamName,
    required this.totalPlayers,
    required this.teamClass,
    required this.isSelected,
    this.onTapCard,
  });

  @override
  State<CustomTeamCard> createState() => _CustomTeamCardState();
}

class _CustomTeamCardState extends State<CustomTeamCard> {
  static const _selectedBorderColor = Color.fromRGBO(173, 111, 57, 1);
  static const _normalBorderColor = Color.fromRGBO(245, 240, 230, 1);

  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final borderColor =
        widget.isSelected ? _selectedBorderColor : _normalBorderColor;
    final borderWidth = widget.isSelected ? 2.0 : 1.0;

    return InkWell(
      onTap: widget.onTapCard,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        height: 100,
        width: double.infinity,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(245, 240, 230, 1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow:
              _isPressed
                  ? [
                    const BoxShadow(
                      blurRadius: 10,
                      offset: Offset(0, 6),
                      color: Colors.black12,
                    ),
                  ]
                  : [
                    const BoxShadow(
                      blurRadius: 6,
                      offset: Offset(0, 3),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 8,
                children: [
                  Image.asset(widget.image, width: 75),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: widget.teamName,
                        size: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      SizedBox(height: 10),
                      CustomText(
                        text: '${widget.totalPlayers} Jugadores',
                        size: 13,
                        fontWeight: FontWeight.w400,
                      ),
                      SizedBox(height: 10),
                      CustomText(
                        text: widget.teamClass,
                        size: 13,
                        fontWeight: FontWeight.w300,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
