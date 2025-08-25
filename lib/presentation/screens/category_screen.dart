import 'package:coach_app/presentation/screens/selected_category_screen.dart';
import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CategoryScreen extends StatelessWidget {
  static const String name = '/category_screen';
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Color.fromRGBO(249, 248, 247, 1),
        appBar: CustomAppbar(title: 'Categorias'),
        bottomNavigationBar: CustomBottomAppbar(),
        floatingActionButton: CustomFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: const _CategoryView(),
      ),
    );
  }
}

class _CategoryView extends StatefulWidget {
  const _CategoryView();

  @override
  State<_CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<_CategoryView> {
  int? selectedIndex = 1;

  final categories = <Category>[
    Category(2015, 32),
    Category(2014, 27),
    Category(2013, 40),
    Category(2012, 55),
    Category(2011, 36),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: SizedBox(
        width: double.infinity,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(height: 15),
          physics:
              categories.length > 5
                  ? const BouncingScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final c = categories[index];
            final isSelected = selectedIndex == index;
            return CategoryCard(
              year: c.year,
              members: c.members,
              isSelected: isSelected,
              onTapCard: () {
                setState(() => selectedIndex = index);
                Future.delayed(const Duration(milliseconds: 120), () {
                  // ignore: use_build_context_synchronously
                  context.pushNamed(SelectedCategoryScreen.name, extra: c.year);
                });
              },
              onTapAssistance: () {
                context.push('/daily_attendance_screen');
              },
            );
          },
        ),
      ),
    );
  }
}

class Category {
  final int year;
  final int members;
  Category(this.year, this.members);
}
