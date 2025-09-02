import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color? backgroundColor;
  final VoidCallback? onPressed;
  const  CustomAppbar({
    super.key,
    required this.title,
    this.backgroundColor = const Color.fromRGBO(249, 248, 247, 1), 
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      leadingWidth: 40,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(0),
        child: IconButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onPressed: onPressed ?? () => context.pop(),
          icon: Icon(Icons.arrow_back_outlined),
        ),
      ),
      titleSpacing: 0,
      title: CustomText(text: title, size: 20, fontWeight: FontWeight.w600),
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
