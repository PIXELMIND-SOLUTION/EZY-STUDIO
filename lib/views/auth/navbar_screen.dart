import 'package:edit_ezy_project/providers/navbar/navbar_provider.dart';
import 'package:edit_ezy_project/views/home/category_screen.dart';
import 'package:edit_ezy_project/views/home/coming_soon_screen.dart';
import 'package:edit_ezy_project/views/home/customer_screen.dart';
import 'package:edit_ezy_project/views/home/home_screen.dart';
import 'package:edit_ezy_project/views/home/horror_scope_screen.dart';
import 'package:edit_ezy_project/views/home/poster_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class NavbarScreen extends StatefulWidget {
  const NavbarScreen({super.key});

  @override
  State<NavbarScreen> createState() => _NavbarScreenState();
}

class _NavbarScreenState extends State<NavbarScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final List<NavBarItemData> _navItems = [
    NavBarItemData(
      icon: Icons.home_rounded,
      activeIcon: Icons.home,
      label: 'Home',
      gradient: const LinearGradient(
        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    NavBarItemData(
      icon: Icons.grid_view_rounded,
      activeIcon: Icons.grid_view,
      label: 'Category',
      gradient: const LinearGradient(
        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    NavBarItemData(
      icon: Icons.auto_awesome_outlined,
      activeIcon: Icons.auto_awesome,
      label: 'Scope',
      gradient: const LinearGradient(
        colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    NavBarItemData(
      icon: Icons.edit_outlined,
      activeIcon: Icons.edit,
      label: 'Create',
      gradient: const LinearGradient(
        colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    NavBarItemData(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person,
      label: 'Customer',
      gradient: const LinearGradient(
        colors: [Color(0xFFFA8BFF), Color(0xFF2BD2FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomNavbarProvider = Provider.of<BottomNavbarProvider>(context);

    final pages = [
      const HomeScreen(),
      const CategoryScreen(),
      ComingSoonScreen(),
      // const HoroscopeScreen(),
      const PosterScreen(),
      const CustomerScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: pages[bottomNavbarProvider.currentIndex],
      ),
      bottomNavigationBar: _buildModernBottomNavigationBar(bottomNavbarProvider),
    );
  }

  Widget _buildModernBottomNavigationBar(BottomNavbarProvider provider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    
    // Adjust margins based on screen width
    final horizontalMargin = screenWidth > 400 ? 20.0 : 16.0;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      transform: Matrix4.translationValues(
        0,
        keyboardHeight > 0 ? keyboardHeight : 0,
        0,
      ),
      child: Container(
        margin: EdgeInsets.only(
          left: horizontalMargin,
          right: horizontalMargin,
          bottom: keyboardHeight > 0 ? 8 : (bottomPadding > 0 ? bottomPadding + 8 : 20),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 40,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: IntrinsicHeight(
            child: Container(
              constraints: const BoxConstraints(
                minHeight: 70,
                maxHeight: 90,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _navItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isSelected = provider.currentIndex == index;
                  
                  return Flexible(
                    flex: 1,
                    child: _buildNavItem(
                      item: item,
                      isSelected: isSelected,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        provider.setIndex(index);
                        _animationController.reset();
                        _animationController.forward();
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required NavBarItemData item,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isSelected ? item.gradient : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with animation
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: isSelected ? _scaleAnimation.value : 1.0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isSelected 
                        ? Colors.white.withOpacity(0.2)
                        : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isSelected ? item.activeIcon : item.icon,
                      size: isSelected ? 24 : 22,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 3),
            
            // Label with fade animation and overflow protection
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: isSelected ? _fadeAnimation.value : 0.7,
                  child: Text(
                    item.label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                      fontSize: isSelected ? 10 : 9,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      letterSpacing: 0.2,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class NavBarItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Gradient gradient;

  NavBarItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.gradient,
  });
}

// Enhanced Bottom Navbar Provider with additional features
class EnhancedBottomNavbarProvider extends ChangeNotifier {
  int _currentIndex = 0;
  bool _isAnimating = false;

  int get currentIndex => _currentIndex;
  bool get isAnimating => _isAnimating;

  void setIndex(int index) {
    if (_currentIndex == index || _isAnimating) return;
    
    _isAnimating = true;
    _currentIndex = index;
    notifyListeners();
    
    // Reset animation flag after animation completes
    Future.delayed(const Duration(milliseconds: 300), () {
      _isAnimating = false;
      notifyListeners();
    });
  }

  void resetToHome() {
    setIndex(0);
  }
}