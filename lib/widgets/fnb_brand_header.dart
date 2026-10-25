import 'package:flutter/material.dart';

const Color fnbTeal = Color(0xff00a8b5);
const Color fnbPaleTeal = Color(0xffc9f3f5);
const Color fnbSoft = Color(0xfff6f8f8);
const Color fnbDark = Color(0xff111111);

class FnbBrandHeader extends StatelessWidget implements PreferredSizeWidget {
  const FnbBrandHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = true,
    this.actions,
  });

  final String title;
  final String? subtitle;
  final bool showBackButton;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: fnbDark),
              onPressed: () => Navigator.of(context).maybePop(),
            )
          : null,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: fnbDark,
              letterSpacing: -0.2,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: const TextStyle(fontSize: 10, color: Colors.black54),
            ),
          ],
        ],
      ),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: const Color(0xffe2eeee), height: 1),
      ),
    );
  }
}
