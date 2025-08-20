import 'dart:ui';
import 'package:edit_ezy_project/models/category_model.dart';
import 'package:edit_ezy_project/providers/language/language_provider.dart';
import 'package:edit_ezy_project/providers/plans/getall_plan_provider.dart';
import 'package:edit_ezy_project/providers/plans/my_plan_provider.dart';
import 'package:edit_ezy_project/providers/posters/getall_poster_provider.dart';
import 'package:edit_ezy_project/views/home/detail_screen.dart';
import 'package:edit_ezy_project/views/home/search_screen.dart';
import 'package:edit_ezy_project/views/poster/poster_making_screen.dart';
import 'package:edit_ezy_project/views/subscriptions/animated_plan_listscreen.dart';
import 'package:edit_ezy_project/views/subscriptions/plandetail_payment_screen.dart';
import 'package:edit_ezy_project/widgets/modal_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> with SingleTickerProviderStateMixin {
  String? posterId;
  String? plan;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Fetch all posters data at once instead of by category
    Future.microtask(() {
      Provider.of<PosterProvider>(context, listen: false).fetchPosters();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (Navigator.canPop(context)) {
      return true;
    } else {
      return await _showExitConfirmation();
    }
  }

  Future<bool> _showExitConfirmation() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.white,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.exit_to_app,
                    color: Colors.red.shade400,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Exit App',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            content: const Text(
              'Are you sure you want to exit the app?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => SystemNavigator.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Exit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final bool isTablet = screenWidth > 600;

    // Responsive design values
    final double horizontalPadding = isTablet ? 32.0 : 20.0;
    final double verticalPadding = isTablet ? 24.0 : 16.0;
    final double itemWidth = isTablet ? 180 : 140;
    final double itemHeight = isTablet ? 160 : 120;
    final double titleFontSize = isTablet ? 32 : 28;
    final double sectionTitleSize = isTablet ? 22 : 18;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Consumer<PosterProvider>(
            builder: (context, posterProvider, child) {
              if (posterProvider.isLoading) {
                return _buildLoadingState(itemWidth, itemHeight, horizontalPadding);
              }

              if (posterProvider.error != null) {
                return _buildErrorState(posterProvider);
              }

              final List<String> uniqueCategories = _extractUniqueCategories(posterProvider.posters);

              if (uniqueCategories.isEmpty) {
                return _buildEmptyState();
              }

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Custom App Bar
                  _buildSliverAppBar(titleFontSize, horizontalPadding),
                  
                  // Welcome Section
                  // SliverToBoxAdapter(
                  //   child: _buildWelcomeSection(horizontalPadding),
                  // ),

                  // Categories
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final category = uniqueCategories[index];
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 300 + (index * 100)),
                          curve: Curves.easeOutCubic,
                          margin: EdgeInsets.only(
                            left: horizontalPadding,
                            right: horizontalPadding,
                            bottom: 24,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildModernSectionHeader(
                                _capitalizeFirstLetter(category),
                                context,
                                sectionTitleSize,
                                category,
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: itemHeight + 40,
                                child: _buildCategoryItemsList(
                                  context,
                                  category,
                                  itemWidth,
                                  itemHeight,
                                  posterProvider.posters,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      childCount: uniqueCategories.length,
                    ),
                  ),
                  
                  // Bottom padding
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 40),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(double titleFontSize, double horizontalPadding) {
    return SliverAppBar(
      expandedHeight: 100,
      floating: true,
      automaticallyImplyLeading: false,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Text(
                      //   'Explore',
                      //   style: TextStyle(
                      //     fontSize: titleFontSize,
                      //     fontWeight: FontWeight.w700,
                      //     color: Colors.black87,
                      //     letterSpacing: -0.5,
                      //   ),
                      // ),
                      Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: titleFontSize * 0.9,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        _buildActionButton(
          icon: Icons.search_rounded,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SearchScreen()),
          ),
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.blue.shade600],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required Gradient gradient,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: gradient.colors.first.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildWelcomeSection(double horizontalPadding) {
  //   return Container(
  //     margin: EdgeInsets.symmetric(
  //       horizontal: horizontalPadding,
  //       vertical: 20,
  //     ),
  //     padding: const EdgeInsets.all(24),
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //         colors: [
  //           Colors.purple.shade400,
  //           Colors.blue.shade500,
  //         ],
  //       ),
  //       borderRadius: BorderRadius.circular(20),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.purple.withOpacity(0.3),
  //           blurRadius: 20,
  //           offset: const Offset(0, 10),
  //         ),
  //       ],
  //     ),
  //     child: Row(
  //       children: [
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               const Text(
  //                 'Create Amazing',
  //                 style: TextStyle(
  //                   fontSize: 22,
  //                   fontWeight: FontWeight.w700,
  //                   color: Colors.white,
  //                 ),
  //               ),
  //               const SizedBox(height: 4),
  //               Text(
  //                 'Professional Posters',
  //                 style: TextStyle(
  //                   fontSize: 16,
  //                   color: Colors.white.withOpacity(0.9),
  //                   fontWeight: FontWeight.w400,
  //                 ),
  //               ),
  //               const SizedBox(height: 16),
  //               Container(
  //                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //                 decoration: BoxDecoration(
  //                   color: Colors.white.withOpacity(0.2),
  //                   borderRadius: BorderRadius.circular(20),
  //                   border: Border.all(
  //                     color: Colors.white.withOpacity(0.3),
  //                   ),
  //                 ),
  //                 child: const Text(
  //                   'Get Started',
  //                   style: TextStyle(
  //                     color: Colors.white,
  //                     fontWeight: FontWeight.w600,
  //                     fontSize: 14,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         Container(
  //           padding: const EdgeInsets.all(16),
  //           decoration: BoxDecoration(
  //             color: Colors.white.withOpacity(0.1),
  //             borderRadius: BorderRadius.circular(16),
  //           ),
  //           child: const Icon(
  //             Icons.design_services_rounded,
  //             color: Colors.white,
  //             size: 32,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildModernSectionHeader(String title, BuildContext context, double fontSize, String category) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.purple.shade400, Colors.blue.shade500],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: -0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Consumer<MyPlanProvider>(
          builder: (context, myPlanProvider, _) {
            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  if (myPlanProvider.isPurchase == true) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailsScreen(category: category),
                      ),
                    );
                  } else {
                    CommonModal.showWarning(
                      context: context,
                      title: "Premium Category",
                      message: "This category contains premium content. Upgrade to premium to access exclusive templates and features!",
                      primaryButtonText: "Upgrade Now",
                      secondaryButtonText: "Cancel",
                      onPrimaryPressed: () => showSubscriptionModal(context),
                      onSecondaryPressed: () => Navigator.of(context).pop(),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'View All',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLoadingState(double itemWidth, double itemHeight, double horizontalPadding) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header shimmer
          Container(
            height: 100,
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 150,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Welcome section shimmer
          Container(
            margin: EdgeInsets.all(horizontalPadding),
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          
          // Categories shimmer
          ...List.generate(3, (index) => 
            Container(
              margin: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 12),
              child: Column(
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 120,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Container(
                          width: 80,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: itemHeight + 40,
                    child: _buildShimmerLoading(itemWidth, itemHeight),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(PosterProvider posterProvider) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: Colors.red.shade400,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'We couldn\'t load the categories right now',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => posterProvider.fetchPosters(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade500,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(
                'Try Again',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.category_outlined,
                color: Colors.grey.shade400,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Categories Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Categories will appear here once they\'re available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Extract unique categories from the posters list
  List<String> _extractUniqueCategories(List<dynamic> posters) {
    final Set<String> categories = {};
    for (var poster in posters) {
      if (poster is CategoryModel && poster.categoryName.isNotEmpty) {
        categories.add(poster.categoryName);
      }
    }
    return categories.toList();
  }

  // Get posters for a specific category
  List<CategoryModel> _getPostersByCategory(String category, List<dynamic> allPosters) {
    return allPosters
        .where((poster) =>
            poster is CategoryModel &&
            poster.categoryName.toLowerCase() == category.toLowerCase())
        .cast<CategoryModel>()
        .toList();
  }

  void showSubscriptionModal(BuildContext context) async {
    final myPlanProvider = Provider.of<MyPlanProvider>(context, listen: false);

    if (myPlanProvider.isPurchase == true) {
      return;
    }

    final planProvider = Provider.of<GetAllPlanProvider>(context, listen: false);
    if (planProvider.plans.isEmpty && !planProvider.isLoading) {
      planProvider.fetchAllPlans();
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Subscription Modal',
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 4 * animation.value,
            sigmaY: 4 * animation.value,
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.8,
                end: 1.0,
              ).animate(curvedAnimation),
              child: FadeTransition(
                opacity: Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                ).animate(curvedAnimation),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.85,
                      maxWidth: 500,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF8E2DE2),
                                  Color(0xFF4A00E0),
                                ],
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                                horizontal: 20.0,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.workspace_premium,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      'Choose Plan',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(30),
                                      onTap: () => Navigator.pop(context),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Flexible(
                            child: Consumer<GetAllPlanProvider>(
                              builder: (context, provider, child) {
                                if (provider.isLoading) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          width: 40,
                                          height: 40,
                                          child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              Color(0xFF8E2DE2),
                                            ),
                                            strokeWidth: 3,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Loading plans...',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                if (provider.error != null) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            color: Colors.red.shade400,
                                            size: 60,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Failed to load plans',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red.shade400,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Please try again later',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          ElevatedButton.icon(
                                            onPressed: () => provider.fetchAllPlans(),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF8E2DE2),
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 12,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(30),
                                              ),
                                            ),
                                            icon: const Icon(Icons.refresh),
                                            label: const Text('Try Again'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                if (provider.plans.isNotEmpty) {
                                  return AnimatedPlanList(
                                    plans: provider.plans,
                                    onPlanSelected: (plan) {
                                      Navigator.of(context).pop();
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation, secondaryAnimation) =>
                                              PlanDetailsAndPaymentScreen(plan: plan),
                                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                            const begin = Offset(1.0, 0.0);
                                            const end = Offset.zero;
                                            const curve = Curves.easeOutCubic;

                                            var tween = Tween(begin: begin, end: end)
                                                .chain(CurveTween(curve: curve));
                                            var offsetAnimation = animation.drive(tween);

                                            return SlideTransition(
                                              position: offsetAnimation,
                                              child: FadeTransition(
                                                opacity: animation,
                                                child: child,
                                              ),
                                            );
                                          },
                                          transitionDuration: const Duration(milliseconds: 500),
                                        ),
                                      );
                                    },
                                  );
                                }

                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.subscriptions,
                                        size: 60,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No subscription plans available',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryItemsList(
    BuildContext context,
    String category,
    double itemWidth,
    double itemHeight,
    List<dynamic> allPosters,
  ) {
    final List<CategoryModel> categoryPosters = _getPostersByCategory(category, allPosters);

    if (categoryPosters.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported_outlined,
                color: Colors.grey.shade400,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                "No items available",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      itemCount: categoryPosters.length,
      itemBuilder: (context, index) {
        final item = categoryPosters[index];
        return AnimatedContainer(
          duration: Duration(milliseconds: 200 + (index * 50)),
          curve: Curves.easeOutCubic,
          child: _buildModernItemCard(item, itemWidth, itemHeight, index),
        );
      },
    );
  }

  Widget _buildShimmerLoading(double itemWidth, double itemHeight) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          width: itemWidth,
          height: itemHeight,
          margin: const EdgeInsets.only(right: 16),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      },
    );
  }

  // Widget _buildModernItemCard(CategoryModel item, double width, double height, int index) {
  //   return Consumer<MyPlanProvider>(
  //     builder: (context, myPlanProvider, child) {
  //       bool isPlanSelected = myPlanProvider.subscribedPlan?.isSelected ?? false;
  //       bool isPremium = !myPlanProvider.isPurchase;

  //       return Container(
  //         width: width,
  //         margin: const EdgeInsets.only(right: 16),
  //         child: Material(
  //           color: Colors.transparent,
  //           child: InkWell(
  //             borderRadius: BorderRadius.circular(20),
  //             onTap: () {
  //               if (myPlanProvider.isPurchase == true) {
  //                 Navigator.push(
  //                   context,
  //                   MaterialPageRoute(
  //                     builder: (context) => SamplePosterScreen(posterId: item.id),
  //                   ),
  //                 );
  //               } else {
  //                 String message = !myPlanProvider.isPurchase
  //                     ? "This feature requires a premium subscription. Upgrade now to unlock all premium templates and features!"
  //                     : "Please select a plan to access this feature.";

  //                 CommonModal.showWarning(
  //                   context: context,
  //                   title: "Premium Feature",
  //                   message: message,
  //                   primaryButtonText: myPlanProvider.isPurchase ? "Select Plan" : "Upgrade Now",
  //                   secondaryButtonText: "Cancel",
  //                   onPrimaryPressed: () => showSubscriptionModal(context),
  //                   onSecondaryPressed: () => Navigator.of(context).pop(),
  //                 );
  //               }
  //             },
  //             child: Container(
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.circular(20),
  //                 color: Colors.white,
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: Colors.black.withOpacity(0.08),
  //                     blurRadius: 12,
  //                     offset: const Offset(0, 4),
  //                   ),
  //                 ],
  //               ),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   // Image Container
  //                   Expanded(
  //                     child: Stack(
  //                       children: [
  //                         ClipRRect(
  //                           borderRadius: const BorderRadius.vertical(
  //                             top: Radius.circular(20),
  //                           ),
  //                           child: item.images != null && item.images.isNotEmpty
  //                               ? Image.network(
  //                                   item.images[0],
  //                                   height: height,
  //                                   width: width,
  //                                   fit: BoxFit.cover,
  //                                   errorBuilder: (context, error, stackTrace) {
  //                                     return Container(
  //                                       height: height,
  //                                       width: width,
  //                                       decoration: BoxDecoration(
  //                                         gradient: LinearGradient(
  //                                           begin: Alignment.topLeft,
  //                                           end: Alignment.bottomRight,
  //                                           colors: [
  //                                             Colors.grey.shade200,
  //                                             Colors.grey.shade300,
  //                                           ],
  //                                         ),
  //                                       ),
  //                                       child: Column(
  //                                         mainAxisAlignment: MainAxisAlignment.center,
  //                                         children: [
  //                                           Icon(
  //                                             Icons.image_not_supported_outlined,
  //                                             color: Colors.grey.shade500,
  //                                             size: 32,
  //                                           ),
  //                                           const SizedBox(height: 8),
  //                                           Text(
  //                                             'Image not available',
  //                                             style: TextStyle(
  //                                               color: Colors.grey.shade600,
  //                                               fontSize: 12,
  //                                             ),
  //                                           ),
  //                                         ],
  //                                       ),
  //                                     );
  //                                   },
  //                                   loadingBuilder: (context, child, loadingProgress) {
  //                                     if (loadingProgress == null) return child;
  //                                     return Container(
  //                                       height: height,
  //                                       width: width,
  //                                       decoration: BoxDecoration(
  //                                         color: Colors.grey.shade100,
  //                                       ),
  //                                       child: Center(
  //                                         child: SizedBox(
  //                                           width: 24,
  //                                           height: 24,
  //                                           child: CircularProgressIndicator(
  //                                             strokeWidth: 2,
  //                                             valueColor: AlwaysStoppedAnimation<Color>(
  //                                               Colors.purple.shade400,
  //                                             ),
  //                                             value: loadingProgress.expectedTotalBytes != null
  //                                                 ? loadingProgress.cumulativeBytesLoaded /
  //                                                     loadingProgress.expectedTotalBytes!
  //                                                 : null,
  //                                           ),
  //                                         ),
  //                                       ),
  //                                     );
  //                                   },
  //                                 )
  //                               : Container(
  //                                   height: height,
  //                                   width: width,
  //                                   decoration: BoxDecoration(
  //                                     gradient: LinearGradient(
  //                                       begin: Alignment.topLeft,
  //                                       end: Alignment.bottomRight,
  //                                       colors: [
  //                                         Colors.purple.shade100,
  //                                         Colors.blue.shade100,
  //                                       ],
  //                                     ),
  //                                   ),
  //                                   child: Column(
  //                                     mainAxisAlignment: MainAxisAlignment.center,
  //                                     children: [
  //                                       Icon(
  //                                         Icons.image_outlined,
  //                                         color: Colors.grey.shade600,
  //                                         size: 32,
  //                                       ),
  //                                       const SizedBox(height: 8),
  //                                       Text(
  //                                         'No Preview',
  //                                         style: TextStyle(
  //                                           color: Colors.grey.shade700,
  //                                           fontSize: 12,
  //                                           fontWeight: FontWeight.w500,
  //                                         ),
  //                                       ),
  //                                     ],
  //                                   ),
  //                                 ),
  //                         ),

  //                         // Premium Badge
  //                         // if (isPremium)
  //                         //   Positioned(
  //                         //     top: 8,
  //                         //     right: 8,
  //                         //     child: Container(
  //                         //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //                         //       decoration: BoxDecoration(
  //                         //         gradient: LinearGradient(
  //                         //           colors: [Colors.orange.shade400, Colors.orange.shade600],
  //                         //         ),
  //                         //         borderRadius: BorderRadius.circular(12),
  //                         //         boxShadow: [
  //                         //           BoxShadow(
  //                         //             color: Colors.orange.withOpacity(0.4),
  //                         //             blurRadius: 4,
  //                         //             offset: const Offset(0, 2),
  //                         //           ),
  //                         //         ],
  //                         //       ),
  //                         //       child: const Row(
  //                         //         mainAxisSize: MainAxisSize.min,
  //                         //         children: [
  //                         //           Icon(
  //                         //             Icons.workspace_premium,
  //                         //             color: Colors.white,
  //                         //             size: 12,
  //                         //           ),
  //                         //           SizedBox(width: 2),
  //                         //           Text(
  //                         //             'PRO',
  //                         //             style: TextStyle(
  //                         //               color: Colors.white,
  //                         //               fontSize: 10,
  //                         //               fontWeight: FontWeight.w700,
  //                         //             ),
  //                         //           ),
  //                         //         ],
  //                         //       ),
  //                         //     ),
  //                         //   ),

  //                         // Selection Indicator
  //                         if (isPlanSelected)
  //                           Positioned(
  //                             top: 8,
  //                             left: 8,
  //                             child: Container(
  //                               padding: const EdgeInsets.all(4),
  //                               decoration: BoxDecoration(
  //                                 color: Colors.green.shade500,
  //                                 shape: BoxShape.circle,
  //                                 boxShadow: [
  //                                   BoxShadow(
  //                                     color: Colors.green.withOpacity(0.4),
  //                                     blurRadius: 4,
  //                                     offset: const Offset(0, 2),
  //                                   ),
  //                                 ],
  //                               ),
  //                               child: const Icon(
  //                                 Icons.check,
  //                                 color: Colors.white,
  //                                 size: 12,
  //                               ),
  //                             ),
  //                           ),

  //                         // Hover Effect Overlay
  //                         Positioned.fill(
  //                           child: Container(
  //                             decoration: BoxDecoration(
  //                               borderRadius: const BorderRadius.vertical(
  //                                 top: Radius.circular(20),
  //                               ),
  //                               color: Colors.black.withOpacity(0.02),
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),

  //                   // Card Footer
  //                   Container(
  //                     padding: const EdgeInsets.all(12),
  //                     child: Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                       children: [
  //                         Expanded(
  //                           child: Text(
  //                             item.categoryName,
  //                             style: const TextStyle(
  //                               fontSize: 13,
  //                               fontWeight: FontWeight.w600,
  //                               color: Colors.black87,
  //                             ),
  //                             maxLines: 1,
  //                             overflow: TextOverflow.ellipsis,
  //                           ),
  //                         ),
  //                         Container(
  //                           padding: const EdgeInsets.all(4),
  //                           decoration: BoxDecoration(
  //                             color: Colors.grey.shade100,
  //                             borderRadius: BorderRadius.circular(6),
  //                           ),
  //                           child: Icon(
  //                             Icons.arrow_forward_ios,
  //                             size: 10,
  //                             color: Colors.grey.shade600,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }







Widget _buildModernItemCard(CategoryModel item, double width, double height, int index) {
  return Consumer<MyPlanProvider>(
    builder: (context, myPlanProvider, child) {
      // Fixed the logic here
      bool hasPlan = myPlanProvider.isPurchase == true;
      
      return Container(
        width: width,
        margin: const EdgeInsets.only(right: 16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              // Simplified and fixed the condition
              if (hasPlan) {
                // User has purchased plan - navigate directly
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SamplePosterScreen(posterId: item.id),
                  ),
                );
              } else {
                // User doesn't have plan - show subscription modal
                CommonModal.showWarning(
                  context: context,
                  title: "Premium Feature",
                  message: "This feature requires a premium subscription. Upgrade now to unlock all premium templates and features!",
                  primaryButtonText: "Upgrade Now",
                  secondaryButtonText: "Cancel",
                  onPrimaryPressed: () {
                    Navigator.of(context).pop(); // Close the warning modal first
                    showSubscriptionModal(context);
                  },
                  onSecondaryPressed: () => Navigator.of(context).pop(),
                );
              }
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Container
                  Expanded(
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          child: item.images != null && item.images.isNotEmpty
                              ? Image.network(
                                  item.images[0],
                                  height: height,
                                  width: width,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: height,
                                      width: width,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.grey.shade200,
                                            Colors.grey.shade300,
                                          ],
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.image_not_supported_outlined,
                                            color: Colors.grey.shade500,
                                            size: 32,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Image not available',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      height: height,
                                      width: width,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                      ),
                                      child: Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              Colors.purple.shade400,
                                            ),
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded /
                                                    loadingProgress.expectedTotalBytes!
                                                : null,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  height: height,
                                  width: width,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.purple.shade100,
                                        Colors.blue.shade100,
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_outlined,
                                        color: Colors.grey.shade600,
                                        size: 32,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'No Preview',
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),

                        // Show premium badge only if user doesn't have plan
                        if (!hasPlan)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.orange.shade400, Colors.orange.shade600],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.withOpacity(0.4),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.workspace_premium,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    'PRO',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Show checkmark if user has purchased plan
                        // if (hasPlan)
                        //   Positioned(
                        //     top: 8,
                        //     right: 8,
                        //     child: Container(
                        //       padding: const EdgeInsets.all(4),
                        //       decoration: BoxDecoration(
                        //         color: Colors.green.shade500,
                        //         shape: BoxShape.circle,
                        //         boxShadow: [
                        //           BoxShadow(
                        //             color: Colors.green.withOpacity(0.4),
                        //             blurRadius: 4,
                        //             offset: const Offset(0, 2),
                        //           ),
                        //         ],
                        //       ),
                        //       child: const Icon(
                        //         Icons.check,
                        //         color: Colors.white,
                        //         size: 12,
                        //       ),
                        //     ),
                        //   ),
                      ],
                    ),
                  ),

                  // Card Footer
                  Container(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.categoryName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}



  Widget _buildLanguageOption({
    required BuildContext context,
    required String languageCode,
    required String languageName,
    required LanguageProvider languageProvider,
  }) {
    final isSelected = languageProvider.locale.languageCode == languageCode;

    return ListTile(
      leading: Icon(
        Icons.language,
        color: isSelected ? Colors.blue : Colors.grey,
      ),
      title: Text(
        languageName,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.blue : Colors.black,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
      onTap: () async {
        try {
          await languageProvider.setLocale(Locale(languageCode));
          if (context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  LocalizationService.translate('language_switched', languageCode),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          print('Error changing language: $e');
          if (context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to change language'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      },
    );
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }
}