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
        appBar: CustomAppbar(title: 'Coach Dashboard'),
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
    final sidePad = wp(context, isPhone(context) ? 0.06 : 0.06);
    final coachImgW = isPhone(context) ? wp(context, 0.38) : wp(context, 0.28);
    final nameSize = ts(context, 25);
    final sectionTitleSize = ts(context, 19);
    final asistenciaTitleSize = ts(context, 26);
    final cardW = isPhone(context) ? wp(context, 0.46) : wp(context, 0.30);
    final cardH = isPhone(context) ? hp(context, 0.13) : hp(context, 0.18);
    final cardTitleSize = ts(context, 25);
    final cardSubtitleSize = ts(context, 20);
    final cardSpacing = isPhone(context) ? 28.0 : 16.0;
    final asistenciaPadH = isPhone(context) ? 5.0 : 14.0;
    final asistenciaHeight =
        isPhone(context) ? hp(context, 0.125) : hp(context, 0.15);
    final actionItemW =
        isPhone(context) ? wp(context, 0.34) : wp(context, 0.30);
    final actionItemH =
        isPhone(context) ? hp(context, 0.12) : hp(context, 0.12);
    final actionTextSize = ts(context, 16);
    final actionIconH = isPhone(context) ? 24.0 : 28.0;
    final actionIconW = isPhone(context) ? 27.0 : 31.0;
    final actionGapH = isPhone(context) ? 30.0 : 16.0;
    final actionGapW = isPhone(context) ? 22.0 : 16.0;

    return maxWidthCenter(
      context: context,
      max: 880,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: sidePad),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset(
                  'assets/images/coach.png',
                  width: coachImgW,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: wp(context, 0.04)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: isPhone(context) ? 14 : 16),
                    CustomText(
                      text: 'Jerome Bell',
                      size: nameSize,
                      fontWeight: FontWeight.w900,
                      color: const Color.fromRGBO(11, 25, 38, 1),
                    ),
                    SizedBox(height: isPhone(context) ? 20 : 16),
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
            // SizedBox(height: hp(context, 0.03)),
          ],
        ),
      ),
    );
  }
}
