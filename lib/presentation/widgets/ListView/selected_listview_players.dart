import 'package:coach_app/presentation/screens/player_status_screen.dart';
import 'package:coach_app/presentation/widgets/texts/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// local model Students
class Students {
  final String name;
  final String image;
  final int number;
  final String position;

  Students({
    required this.name,
    required this.image,
    required this.number,
    required this.position,
  });
}

class SelectedListviewPlayers extends StatelessWidget {
  const SelectedListviewPlayers({super.key});

  @override
  Widget build(BuildContext context) {
    final kb = MediaQuery.of(context).viewInsets.bottom;

    return ListView.separated(
      itemCount: _students.length + 1,
      padding: EdgeInsets.only(bottom: kb + 74),
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder:
          (_, __) => Container(
            height: 2,
            margin: const EdgeInsets.symmetric(vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFE3503B),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 4),
                ),
              ],
            ),
          ),
      itemBuilder: (_, i) {
        if (i < _students.length) {
          return StudentTiles(s: _students[i]);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

final _students = <Students>[
  Students(
    name: 'Camilo Andréss©s',
    image: 'assets/images/student-eg1-icon.png',
    number: 22,
    position: 'ST',
  ),
  Students(
    name: 'Andrés©s Felipe',
    image: 'assets/images/student-eg2-icon.png',
    number: 11,
    position: 'DC',
  ),
  Students(
    name: 'Juan David',
    image: 'assets/images/student-eg3-icon.png',
    number: 99,
    position: 'PO',
  ),
  Students(
    name: 'Carlos Alberto',
    image: 'assets/images/student-eg4-icon.png',
    number: 11,
    position: 'ED',
  ),
  Students(
    name: 'Santiago José©',
    image: 'assets/images/student-eg5-icon.png',
    number: 15,
    position: 'DC',
  ),
  Students(
    name: 'Juan Andréss',
    image: 'assets/images/student-eg6-icon.png',
    number: 22,
    position: 'SD',
  ),
];

class StudentTiles extends StatelessWidget {
  final Students s;
  const StudentTiles({super.key, required this.s});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 82,
      child: Row(
        spacing: 4,
        children: [
          InkWell(
            onTap:
                () => context.pushNamed(
                  PlayerStatusScreen.name,
                  extra: {'name': s.name, 'image': s.image},
                ),
            child: Stack(
              children: [
                Container(
                  width: 64,
                  height: 65.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Color.fromRGBO(27, 71, 56, 1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 1,
                        offset: const Offset(0, 3),
                        color: Colors.black12,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 64,
                  height: 70,
                  child: ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Image.asset(
                        s.image,
                        fit: BoxFit.cover,
                        cacheWidth: 128,
                        cacheHeight: 128,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                InkWell(
                  onTap:
                      () => context.pushNamed(
                        PlayerStatusScreen.name,
                        extra: {'name': s.name, 'image': s.image},
                      ),
                  child: CustomText(
                    text: s.name,
                    size: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _StatChips(
                      text: '${s.number}',
                      color: Color.fromRGBO(79, 166, 38, 1),
                      kind: StatChipKinds.circle,
                      size: 24,
                    ),
                    const SizedBox(width: 20),
                    _StatChips(
                      text: s.position,
                      color: Color.fromRGBO(173, 111, 57, 1),
                      kind: StatChipKinds.circle,
                      size: 24,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum StatChipKinds { circle, pill }

class _StatChips extends StatelessWidget {
  final String text;
  final Color color;
  final StatChipKinds kind;
  final double? size;

  const _StatChips({
    required this.text,
    required this.color,
    required this.kind,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFD5E5F4);

    if (kind == StatChipKinds.circle) {
      return Container(
        padding: EdgeInsets.zero,
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: CustomText(
          text: text,
          size: 13.5,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 4)),
        ],
      ),
      child: CustomText(
        text: text,
        size: 13.5,
        fontWeight: FontWeight.w400,
        color: color,
      ),
    );
  }
}

