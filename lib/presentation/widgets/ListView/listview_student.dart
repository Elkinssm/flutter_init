import 'package:coach_app/presentation/screens/player_status_screen.dart';
import 'package:coach_app/presentation/widgets/texts/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// local model Students
class Student {
  final String name;
  final String image;
  final int number;
  final String position;
  final String weight;
  final int percent;

  Student({
    required this.name,
    required this.image,
    required this.number,
    required this.position,
    required this.weight,
    required this.percent,
  });
}

class ListViewStudent extends StatelessWidget {
  const ListViewStudent({super.key});

  @override
  Widget build(BuildContext context) {
    final kb = MediaQuery.of(context).viewInsets.bottom;

    return ListView.separated(
      itemCount: _students.length,
      padding: EdgeInsets.only(bottom: kb + 74),
      physics:
          _students.length > 4
              ? const ClampingScrollPhysics()
              : const NeverScrollableScrollPhysics(),
      separatorBuilder:
          (_, __) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(vertical: 6),
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
          ),
      itemBuilder: (_, i) => StudentTile(s: _students[i]),
    );
  }
}

final _students = <Student>[
  Student(
    name: 'Camilo Andrés',
    image: 'assets/images/student-eg1-icon.png',
    number: 22,
    position: 'ST',
    weight: '37kg',
    percent: 92,
  ),
  Student(
    name: 'Andrés Felipe',
    image: 'assets/images/student-eg2-icon.png',
    number: 11,
    position: 'DC',
    weight: '50kg',
    percent: 100,
  ),
  Student(
    name: 'Juan David',
    image: 'assets/images/student-eg3-icon.png',
    number: 99,
    position: 'PO',
    weight: '57kg',
    percent: 82,
  ),
  Student(
    name: 'Carlos Alberto',
    image: 'assets/images/student-eg4-icon.png',
    number: 11,
    position: 'ED',
    weight: '67kg',
    percent: 92,
  ),
  Student(
    name: 'Carlos Alberto',
    image: 'assets/images/student-eg5-icon.png',
    number: 15,
    position: 'DC',
    weight: '67kg',
    percent: 92,
  ),
  Student(
    name: 'Carlos Alberto',
    image: 'assets/images/student-eg6-icon.png',
    number: 22,
    position: 'SD',
    weight: '67kg',
    percent: 92,
  ),
];

class StudentTile extends StatelessWidget {
  final Student s;
  const StudentTile({super.key, required this.s});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: SizedBox(
        height: 70.5,
        child: Row(
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
                      _StatChip(
                        text: '${s.number}',
                        color: Color.fromRGBO(79, 166, 38, 1),
                        kind: StatChipKind.circle,
                        size: 24,
                      ),
                      const SizedBox(width: 6),
                      _StatChip(
                        text: s.position,
                        color: Color.fromRGBO(173, 111, 57, 1),
                        kind: StatChipKind.circle,
                        size: 24,
                      ),
                      const SizedBox(width: 6),
                      _StatChip(
                        text: s.weight,
                        color: Color.fromRGBO(212, 175, 55, 1),
                        kind: StatChipKind.pill,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            CustomText(
              text: '${s.percent}%',
              size: 20,
              fontWeight: FontWeight.w700,
            ),
          ],
        ),
      ),
    );
  }
}

enum StatChipKind { circle, pill }

class _StatChip extends StatelessWidget {
  final String text;
  final Color color;
  final StatChipKind kind;
  final double? size;

  const _StatChip({
    required this.text,
    required this.color,
    required this.kind,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFD5E5F4);

    if (kind == StatChipKind.circle) {
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
          fontWeight: FontWeight.w400,
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
