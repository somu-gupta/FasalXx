import 'package:flutter/material.dart';

import '../screens/notifications_screen.dart';
import '../screens/settings_screen.dart';
import '../theme/app_theme.dart';

class FasalXHeader extends StatelessWidget implements PreferredSizeWidget {
  const FasalXHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(76);

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final fx = context.fx;

    return Material(
      color: Colors.transparent,
      child: Container(
        height: preferredSize.height + topPadding,
        padding: EdgeInsets.fromLTRB(18, topPadding + 10, 18, 12),
        decoration: BoxDecoration(
          color: fx.surfaceAlt,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(22),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            const _BrandMark(),
            const SizedBox(width: 10),
            Text(
              'FasalX',
              style: TextStyle(
                color: fx.textStrong,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
            const Spacer(),
            _HeaderIconButton(
              tooltip: 'Notifications',
              icon: Icons.notifications_none_rounded,
              showBadge: true,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            _HeaderIconButton(
              tooltip: 'Settings',
              icon: Icons.settings_outlined,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: fx.selectedFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: fx.border),
      ),
      child: Icon(
        Icons.eco_rounded,
        color: Theme.of(context).colorScheme.primary,
        size: 28,
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
    this.showBadge = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: fx.fieldFill,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          hoverColor: fx.selectedFill,
          splashColor: fx.selectedFill,
          onTap: onTap,
          child: SizedBox(
            width: 46,
            height: 46,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Icon(icon, color: fx.textStrong, size: 27),
                if (showBadge)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: fx.danger,
                        shape: BoxShape.circle,
                        border: Border.all(color: fx.surface, width: 1.5),
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
