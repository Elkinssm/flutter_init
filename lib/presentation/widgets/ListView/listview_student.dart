import 'package:flutter/material.dart';

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
    return Expanded(
      child: ListView.separated(
        itemCount: _students.length,
        physics:
            _students.length > 4
                ? const BouncingScrollPhysics()
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
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
        itemBuilder: (_, i) => StudentTile(s: _students[i]),
      ),
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
        height: 75,
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green.shade600, width: 1),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 1,
                    offset: const Offset(0, 3),
                    color: Colors.black12,
                  ),
                ],
              ),
              child: ClipOval(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Image.asset(s.image, fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _StatChip(text: '${s.number}'),
                      const SizedBox(width: 6),
                      _StatChip(text: s.position),
                      const SizedBox(width: 6),
                      _StatChip(text: s.weight, highlighted: true),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '${s.percent}%',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String text;
  final bool highlighted;
  const _StatChip({required this.text, this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    final bg = highlighted ? const Color(0xFFFFF4DF) : const Color(0xFFE9F1F5);
    final border =
        highlighted ? const Color(0xFFFFC773) : const Color(0xFFD4E1E8);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            blurRadius: 1,
            offset: const Offset(0, 3),
            color: Colors.black12,
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
