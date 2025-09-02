import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:coach_app/presentation/helpers/responsive.dart';

class CoachScreen extends StatelessWidget {
  static const String name = '/coach_screen';
  const CoachScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Color.fromRGBO(249, 248, 247, 1),
        appBar: CustomAppbar(
          title: 'Coach Dashboard',
          onPressed: () => context.push('/login_screen'),
        ),
        bottomNavigationBar: CustomBottomAppbar(),
        floatingActionButton: CustomFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: const _CoachView(),
      ),
    );
  }
}

class _CoachView extends StatelessWidget {
  const _CoachView();

  @override
  Widget build(BuildContext context) {
    final sidePad = wp(
      context,
      isPhone(context)
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
            : isPhone(context)
            ? wp(context, 0.38)
            : isSmallTablet(context)
            ? wp(context, 0.48)
            : isLargeTablet(context)
            ? wp(context, 0.42)
            : null;
    final nameSize =
        isSmallPhone(context)
            ? ts(context, 19)
            : isPhone(context)
            ? ts(context, 27)
            : isSmallTablet(context)
            ? ts(context, 35)
            : isLargeTablet(context)
            ? ts(context, 52)
            : double.nan;
    final sectionTitleSize = ts(context, 19);
    final asistenciaTitleSize = ts(context, 26);
    final cardW =
        isSmallPhone(context)
            ? wp(context, 0.38)
            : isPhone(context)
            ? wp(context, 0.44)
            : isSmallTablet(context)
            ? wp(context, 0.30)
            : isLargeTablet(context)
            ? wp(context, 0.38)
            : double.nan;
    final cardH =
        isSmallPhone(context)
            ? hp(context, 0.15)
            : isPhone(context)
            ? hp(context, 0.14)
            : isSmallTablet(context)
            ? hp(context, 0.18)
            : isLargeTablet(context)
            ? hp(context, 0.18)
            : double.nan;
    final cardTitleSize =
        isSmallPhone(context)
            ? ts(context, 18)
            : isPhone(context)
            ? ts(context, 25)
            : isSmallTablet(context)
            ? ts(context, 25)
            : isLargeTablet(context)
            ? ts(context, 36)
            : double.nan;
    final cardSubtitleSize =
        isSmallPhone(context)
            ? ts(context, 18)
            : isPhone(context)
            ? ts(context, 20)
            : isSmallTablet(context)
            ? ts(context, 23)
            : isLargeTablet(context)
            ? ts(context, 33)
            : double.nan;
    final cardSpacing =
        isPhone(context)
            ? hp(context, 0.032)
            : isSmallTablet(context)
            ? hp(context, 0.1)
            : isLargeTablet(context)
            ? hp(context, 0.1)
            : hp(context, 0.036);
    final asistenciaPadH = isPhone(context) ? 5.0 : 14.0;
    final asistenciaHeight =
        isSmallPhone(context)
            ? hp(context, 0.28)
            : isPhone(context)
            ? hp(context, 0.128)
            : hp(context, 0.22);
    final actionItemW =
        isPhone(context)
            ? wp(context, 0.34)
            : isSmallTablet(context)
            ? hp(context, 0.18)
            : isLargeTablet(context)
            ? wp(context, 0.24)
            : wp(context, 0.30);
    final actionItemH =
        isPhone(context) ? hp(context, 0.12) : hp(context, 0.12);
    final actionTextSize =
        isPhone(context)
            ? ts(context, 16)
            : isSmallPhone(context)
            ? ts(context, 2)
            : ts(context, 14);
    final actionIconH = isPhone(context) ? 24.0 : 28.0;
    final actionIconW = isPhone(context) ? 27.0 : 31.0;
    final actionGapH =
        isPhone(context)
            ? 30.0
            : isSmallTablet(context)
            ? 46.0
            : isLargeTablet(context)
            ? 56.0
            : 30.0;
    final actionGapW = isPhone(context) ? 22.0 : 16.0;

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
                  Image.asset(
                    'assets/images/coach.png',
                    width: coachImgW,
                    fit: BoxFit.contain,
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
                                : isPhone(context)
                                ? hp(context, 0.014)
                                : isSmallTablet(context)
                                ? hp(context, 0.016)
                                : isLargeTablet(context)
                                ? hp(context, 0.016)
                                : double.nan,
                      ),
                      CustomText(
                        text: 'Jerome Bell',
                        size: nameSize,
                        fontWeight: FontWeight.w900,
                        color: const Color.fromRGBO(11, 25, 38, 1),
                      ),
                      SizedBox(
                        height:
                            isSmallPhone(context)
                                ? hp(context, 0.01)
                                : isPhone(context)
                                ? hp(context, 0.015)
                                : isSmallTablet(context)
                                ? hp(context, 0.025)
                                : isLargeTablet(context)
                                ? hp(context, 0.026)
                                : double.nan,
                      ),
                      CustomButtonCard(
                        width: cardW,
                        height: cardH,
                        titleText: 'Estudiantes',
                        subtitleText: '20',
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
              Wrap(
                spacing: actionGapH,
                runSpacing: actionGapW,
                alignment: WrapAlignment.center,
                children: [
                  SizedBox(
                    width: actionItemW,
                    height: actionItemH,
                    child: CustomActionButton(
                      image: 'assets/images/student-icon.png',
                      text: 'Crear\nEstudiante',
                      textSize: actionTextSize,
                      iconH: actionIconH,
                      iconW: actionIconW,
                      onTap: () => context.push('/new_player_screen'),
                    ),
                  ),
                  SizedBox(
                    width: actionItemW,
                    height: actionItemH,
                    child: CustomActionButton(
                      image: 'assets/images/edit-icon.png',
                      text: 'Editar\nEquipo',
                      textSize: actionTextSize,
                      iconH: actionIconH,
                      iconW: actionIconW,
                      onTap: () => context.push('/my_teams_screen'),
                    ),
                  ),
                  SizedBox(
                    width: actionItemW,
                    height: actionItemH,
                    child: CustomActionButton(
                      image: 'assets/images/calendar-icon.png',
                      text: 'Programar\nPartido',
                      textSize: actionTextSize,
                      iconH: actionIconH,
                      iconW: actionIconW,
                    ),
                  ),
                  SizedBox(
                    width: actionItemW,
                    height: actionItemH,
                    child: CustomActionButton(
                      image: 'assets/images/cup-icon.png',
                      text: 'Torneos',
                      textSize: actionTextSize,
                      iconH: actionIconH,
                      iconW: actionIconW,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height:
                    isSmallPhone(context)
                        ? hp(context, 0.01)
                        : isPhone(context)
                        ? hp(context, 0.014)
                        : isSmallTablet(context)
                        ? hp(context, 0.016)
                        : isLargeTablet(context)
                        ? hp(context, 0.016)
                        : double.nan,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
