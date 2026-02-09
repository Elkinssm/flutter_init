import 'package:coach_app/config/constants/environment.dart';
import 'package:coach_app/infrastructure/services/coach_api_service.dart';
import 'package:coach_app/infrastructure/services/jugador_api_service.dart';
import 'package:coach_app/presentation/providers/auth_role_provider.dart';
import 'package:coach_app/presentation/screens/selected_category_screen.dart';
import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        appBar: const CustomAppbar(title: 'Categorías'),
        bottomNavigationBar: const CustomBottomAppbar(),
        floatingActionButton: const CustomFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: const _CategoryView(),
      ),
    );
  }
}

class _CategoryItem {
  final int id;
  final int members;
  final String? displayLabel;
  _CategoryItem({required this.id, required this.members, this.displayLabel});
}

class _CategoryView extends ConsumerStatefulWidget {
  const _CategoryView();

  @override
  ConsumerState<_CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends ConsumerState<_CategoryView> {
  int? selectedIndex;

  static final List<_CategoryItem> _localFallback = [
    _CategoryItem(id: 2015, members: 32, displayLabel: '2015'),
    _CategoryItem(id: 2014, members: 27, displayLabel: '2014'),
    _CategoryItem(id: 2013, members: 40, displayLabel: '2013'),
    _CategoryItem(id: 2012, members: 55, displayLabel: '2012'),
    _CategoryItem(id: 2011, members: 36, displayLabel: '2011'),
  ];

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(currentUserRoleProvider);
    final isCoach = role == 'coach';
    final jugadorAsync = ref.watch(jugadorCategoriasProvider);
    final coachAsync = ref.watch(coachCategoriasProvider);

    final async = isCoach ? coachAsync : jugadorAsync;
    List<_CategoryItem> items = _localFallback;
    if (Environment.useBackend && async.hasValue && async.value != null) {
      final data = async.value!;
      final list = data['categorias'] as List<dynamic>? ?? [];
      items = list.map((e) {
        final m = e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{};
        final id = m['id'] is int ? m['id'] as int : int.tryParse(m['id']?.toString() ?? '0') ?? 0;
        final members = m['jugadores_count'] is int ? m['jugadores_count'] as int : int.tryParse(m['jugadores_count']?.toString() ?? '0') ?? 0;
        final label = m['categoria']?.toString() ?? m['nombre']?.toString() ?? '$id';
        return _CategoryItem(id: id, members: members, displayLabel: label);
      }).toList();
      if (items.isEmpty) items = _localFallback;
    }

    if (async.isLoading && items == _localFallback) {
      return const Center(child: CircularProgressIndicator());
    }

    if (async.hasError && Environment.useBackend) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No se pudieron cargar las categorías',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () {
                ref.invalidate(isCoach ? coachCategoriasProvider : jugadorCategoriasProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 15),
        physics: items.length > 5 ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final c = items[index];
          final isSelected = selectedIndex == index;
          return CategoryCard(
            year: c.id,
            members: c.members,
            isSelected: isSelected,
            displayLabel: c.displayLabel,
            onTapCard: () {
              setState(() => selectedIndex = index);
              Future.delayed(const Duration(milliseconds: 120), () {
                if (!context.mounted) return;
                context.pushNamed(SelectedCategoryScreen.name, extra: c.id);
              });
            },
            onTapAssistance: () {
              context.push('/daily_attendance_screen', extra: c.id);
            },
          );
        },
      ),
    );
  }
}
