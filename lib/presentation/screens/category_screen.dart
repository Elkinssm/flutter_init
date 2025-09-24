import 'package:coach_app/presentation/screens/selected_category_screen.dart';
import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CategoryScreen extends StatefulWidget {
  static const String name = '/category_screen';
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Precarga de íconos usados en esta vista
      precacheImage(const AssetImage('assets/images/group14.png'), context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        extendBody: true,
        backgroundColor: const Color.fromRGBO(249, 248, 247, 1),
        appBar: const CustomAppbar(title: 'Categorias'),
        bottomNavigationBar: const CustomBottomAppbar(),
        floatingActionButton: const CustomFloatingActionButton(),
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
                  context.pushNamed(
                    SelectedCategoryScreen.name,
                    extra: c.year.toInt(),
                  );
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
