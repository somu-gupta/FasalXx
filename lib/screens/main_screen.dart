import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'health_screen.dart';
import 'profile_screen.dart';
import 'schemes_screen.dart';
import 'store_screen.dart';
import '../widgets/floating_ai_chatbot.dart';
import '../theme/app_theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const _screens = [
    HomeScreen(),
    StoreScreen(),
    HealthScreen(),
    SchemesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: KeyedSubtree(
              key: ValueKey(_selectedIndex),
              child: _screens[_selectedIndex],
            ),
          ),
          if (_selectedIndex == 0) const FloatingAiChatbot(),
        ],
      ),
      bottomNavigationBar: _PremiumBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }
}

class _PremiumBottomNavBar extends StatelessWidget {
  const _PremiumBottomNavBar({
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final fx = context.fx;

    return SizedBox(
      height: 108 + bottomPadding,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: 82 + bottomPadding,
            padding: EdgeInsets.fromLTRB(12, 9, 12, 11 + bottomPadding),
            decoration: BoxDecoration(
              color: fx.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1F000000),
                  blurRadius: 28,
                  offset: Offset(0, -10),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _BottomNavItem(
                    label: 'Dashboard',
                    icon: Icons.dashboard_outlined,
                    selectedIcon: Icons.dashboard_rounded,
                    isActive: selectedIndex == 0,
                    onTap: () => onTap(0),
                  ),
                ),
                Expanded(
                  child: _BottomNavItem(
                    label: 'Store',
                    icon: Icons.storefront_outlined,
                    selectedIcon: Icons.storefront_rounded,
                    isActive: selectedIndex == 1,
                    onTap: () => onTap(1),
                  ),
                ),
                const SizedBox(width: 74),
                Expanded(
                  child: _BottomNavItem(
                    label: 'Schemes',
                    icon: Icons.description_outlined,
                    selectedIcon: Icons.description_rounded,
                    isActive: selectedIndex == 3,
                    badge: '3',
                    onTap: () => onTap(3),
                  ),
                ),
                Expanded(
                  child: _BottomNavItem(
                    label: 'Profile',
                    icon: Icons.person_outline_rounded,
                    selectedIcon: Icons.person_rounded,
                    isActive: selectedIndex == 4,
                    onTap: () => onTap(4),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: -8,
            child: _HealthFab(
              isActive: selectedIndex == 2,
              onTap: () => onTap(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthFab extends StatelessWidget {
  const _HealthFab({required this.isActive, required this.onTap});

  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fx = context.fx;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        scale: isActive ? 1.08 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          width: 74,
          height: 74,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: isActive
                    ? colorScheme.primary.withAlpha(92)
                    : colorScheme.primary.withAlpha(61),
                blurRadius: isActive ? 24 : 18,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: fx.surface, width: 6),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.add_rounded, color: Colors.white, size: 32),
              SizedBox(height: 1),
              Text(
                'Health',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.isActive,
    required this.onTap,
    this.badge,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool isActive;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    final activeColor = fx.bottomNavActive;
    final inactiveColor = fx.bottomNavInactive;

    return Semantics(
      button: true,
      selected: isActive,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          decoration: BoxDecoration(
            color: isActive ? fx.selectedFill : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedScale(
                    duration: const Duration(milliseconds: 180),
                    scale: isActive ? 1.06 : 1,
                    child: Icon(
                      isActive ? selectedIcon : icon,
                      color: isActive ? activeColor : inactiveColor,
                      size: 25,
                    ),
                  ),
                  if (badge != null)
                    Positioned(
                      right: -9,
                      top: -7,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: fx.danger,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: fx.surface, width: 1.5),
                        ),
                        child: Text(
                          badge!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    color: isActive ? activeColor : inactiveColor,
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
