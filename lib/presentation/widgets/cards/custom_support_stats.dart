import 'package:Coach_App/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomSupportStats extends StatelessWidget {
  const CustomSupportStats({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/assistance_screen'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Card(
          color: const Color.fromRGBO(245, 240, 230, 1),
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(
              color: Color.fromRGBO(212, 175, 55, 1),
              width: 1,
            ),
          ),
          child: SizedBox(
            height: 80,
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: Colors.amber.shade700,
                          width: 1,
                        ),
                      ),
                    ),
                    child: CustomText(
                      text: 'Asistencia',
                      fontWeight: FontWeight.bold,
                      size: 18,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: Color.fromRGBO(212, 175, 55, 1),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomText(
                          text: 'Total',
                          fontWeight: FontWeight.bold,
                          size: 16,
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Container(
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: const Color.fromRGBO(20, 31, 44, 1),
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.all(2),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: LinearProgressIndicator(
                                value: 0.7, // Valor de la barra
                                backgroundColor: Colors.transparent,
                                color: const Color.fromRGBO(20, 31, 44, 1),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: CustomText(
                      text: '90%',
                      fontWeight: FontWeight.bold,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
