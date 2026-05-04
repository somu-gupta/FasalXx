import 'package:flutter/material.dart';

class FasalXHeader extends StatelessWidget implements PreferredSizeWidget {
  const FasalXHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(76);

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Material(
      color: Colors.transparent,
      child: Container(
        height: preferredSize.height + topPadding,
        padding: EdgeInsets.fromLTRB(18, topPadding + 10, 18, 12),
        decoration: const BoxDecoration(
          color: Color(0xFFFBFEF8),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
          boxShadow: [
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
            const Text(
              'FasalX',
              style: TextStyle(
                color: Color(0xFF17251A),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Alerts khulenge yahan.')),
                );
              },
            ),
            const SizedBox(width: 8),
            _HeaderIconButton(
              tooltip: 'Settings',
              icon: Icons.settings_outlined,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings khulenge yahan.')),
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
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7E8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD6EED2)),
      ),
      child: const Icon(
        Icons.eco_rounded,
        color: Color(0xFF16823A),
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
    return Tooltip(
      message: tooltip,
      child: Material(
        color: const Color(0xFFF1F6EF),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          hoverColor: const Color(0xFFE5F2E2),
          splashColor: const Color(0xFFD8ECD4),
          onTap: onTap,
          child: SizedBox(
            width: 46,
            height: 46,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Icon(
                  icon,
                  color: const Color(0xFF203426),
                  size: 27,
                ),
                if (showBadge)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
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
