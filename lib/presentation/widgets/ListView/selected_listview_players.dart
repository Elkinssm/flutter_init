import 'package:coach_app/presentation/screens/player_status_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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

  static int get playerCount => _students.length;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: _students.length,
      padding: const EdgeInsets.only(bottom: 80),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, __) => Divider(
        height: 1,
        thickness: 0.8,
        color: Colors.grey.shade300,
      ),
      itemBuilder: (_, i) => StudentTiles(s: _students[i]),
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
    return InkWell(
      onTap: () => context.pushNamed(
        PlayerStatusScreen.name,
        extra: {'name': s.name, 'image': s.image},
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            // Foto
            Stack(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE0D6C8),
                      width: 1.5,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 4,
                        offset: Offset(0, 2),
                        color: Colors.black12,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      s.image,
                      fit: BoxFit.cover,
                      cacheWidth: 128,
                      cacheHeight: 128,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.name,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0B1926),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '# ${s.number}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4FA626),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '·',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD94929).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          s.position,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFD94929),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Chevron
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF9CA3AF),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
