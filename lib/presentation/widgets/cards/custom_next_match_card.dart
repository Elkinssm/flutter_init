import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';

class CustomNextMatchCard extends StatelessWidget {
  final String image;
  final String teamName;
  final String date;
  const CustomNextMatchCard({
    super.key,
    required this.image,
    required this.teamName,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 7,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 8,
              children: [
                Padding(
                  padding: EdgeInsets.zero,
                  child: Image.asset(image, width: 90),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: teamName,
                      size: 17,
                      fontWeight: FontWeight.w700,
                    ),
                    SizedBox(height: 10),
                    CustomText(
                      text: date,
                      size: 15,
                      color: Color.fromRGBO(217, 73, 41, 1),
                      fontWeight: FontWeight.w300,
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
