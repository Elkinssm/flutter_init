import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// TshirtStatus is re-exported by widgets.dart

enum _BatchAction { allPresent, allAbsent }

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
  final Map<int, TshirtStatus> _status = <int, TshirtStatus>{};
  bool _assetsPrecached = false;

  @override
  void initState() {
    super.initState();
    // Estado inicial: todos ausentes (amarillo)
    for (var i = 0; i < totalPlayers; i++) {
      _status[i] = TshirtStatus.absent;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precarga de assets para evitar parpadeos/jank al mostrar íconos
    if (!_assetsPrecached) {
      _precacheTshirtIcons(context);
      _assetsPrecached = true;
    }
  }

  Future<void> _precacheTshirtIcons(BuildContext context) async {
    const assets = [
      'assets/images/tshirt-icon-green.png',
      'assets/images/tshirt-icon-yellow.png',
      'assets/images/tshirt-icon-blue.png',
    ];
    for (final path in assets) {
      await precacheImage(AssetImage(path), context);
    }
  }

  Future<void> _pickDate() async {
    const brand = Color.fromRGBO(217, 73, 41, 1);

    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      locale: const Locale('es', 'CO'),
      confirmText: 'aceptar',
      builder: (context, child) {
        final base = Theme.of(context);
        return Theme(
          data: base.copyWith(
            // Colores base del date picker
            colorScheme: base.colorScheme.copyWith(
              primary: brand, // afecta selección, encabezado, etc.
              onPrimary: Colors.white, // texto/íconos sobre primary
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
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
          final presentCount =
              _status.values.where((s) => s == TshirtStatus.present).length;
          final allPresent = _status.values.every(
            (s) => s == TshirtStatus.present,
          );
          final allAbsent = _status.values.every(
            (s) => s == TshirtStatus.absent,
          );
          const crossAxisCount = 4;
          const gridPadding = 20.0;
          final totalSpacing = gridPadding * 2 + 0 * (crossAxisCount - 1);
          final itemWidth =
              (constraints.maxWidth - totalSpacing) / crossAxisCount;
          final itemHeight = itemWidth;

          return RepaintBoundary(
            child: Padding(
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
                Expanded(
                  child: RepaintBoundary(
                    child: GridView.builder(
                    padding: const EdgeInsets.only(
                      top: 20,
                      right: 8,
                      left: 8,
                      bottom: 8,
                    ),
                    itemCount: totalPlayers,
                    physics: const BouncingScrollPhysics(),
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
                        status: _status[index] ?? TshirtStatus.none,
                        onHoldStart:
                            () => setState(() => _highlightedIndex = index),
                        onHoldEnd:
                            () => setState(() => _highlightedIndex = null),
                        onTap: () {
                          setState(() {
                            final current =
                                _status[index] ?? TshirtStatus.absent;
                            _status[index] =
                                current == TshirtStatus.present
                                    ? TshirtStatus.absent
                                    : TshirtStatus.present;
                          });
                        },
                        number: number,
                        itemWidth: itemWidth,
                        itemHeight: itemHeight,
                      );
                    },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const CustomText(
                      text: 'Asistencia',
                      size: 16,
                      fontWeight: FontWeight.w700,
                      color: Color.fromRGBO(55, 73, 87, 1),
                    ),
                    const Spacer(),
                    CustomText(
                      text: '$presentCount/$totalPlayers',
                      size: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color.fromRGBO(21, 71, 56, 1),
                    ),
                    const SizedBox(width: 4),
                    PopupMenuButton<_BatchAction>(
                      tooltip: 'Acciones',
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        setState(() {
                          switch (value) {
                            case _BatchAction.allPresent:
                              for (var i = 0; i < totalPlayers; i++) {
                                _status[i] = TshirtStatus.present;
                              }
                              break;
                            case _BatchAction.allAbsent:
                              for (var i = 0; i < totalPlayers; i++) {
                                _status[i] = TshirtStatus.absent;
                              }
                              break;
                          }
                        });
                      },
                      itemBuilder:
                          (context) => [
                            PopupMenuItem<_BatchAction>(
                              value: _BatchAction.allPresent,
                              enabled: !allPresent,
                              child: const ListTile(
                                leading: Icon(Icons.done_all),
                                title: Text('Todos presentes'),
                                dense: true,
                              ),
                            ),
                            PopupMenuItem<_BatchAction>(
                              value: _BatchAction.allAbsent,
                              enabled: !allAbsent,
                              child: const ListTile(
                                leading: Icon(Icons.clear),
                                title: Text('Todos ausentes'),
                                dense: true,
                              ),
                            ),
                          ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Acciones ahora están integradas en el menú de la fila superior
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: presentCount / totalPlayers,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color.fromRGBO(21, 71, 56, 1),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: OnboardingNextButton(
                    text: 'Registrar Asistencia',
                    isEnabled: presentCount > 0,
                    action: () => context.push('/new_player_screen'),
                  ),
                ),
                // Leave room so the FAB/bottom bar doesn't overlap the CTA
                const SizedBox(height: 30),
              ],
            ),
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
    required this.onTap,
    required this.status,
    required this.number,
    required this.itemWidth,
    required this.itemHeight,
  });

  final int index;
  final String name;
  final bool isHighlighted;
  final VoidCallback onHoldStart;
  final VoidCallback onHoldEnd;
  final VoidCallback onTap;
  final TshirtStatus status;
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
          onTap: onTap,
          onTapCancel: onHoldEnd,
          child: CustomTshirtIcon(
            number: number,
            width: itemWidth * 0.7,
            height: itemHeight * 0.7,
            status: status,
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
