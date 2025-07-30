import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const CustomAppbar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Color.fromRGBO(249, 248, 247, 1),
      leadingWidth: 40,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(0),
        child: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_outlined),
        ),
      ),
      titleSpacing: 0,
      title: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      centerTitle: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: SizedBox(
            height: 36,
            width: 90,
            child: Image.asset('assets/images/group5.png', fit: BoxFit.contain),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
