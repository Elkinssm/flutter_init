import 'package:coach_app/infrastructure/services/dashboard_service.dart';
import 'package:coach_app/presentation/helpers/responsive.dart';
import 'package:coach_app/presentation/providers/profile_incomplete_provider.dart';
import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CoachScreen extends StatefulWidget {
  static const String name = '/coach_screen';
  const CoachScreen({super.key});

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Retrasar precache para no competir con la primera pintada (evita bloqueos/crash).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        precacheImage(
          const AssetImage('assets/images/student-icon.png'),
          context,
        );
        precacheImage(const AssetImage('assets/images/edit-icon.png'), context);
        precacheImage(
          const AssetImage('assets/images/calendar-icon.png'),
          context,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        if (ref.watch(openProfileDrawerProvider)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(openProfileDrawerProvider.notifier).state = false;
            _scaffoldKey.currentState?.openEndDrawer();
          });
        }
        return SafeArea(
          top: false,
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: const Color.fromRGBO(249, 248, 247, 1),
            appBar: CustomAppbar(
              title: 'Coach Dashboard',
              onPressed: () => context.push('/login_screen'),
            ),
            endDrawer: const ProfileDrawer(),
            bottomNavigationBar: const CustomBottomAppbar(),
            floatingActionButton: const CustomFloatingActionButton(),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            body: const _CoachView(),
          ),
        );
      },
    );
  }
}

class _CoachView extends ConsumerWidget {
  const _CoachView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(coachDashboardProvider);

    if (dashboardAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Mostrar error si falla
    if (dashboardAsync.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error al cargar: ${dashboardAsync.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(coachDashboardProvider),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final dashboard = dashboardAsync.valueOrNull;
    final coachData = dashboard?['coach'] ?? dashboard?['entrenador'];
    final coachName = coachData is Map ? coachData['nombre']?.toString() : null;
    final resumen = dashboard?['resumen'] as Map<String, dynamic>?;
    final totalJugadores = resumen?['total_jugadores']?.toString() ?? '0';
    final sidePad = wp(
      context,
      isPhone(context) || isBigPhone(context)
          ? 0.06
          : isSmallTablet(context)
          ? 0.06
          : isLargeTablet(context)
          ? 0.001
          : 0.01,
    );
    final coachImgW =
        isSmallPhone(context)
            ? wp(context, 0.34)
            : isPhone(context) || isBigPhone(context)
            ? wp(context, 0.38)
            : isSmallTablet(context)
            ? wp(context, 0.48)
            : isLargeTablet(context)
            ? wp(context, 0.42)
            : wp(context, 0.38); // fallback
    final nameSize =
        isSmallPhone(context)
            ? ts(context, 19)
            : isPhone(context) || isBigPhone(context)
            ? ts(context, 27)
            : isSmallTablet(context)
            ? ts(context, 35)
            : isLargeTablet(context)
            ? ts(context, 52)
            : ts(context, 27); // fallback
    final sectionTitleSize = ts(context, 19);
    final asistenciaTitleSize = ts(context, 26);
    final cardW =
        isSmallPhone(context)
            ? wp(context, 0.38)
            : isPhone(context) || isBigPhone(context)
            ? wp(context, 0.44)
            : isSmallTablet(context)
            ? wp(context, 0.30)
            : isLargeTablet(context)
            ? wp(context, 0.38)
            : wp(context, 0.44); // fallback
    final cardH =
        isSmallPhone(context)
            ? hp(context, 0.15)
            : isPhone(context) || isBigPhone(context)
            ? hp(context, 0.14)
            : isSmallTablet(context)
            ? hp(context, 0.18)
            : isLargeTablet(context)
            ? hp(context, 0.18)
            : hp(context, 0.14); // fallback
    final cardTitleSize =
        isSmallPhone(context)
            ? ts(context, 18)
            : isPhone(context) || isBigPhone(context)
            ? ts(context, 25)
            : isSmallTablet(context)
            ? ts(context, 25)
            : isLargeTablet(context)
            ? ts(context, 36)
            : ts(context, 25); // fallback
    final cardSubtitleSize =
        isSmallPhone(context)
            ? ts(context, 18)
            : isPhone(context) || isBigPhone(context)
            ? ts(context, 20)
            : isSmallTablet(context)
            ? ts(context, 23)
            : isLargeTablet(context)
            ? ts(context, 33)
            : ts(context, 20); // fallback
    final cardSpacing =
        isPhone(context) || isBigPhone(context)
            ? hp(context, 0.032)
            : isSmallTablet(context)
            ? hp(context, 0.1)
            : isLargeTablet(context)
            ? hp(context, 0.1)
            : hp(context, 0.036);
    final asistenciaPadH = isPhone(context) || isBigPhone(context) ? 5.0 : 14.0;
    final asistenciaHeight =
        isSmallPhone(context)
            ? hp(context, 0.28)
            : isPhone(context) || isBigPhone(context)
            ? hp(context, 0.128)
            : hp(context, 0.22);
    final actionItemH =
        isPhone(context) || isBigPhone(context)
            ? hp(context, 0.12)
            : hp(context, 0.12);
    final actionTextSize =
        isPhone(context) || isBigPhone(context)
            ? ts(context, 16)
            : isSmallPhone(context)
            ? ts(context, 2)
            : ts(context, 14);
    final actionIconH = isPhone(context) || isBigPhone(context) ? 24.0 : 28.0;
    final actionIconW = isPhone(context) || isBigPhone(context) ? 27.0 : 31.0;
    final actionGapW = isPhone(context) || isBigPhone(context) ? 22.0 : 16.0;

    return SingleChildScrollView(
      child: maxWidthCenter(
        context: context,
        max: 880,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: sidePad),
          child: Column(
            children: [
              SizedBox(height: isPhone(context) ? 0 : hp(context, 0.01)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    child: Image.asset(
                      'assets/images/coach.png',
                      width: coachImgW,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(
                    width:
                        isPhone(context)
                            ? wp(context, 0.04)
                            : wp(context, 0.01),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height:
                            isSmallPhone(context)
                                ? hp(context, 0.01)
                                : isPhone(context) || isBigPhone(context)
                                ? hp(context, 0.014)
                                : isSmallTablet(context)
                                ? hp(context, 0.016)
                                : isLargeTablet(context)
                                ? hp(context, 0.016)
                                : hp(context, 0.014),
                      ),
                      CustomText(
                        text: coachName ?? 'Jerome Bell',
                        size: nameSize,
                        fontWeight: FontWeight.w900,
                        color: const Color.fromRGBO(11, 25, 38, 1),
                      ),
                      SizedBox(
                        height:
                            isSmallPhone(context)
                                ? hp(context, 0.01)
                                : isPhone(context) || isBigPhone(context)
                                ? hp(context, 0.015)
                                : isSmallTablet(context)
                                ? hp(context, 0.025)
                                : isLargeTablet(context)
                                ? hp(context, 0.026)
                                : hp(context, 0.015),
                      ),
                      CustomButtonCard(
                        width: cardW,
                        height: cardH,
                        titleText: 'Estudiantes',
                        subtitleText: totalJugadores,
                        titleTextSize: cardTitleSize,
                        subtitleTextSize: cardSubtitleSize,
                        spacing: cardSpacing,
                        onTap: () => context.push('/category_screen'),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: hp(context, 0.02)),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: wp(context, 0.02),
                  vertical: asistenciaPadH,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color.fromRGBO(229, 240, 246, 1),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 4),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () => context.push('/daily_attendance_screen'),
                  child: Column(
                    children: [
                      SizedBox(height: isPhone(context) ? 4 : 2),
                      CustomText(
                        text: 'Asistencia',
                        fontWeight: FontWeight.w900,
                        size: asistenciaTitleSize,
                        color: const Color.fromRGBO(11, 25, 38, 1),
                      ),
                      // SizedBox(height: hp(context, 0.01)),
                      SizedBox(
                        height: asistenciaHeight,
                        child: const AssistanceBarChart(),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: hp(context, 0.02)),
              Container(
                margin: EdgeInsets.symmetric(horizontal: wp(context, 0.012)),
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 4,
                      offset: Offset(3, 4),
                    ),
                  ],
                  color: Colors.black,
                ),
                height: 3,
              ),
              SizedBox(height: hp(context, 0.013)),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: wp(context, 0.02)),
                  child: CustomText(
                    text: 'Acciones rápidas',
                    fontWeight: FontWeight.w700,
                    size: sectionTitleSize,
                    color: const Color.fromRGBO(11, 25, 38, 1),
                  ),
                ),
              ),
              SizedBox(height: hp(context, 0.018)),
              // Primera fila: 2 botones
              Padding(
                padding: EdgeInsets.symmetric(horizontal: wp(context, 0.02)),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: actionItemH,
                        child: CustomActionButton(
                          image: 'assets/images/student-icon.png',
                          text: 'Crear\nEstudiante',
                          textSize: actionTextSize,
                          iconH: actionIconH,
                          iconW: actionIconW,
                          onTap: () => context.push('/new_player_screen'),
                          isDisabled: false,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: actionItemH,
                        child: CustomActionButton(
                          image: 'assets/images/edit-icon.png',
                          text: 'Editar\nEquipo',
                          textSize: actionTextSize,
                          iconH: actionIconH,
                          iconW: actionIconW,
                          onTap: () => context.push('/my_teams_screen'),
                          isDisabled: false,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: actionGapW),
              // Segunda fila: botón ancho completo
              Padding(
                padding: EdgeInsets.symmetric(horizontal: wp(context, 0.02)),
                child: SizedBox(
                  width: double.infinity,
                  height: actionItemH,
                  child: CustomActionButton(
                    image: 'assets/images/calendar-icon.png',
                    text: 'Programar Partido',
                    textSize: actionTextSize,
                    iconH: actionIconH,
                    iconW: actionIconW,
                    onTap: () => context.push('/new_match_screen'),
                    isDisabled: false,
                  ),
                ),
              ),
              SizedBox(
                height:
                    isSmallPhone(context)
                        ? hp(context, 0.01)
                        : isPhone(context) || isBigPhone(context)
                        ? hp(context, 0.014)
                        : isSmallTablet(context)
                        ? hp(context, 0.016)
                        : isLargeTablet(context)
                        ? hp(context, 0.016)
                        : hp(context, 0.014),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
