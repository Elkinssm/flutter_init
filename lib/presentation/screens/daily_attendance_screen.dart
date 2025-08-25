import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DailyAttendanceScreen extends StatelessWidget {
  static const String name = '/daily_attendance_screen';
  const DailyAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Color.fromRGBO(249, 248, 247, 1),
        appBar: CustomAppbar(title: 'Asistencia diaria'),
        bottomNavigationBar: CustomBottomAppbar(),
        floatingActionButton: CustomFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: _DailyAttendanceView(),
      ),
    );
  }
}

class _DailyAttendanceView extends StatefulWidget {
  const _DailyAttendanceView();

  @override
  State<_DailyAttendanceView> createState() => _DailyAttendanceViewState();
}

class _DailyAttendanceViewState extends State<_DailyAttendanceView> {
  static const int totalPlayers = 24;
  final List<String> playerNames = List.generate(
    totalPlayers,
    (i) => 'Camilo Andres',
  );
  int? _highlightedIndex;
  DateTime _selectedDate = DateTime.now();

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      locale: const Locale('es', 'CO'),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  String get _formattedDate {
    final d = _selectedDate.day.toString().padLeft(2, '0');
    final m = _selectedDate.month.toString().padLeft(2, '0');
    final y = _selectedDate.year.toString();
    return '$d/$m/$y';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          const crossAxisCount = 4;
          const gridPadding = 20.0;
          final totalSpacing = gridPadding * 2 + 0 * (crossAxisCount - 1);
          final itemWidth =
              (constraints.maxWidth - totalSpacing) / crossAxisCount;
          final itemHeight = itemWidth;

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 00),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 5),
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 6),
                  child: CustomText(
                    text: 'Seleccione una fecha',
                    size: 16,
                    fontWeight: FontWeight.w700,
                    color: Color.fromRGBO(55, 73, 87, 1),
                  ),
                ),
                SizedBox(height: 5),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color.fromRGBO(173, 111, 57, 1),
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const CustomText(
                          text: 'Fecha',
                          size: 14,
                          fontWeight: FontWeight.w500,
                          color: Color.fromRGBO(21, 71, 56, 1),
                        ),
                        CustomText(
                          text: _formattedDate,
                          size: 14,
                          fontWeight: FontWeight.w500,
                          color: Color.fromRGBO(21, 71, 56, 1),
                        ),
                        Icon(Icons.arrow_drop_down, size: 25),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: SizedBox(
                    height: 470,
                    child: GridView.builder(
                      padding: const EdgeInsets.only(
                        top: 20,
                        right: 8,
                        left: 8,
                      ),
                      shrinkWrap: true,
                      itemCount: totalPlayers,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 0.0,
                            crossAxisSpacing: 0.0,
                            childAspectRatio: 1.12,
                          ),
                      itemBuilder: (context, index) {
                        final number = index + 1;
                        return _SelectedIcons(
                          index: index,
                          name: playerNames[index],
                          isHighlighted: _highlightedIndex == index,
                          onHoldStart:
                              () => setState(() => _highlightedIndex = index),
                          onHoldEnd:
                              () => setState(() => _highlightedIndex = null),
                          number: number,
                          itemWidth: itemWidth,
                          itemHeight: itemHeight,
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: OnboardingNextButton(
                    text: 'Registrar Asistencia',
                    action: () => context.push('/newPlayerScreen'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SelectedIcons extends StatelessWidget {
  const _SelectedIcons({
    required this.index,
    required this.name,
    required this.isHighlighted,
    required this.onHoldStart,
    required this.onHoldEnd,
    required this.number,
    required this.itemWidth,
    required this.itemHeight,
  });

  final int index;
  final String name;
  final bool isHighlighted;
  final VoidCallback onHoldStart;
  final VoidCallback onHoldEnd;
  final int number;
  final double itemWidth;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTapDown: (_) => onHoldStart(),
          onTapUp: (_) => onHoldEnd(),
          onTapCancel: onHoldEnd,
          child: CustomTshirtIcon(
            number: number,
            width: itemWidth * 0.7,
            height: itemHeight * 0.7,
          ),
        ),
        Positioned(
          top: -6,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: isHighlighted ? 1 : 0,
            child: IgnorePointer(
              ignoring: true,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(217, 73, 41, 1),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: CustomText(
                  text: name,
                  color: Colors.white,
                  size: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
