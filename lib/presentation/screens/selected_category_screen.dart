import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';

class SelectedCategoryScreen extends StatelessWidget {
  static const String name = '/selected_category_screen';
  const SelectedCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(249, 248, 247, 1),
      appBar: CustomAppbar(title: 'Categoria seleccionada'),
      bottomNavigationBar: CustomBottomAppbar(),
      floatingActionButton: CustomFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: _SelectedCategoryView(),
    );
  }
}

class _SelectedCategoryView extends StatelessWidget {
  const _SelectedCategoryView();

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
